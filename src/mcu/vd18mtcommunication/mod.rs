use crate::drv::{
    cortex::{with_interrupts_masked, Shared},
    iomuxc::{
        Iomuxc, IOMUXC_DAISY, IOMUXC_DRIVE_STRENGTH, IOMUXC_MUX_MODE, IOMUXC_PULL,
        IOMUXC_SLEW_RATE, IOMUXC_SPEED, SW_MUX_CTL_PAD, SW_PAD_CTL_PAD,
    },
    lpuart::{Lpuart, LPUART_BYTE_READ_RESULT, LPUART_ERROR_FLAGS, LPUART_INSTANCE},
    nvic, BIT,
};

use super::{clocktree, McuManager, UartByteReadResult, NVIC, USART_ERROR_FLAGS};

const VD18MT_UART_BAUD_RATE: u32 = 9_600;
const VD18MT_UART_INTERRUPT_PRIORITY: u8 = 0xC0;
const VD18MT_UART_INSTANCE: LPUART_INSTANCE = LPUART_INSTANCE::LPUART2;
const VD18MT_UART_INTERRUPT_NUMBER: u16 = VD18MT_UART_INSTANCE.InterruptNumber();

// SoM pad 12 is GPIO_AD_B1_02 / LPUART2_TX. SoM pad 13 is
// GPIO_AD_B1_03 / LPUART2_RX. IOMUXC indexes count from GPIO_EMC_00.
const VD18MT_UART_TX_PAD: u8 = 60;
const VD18MT_UART_RX_PAD: u8 = 61;
const LPUART2_RX_SELECT_INPUT: u8 = 78;
const LPUART2_TX_SELECT_INPUT: u8 = 79;

// A display request is seven bytes and arrives in about 7.3 ms at 9600 8N1,
// which is longer than the hardware FIFO can retain until the 10 ms task.
// Interrupt-backed queues keep complete frames independent of task phasing.
const RX_QUEUE_CAPACITY: usize = 32;
const TX_QUEUE_CAPACITY: usize = 16;

const EMPTY_READ_RESULT: UartByteReadResult = UartByteReadResult {
    Byte: None,
    Errors: USART_ERROR_FLAGS {
        parityError: false,
        framingError: false,
        noiseDetected: false,
        overrunError: false,
    },
};

static VD18MT_LPUART2: Shared<Lpuart> = Shared::new(Lpuart::new(VD18MT_UART_INSTANCE));
static IOMUXC: Shared<Iomuxc> = Shared::new(Iomuxc::new());
static VD18MT_UART_STATE: Shared<Vd18mtUartState> = Shared::new(Vd18mtUartState::new());

struct Vd18mtUartState {
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

impl Vd18mtUartState {
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
            // Once a byte has been dropped, no queued frame boundary can be
            // trusted. Report one synthetic overrun and resume with new data.
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

