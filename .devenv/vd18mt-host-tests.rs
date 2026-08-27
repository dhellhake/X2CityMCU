#![allow(dead_code)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use std::{cell::RefCell, collections::VecDeque};

mod drv {
    pub mod cortex {
        use std::cell::UnsafeCell;

        pub struct Shared<T> {
            value: UnsafeCell<T>,
        }

        impl<T> Shared<T> {
            pub const fn new(value: T) -> Self {
                Self {
                    value: UnsafeCell::new(value),
                }
            }

            pub fn with<R>(&self, operation: impl FnOnce(&mut T) -> R) -> R {
                operation(unsafe { &mut *self.value.get() })
            }
        }

        unsafe impl<T> Sync for Shared<T> {}
    }
}

mod mcu {
    use super::{RefCell, VecDeque};

    #[repr(C, align(4))]
    #[derive(Copy, Clone)]
    pub struct USART_ERROR_FLAGS {
        pub parityError: bool,
        pub framingError: bool,
        pub noiseDetected: bool,
        pub overrunError: bool,
    }

    impl USART_ERROR_FLAGS {
        pub const fn Any(self) -> bool {
            self.parityError || self.framingError || self.noiseDetected || self.overrunError
        }
    }

    #[repr(C)]
    #[derive(Copy, Clone)]
    pub struct UartByteReadResult {
        pub Byte: Option<u8>,
        pub Errors: USART_ERROR_FLAGS,
    }

    impl UartByteReadResult {
        pub const fn HasError(self) -> bool {
            self.Errors.Any()
        }
    }

    pub struct McuManager;

    thread_local! {
        static RECEIVE: RefCell<VecDeque<UartByteReadResult>> = RefCell::new(VecDeque::new());
        static TRANSMIT: RefCell<Vec<u8>> = const { RefCell::new(Vec::new()) };
    }

    impl McuManager {
        pub fn VD18MTCommunication_TryWriteByte(byte: u8) -> bool {
            TRANSMIT.with(|transmit| transmit.borrow_mut().push(byte));
            true
        }

        pub fn VD18MTCommunication_TryReadByteWithErrors() -> UartByteReadResult {
            RECEIVE.with(|receive| {
                receive
                    .borrow_mut()
                    .pop_front()
                    .unwrap_or(UartByteReadResult {
                        Byte: None,
                        Errors: no_errors(),
                    })
            })
        }
    }

    pub const fn no_errors() -> USART_ERROR_FLAGS {
        USART_ERROR_FLAGS {
            parityError: false,
            framingError: false,
            noiseDetected: false,
            overrunError: false,
        }
    }

    pub fn reset_uart() {
        RECEIVE.with(|receive| receive.borrow_mut().clear());
        TRANSMIT.with(|transmit| transmit.borrow_mut().clear());
    }

    pub fn enqueue_receive(result: UartByteReadResult) {
        RECEIVE.with(|receive| receive.borrow_mut().push_back(result));
    }

    pub fn take_transmit() -> Vec<u8> {
        TRANSMIT.with(|transmit| transmit.borrow_mut().drain(..).collect())
    }
}

#[path = "../src/vd18mt/mod.rs"]
mod vd18mt;

use mcu::{enqueue_receive, no_errors, reset_uart, take_transmit, UartByteReadResult};
use vd18mt::{
    VD18MTAssistLevel, VD18MTInterface, VT8MTBatteryCurrent, VT8MTBatteryIndication,
    VT8MTControllerStatusFlags, VT8MTData, VT8MTErrorCode, VT8MT_STATIONARY_WHEEL_PULSE_PERIOD,
};

fn request_frame(flags: u8, wheel_diameter_inches: u8, speed_limit_kmh: u8) -> [u8; 7] {
    let mut frame = [0x59, flags, 0, wheel_diameter_inches, 0, speed_limit_kmh, 0];
    frame[6] = frame[..6]
        .iter()
        .fold(0u8, |sum, byte| sum.wrapping_add(*byte));
    frame
}

#[test]
fn accepts_and_decodes_a_valid_display_request() {
    reset_uart();
    let mut interface = VD18MTInterface::new();
    let frame = request_frame(0x41, 26, 25);

    for byte in frame {
        interface.VD18MTInterface_ReceiveByte(byte, 12_000);
    }

    assert_eq!(interface.ReceivedFrameCount, 1);
    assert_eq!(interface.InvalidFrameCount, 0);
    assert_eq!(interface.LatestData.AssistLevel, VD18MTAssistLevel::Level2);
    assert!(interface.LatestData.HeadlightRequested);
    assert_eq!(interface.LatestData.WheelDiameterInches, 26);
    assert_eq!(interface.LatestData.SpeedLimitKmh, 25);
    assert_eq!(interface.LatestFrame.bytes, frame);
    assert_eq!(interface.LatestFrame.timestamp_us, 12_000);
    assert!(interface.VD18MTInterface_TakeLatestFrame().is_some());
    assert!(interface.VD18MTInterface_TakeLatestFrame().is_none());
}

