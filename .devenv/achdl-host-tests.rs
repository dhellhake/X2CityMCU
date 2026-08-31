#![allow(dead_code)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

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
    #[repr(u8)]
    #[derive(Copy, Clone, Debug, PartialEq, Eq)]
    pub enum AcHdlAdcPairStatus {
        Complete = 0,
        NotInitialized = 1,
        CalibrationFailed = 2,
        Timeout = 3,
        Stale = 4,
    }

    #[repr(C)]
    #[derive(Copy, Clone)]
    pub struct AcHdlAdcPair {
        pub Status: AcHdlAdcPairStatus,
        pub RawSignal: u16,
        pub RawSupply: u16,
        pub Sequence: u32,
        pub CompletionTimestampUs: u64,
    }
}

#[path = "../src/achdl/mod.rs"]
mod achdl;

use achdl::{AcHdlInterface, AcHdlSnapshot, AcHdlState};
use mcu::{AcHdlAdcPair, AcHdlAdcPairStatus};

const RELEASED_SIGNAL: u16 = 1_007;
const VALID_SUPPLY: u16 = 2_050;

fn pair(sequence: u32, timestamp_us: u64, signal: u16, supply: u16) -> AcHdlAdcPair {
    AcHdlAdcPair {
        Status: AcHdlAdcPairStatus::Complete,
        RawSignal: signal,
        RawSupply: supply,
        Sequence: sequence,
        CompletionTimestampUs: timestamp_us,
    }
}

fn error_pair(status: AcHdlAdcPairStatus, sequence: u32) -> AcHdlAdcPair {
    AcHdlAdcPair {
        Status: status,
        RawSignal: 0,
        RawSupply: 0,
        Sequence: sequence,
        CompletionTimestampUs: 0,
    }
}

fn step(interface: &mut AcHdlInterface, timestamp_us: u64, sample: AcHdlAdcPair) {
    interface.AcHdlInterface_ProcessAcquisition(timestamp_us, sample);
}

fn snapshot(interface: &AcHdlInterface, timestamp_us: u64) -> AcHdlSnapshot {
    interface.AcHdlInterface_GetSnapshot(timestamp_us)
}

fn qualify_released(interface: &mut AcHdlInterface, first_sequence: u32) {
    for offset in 0..5 {
        let sequence = first_sequence + offset;
        let timestamp_us = u64::from(sequence) * 5_000;
        step(
            interface,
            timestamp_us,
            pair(sequence, timestamp_us, RELEASED_SIGNAL, VALID_SUPPLY),
        );
    }
}

#[test]
fn starts_invalid_and_qualifies_zero_after_five_released_samples() {
    let mut interface = AcHdlInterface::new();
    let initial = snapshot(&interface, 0);
    assert_eq!(initial.State, AcHdlState::Error);
    assert!(!initial.PositionValid);
    assert!(!initial.ReleaseQualified);

    for sequence in 1..5 {
        let timestamp_us = u64::from(sequence) * 5_000;
        step(
            &mut interface,
            timestamp_us,
            pair(sequence, timestamp_us, RELEASED_SIGNAL, VALID_SUPPLY),
        );
        let state = snapshot(&interface, timestamp_us);
        assert_eq!(state.State, AcHdlState::Error);
        assert_eq!(state.InstantaneousState, AcHdlState::Released);
        assert!(!state.PositionValid);
    }

    step(
        &mut interface,
        25_000,
        pair(5, 25_000, RELEASED_SIGNAL, VALID_SUPPLY),
    );
    let state = snapshot(&interface, 25_000);
    assert_eq!(state.State, AcHdlState::Released);
    assert!(state.PositionValid);
    assert!(state.ReleaseQualified);
    assert_eq!(state.PositionPermille, 0);
    assert_eq!(state.ReleaseConfirmationCount, 5);
    assert_eq!(state.RawSignalToSupplySenseRatioX10000, 4_912);
}

#[test]
fn rejects_active_demand_before_released_history() {
    let mut interface = AcHdlInterface::new();
    step(&mut interface, 5_000, pair(1, 5_000, 1_734, VALID_SUPPLY));
    let state = snapshot(&interface, 5_000);
    assert_eq!(state.InstantaneousState, AcHdlState::Active);
    assert_eq!(state.State, AcHdlState::Error);
    assert!(!state.PositionValid);
    assert_eq!(state.PositionPermille, 0);
    assert_eq!(state.QualificationRejectCount, 1);
}

#[test]
fn maps_fixed_position_without_learning_runtime_peaks() {
    let mut interface = AcHdlInterface::new();
    qualify_released(&mut interface, 1);

    step(&mut interface, 30_000, pair(6, 30_000, 1_754, VALID_SUPPLY));
    let midpoint = snapshot(&interface, 30_000);
    assert_eq!(midpoint.State, AcHdlState::Active);
    assert!(midpoint.PositionValid);
    assert_eq!(midpoint.PositionPermille, 500);

    step(&mut interface, 35_000, pair(7, 35_000, 2_500, VALID_SUPPLY));
    assert_eq!(snapshot(&interface, 35_000).PositionPermille, 1_000);

    step(&mut interface, 40_000, pair(8, 40_000, 1_754, VALID_SUPPLY));
    assert_eq!(snapshot(&interface, 40_000).PositionPermille, 500);
}

