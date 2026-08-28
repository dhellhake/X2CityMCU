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

    #[repr(u8)]
    #[derive(Copy, Clone, Debug, PartialEq, Eq)]
    pub enum BrkHdlAdcPairStatus {
        Complete = 0,
        NotInitialized = 1,
        CalibrationFailed = 2,
        Timeout = 3,
        Stale = 4,
    }

    #[repr(C)]
    #[derive(Copy, Clone)]
    pub struct BrkHdlAdcPair {
        pub Status: BrkHdlAdcPairStatus,
        pub RawA: u16,
        pub RawB: u16,
        pub Sequence: u32,
        pub CompletionTimestampUs: u64,
    }

    pub struct McuManager;

    thread_local! {
        static SAMPLES: RefCell<VecDeque<BrkHdlAdcPair>> = RefCell::new(VecDeque::new());
    }

    impl McuManager {
        pub fn BrkHdlInput_ReadPair() -> BrkHdlAdcPair {
            SAMPLES.with(|samples| {
                samples.borrow_mut().pop_front().unwrap_or(BrkHdlAdcPair {
                    Status: BrkHdlAdcPairStatus::NotInitialized,
                    RawA: 0,
                    RawB: 0,
                    Sequence: 0,
                    CompletionTimestampUs: 0,
                })
            })
        }
    }

    pub fn reset_samples() {
        SAMPLES.with(|samples| samples.borrow_mut().clear());
    }

    pub fn enqueue(sample: BrkHdlAdcPair) {
        SAMPLES.with(|samples| samples.borrow_mut().push_back(sample));
    }
}

#[path = "../src/brkhdl/mod.rs"]
mod brkhdl;

use brkhdl::{BrkHdlInterface, BrkHdlSnapshot, BrkHdlState};
use mcu::{reset_samples, BrkHdlAdcPair, BrkHdlAdcPairStatus};

fn pair(sequence: u32, timestamp_us: u64, raw_a: u16, raw_b: u16) -> BrkHdlAdcPair {
    BrkHdlAdcPair {
        Status: BrkHdlAdcPairStatus::Complete,
        RawA: raw_a,
        RawB: raw_b,
        Sequence: sequence,
        CompletionTimestampUs: timestamp_us,
    }
}

fn error_pair(status: BrkHdlAdcPairStatus, sequence: u32) -> BrkHdlAdcPair {
    BrkHdlAdcPair {
        Status: status,
        RawA: 0,
        RawB: 0,
        Sequence: sequence,
        CompletionTimestampUs: 0,
    }
}

fn step(interface: &mut BrkHdlInterface, timestamp_us: u64, sample: BrkHdlAdcPair) {
    interface.BrkHdlInterface_ProcessAcquisition(timestamp_us, sample);
}

fn snapshot(interface: &BrkHdlInterface, timestamp_us: u64) -> BrkHdlSnapshot {
    interface.BrkHdlInterface_GetSnapshot(timestamp_us)
}

fn qualify_unpressed(interface: &mut BrkHdlInterface, first_sequence: u32) {
    for offset in 0..5 {
        let timestamp_us = u64::from(first_sequence + offset) * 5_000;
        step(
            interface,
            timestamp_us,
            pair(first_sequence + offset, timestamp_us, 3_013, 1_086),
        );
    }
}

