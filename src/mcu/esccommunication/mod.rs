use crate::drv::{
    cortex::{with_interrupts_masked, Shared},
    gpio::{Gpio, GPIO_INSTANCE, GPIO_PIN_STATE},
    iomuxc::{
        Iomuxc, IOMUXC_DAISY, IOMUXC_DRIVE_STRENGTH, IOMUXC_GPIO_MUX, IOMUXC_MUX_MODE, IOMUXC_PULL,
        IOMUXC_SLEW_RATE, IOMUXC_SPEED, SW_MUX_CTL_PAD, SW_PAD_CTL_PAD,
    },
    lpuart::{Lpuart, LPUART_BYTE_READ_RESULT, LPUART_ERROR_FLAGS, LPUART_INSTANCE},
    nvic, BIT,
};

use super::{clocktree, McuManager, UartByteReadResult, NVIC, USART_ERROR_FLAGS};

const ESC_UART_BAUD_RATE: u32 = 1_000_000;
const ESC_UART_INTERRUPT_PRIORITY: u8 = 0xC0;
const ESC_UART_INSTANCE: LPUART_INSTANCE = LPUART_INSTANCE::LPUART3;
const ESC_UART_INTERRUPT_NUMBER: u16 = ESC_UART_INSTANCE.InterruptNumber();

// SoM pad 7 is GPIO_AD_B1_06 / LPUART3_TX. SoM pad 6 is
// GPIO_AD_B1_07 / LPUART3_RX. IOMUXC indexes count from GPIO_EMC_00.
const ESC_UART_TX_PAD: u8 = 64;
const ESC_UART_RX_PAD: u8 = 65;
const LPUART3_RX_SELECT_INPUT: u8 = 81;
const LPUART3_TX_SELECT_INPUT: u8 = 82;

// SoM pad 99 is GPIO_AD_B1_05 / GPIO1_IO21. The fitted level shifter uses an
// active-high input: high powers the ESC, low requests power-off.
const ESC_POWER_ON_PAD: u8 = 63;
const ESC_POWER_ON_PIN: u8 = 21;

// Selective VESC replies fit well below this bound. The additional headroom
// lets the parser retain an entire firmware response while remaining static.
const RX_QUEUE_CAPACITY: usize = 128;
// One 1 ms transmission contains the ten-byte current frame and at most one
// ten-byte request. Keeping only one batch prevents stale commands queueing.
const TX_QUEUE_CAPACITY: usize = 32;

const EMPTY_READ_RESULT: UartByteReadResult = UartByteReadResult {
    Byte: None,
    Errors: USART_ERROR_FLAGS {
        parityError: false,
        framingError: false,
        noiseDetected: false,
        overrunError: false,
    },
};

static ESC_LPUART3: Shared<Lpuart> = Shared::new(Lpuart::new(ESC_UART_INSTANCE));
static GPIO1: Shared<Gpio> = Shared::new(Gpio::new(GPIO_INSTANCE::GPIO1));
static IOMUXC: Shared<Iomuxc> = Shared::new(Iomuxc::new());
static ESC_UART_STATE: Shared<EscUartState> = Shared::new(EscUartState::new());

struct EscUartState {
    receiveQueue: [UartByteReadResult; RX_QUEUE_CAPACITY],
    receiveReadIndex: usize,
    receiveWriteIndex: usize,
    receiveCount: usize,
    receiveOverflowed: bool,
    transmitQueue: [u8; TX_QUEUE_CAPACITY],
    transmitReadIndex: usize,
    transmitWriteIndex: usize,
    transmitCount: usize,
}

impl EscUartState {
    const fn new() -> Self {
        Self {
            receiveQueue: [EMPTY_READ_RESULT; RX_QUEUE_CAPACITY],
            receiveReadIndex: 0,
            receiveWriteIndex: 0,
            receiveCount: 0,
            receiveOverflowed: false,
            transmitQueue: [0; TX_QUEUE_CAPACITY],
            transmitReadIndex: 0,
            transmitWriteIndex: 0,
            transmitCount: 0,
        }
    }

    fn Reset(&mut self) {
        *self = Self::new();
    }

    fn PushReceive(&mut self, result: UartByteReadResult) {
        if self.receiveOverflowed || self.receiveCount == RX_QUEUE_CAPACITY {
            self.receiveOverflowed = true;
            return;
        }

        self.receiveQueue[self.receiveWriteIndex] = result;
        self.receiveWriteIndex = (self.receiveWriteIndex + 1) % RX_QUEUE_CAPACITY;
        self.receiveCount += 1;
    }

    fn PopReceive(&mut self) -> UartByteReadResult {
        if self.receiveOverflowed {
            // A dropped byte invalidates every queued frame boundary. Report
            // one synthetic overrun and resume only with subsequently received
            // bytes after the protocol task has observed it.
            self.receiveOverflowed = false;
            self.receiveReadIndex = self.receiveWriteIndex;
            self.receiveCount = 0;
            return UartByteReadResult {
                Byte: None,
                Errors: USART_ERROR_FLAGS {
                    parityError: false,
                    framingError: false,
                    noiseDetected: false,
                    overrunError: true,
                },
            };
        }

        if self.receiveCount == 0 {
            return EMPTY_READ_RESULT;
        }

        let result = self.receiveQueue[self.receiveReadIndex];
        self.receiveReadIndex = (self.receiveReadIndex + 1) % RX_QUEUE_CAPACITY;
        self.receiveCount -= 1;
        result
    }

