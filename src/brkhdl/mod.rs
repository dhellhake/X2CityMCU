#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use crate::{
    drv::cortex::Shared,
    mcu::{BrkHdlAdcPair, BrkHdlAdcPairStatus, McuManager},
};

const ADC_MAX_CODE: u16 = 4_095;
const ADC_RAIL_GUARD_CODES: u16 = 16;
const ADC_SUM_MIN: u32 = 3_800;
const ADC_SUM_MAX: u32 = 4_400;
const ADC_DIFFERENCE_MIN: u32 = 512;
const K_SCALE: u32 = 10_000;
const UNPRESSED_K_MIN: u32 = 5_400;
const UNPRESSED_K_MAX: u32 = 5_900;
const HANDLE_A_K_MIN: u32 = 7_500;
const HANDLE_A_K_MAX: u32 = 8_200;
const HANDLE_B_K_MIN: u32 = 9_900;
const HANDLE_B_K_MAX: u32 = 10_600;
const BOTH_HANDLES_K_MIN: u32 = 12_100;
const BOTH_HANDLES_K_MAX: u32 = 12_800;
const RELEASE_CONFIRMATION_SAMPLES: u8 = 5;
const SAMPLE_STALE_AFTER_US: u64 = 10_000;

/// Qualified brake-handle state published to the application.
///
/// Handle A is the former left-handle resistor signature (nominal K around
/// 0.786). Handle B is the former right-handle signature (nominal K around
/// 1.026). These names do not refer to the ADC_A/ADC_B loop conductors.
#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum BrkHdlState {
    Unpressed = 0,
    A_Pressed = 1,
    B_Pressed = 2,
    AB_Pressed = 3,
    Error = 4,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct BrkHdlSnapshot {
    pub State: BrkHdlState,
    pub InstantaneousState: BrkHdlState,
    pub LastAcquisitionStatus: BrkHdlAdcPairStatus,
    pub PropulsionPermitted: bool,
    pub ReleaseConfirmationCount: u8,
    pub RawA: u16,
    pub RawB: u16,
    pub Difference: u16,
    pub Sum: u16,
    pub Kx10000: u32,
    pub SampleSequence: u32,
    pub CompleteSampleCount: u32,
    pub AcquisitionErrorCount: u32,
    pub ElectricalErrorCount: u32,
    pub StateChangeCount: u32,
    pub LastSampleTimestampUs: u64,
    pub LastStepTimestampUs: u64,
}

#[repr(C)]
pub struct BrkHdlInterface {
    State: BrkHdlState,
    InstantaneousState: BrkHdlState,
    LastAcquisitionStatus: BrkHdlAdcPairStatus,
    PropulsionPermitted: bool,
    ReleaseConfirmationCount: u8,
    RawA: u16,
    RawB: u16,
    Difference: u16,
    Sum: u16,
    Kx10000: u32,
    SampleSequence: u32,
    CompleteSampleCount: u32,
    AcquisitionErrorCount: u32,
    ElectricalErrorCount: u32,
    StateChangeCount: u32,
    LastSampleTimestampUs: u64,
    LastStepTimestampUs: u64,
}

/// The single application instance. The unmangled name deliberately keeps the
/// live state easy to inspect during target bring-up without duplicating it in
/// a debugger-only mirror.
#[unsafe(no_mangle)]
static BRKHDL: Shared<BrkHdlInterface> = Shared::new(BrkHdlInterface::new());

#[inline]
pub fn BrkHdlInterface_Run(tstmp: u64) {
    // The two averaged ADC conversions take about 171 us. Acquire them before
    // taking the component-state lock so scheduler interrupts remain enabled
    // throughout that wait; only coherent-pair publication is atomic.
    let sample = McuManager::BrkHdlInput_ReadPair();
    BRKHDL.with(|interface| interface.BrkHdlInterface_ProcessAcquisition(tstmp, sample));
}

pub fn BrkHdlInterface_GetSnapshot(tstmp: u64) -> BrkHdlSnapshot {
    BRKHDL.with(|interface| interface.BrkHdlInterface_GetSnapshot(tstmp))
}