#[test]
fn recognizes_all_four_measured_handle_states() {
    reset_samples();
    let mut interface = BrkHdlInterface::new();

    qualify_unpressed(&mut interface, 1);
    let state = snapshot(&interface, 25_000);
    assert_eq!(state.State, BrkHdlState::Unpressed);
    assert_eq!(state.InstantaneousState, BrkHdlState::Unpressed);
    assert!(state.PropulsionPermitted);
    assert_eq!(state.Kx10000, 5_636);

    step(&mut interface, 30_000, pair(6, 30_000, 2_847, 1_253));
    let state = snapshot(&interface, 30_000);
    assert_eq!(state.State, BrkHdlState::A_Pressed);
    assert!(!state.PropulsionPermitted);

    step(&mut interface, 35_000, pair(7, 35_000, 2_722, 1_379));
    assert_eq!(snapshot(&interface, 35_000).State, BrkHdlState::B_Pressed);

    step(&mut interface, 40_000, pair(8, 40_000, 2_638, 1_464));
    let state = snapshot(&interface, 40_000);
    assert_eq!(state.State, BrkHdlState::AB_Pressed);
    assert_eq!(state.AcquisitionErrorCount, 0);
    assert_eq!(state.ElectricalErrorCount, 0);
}

#[test]
fn release_requires_five_consecutive_unpressed_samples() {
    reset_samples();
    let mut interface = BrkHdlInterface::new();
    qualify_unpressed(&mut interface, 1);
    step(&mut interface, 30_000, pair(6, 30_000, 2_847, 1_253));
    assert_eq!(snapshot(&interface, 30_000).State, BrkHdlState::A_Pressed);

    for sequence in 7..11 {
        let timestamp_us = u64::from(sequence) * 5_000;
        step(
            &mut interface,
            timestamp_us,
            pair(sequence, timestamp_us, 3_013, 1_086),
        );
        let state = snapshot(&interface, timestamp_us);
        assert_eq!(state.State, BrkHdlState::A_Pressed);
        assert!(!state.PropulsionPermitted);
    }

    step(&mut interface, 55_000, pair(11, 55_000, 3_013, 1_086));
    let state = snapshot(&interface, 55_000);
    assert_eq!(state.State, BrkHdlState::Unpressed);
    assert!(state.PropulsionPermitted);
    assert_eq!(state.ReleaseConfirmationCount, 5);
}

#[test]
fn electrical_faults_fail_closed_immediately() {
    let invalid_pairs = [
        (4_095, 0),
        (2_048, 2_048),
        (2_100, 760),
        (3_300, 1_800),
        (2_900, 1_200),
        (3_013, 17),
    ];

    for (raw_a, raw_b) in invalid_pairs {
        reset_samples();
        let mut interface = BrkHdlInterface::new();
        qualify_unpressed(&mut interface, 1);
        step(&mut interface, 30_000, pair(6, 30_000, raw_a, raw_b));
        let state = snapshot(&interface, 30_000);
        assert_eq!(state.State, BrkHdlState::Error);
        assert_eq!(state.InstantaneousState, BrkHdlState::Error);
        assert!(!state.PropulsionPermitted);
        assert_eq!(state.ElectricalErrorCount, 1);
    }
}

#[test]
fn acquisition_failure_duplicate_and_old_timestamp_fail_closed() {
    reset_samples();
    let mut interface = BrkHdlInterface::new();
    qualify_unpressed(&mut interface, 1);

    step(
        &mut interface,
        30_000,
        error_pair(BrkHdlAdcPairStatus::Timeout, 5),
    );
    let state = snapshot(&interface, 30_000);
    assert_eq!(state.State, BrkHdlState::Error);
    assert_eq!(
        state.LastAcquisitionStatus,
        BrkHdlAdcPairStatus::Timeout
    );

    step(&mut interface, 35_000, pair(5, 35_000, 3_013, 1_086));
    assert_eq!(
        snapshot(&interface, 35_000).LastAcquisitionStatus,
        BrkHdlAdcPairStatus::Stale
    );

    step(&mut interface, 45_001, pair(6, 35_000, 3_013, 1_086));
    let state = snapshot(&interface, 45_001);
    assert_eq!(state.LastAcquisitionStatus, BrkHdlAdcPairStatus::Stale);
    assert_eq!(state.AcquisitionErrorCount, 3);
    assert_eq!(state.CompleteSampleCount, 5);
}