    fn QueueTransmitBatch(&mut self, bytes: &[u8]) -> bool {
        if bytes.is_empty() || bytes.len() > TX_QUEUE_CAPACITY || self.transmitCount != 0 {
            return false;
        }

        for &byte in bytes {
            self.transmitQueue[self.transmitWriteIndex] = byte;
            self.transmitWriteIndex = (self.transmitWriteIndex + 1) % TX_QUEUE_CAPACITY;
            self.transmitCount += 1;
        }
        true
    }

    fn PeekTransmit(&self) -> Option<u8> {
        if self.transmitCount == 0 {
            None
        } else {
            Some(self.transmitQueue[self.transmitReadIndex])
        }
    }

    fn PopTransmit(&mut self) {
        debug_assert!(self.transmitCount > 0);
        self.transmitReadIndex = (self.transmitReadIndex + 1) % TX_QUEUE_CAPACITY;
        self.transmitCount -= 1;
    }
}

impl McuManager {
    pub fn EscCommunication_Init() {
        clocktree::EnableLpuart3Gpio1AndIomuxcClocks();
        ESC_UART_STATE.with(EscUartState::Reset);

        // Retain the board's powered-on hardware default without a low glitch.
        // The GPIO latch is loaded before the output driver or pad mux changes.
        GPIO1.with(|gpio| {
            gpio.ConfigureOutput(ESC_POWER_ON_PIN, GPIO_PIN_STATE::HIGH);
        });
        IOMUXC.with(|iomuxc| {
            iomuxc.Set_GPR26_GPIO_MUX(ESC_POWER_ON_PIN, IOMUXC_GPIO_MUX::GPIO1);
            iomuxc.Write_SW_PAD_CTL_PAD(
                ESC_POWER_ON_PAD,
                SW_PAD_CTL_PAD {
                    SRE: IOMUXC_SLEW_RATE::SLOW,
                    DSE: IOMUXC_DRIVE_STRENGTH::R0_DIV_6,
                    SPEED: IOMUXC_SPEED::LOW_50MHZ,
                    ODE: BIT::VALUE_0,
                    PKE: BIT::VALUE_0,
                    PUE: BIT::VALUE_0,
                    PUS: IOMUXC_PULL::DOWN_100K,
                    HYS: BIT::VALUE_0,
                },
            );
            iomuxc.Write_SW_MUX_CTL_PAD(
                ESC_POWER_ON_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT5,
                    SION: BIT::VALUE_0,
                },
            );
        });

        let configured = ESC_LPUART3
            .with(|uart| uart.Configure8N1(clocktree::LPUART_CLOCK_HZ, ESC_UART_BAUD_RATE));
        assert!(configured);