    fn PushTransmit(&mut self, byte: u8) -> bool {
        if self.transmitCount == TX_QUEUE_CAPACITY {
            return false;
        }

        self.transmitQueue[self.transmitWriteIndex] = byte;
        self.transmitWriteIndex = (self.transmitWriteIndex + 1) % TX_QUEUE_CAPACITY;
        self.transmitCount += 1;
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
    pub fn VD18MTCommunication_Init() {
        clocktree::EnableLpuart2AndIomuxcClocks();
        VD18MT_UART_STATE.with(Vd18mtUartState::Reset);

        let configured = VD18MT_LPUART2
            .with(|uart| uart.Configure8N1(clocktree::LPUART_CLOCK_HZ, VD18MT_UART_BAUD_RATE));
        assert!(configured);

        IOMUXC.with(|iomuxc| {
            iomuxc.Write_SW_PAD_CTL_PAD(
                VD18MT_UART_TX_PAD,
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
            iomuxc.Write_SW_PAD_CTL_PAD(
                VD18MT_UART_RX_PAD,
                SW_PAD_CTL_PAD {
                    SRE: IOMUXC_SLEW_RATE::SLOW,
                    DSE: IOMUXC_DRIVE_STRENGTH::R0_DIV_6,
                    SPEED: IOMUXC_SPEED::LOW_50MHZ,
                    ODE: BIT::VALUE_0,
                    PKE: BIT::VALUE_1,
                    PUE: BIT::VALUE_1,
                    PUS: IOMUXC_PULL::UP_100K,
                    HYS: BIT::VALUE_1,
                },
            );

            iomuxc.Write_SELECT_INPUT(LPUART2_RX_SELECT_INPUT, IOMUXC_DAISY::DAISY_1);
            iomuxc.Write_SELECT_INPUT(LPUART2_TX_SELECT_INPUT, IOMUXC_DAISY::DAISY_1);

            // Configure the UART first so TX is already idle-high when these
            // pads leave their reset GPIO functions.
            iomuxc.Write_SW_MUX_CTL_PAD(
                VD18MT_UART_RX_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT2,
                    SION: BIT::VALUE_0,
                },
            );
            iomuxc.Write_SW_MUX_CTL_PAD(
                VD18MT_UART_TX_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT2,
                    SION: BIT::VALUE_0,
                },
            );
        });

        NVIC.with(|nvic| {
            nvic.DisableInterrupt(VD18MT_UART_INTERRUPT_NUMBER);
            nvic.ClearPendingInterrupt(VD18MT_UART_INTERRUPT_NUMBER);
            nvic.SetPriority(VD18MT_UART_INTERRUPT_NUMBER, VD18MT_UART_INTERRUPT_PRIORITY);
            nvic.BindInterruptHandler(
                VD18MT_UART_INTERRUPT_NUMBER,
                VD18MTCommunication_InterruptHandler,
            );
        });
        VD18MT_LPUART2.with(|uart| uart.Set_CTRL_RIE(true));
        NVIC.with(|nvic| nvic.EnableInterrupt(VD18MT_UART_INTERRUPT_NUMBER));
    }

    pub fn VD18MTCommunication_TryWriteByte(byte: u8) -> bool {
        with_interrupts_masked(|| {
            let accepted = VD18MT_UART_STATE.with(|state| state.PushTransmit(byte));
            if accepted {
                VD18MT_LPUART2.with(|uart| {
                    uart.Set_CTRL_TIE(true);
                    Self::VD18MTCommunication_ServiceTransmit(uart);
                });
            }
            accepted
        })
    }

    pub fn VD18MTCommunication_TryReadByteWithErrors() -> UartByteReadResult {
        VD18MT_UART_STATE.with(Vd18mtUartState::PopReceive)
    }

    fn VD18MTCommunication_ServiceReceive(uart: &Lpuart) {
        loop {
            let result = uart.TryReadByteWithErrors();
            if result.Byte.is_none() && !result.Errors.Any() {
                break;
            }

            VD18MT_UART_STATE
                .with(|state| state.PushReceive(Self::VD18MTCommunication_MapReadResult(result)));
        }
    }

    fn VD18MTCommunication_ServiceTransmit(uart: &Lpuart) {
        loop {
            let byte = VD18MT_UART_STATE.with(|state| state.PeekTransmit());
            let Some(byte) = byte else {
                uart.Set_CTRL_TIE(false);
                break;
            };

            if !uart.TryWriteByte(byte) {
                break;
            }

            VD18MT_UART_STATE.with(Vd18mtUartState::PopTransmit);
        }
    }

    #[inline]
    fn VD18MTCommunication_MapReadResult(result: LPUART_BYTE_READ_RESULT) -> UartByteReadResult {
        UartByteReadResult {
            Byte: result.Byte,
            Errors: Self::VD18MTCommunication_MapErrorFlags(result.Errors),
        }
    }

    #[inline]
    fn VD18MTCommunication_MapErrorFlags(errors: LPUART_ERROR_FLAGS) -> USART_ERROR_FLAGS {
        USART_ERROR_FLAGS {
            parityError: errors.parityError,
            framingError: errors.framingError,
            noiseDetected: errors.noiseDetected,
            overrunError: errors.overrunError,
        }
    }
}

unsafe extern "C" fn VD18MTCommunication_InterruptHandler() {
    VD18MT_LPUART2.with(|uart| {
        McuManager::VD18MTCommunication_ServiceReceive(uart);
        McuManager::VD18MTCommunication_ServiceTransmit(uart);
    });
    nvic::ExitBarrier();
}
