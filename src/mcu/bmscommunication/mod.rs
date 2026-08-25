use crate::drv::{
    cortex::{with_interrupts_masked, Shared},
    iomuxc::{
        Iomuxc, IOMUXC_DAISY, IOMUXC_DRIVE_STRENGTH, IOMUXC_MUX_MODE, IOMUXC_PULL,
        IOMUXC_SLEW_RATE, IOMUXC_SPEED, SW_MUX_CTL_PAD, SW_PAD_CTL_PAD,
    },
    lpuart::{uart6, Lpuart, LPUART_BYTE_READ_RESULT, LPUART_ERROR_FLAGS, LPUART_INSTANCE},
    nvic, BIT,
};

use super::{clocktree, McuManager, UartByteReadResult, NVIC, USART_ERROR_FLAGS};

const BMS_UART_BAUD_RATE: u32 = 9_600;
const BMS_UART_INTERRUPT_PRIORITY: u8 = 0xC0;

// SoM pad 29 is GPIO_AD_B0_02 / LPUART6_TX. SoM pad 28 is
// GPIO_AD_B0_03 / LPUART6_RX. IOMUXC indexes count from GPIO_EMC_00.
const BMS_UART_TX_PAD: u8 = 44;
const BMS_UART_RX_PAD: u8 = 45;
const LPUART6_RX_SELECT_INPUT: u8 = 87;
const LPUART6_TX_SELECT_INPUT: u8 = 88;

// A maximum JDB response is 43 bytes including framing. The interrupt-backed
// queue lets the 10 ms protocol task drain complete bursts without relying on
// the RT1061's four-entry hardware FIFO.
const RX_QUEUE_CAPACITY: usize = 64;
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

static BMS_LPUART6: Shared<Lpuart> = Shared::new(Lpuart::new(LPUART_INSTANCE::LPUART6));
static IOMUXC: Shared<Iomuxc> = Shared::new(Iomuxc::new());
static BMS_UART_STATE: Shared<BmsUartState> = Shared::new(BmsUartState::new());

struct BmsUartState {
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

impl BmsUartState {
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
            // None of the queued bytes can be trusted to belong to a complete
            // frame after data was dropped. Present one synthetic overrun and
            // restart from bytes received after the protocol task observes it.
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
    pub fn BmsCommunication_Init() {
        clocktree::EnableLpuart6AndIomuxcClocks();
        BMS_UART_STATE.with(BmsUartState::Reset);

        let configured = BMS_LPUART6
            .with(|uart| uart.Configure8N1(clocktree::LPUART_CLOCK_HZ, BMS_UART_BAUD_RATE));
        assert!(configured);

        IOMUXC.with(|iomuxc| {
            iomuxc.Write_SW_PAD_CTL_PAD(
                BMS_UART_TX_PAD,
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
                BMS_UART_RX_PAD,
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

            iomuxc.Write_SELECT_INPUT(LPUART6_RX_SELECT_INPUT, IOMUXC_DAISY::DAISY_1);
            iomuxc.Write_SELECT_INPUT(LPUART6_TX_SELECT_INPUT, IOMUXC_DAISY::DAISY_1);

            // The UART is configured and drives an idle-high TX before either
            // pad is switched away from its reset GPIO function.
            iomuxc.Write_SW_MUX_CTL_PAD(
                BMS_UART_RX_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT2,
                    SION: BIT::VALUE_0,
                },
            );
            iomuxc.Write_SW_MUX_CTL_PAD(
                BMS_UART_TX_PAD,
                SW_MUX_CTL_PAD {
                    MUX_MODE: IOMUXC_MUX_MODE::ALT2,
                    SION: BIT::VALUE_0,
                },
            );
        });

        NVIC.with(|nvic| {
            nvic.DisableInterrupt(uart6::INTERRUPT_NUMBER);
            nvic.ClearPendingInterrupt(uart6::INTERRUPT_NUMBER);
            nvic.SetPriority(uart6::INTERRUPT_NUMBER, BMS_UART_INTERRUPT_PRIORITY);
            nvic.BindInterruptHandler(uart6::INTERRUPT_NUMBER, BmsCommunication_InterruptHandler);
        });
        BMS_LPUART6.with(|uart| uart.Set_CTRL_RIE(true));
        NVIC.with(|nvic| nvic.EnableInterrupt(uart6::INTERRUPT_NUMBER));
    }

    pub fn BmsCommunication_TryWriteByte(byte: u8) -> bool {
        with_interrupts_masked(|| {
            let accepted = BMS_UART_STATE.with(|state| state.PushTransmit(byte));
            if accepted {
                BMS_LPUART6.with(|uart| {
                    uart.Set_CTRL_TIE(true);
                    Self::BmsCommunication_ServiceTransmit(uart);
                });
            }
            accepted
        })
    }

    pub fn BmsCommunication_TryReadByteWithErrors() -> UartByteReadResult {
        BMS_UART_STATE.with(BmsUartState::PopReceive)
    }

    fn BmsCommunication_ServiceReceive(uart: &Lpuart) {
        loop {
            let result = uart.TryReadByteWithErrors();
            if result.Byte.is_none() && !result.Errors.Any() {
                break;
            }

            BMS_UART_STATE.with(|state| state.PushReceive(Self::MapReadResult(result)));
        }
    }

    fn BmsCommunication_ServiceTransmit(uart: &Lpuart) {
        loop {
            let byte = BMS_UART_STATE.with(|state| state.PeekTransmit());
            let Some(byte) = byte else {
                uart.Set_CTRL_TIE(false);
                break;
            };

            if !uart.TryWriteByte(byte) {
                break;
            }

            BMS_UART_STATE.with(BmsUartState::PopTransmit);
        }
    }

    #[inline]
    fn MapReadResult(result: LPUART_BYTE_READ_RESULT) -> UartByteReadResult {
        UartByteReadResult {
            Byte: result.Byte,
            Errors: Self::MapErrorFlags(result.Errors),
        }
    }

    #[inline]
    fn MapErrorFlags(errors: LPUART_ERROR_FLAGS) -> USART_ERROR_FLAGS {
        USART_ERROR_FLAGS {
            parityError: errors.parityError,
            framingError: errors.framingError,
            noiseDetected: errors.noiseDetected,
            overrunError: errors.overrunError,
        }
    }
}

unsafe extern "C" fn BmsCommunication_InterruptHandler() {
    BMS_LPUART6.with(|uart| {
        McuManager::BmsCommunication_ServiceReceive(uart);
        McuManager::BmsCommunication_ServiceTransmit(uart);
    });
    nvic::ExitBarrier();
}