impl BrkHdlInterface {
    pub const fn new() -> Self {
        Self {
            State: BrkHdlState::Error,
            InstantaneousState: BrkHdlState::Error,
            LastAcquisitionStatus: BrkHdlAdcPairStatus::NotInitialized,
            PropulsionPermitted: false,
            ReleaseConfirmationCount: 0,
            RawA: 0,
            RawB: 0,
            Difference: 0,
            Sum: 0,
            Kx10000: 0,
            SampleSequence: 0,
            CompleteSampleCount: 0,
            AcquisitionErrorCount: 0,
            ElectricalErrorCount: 0,
            StateChangeCount: 0,
            LastSampleTimestampUs: 0,
            LastStepTimestampUs: 0,
        }
    }

    pub fn BrkHdlInterface_GetSnapshot(&self, tstmp: u64) -> BrkHdlSnapshot {
        let mut snapshot = BrkHdlSnapshot {
            State: self.State,
            InstantaneousState: self.InstantaneousState,
            LastAcquisitionStatus: self.LastAcquisitionStatus,
            PropulsionPermitted: self.PropulsionPermitted,
            ReleaseConfirmationCount: self.ReleaseConfirmationCount,
            RawA: self.RawA,
            RawB: self.RawB,
            Difference: self.Difference,
            Sum: self.Sum,
            Kx10000: self.Kx10000,
            SampleSequence: self.SampleSequence,
            CompleteSampleCount: self.CompleteSampleCount,
            AcquisitionErrorCount: self.AcquisitionErrorCount,
            ElectricalErrorCount: self.ElectricalErrorCount,
            StateChangeCount: self.StateChangeCount,
            LastSampleTimestampUs: self.LastSampleTimestampUs,
            LastStepTimestampUs: self.LastStepTimestampUs,
        };

        // A safety consumer may use only the pair produced in its current
        // scheduler release. This rejects a completely omitted producer step
        // immediately; acquisition failures already publish Error from Run.
        let sampleAgeUs = tstmp.saturating_sub(self.LastStepTimestampUs);
        let sampleFresh = self.CompleteSampleCount != 0
            && self.LastAcquisitionStatus == BrkHdlAdcPairStatus::Complete
            && sampleAgeUs <= SAMPLE_STALE_AFTER_US
            && tstmp == self.LastStepTimestampUs;
        if !sampleFresh {
            snapshot.State = BrkHdlState::Error;
            snapshot.InstantaneousState = BrkHdlState::Error;
            snapshot.PropulsionPermitted = false;
            if self.LastAcquisitionStatus == BrkHdlAdcPairStatus::Complete {
                snapshot.LastAcquisitionStatus = BrkHdlAdcPairStatus::Stale;
            }
        }
        snapshot
    }

    pub(crate) fn BrkHdlInterface_ProcessAcquisition(&mut self, tstmp: u64, sample: BrkHdlAdcPair) {
        self.LastStepTimestampUs = tstmp;
        self.BrkHdlInterface_ProcessSample(tstmp, sample);
    }

    pub(crate) fn BrkHdlInterface_ProcessSample(&mut self, tstmp: u64, sample: BrkHdlAdcPair) {
        self.LastAcquisitionStatus = sample.Status;
        if sample.Status != BrkHdlAdcPairStatus::Complete {
            self.BrkHdlInterface_RecordAcquisitionError();
            return;
        }

        let invalidSequence =
            self.CompleteSampleCount != 0 && sample.Sequence != self.SampleSequence.wrapping_add(1);
        let staleTimestamp = tstmp.saturating_sub(sample.CompletionTimestampUs)
            > SAMPLE_STALE_AFTER_US
            || (self.CompleteSampleCount != 0
                && sample.CompletionTimestampUs <= self.LastSampleTimestampUs);
        if invalidSequence || staleTimestamp {
            self.LastAcquisitionStatus = BrkHdlAdcPairStatus::Stale;
            self.BrkHdlInterface_RecordAcquisitionError();
            return;
        }

        self.RawA = sample.RawA;
        self.RawB = sample.RawB;
        self.SampleSequence = sample.Sequence;
        self.LastSampleTimestampUs = sample.CompletionTimestampUs;
        self.CompleteSampleCount = self.CompleteSampleCount.saturating_add(1);

        let instantaneousState = self.BrkHdlInterface_Classify(sample.RawA, sample.RawB);
        self.InstantaneousState = instantaneousState;

        match instantaneousState {
            BrkHdlState::Error => {
                self.ElectricalErrorCount = self.ElectricalErrorCount.saturating_add(1);
                self.ReleaseConfirmationCount = 0;
                self.BrkHdlInterface_SetState(BrkHdlState::Error);
            }
            BrkHdlState::Unpressed => {
                self.ReleaseConfirmationCount = self
                    .ReleaseConfirmationCount
                    .saturating_add(1)
                    .min(RELEASE_CONFIRMATION_SAMPLES);
                if self.ReleaseConfirmationCount >= RELEASE_CONFIRMATION_SAMPLES {
                    self.BrkHdlInterface_SetState(BrkHdlState::Unpressed);
                }
            }
            pressedState => {
                self.ReleaseConfirmationCount = 0;
                self.BrkHdlInterface_SetState(pressedState);
            }
        }
    }