        IOMUXC.with(|iomuxc| {
            iomuxc.Write_SW_PAD_CTL_PAD(
                ESC_UART_TX_PAD,
                SW_PAD_CTL_PAD {
                    SRE: IOMUXC_SLEW_RATE::FAST,
                    DSE: IOMUXC_DRIVE_STRENGTH::R0_DIV_6,
                    SPEED: IOMUXC_SPEED::LOW_50MHZ,
                    ODE: BIT::VALUE_0,
                    PKE: BIT::VALUE_0,
                    PUE: BIT::VALUE_0,
                    PUS: IOMUXC_PULL::DOWN_100K,
                    HYS: BIT::VALUE_0,
                },
            );
            iomuxc.Write_SW_PAD_CTL_PAD(
                ESC_UART_RX_PAD,
                SW_PAD_CTL_PAD {
                    SRE: IOMUXC_SLEW_RATE::FAST,
                    DSE: IOMUXC_DRIVE_STRENGTH::R0_DIV_6,
                    SPEED: IOMUXC_SPEED::LOW_50MHZ,
                    ODE: BIT::VALUE_0,
                    PKE: BIT::VALUE_1,
                    PUE: BIT::VALUE_1,
                    PUS: IOMUXC_PULL::UP_100K,
                    HYS: BIT::VALUE_1,
                },
            );

            iomuxc.Write_SELECT_INPUT(LPUART3_RX_SELECT_INPUT, IOMUXC_DAISY::DAISY_0);
            iomuxc.Write_SELECT_INPUT(LPUART3_TX_SELECT_INPUT, IOMUXC_DAISY::DAISY_0);

            // Configure the UART first so TX already drives its idle-high level
            // when either signal leaves the reset GPIO function.
            iomuxc.Write_SW_MUX_CTL_PAD(
                ESC_UART_RX_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT2,
                    SION: BIT::VALUE_0,
                },
            );
            iomuxc.Write_SW_MUX_CTL_PAD(
                ESC_UART_TX_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT2,
                    SION: BIT::VALUE_0,
                },
            );
        });

        NVIC.with(|nvic| {
            nvic.DisableInterrupt(ESC_UART_INTERRUPT_NUMBER);
            nvic.ClearPendingInterrupt(ESC_UART_INTERRUPT_NUMBER);
            nvic.SetPriority(ESC_UART_INTERRUPT_NUMBER, ESC_UART_INTERRUPT_PRIORITY);
            nvic.BindInterruptHandler(ESC_UART_INTERRUPT_NUMBER, EscCommunication_InterruptHandler);
        });
        ESC_LPUART3.with(|uart| uart.Set_CTRL_RIE(true));
        NVIC.with(|nvic| nvic.EnableInterrupt(ESC_UART_INTERRUPT_NUMBER));
    }

    /// Queues one complete 1 ms protocol batch, or rejects all of it. A batch
    /// is accepted only after the previous final stop bit reached the wire.
    pub(crate) fn EscCommunication_TryWriteFrame(frame: &[u8]) -> bool {
        with_interrupts_masked(|| {
            let hardwareIdle = ESC_LPUART3.with(|uart| uart.IsTransmitComplete());
            if !hardwareIdle {
                return false;
            }

            let accepted = ESC_UART_STATE.with(|state| state.QueueTransmitBatch(frame));
            if accepted {
                ESC_LPUART3.with(|uart| {
                    uart.Set_CTRL_TIE(true);
                    Self::EscCommunication_ServiceTransmit(uart);
                });
            }
            accepted
        })
    }

    pub(crate) fn EscCommunication_TryReadByteWithErrors() -> UartByteReadResult {
        ESC_UART_STATE.with(EscUartState::PopReceive)
    }

    /// Aborts any in-flight session and returns LPUART3 plus both software
    /// queues to the same empty 8N1 state used at startup. This is called on
    /// each ESC power edge so commands and replies cannot cross sessions.
    pub(crate) fn EscCommunication_ResetTransport() {
        with_interrupts_masked(|| {
            NVIC.with(|nvic| nvic.DisableInterrupt(ESC_UART_INTERRUPT_NUMBER));
            ESC_UART_STATE.with(EscUartState::Reset);

            let configured = ESC_LPUART3
                .with(|uart| uart.Configure8N1(clocktree::LPUART_CLOCK_HZ, ESC_UART_BAUD_RATE));
            assert!(configured);

            NVIC.with(|nvic| {
                nvic.ClearPendingInterrupt(ESC_UART_INTERRUPT_NUMBER);
                nvic.SetPriority(ESC_UART_INTERRUPT_NUMBER, ESC_UART_INTERRUPT_PRIORITY);
                nvic.BindInterruptHandler(
                    ESC_UART_INTERRUPT_NUMBER,
                    EscCommunication_InterruptHandler,
                );
            });
            ESC_LPUART3.with(|uart| uart.Set_CTRL_RIE(true));
            NVIC.with(|nvic| nvic.EnableInterrupt(ESC_UART_INTERRUPT_NUMBER));
        });
    }

    pub(crate) fn EscCommunication_SetPowerOn(powerOn: bool) {
        let state = if powerOn {
            GPIO_PIN_STATE::HIGH
        } else {
            GPIO_PIN_STATE::LOW
        };
        GPIO1.with(|gpio| gpio.WritePin(ESC_POWER_ON_PIN, state));
    }

    fn EscCommunication_ServiceReceive(uart: &Lpuart) {
        loop {
            let result = uart.TryReadByteWithErrors();
            if result.Byte.is_none() && !result.Errors.Any() {
                break;
            }

            ESC_UART_STATE
                .with(|state| state.PushReceive(Self::EscCommunication_MapReadResult(result)));
        }
    }

    fn EscCommunication_ServiceTransmit(uart: &Lpuart) {
        loop {
            let byte = ESC_UART_STATE.with(|state| state.PeekTransmit());
            let Some(byte) = byte else {
                uart.Set_CTRL_TIE(false);
                break;
            };

            if !uart.TryWriteByte(byte) {
                break;
            }

            ESC_UART_STATE.with(EscUartState::PopTransmit);
        }
    }

    #[inline]
    fn EscCommunication_MapReadResult(result: LPUART_BYTE_READ_RESULT) -> UartByteReadResult {
        UartByteReadResult {
            Byte: result.Byte,
            Errors: Self::EscCommunication_MapErrorFlags(result.Errors),
        }
    }

    #[inline]
    fn EscCommunication_MapErrorFlags(errors: LPUART_ERROR_FLAGS) -> USART_ERROR_FLAGS {
        USART_ERROR_FLAGS {
            parityError: errors.parityError,
            framingError: errors.framingError,
            noiseDetected: errors.noiseDetected,
            overrunError: errors.overrunError,
        }
    }
}

unsafe extern "C" fn EscCommunication_InterruptHandler() {
    ESC_LPUART3.with(|uart| {
        McuManager::EscCommunication_ServiceReceive(uart);
        McuManager::EscCommunication_ServiceTransmit(uart);
    });
    nvic::ExitBarrier();
}