#[test]
fn every_ratio_window_includes_its_edges_and_rejects_guard_bands() {
    let cases = [
        (3_080, 1_080, BrkHdlState::Unpressed),
        (3_180, 1_180, BrkHdlState::Unpressed),
        (2_800, 1_200, BrkHdlState::A_Pressed),
        (2_912, 1_312, BrkHdlState::A_Pressed),
        (2_786, 1_386, BrkHdlState::B_Pressed),
        (2_884, 1_484, BrkHdlState::B_Pressed),
        (2_652, 1_452, BrkHdlState::AB_Pressed),
        (2_736, 1_536, BrkHdlState::AB_Pressed),
        (3_079, 1_079, BrkHdlState::Error),
        (3_181, 1_181, BrkHdlState::Error),
        (2_900, 1_200, BrkHdlState::Error),
    ];

    for (index, (raw_a, raw_b, expected)) in cases.into_iter().enumerate() {
        reset_samples();
        let mut interface = BrkHdlInterface::new();
        let sequence = index as u32 + 1;
        let timestamp_us = u64::from(sequence) * 5_000;
        step(
            &mut interface,
            timestamp_us,
            pair(sequence, timestamp_us, raw_a, raw_b),
        );
        assert_eq!(snapshot(&interface, timestamp_us).InstantaneousState, expected);
    }
}

#[test]
fn startup_and_error_recovery_remain_fail_safe() {
    reset_samples();
    let mut interface = BrkHdlInterface::new();
    assert_eq!(snapshot(&interface, 0).State, BrkHdlState::Error);
    assert!(!snapshot(&interface, 0).PropulsionPermitted);

    step(
        &mut interface,
        5_000,
        error_pair(BrkHdlAdcPairStatus::CalibrationFailed, 0),
    );
    assert_eq!(snapshot(&interface, 5_000).State, BrkHdlState::Error);

    qualify_unpressed(&mut interface, 1);
    assert_eq!(snapshot(&interface, 25_000).State, BrkHdlState::Unpressed);

    step(&mut interface, 30_000, pair(6, 30_000, 2_048, 2_048));
    assert_eq!(snapshot(&interface, 30_000).State, BrkHdlState::Error);
    qualify_unpressed(&mut interface, 7);
    let state = snapshot(&interface, 55_000);
    assert_eq!(state.State, BrkHdlState::Unpressed);
    assert!(state.PropulsionPermitted);
}

#[test]
fn diagnostic_counters_saturate_instead_of_wrapping() {
    reset_samples();
    let mut interface = BrkHdlInterface::new();
    interface.BrkHdlInterface_SetDiagnosticCountersForTest(u32::MAX, u32::MAX, u32::MAX);

    step(
        &mut interface,
        5_000,
        error_pair(BrkHdlAdcPairStatus::NotInitialized, 0),
    );
    assert_eq!(snapshot(&interface, 5_000).AcquisitionErrorCount, u32::MAX);
    step(&mut interface, 10_000, pair(1, 10_000, 2_048, 2_048));
    let state = snapshot(&interface, 10_000);
    assert_eq!(state.ElectricalErrorCount, u32::MAX);
    assert_eq!(state.StateChangeCount, u32::MAX);
}

#[test]
fn snapshot_fails_closed_outside_the_pairs_scheduler_release() {
    let mut interface = BrkHdlInterface::new();
    qualify_unpressed(&mut interface, 1);

    let fresh = snapshot(&interface, 25_000);
    assert_eq!(fresh.State, BrkHdlState::Unpressed);
    assert!(fresh.PropulsionPermitted);

    let stale = snapshot(&interface, 30_000);
    assert_eq!(stale.State, BrkHdlState::Error);
    assert_eq!(stale.InstantaneousState, BrkHdlState::Error);
    assert_eq!(stale.LastAcquisitionStatus, BrkHdlAdcPairStatus::Stale);
    assert!(!stale.PropulsionPermitted);
    assert_eq!(stale.RawA, 3_013);
    assert_eq!(stale.RawB, 1_086);
}
