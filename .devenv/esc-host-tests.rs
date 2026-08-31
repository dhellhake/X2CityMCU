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
        static TRANSMIT: RefCell<Vec<Vec<u8>>> = const { RefCell::new(Vec::new()) };
        static TRANSMIT_ACCEPTED: RefCell<bool> = const { RefCell::new(true) };
        static POWER_ON: RefCell<bool> = const { RefCell::new(true) };
        static TRANSPORT_RESET_COUNT: RefCell<u32> = const { RefCell::new(0) };
    }

    impl McuManager {
        pub fn EscCommunication_TryWriteFrame(frame: &[u8]) -> bool {
            let accepted = TRANSMIT_ACCEPTED.with(|value| *value.borrow());
            if accepted {
                TRANSMIT.with(|transmit| transmit.borrow_mut().push(frame.to_vec()));
            }
            accepted
        }

        pub fn EscCommunication_TryReadByteWithErrors() -> UartByteReadResult {
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

        pub fn EscCommunication_SetPowerOn(powerOn: bool) {
            POWER_ON.with(|value| *value.borrow_mut() = powerOn);
        }

        pub fn EscCommunication_ResetTransport() {
            RECEIVE.with(|receive| receive.borrow_mut().clear());
            TRANSMIT.with(|transmit| transmit.borrow_mut().clear());
            TRANSPORT_RESET_COUNT.with(|count| {
                let next = count.borrow().saturating_add(1);
                *count.borrow_mut() = next;
            });
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

    pub fn reset_transport() {
        RECEIVE.with(|receive| receive.borrow_mut().clear());
        TRANSMIT.with(|transmit| transmit.borrow_mut().clear());
        TRANSMIT_ACCEPTED.with(|value| *value.borrow_mut() = true);
        POWER_ON.with(|value| *value.borrow_mut() = true);
        TRANSPORT_RESET_COUNT.with(|count| *count.borrow_mut() = 0);
    }

    pub fn enqueue_receive_byte(byte: u8) {
        RECEIVE.with(|receive| {
            receive.borrow_mut().push_back(UartByteReadResult {
                Byte: Some(byte),
                Errors: no_errors(),
            })
        });
    }

    pub fn enqueue_receive(result: UartByteReadResult) {
        RECEIVE.with(|receive| receive.borrow_mut().push_back(result));
    }

    pub fn take_transmit() -> Vec<Vec<u8>> {
        TRANSMIT.with(|transmit| transmit.borrow_mut().drain(..).collect())
    }

    pub fn set_transmit_accepted(accepted: bool) {
        TRANSMIT_ACCEPTED.with(|value| *value.borrow_mut() = accepted);
    }

    pub fn power_on() -> bool {
        POWER_ON.with(|value| *value.borrow())
    }

    pub fn transport_reset_count() -> u32 {
        TRANSPORT_RESET_COUNT.with(|count| *count.borrow())
    }
}

#[path = "../src/esc/mod.rs"]
mod esc;

use esc::{EscInterface, EscState, VescAppendShortFrame, VESC_SELECTIVE_VALUES_MASK};
use mcu::{
    enqueue_receive, enqueue_receive_byte, power_on, reset_transport, set_transmit_accepted,
    take_transmit, transport_reset_count, UartByteReadResult, USART_ERROR_FLAGS,
};

const TEST_MOTOR_CURRENT_LIMIT_MILLIAMPERES: u32 = 50_000;
const SUPPORTED_HARDWARE_NAME: &[u8] = b"75_300_R2";

fn test_interface() -> EscInterface {
    EscInterface::newWithMotorCurrentLimit(TEST_MOTOR_CURRENT_LIMIT_MILLIAMPERES)
}

fn short_frame(payload: &[u8]) -> Vec<u8> {
    let mut encoded = [0u8; 96];
    let length = VescAppendShortFrame(payload, &mut encoded, 0).unwrap();
    encoded[..length].to_vec()
}

fn enqueue_frame(payload: &[u8]) {
    for byte in short_frame(payload) {
        enqueue_receive_byte(byte);
    }
}

fn firmware_payload(major: u8, minor: u8) -> Vec<u8> {
    firmware_payload_with_hardware_name(major, minor, SUPPORTED_HARDWARE_NAME)
}

fn firmware_payload_with_hardware_name(
    major: u8,
    minor: u8,
    hardware_name: &[u8],
) -> Vec<u8> {
    let mut payload = vec![0, major, minor];
    payload.extend_from_slice(hardware_name);
    payload.push(0);
    // The production decoder intentionally consumes only the stable prefix
    // and ignores the UUID and capability fields which follow HW_NAME.
    payload.extend_from_slice(&[0x10, 0x32, 0x54, 0x76]);
    payload
}

fn telemetry_payload(fault: u8, status: u8) -> Vec<u8> {
    let mut payload = Vec::new();
    payload.push(50);
    payload.extend_from_slice(&VESC_SELECTIVE_VALUES_MASK.to_be_bytes());
    payload.extend_from_slice(&423i16.to_be_bytes());
    payload.extend_from_slice(&315i16.to_be_bytes());
    payload.extend_from_slice(&1_234i32.to_be_bytes());
    payload.extend_from_slice(&(-250i32).to_be_bytes());
    payload.extend_from_slice(&500i16.to_be_bytes());
    payload.extend_from_slice(&12_345i32.to_be_bytes());
    payload.extend_from_slice(&523i16.to_be_bytes());
    payload.push(fault);
    payload.push(status);
    assert_eq!(payload.len(), 27);
    payload
}

fn qualify(interface: &mut EscInterface) {
    interface.EscInterface_Step(1_000);
    take_transmit();

    enqueue_frame(&firmware_payload(6, 2));
    interface.EscInterface_Step(2_000);
    take_transmit();

    enqueue_frame(&telemetry_payload(0, 0));
    interface.EscInterface_Step(3_000);
    take_transmit();
    assert_eq!(
        interface.EscInterface_GetSnapshot(3_000).State,
        EscState::Ready
    );
}

#[test]
fn first_step_sends_zero_current_before_firmware_probe() {
    reset_transport();
    let mut interface = EscInterface::new();

    interface.EscInterface_Step(1_000);

    let batches = take_transmit();
    assert_eq!(batches.len(), 1);
    assert_eq!(
        batches[0],
        [
            0x02, 0x05, 0x06, 0x00, 0x00, 0x00, 0x00, 0xCD, 0x85, 0x03, 0x02, 0x01, 0x00, 0x00,
            0x00, 0x03,
        ]
    );
    assert_eq!(interface.Diagnostics.CurrentCommandCount, 1);
    assert_eq!(interface.Diagnostics.ZeroCurrentCommandCount, 1);
    assert_eq!(interface.Diagnostics.FirmwareRequestCount, 1);
    assert_eq!(interface.State, EscState::Starting);
}

#[test]
fn qualifies_firmware_and_decodes_selective_telemetry() {
    reset_transport();
    let mut interface = EscInterface::new();
    interface.EscInterface_Step(1_000);
    take_transmit();

    enqueue_frame(&firmware_payload(6, 2));
    interface.EscInterface_Step(2_000);
    let firmware_step = take_transmit();
    assert_eq!(firmware_step.len(), 1);
    assert_eq!(firmware_step[0].len(), 20);
    assert_eq!(
        &firmware_step[0][10..],
        &[0x02, 0x05, 0x32, 0x00, 0x20, 0x81, 0xCF, 0xCE, 0xA1, 0x03]
    );

    enqueue_frame(&telemetry_payload(0, 0));
    interface.EscInterface_Step(3_000);
    let snapshot = interface.EscInterface_GetSnapshot(3_000);

    assert_eq!(snapshot.State, EscState::Ready);
    assert!(snapshot.CommunicationReady);
    assert!(snapshot.Firmware.Valid);
    assert!(snapshot.Firmware.Compatible);
    assert_eq!(snapshot.Firmware.Major, 6);
    assert_eq!(snapshot.Firmware.Minor, 2);
    assert_eq!(snapshot.Firmware.HardwareNameLength, 9);
    assert_eq!(&snapshot.Firmware.HardwareName[..9], SUPPORTED_HARDWARE_NAME);
    assert_eq!(snapshot.Telemetry.FetTemperatureDeciCelsius, 423);
    assert_eq!(snapshot.Telemetry.MotorTemperatureDeciCelsius, 315);
    assert_eq!(snapshot.Telemetry.MotorCurrentCentiAmperes, 1_234);
    assert_eq!(snapshot.Telemetry.InputCurrentCentiAmperes, -250);
    assert_eq!(snapshot.Telemetry.DutyPermille, 500);
    assert_eq!(snapshot.Telemetry.ElectricalRpm, 12_345);
    assert_eq!(snapshot.Telemetry.InputVoltageDecivolts, 523);
    assert_eq!(snapshot.Diagnostics.FirmwareResponseCount, 1);
    assert_eq!(snapshot.Diagnostics.TelemetryResponseCount, 1);
}

#[test]
fn explicit_current_request_is_valid_at_five_milliseconds_and_expires_afterward() {
    reset_transport();
    let mut interface = test_interface();
    qualify(&mut interface);

    assert!(interface.EscInterface_RequestMotorCurrent(3_000, 12_345));
    interface.EscInterface_Step(4_000);
    assert_eq!(
        take_transmit()[0],
        [0x02, 0x05, 0x06, 0x00, 0x00, 0x30, 0x39, 0x6F, 0x6A, 0x03]
    );

    interface.EscInterface_Step(8_000);
    assert_eq!(interface.LastQueuedMotorCurrentMilliamperes, 12_345);
    take_transmit();

    interface.EscInterface_Step(8_001);
    assert_eq!(
        take_transmit()[0],
        [0x02, 0x05, 0x06, 0x00, 0x00, 0x00, 0x00, 0xCD, 0x85, 0x03]
    );
    assert_eq!(interface.RequestedMotorCurrentMilliamperes, 0);
    assert_eq!(interface.Diagnostics.ExpiredCurrentRequestCount, 1);
}

#[test]
fn esc_fault_status_prevents_a_nonzero_command() {
    reset_transport();
    let mut interface = test_interface();
    qualify(&mut interface);

    interface.EscInterface_Step(12_000);
    take_transmit();
    assert!(interface.EscInterface_RequestMotorCurrent(12_000, 20_000));
    enqueue_frame(&telemetry_payload(5, 0));
    interface.EscInterface_Step(13_000);

    let snapshot = interface.EscInterface_GetSnapshot(13_000);
    assert_eq!(snapshot.State, EscState::Fault);
    assert!(!snapshot.PropulsionCommandPermitted);
    assert_eq!(snapshot.Telemetry.FaultCode, 5);
    assert_eq!(snapshot.RequestedMotorCurrentMilliamperes, 0);
    assert_eq!(
        take_transmit()[0],
        [0x02, 0x05, 0x06, 0x00, 0x00, 0x00, 0x00, 0xCD, 0x85, 0x03]
    );
}

#[test]
fn rejects_bad_crc_and_uart_errors_and_recovers_on_valid_responses() {
    reset_transport();
    let mut interface = EscInterface::new();
    interface.EscInterface_Step(1_000);
    take_transmit();

    let mut corrupted = short_frame(&firmware_payload(6, 2));
    corrupted[4] ^= 0x01;
    for byte in corrupted {
        enqueue_receive_byte(byte);
    }
    interface.EscInterface_Step(2_000);
    assert_eq!(interface.Diagnostics.ChecksumErrorCount, 1);
    assert_eq!(interface.State, EscState::Fault);
    take_transmit();

    enqueue_receive(UartByteReadResult {
        Byte: Some(0x02),
        Errors: USART_ERROR_FLAGS {
            parityError: false,
            framingError: true,
            noiseDetected: false,
            overrunError: false,
        },
    });
    enqueue_frame(&firmware_payload(6, 2));
    interface.EscInterface_Step(3_000);
    assert_eq!(interface.Diagnostics.UartErrorCount, 1);
    assert_eq!(interface.Diagnostics.UartFramingErrorCount, 1);
    assert_eq!(interface.Diagnostics.FirmwareResponseCount, 1);
}

#[test]
fn partial_frame_and_response_timeouts_are_bounded_and_retried() {
    reset_transport();
    let mut partial = EscInterface::new();
    partial.EscInterface_ReceiveByte(0x02, 100);
    partial.EscInterface_Step(5_101);
    assert_eq!(partial.Diagnostics.PartialFrameTimeoutCount, 1);
    assert_eq!(partial.Diagnostics.InvalidFrameCount, 1);
    take_transmit();

    reset_transport();
    let mut response = EscInterface::new();
    response.EscInterface_Step(1_000);
    take_transmit();
    response.EscInterface_Step(21_001);
    assert_eq!(response.Diagnostics.ResponseTimeoutCount, 1);
    assert_eq!(response.Diagnostics.FirmwareRequestCount, 2);
    assert_eq!(take_transmit().len(), 1);
}

#[test]
fn atomic_transmit_rejection_is_a_current_deadline_fault() {
    reset_transport();
    let mut interface = EscInterface::new();
    set_transmit_accepted(false);

    interface.EscInterface_Step(1_000);

    assert!(take_transmit().is_empty());
    assert_eq!(interface.Diagnostics.TransmitFailureCount, 1);
    assert_eq!(interface.Diagnostics.CurrentCommandDeadlineMissCount, 1);
    assert_eq!(interface.Diagnostics.CurrentCommandCount, 0);
    assert_eq!(interface.State, EscState::Fault);
}

#[test]
fn power_control_clears_demand_and_stops_all_uart_commands() {
    reset_transport();
    let mut interface = test_interface();
    qualify(&mut interface);
    assert!(interface.EscInterface_RequestMotorCurrent(3_000, 1_000));

    interface.EscInterface_SetPowerOn(false);
    interface.EscInterface_Step(4_000);

    assert!(!power_on());
    assert!(take_transmit().is_empty());
    assert_eq!(interface.State, EscState::PoweredOff);
    assert_eq!(interface.RequestedMotorCurrentMilliamperes, 0);
    assert!(!interface.EscInterface_RequestMotorCurrent(4_000, 1_000));
    assert_eq!(transport_reset_count(), 1);

    interface.EscInterface_SetPowerOn(true);
    interface.EscInterface_Step(5_000);
    assert!(power_on());
    assert_eq!(interface.State, EscState::Starting);
    assert_eq!(take_transmit().len(), 1);
    assert_eq!(transport_reset_count(), 2);
}

#[test]
fn unsupported_firmware_and_stale_snapshot_fail_closed() {
    reset_transport();
    let mut interface = EscInterface::new();
    interface.EscInterface_Step(1_000);
    take_transmit();
    enqueue_frame(&firmware_payload(5, 3));
    interface.EscInterface_Step(2_000);

    let unsupported = interface.EscInterface_GetSnapshot(2_000);
    assert_eq!(unsupported.State, EscState::Fault);
    assert!(unsupported.Firmware.Valid);
    assert!(!unsupported.Firmware.Compatible);
    assert_eq!(unsupported.Diagnostics.UnsupportedFirmwareCount, 1);

    let stale = interface.EscInterface_GetSnapshot(4_001);
    assert_eq!(stale.State, EscState::Fault);
    assert!(!stale.CommunicationReady);
    assert!(!stale.PropulsionCommandPermitted);
}

#[test]
fn unsupported_minor_or_hardware_profile_fails_closed() {
    for payload in [
        firmware_payload(6, 1),
        firmware_payload(7, 0),
        firmware_payload_with_hardware_name(6, 2, b"75_100"),
    ] {
        reset_transport();
        let mut interface = EscInterface::new();
        interface.EscInterface_Step(1_000);
        take_transmit();
        enqueue_frame(&payload);
        interface.EscInterface_Step(2_000);

        let snapshot = interface.EscInterface_GetSnapshot(2_000);
        assert_eq!(snapshot.State, EscState::Fault);
        assert!(snapshot.Firmware.Valid);
        assert!(!snapshot.Firmware.Compatible);
        assert_eq!(snapshot.Diagnostics.UnsupportedFirmwareCount, 1);
    }
}

#[test]
fn current_requests_reject_unrepresentable_and_old_values() {
    reset_transport();
    let mut interface = test_interface();

    assert!(!interface.EscInterface_RequestMotorCurrent(0, 1));
    qualify(&mut interface);
    assert!(!interface.EscInterface_RequestMotorCurrent(2_999, 1));
    assert!(!interface.EscInterface_RequestMotorCurrent(
        3_000,
        TEST_MOTOR_CURRENT_LIMIT_MILLIAMPERES + 1
    ));
    assert!(!interface.EscInterface_RequestMotorCurrent(3_000, i32::MAX as u32 + 1));
    assert!(interface.EscInterface_RequestMotorCurrent(
        3_000,
        TEST_MOTOR_CURRENT_LIMIT_MILLIAMPERES
    ));
    assert_eq!(interface.Diagnostics.RejectedCurrentRequestCount, 4);
    assert_eq!(
        interface.RequestedMotorCurrentMilliamperes,
        TEST_MOTOR_CURRENT_LIMIT_MILLIAMPERES as i32
    );
}

#[test]
fn deployed_default_disables_nonzero_current() {
    reset_transport();
    let mut interface = EscInterface::new();
    qualify(&mut interface);

    assert_eq!(
        interface
            .EscInterface_GetSnapshot(3_000)
            .MotorCurrentLimitMilliamperes,
        0
    );
    assert!(!interface.EscInterface_RequestMotorCurrent(3_000, 1));
    assert_eq!(interface.RequestedMotorCurrentMilliamperes, 0);
}

#[test]
fn transmit_failure_preserves_last_successfully_queued_command() {
    reset_transport();
    let mut interface = test_interface();
    qualify(&mut interface);
    assert!(interface.EscInterface_RequestMotorCurrent(3_000, 12_345));

    interface.EscInterface_Step(4_000);
    take_transmit();
    assert_eq!(interface.LastQueuedMotorCurrentMilliamperes, 12_345);
    assert_eq!(interface.LastQueuedCurrentTimestampUs, 4_000);

    set_transmit_accepted(false);
    interface.EscInterface_Step(5_000);

    assert_eq!(interface.LastQueuedMotorCurrentMilliamperes, 12_345);
    assert_eq!(interface.LastQueuedCurrentTimestampUs, 4_000);
    assert_eq!(interface.Diagnostics.CurrentCommandDeadlineMissCount, 1);
    assert_eq!(interface.State, EscState::Fault);
    assert_eq!(interface.RequestedMotorCurrentMilliamperes, 0);
}