#[test]
fn electrical_fault_disarms_and_requires_released_requalification() {
    let mut interface = AcHdlInterface::new();
    qualify_released(&mut interface, 1);
    step(&mut interface, 30_000, pair(6, 30_000, 1_734, VALID_SUPPLY));
    assert_eq!(snapshot(&interface, 30_000).State, AcHdlState::Active);

    step(&mut interface, 35_000, pair(7, 35_000, 1_734, 1_899));
    let fault = snapshot(&interface, 35_000);
    assert_eq!(fault.State, AcHdlState::Error);
    assert_eq!(fault.ElectricalErrorCount, 1);
    assert!(!fault.ReleaseQualified);
    assert!(!fault.PositionValid);

    step(&mut interface, 40_000, pair(8, 40_000, 1_734, VALID_SUPPLY));
    let rejected = snapshot(&interface, 40_000);
    assert_eq!(rejected.State, AcHdlState::Error);
    assert_eq!(rejected.QualificationRejectCount, 1);

    qualify_released(&mut interface, 9);
    let recovered = snapshot(&interface, 65_000);
    assert_eq!(recovered.State, AcHdlState::Released);
    assert!(recovered.PositionValid);
}

#[test]
fn acquisition_failure_duplicate_and_old_timestamp_fail_closed() {
    let mut interface = AcHdlInterface::new();
    qualify_released(&mut interface, 1);

    step(
        &mut interface,
        30_000,
        error_pair(AcHdlAdcPairStatus::Timeout, 5),
    );
    assert_eq!(snapshot(&interface, 30_000).State, AcHdlState::Error);

    step(
        &mut interface,
        35_000,
        pair(5, 35_000, RELEASED_SIGNAL, VALID_SUPPLY),
    );
    assert_eq!(
        snapshot(&interface, 35_000).LastAcquisitionStatus,
        AcHdlAdcPairStatus::Stale
    );

    step(
        &mut interface,
        45_001,
        pair(6, 35_000, RELEASED_SIGNAL, VALID_SUPPLY),
    );
    let state = snapshot(&interface, 45_001);
    assert_eq!(state.LastAcquisitionStatus, AcHdlAdcPairStatus::Stale);
    assert_eq!(state.AcquisitionErrorCount, 3);
}

#[test]
fn provisional_electrical_windows_include_edges_and_reject_outside() {
    let cases = [
        (900, 2_050, AcHdlState::Released),
        (1_075, 2_050, AcHdlState::Released),
        (1_076, 2_050, AcHdlState::Active),
        (2_600, 2_050, AcHdlState::Active),
        (899, 2_050, AcHdlState::Error),
        (2_601, 2_050, AcHdlState::Error),
        (1_007, 1_900, AcHdlState::Released),
        (1_007, 2_200, AcHdlState::Released),
        (1_007, 1_899, AcHdlState::Error),
        (1_007, 2_201, AcHdlState::Error),
    ];

    for (index, (signal, supply, expected)) in cases.into_iter().enumerate() {
        let mut interface = AcHdlInterface::new();
        let sequence = index as u32 + 1;
        let timestamp_us = u64::from(sequence) * 5_000;
        step(
            &mut interface,
            timestamp_us,
            pair(sequence, timestamp_us, signal, supply),
        );
        assert_eq!(
            snapshot(&interface, timestamp_us).InstantaneousState,
            expected
        );
    }
}

#[test]
fn diagnostic_counters_saturate_instead_of_wrapping() {
    let mut interface = AcHdlInterface::new();
    interface.AcHdlInterface_SetDiagnosticCountersForTest(
        u32::MAX,
        u32::MAX,
        u32::MAX,
        u32::MAX,
    );

    step(
        &mut interface,
        5_000,
        error_pair(AcHdlAdcPairStatus::NotInitialized, 0),
    );
    step(&mut interface, 10_000, pair(1, 10_000, 899, VALID_SUPPLY));
    step(&mut interface, 15_000, pair(2, 15_000, 1_734, VALID_SUPPLY));
    let state = snapshot(&interface, 15_000);
    assert_eq!(state.AcquisitionErrorCount, u32::MAX);
    assert_eq!(state.ElectricalErrorCount, u32::MAX);
    assert_eq!(state.QualificationRejectCount, u32::MAX);
    assert_eq!(state.StateChangeCount, u32::MAX);
}

#[test]
fn snapshot_fails_closed_outside_the_samples_scheduler_release() {
    let mut interface = AcHdlInterface::new();
    qualify_released(&mut interface, 1);

    let fresh = snapshot(&interface, 25_000);
    assert_eq!(fresh.State, AcHdlState::Released);
    assert!(fresh.PositionValid);

    let stale = snapshot(&interface, 30_000);
    assert_eq!(stale.State, AcHdlState::Error);
    assert_eq!(stale.InstantaneousState, AcHdlState::Error);
    assert_eq!(stale.LastAcquisitionStatus, AcHdlAdcPairStatus::Stale);
    assert!(!stale.PositionValid);
    assert_eq!(stale.PositionPermille, 0);
    assert_eq!(stale.RawSignal, RELEASED_SIGNAL);
    assert_eq!(stale.RawSupply, VALID_SUPPLY);
}