    fn BrkHdlInterface_Classify(&mut self, rawA: u16, rawB: u16) -> BrkHdlState {
        let sum = u32::from(rawA) + u32::from(rawB);
        self.Sum = sum.min(u32::from(u16::MAX)) as u16;

        if rawA <= ADC_RAIL_GUARD_CODES
            || rawB <= ADC_RAIL_GUARD_CODES
            || rawA >= ADC_MAX_CODE - ADC_RAIL_GUARD_CODES
            || rawB >= ADC_MAX_CODE - ADC_RAIL_GUARD_CODES
            || rawA <= rawB
        {
            self.Difference = rawA.saturating_sub(rawB);
            self.Kx10000 = 0;
            return BrkHdlState::Error;
        }

        let difference = u32::from(rawA - rawB);
        self.Difference = difference as u16;
        self.Kx10000 = ((u32::from(rawB) * K_SCALE) + difference / 2) / difference;

        if !(ADC_SUM_MIN..=ADC_SUM_MAX).contains(&sum) || difference < ADC_DIFFERENCE_MIN {
            return BrkHdlState::Error;
        }

        let mut matchedState = BrkHdlState::Error;
        let mut matchCount = 0u8;

        if Self::BrkHdlInterface_RatioInWindow(rawB, difference, UNPRESSED_K_MIN, UNPRESSED_K_MAX) {
            matchedState = BrkHdlState::Unpressed;
            matchCount += 1;
        }
        if Self::BrkHdlInterface_RatioInWindow(rawB, difference, HANDLE_A_K_MIN, HANDLE_A_K_MAX) {
            matchedState = BrkHdlState::A_Pressed;
            matchCount += 1;
        }
        if Self::BrkHdlInterface_RatioInWindow(rawB, difference, HANDLE_B_K_MIN, HANDLE_B_K_MAX) {
            matchedState = BrkHdlState::B_Pressed;
            matchCount += 1;
        }
        if Self::BrkHdlInterface_RatioInWindow(
            rawB,
            difference,
            BOTH_HANDLES_K_MIN,
            BOTH_HANDLES_K_MAX,
        ) {
            matchedState = BrkHdlState::AB_Pressed;
            matchCount += 1;
        }

        if matchCount == 1 {
            matchedState
        } else {
            BrkHdlState::Error
        }
    }

    #[inline]
    fn BrkHdlInterface_RatioInWindow(
        rawB: u16,
        difference: u32,
        minimum: u32,
        maximum: u32,
    ) -> bool {
        let scaledB = u32::from(rawB) * K_SCALE;
        scaledB >= minimum * difference && scaledB <= maximum * difference
    }

    fn BrkHdlInterface_RecordAcquisitionError(&mut self) {
        self.AcquisitionErrorCount = self.AcquisitionErrorCount.saturating_add(1);
        self.InstantaneousState = BrkHdlState::Error;
        self.ReleaseConfirmationCount = 0;
        self.BrkHdlInterface_SetState(BrkHdlState::Error);
    }

    fn BrkHdlInterface_SetState(&mut self, state: BrkHdlState) {
        if self.State != state {
            self.State = state;
            self.StateChangeCount = self.StateChangeCount.saturating_add(1);
        }
        self.PropulsionPermitted = self.State == BrkHdlState::Unpressed;
    }

    #[cfg(all(test, not(target_arch = "arm")))]
    pub(crate) fn BrkHdlInterface_SetDiagnosticCountersForTest(
        &mut self,
        acquisitionErrors: u32,
        electricalErrors: u32,
        stateChanges: u32,
    ) {
        self.AcquisitionErrorCount = acquisitionErrors;
        self.ElectricalErrorCount = electricalErrors;
        self.StateChangeCount = stateChanges;
    }
}