#[test]
fn rejects_bad_checksum_and_resynchronizes_at_an_embedded_start() {
    reset_uart();
    let mut interface = VD18MTInterface::new();
    let valid = request_frame(0x10, 28, 20);
    let invalid_with_next_start = [0x59, 0x10, 0, 28, 0, 20, 0x59];

    for byte in invalid_with_next_start {
        interface.VD18MTInterface_ReceiveByte(byte, 1_000);
    }
    for byte in &valid[1..] {
        interface.VD18MTInterface_ReceiveByte(*byte, 2_000);
    }

    assert_eq!(interface.ChecksumErrorCount, 1);
    assert_eq!(interface.ReceiveResynchronizationCount, 1);
    assert_eq!(interface.ReceivedFrameCount, 1);
    assert_eq!(interface.LatestFrame.bytes, valid);
}

#[test]
fn uart_error_discards_the_partial_protocol_frame() {
    reset_uart();
    let mut interface = VD18MTInterface::new();
    interface.VD18MTInterface_ReceiveByte(0x59, 1_000);
    enqueue_receive(UartByteReadResult {
        Byte: Some(0x10),
        Errors: mcu::USART_ERROR_FLAGS {
            parityError: false,
            framingError: true,
            noiseDetected: false,
            overrunError: false,
        },
    });

    interface.VD18MTInterface_Step(2_000);
    for byte in request_frame(0x10, 26, 25) {
        enqueue_receive(UartByteReadResult {
            Byte: Some(byte),
            Errors: no_errors(),
        });
    }
    interface.VD18MTInterface_Step(12_000);

    assert_eq!(interface.UartErrorCount, 1);
    assert_eq!(interface.UartFramingErrorCount, 1);
    assert_eq!(interface.RejectedByteCount, 1);
    assert_eq!(interface.ReceivedFrameCount, 1);
}

#[test]
fn expires_a_partial_frame_after_twenty_milliseconds() {
    reset_uart();
    let mut interface = VD18MTInterface::new();
    interface.VD18MTInterface_ReceiveByte(0x59, 100);

    interface.VD18MTInterface_Step(20_101);

    assert_eq!(interface.PartialFrameTimeoutCount, 1);
    assert_eq!(interface.InvalidFrameCount, 1);
}

#[test]
fn transmits_the_safe_default_frame_every_one_hundred_milliseconds() {
    reset_uart();
    let mut interface = VD18MTInterface::new();

    interface.VD18MTInterface_Step(10_000);
    let first = take_transmit();
    interface.VD18MTInterface_Step(109_999);
    let early = take_transmit();
    interface.VD18MTInterface_Step(110_000);
    let second = take_transmit();

    let period = VT8MT_STATIONARY_WHEEL_PULSE_PERIOD.to_le_bytes();
    let expected = [0x43, 0, 0, 0, 0, 0, period[0], period[1], 0x51];
    assert_eq!(first, expected);
    assert!(early.is_empty());
    assert_eq!(second, expected);
    assert_eq!(interface.TransmittedFrameCount, 2);
}

#[test]
fn encodes_application_data_and_quantizes_current_to_point_two_ampere_units() {
    reset_uart();
    let mut interface = VD18MTInterface::new();
    for byte in request_frame(0x10, 26, 25) {
        interface.VD18MTInterface_ReceiveByte(byte, 1_000);
    }
    interface.VD18MTInterface_SetVT8MTData(VT8MTData {
        BatteryIndication: VT8MTBatteryIndication::FourSixths,
        ControllerStatus: VT8MTControllerStatusFlags::ControllerWorking
            | VT8MTControllerStatusFlags::PedalActivity,
        BatteryCurrentAmperes: VT8MTBatteryCurrent::FromAmperes(12.3),
        ErrorCode: VT8MTErrorCode::NoError,
        SpeedKmh: 25,
    });

    interface.VD18MTInterface_Step(2_000);

    // 26 display wheel units at 25 km/h result in a rounded 150 ms period.
    // 12.3 A rounds to 62 protocol units (12.4 A represented).
    assert_eq!(take_transmit(), [0x43, 0x08, 0x0C, 0, 62, 0, 150, 0, 0x2B]);
    assert!((VT8MTBatteryCurrent::FromAmperes(12.3).Amperes() - 12.4).abs() <= f32::EPSILON);
}
