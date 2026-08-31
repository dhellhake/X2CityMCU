#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use crate::{
    drv::cortex::Shared,
    mcu::{AcHdlAdcPair, AcHdlAdcPairStatus},
};

const ADC_MAX_CODE: u16 = 4_095;
const ADC_RAIL_GUARD_CODES: u16 = 16;

// Initial development windows. They deliberately contain the first DMM
// observations with margin, but remain provisional until full travel,
// temperature, harness-fault and ADC-error characterization is complete.
const ADC_SUPPLY_MIN: u16 = 1_900;
const ADC_SUPPLY_MAX: u16 = 2_200;
const ADC_SIGNAL_MIN: u16 = 900;
const ADC_SIGNAL_MAX: u16 = 2_600;
const RELEASED_SIGNAL_MAX: u16 = 1_075;

// The 2.00 V specified Hall endpoint, measured 0.982 kOhm series path and
// present development-board reference estimate predict about this code. This
// fixed endpoint is intentionally not learned from ordinary operation.
const POSITION_FULL_SCALE_CODE: u16 = 2_433;
const POSITION_SCALE_PERMILLE: u32 = 1_000;
const SIGNAL_SUPPLY_RATIO_SCALE: u32 = 10_000;
const RELEASE_CONFIRMATION_SAMPLES: u8 = 5;
const SAMPLE_STALE_AFTER_US: u64 = 10_000;

const _: () = {
    assert!(ADC_RAIL_GUARD_CODES < ADC_SIGNAL_MIN);
    assert!(ADC_SIGNAL_MIN < RELEASED_SIGNAL_MAX);
    assert!(RELEASED_SIGNAL_MAX < POSITION_FULL_SCALE_CODE);
    assert!(POSITION_FULL_SCALE_CODE < ADC_SIGNAL_MAX);
    assert!(ADC_SIGNAL_MAX < ADC_MAX_CODE - ADC_RAIL_GUARD_CODES);
    assert!(ADC_SUPPLY_MIN < ADC_SUPPLY_MAX);
    assert!(ADC_SUPPLY_MAX < ADC_MAX_CODE - ADC_RAIL_GUARD_CODES);
};

#[repr(u8)]
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum AcHdlState {
    Released = 0,
    Active = 1,
    Error = 2,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct AcHdlSnapshot {
    pub State: AcHdlState,
    pub InstantaneousState: AcHdlState,
    pub LastAcquisitionStatus: AcHdlAdcPairStatus,
    pub PositionValid: bool,
    pub ReleaseQualified: bool,
    pub ReleaseConfirmationCount: u8,
    pub PositionPermille: u16,
    pub RawSignal: u16,
    pub RawSupply: u16,
    pub RawSignalToSupplySenseRatioX10000: u32,
    pub SampleSequence: u32,
    pub CompleteSampleCount: u32,
    pub AcquisitionErrorCount: u32,
    pub ElectricalErrorCount: u32,
    pub QualificationRejectCount: u32,
    pub StateChangeCount: u32,
    pub LastSampleTimestampUs: u64,
    pub LastStepTimestampUs: u64,
}

#[repr(C)]
pub struct AcHdlInterface {
    State: AcHdlState,
    InstantaneousState: AcHdlState,
    LastAcquisitionStatus: AcHdlAdcPairStatus,
    PositionValid: bool,
    ReleaseQualified: bool,
    ReleaseConfirmationCount: u8,
    PositionPermille: u16,
    RawSignal: u16,
    RawSupply: u16,
    RawSignalToSupplySenseRatioX10000: u32,
    SampleSequence: u32,
    CompleteSampleCount: u32,
    AcquisitionErrorCount: u32,
    ElectricalErrorCount: u32,
    QualificationRejectCount: u32,
    StateChangeCount: u32,
    LastSampleTimestampUs: u64,
    LastStepTimestampUs: u64,
}

/// Single debugger-visible application instance.
#[unsafe(no_mangle)]
static ACHDL: Shared<AcHdlInterface> = Shared::new(AcHdlInterface::new());

#[inline]
pub fn AcHdlInterface_Run(tstmp: u64, sample: AcHdlAdcPair) {
    ACHDL.with(|interface| interface.AcHdlInterface_ProcessAcquisition(tstmp, sample));
}

pub fn AcHdlInterface_GetSnapshot(tstmp: u64) -> AcHdlSnapshot {
    ACHDL.with(|interface| interface.AcHdlInterface_GetSnapshot(tstmp))
}

impl AcHdlInterface {
    pub const fn new() -> Self {
        Self {
            State: AcHdlState::Error,
            InstantaneousState: AcHdlState::Error,
            LastAcquisitionStatus: AcHdlAdcPairStatus::NotInitialized,
            PositionValid: false,
            ReleaseQualified: false,
            ReleaseConfirmationCount: 0,
            PositionPermille: 0,
            RawSignal: 0,
            RawSupply: 0,
            RawSignalToSupplySenseRatioX10000: 0,
            SampleSequence: 0,
            CompleteSampleCount: 0,
            AcquisitionErrorCount: 0,
            ElectricalErrorCount: 0,
            QualificationRejectCount: 0,
            StateChangeCount: 0,
            LastSampleTimestampUs: 0,
            LastStepTimestampUs: 0,
        }
    }

    pub fn AcHdlInterface_GetSnapshot(&self, tstmp: u64) -> AcHdlSnapshot {
        let mut snapshot = AcHdlSnapshot {
            State: self.State,
            InstantaneousState: self.InstantaneousState,
            LastAcquisitionStatus: self.LastAcquisitionStatus,
            PositionValid: self.PositionValid,
            ReleaseQualified: self.ReleaseQualified,
            ReleaseConfirmationCount: self.ReleaseConfirmationCount,
            PositionPermille: self.PositionPermille,
            RawSignal: self.RawSignal,
            RawSupply: self.RawSupply,
            RawSignalToSupplySenseRatioX10000: self.RawSignalToSupplySenseRatioX10000,
            SampleSequence: self.SampleSequence,
            CompleteSampleCount: self.CompleteSampleCount,
            AcquisitionErrorCount: self.AcquisitionErrorCount,
            ElectricalErrorCount: self.ElectricalErrorCount,
            QualificationRejectCount: self.QualificationRejectCount,
            StateChangeCount: self.StateChangeCount,
            LastSampleTimestampUs: self.LastSampleTimestampUs,
            LastStepTimestampUs: self.LastStepTimestampUs,
        };

        // A safety consumer may use only the sample produced in its current
        // scheduler release. Missing producer execution therefore fails
        // independently from the electrical classification.
        let sampleAgeUs = tstmp.saturating_sub(self.LastStepTimestampUs);
        let sampleFresh = self.CompleteSampleCount != 0
            && self.LastAcquisitionStatus == AcHdlAdcPairStatus::Complete
            && sampleAgeUs <= SAMPLE_STALE_AFTER_US
            && tstmp == self.LastStepTimestampUs;
        if !sampleFresh {
            snapshot.State = AcHdlState::Error;
            snapshot.InstantaneousState = AcHdlState::Error;
            snapshot.PositionValid = false;
            snapshot.PositionPermille = 0;
            if self.LastAcquisitionStatus == AcHdlAdcPairStatus::Complete {
                snapshot.LastAcquisitionStatus = AcHdlAdcPairStatus::Stale;
            }
        }
        snapshot
    }

    pub(crate) fn AcHdlInterface_ProcessAcquisition(&mut self, tstmp: u64, sample: AcHdlAdcPair) {
        self.LastStepTimestampUs = tstmp;
        self.AcHdlInterface_ProcessSample(tstmp, sample);
    }

    pub(crate) fn AcHdlInterface_ProcessSample(&mut self, tstmp: u64, sample: AcHdlAdcPair) {
        self.LastAcquisitionStatus = sample.Status;
        if sample.Status != AcHdlAdcPairStatus::Complete {
            self.AcHdlInterface_RecordAcquisitionError();
            return;
        }

        let invalidSequence =
            self.CompleteSampleCount != 0 && sample.Sequence != self.SampleSequence.wrapping_add(1);
        let staleTimestamp = tstmp.saturating_sub(sample.CompletionTimestampUs)
            > SAMPLE_STALE_AFTER_US
            || (self.CompleteSampleCount != 0
                && sample.CompletionTimestampUs <= self.LastSampleTimestampUs);
        if invalidSequence || staleTimestamp {
            self.LastAcquisitionStatus = AcHdlAdcPairStatus::Stale;
            self.AcHdlInterface_RecordAcquisitionError();
            return;
        }

        self.RawSignal = sample.RawSignal;
        self.RawSupply = sample.RawSupply;
        self.SampleSequence = sample.Sequence;
        self.LastSampleTimestampUs = sample.CompletionTimestampUs;
        self.CompleteSampleCount = self.CompleteSampleCount.saturating_add(1);

        let instantaneousState = self.AcHdlInterface_Classify(sample.RawSignal, sample.RawSupply);
        self.InstantaneousState = instantaneousState;

        match instantaneousState {
            AcHdlState::Error => {
                self.ElectricalErrorCount = self.ElectricalErrorCount.saturating_add(1);
                self.AcHdlInterface_Disarm();
            }
            AcHdlState::Released => {
                self.PositionPermille = 0;
                if !self.ReleaseQualified {
                    self.ReleaseConfirmationCount = self
                        .ReleaseConfirmationCount
                        .saturating_add(1)
                        .min(RELEASE_CONFIRMATION_SAMPLES);
                    if self.ReleaseConfirmationCount >= RELEASE_CONFIRMATION_SAMPLES {
                        self.ReleaseQualified = true;
                    }
                }

                if self.ReleaseQualified {
                    self.AcHdlInterface_SetValidState(AcHdlState::Released, 0);
                } else {
                    self.PositionValid = false;
                }
            }
            AcHdlState::Active => {
                self.ReleaseConfirmationCount = 0;
                if self.ReleaseQualified {
                    let position = Self::AcHdlInterface_MapPosition(sample.RawSignal);
                    self.AcHdlInterface_SetValidState(AcHdlState::Active, position);
                } else {
                    self.QualificationRejectCount = self.QualificationRejectCount.saturating_add(1);
                    self.PositionValid = false;
                    self.PositionPermille = 0;
                    self.AcHdlInterface_SetState(AcHdlState::Error);
                }
            }
        }
    }

    fn AcHdlInterface_Classify(&mut self, rawSignal: u16, rawSupply: u16) -> AcHdlState {
        // This is deliberately the ratio of the two ADC codes. The supply
        // channel contains a nominal 1:2 divider, so it is not the physical
        // Hall-output-to-supply ratio and must not be used as one.
        self.RawSignalToSupplySenseRatioX10000 = if rawSupply == 0 {
            0
        } else {
            ((u32::from(rawSignal) * SIGNAL_SUPPLY_RATIO_SCALE) + u32::from(rawSupply) / 2)
                / u32::from(rawSupply)
        };

        if rawSignal <= ADC_RAIL_GUARD_CODES
            || rawSupply <= ADC_RAIL_GUARD_CODES
            || rawSignal >= ADC_MAX_CODE - ADC_RAIL_GUARD_CODES
            || rawSupply >= ADC_MAX_CODE - ADC_RAIL_GUARD_CODES
            || !(ADC_SIGNAL_MIN..=ADC_SIGNAL_MAX).contains(&rawSignal)
            || !(ADC_SUPPLY_MIN..=ADC_SUPPLY_MAX).contains(&rawSupply)
        {
            return AcHdlState::Error;
        }

        if rawSignal <= RELEASED_SIGNAL_MAX {
            AcHdlState::Released
        } else {
            AcHdlState::Active
        }
    }

    #[inline]
    fn AcHdlInterface_MapPosition(rawSignal: u16) -> u16 {
        if rawSignal <= RELEASED_SIGNAL_MAX {
            return 0;
        }
        if rawSignal >= POSITION_FULL_SCALE_CODE {
            return POSITION_SCALE_PERMILLE as u16;
        }

        let numerator = u32::from(rawSignal - RELEASED_SIGNAL_MAX) * POSITION_SCALE_PERMILLE;
        let span = u32::from(POSITION_FULL_SCALE_CODE - RELEASED_SIGNAL_MAX);
        ((numerator + span / 2) / span) as u16
    }

    fn AcHdlInterface_RecordAcquisitionError(&mut self) {
        self.AcquisitionErrorCount = self.AcquisitionErrorCount.saturating_add(1);
        self.InstantaneousState = AcHdlState::Error;
        self.AcHdlInterface_Disarm();
    }

    fn AcHdlInterface_Disarm(&mut self) {
        self.ReleaseQualified = false;
        self.ReleaseConfirmationCount = 0;
        self.PositionValid = false;
        self.PositionPermille = 0;
        self.AcHdlInterface_SetState(AcHdlState::Error);
    }

    fn AcHdlInterface_SetValidState(&mut self, state: AcHdlState, positionPermille: u16) {
        self.PositionValid = true;
        self.PositionPermille = positionPermille;
        self.AcHdlInterface_SetState(state);
    }

    fn AcHdlInterface_SetState(&mut self, state: AcHdlState) {
        if self.State != state {
            self.State = state;
            self.StateChangeCount = self.StateChangeCount.saturating_add(1);
        }
    }

    #[cfg(all(test, not(target_arch = "arm")))]
    pub(crate) fn AcHdlInterface_SetDiagnosticCountersForTest(
        &mut self,
        acquisitionErrors: u32,
        electricalErrors: u32,
        qualificationRejects: u32,
        stateChanges: u32,
    ) {
        self.AcquisitionErrorCount = acquisitionErrors;
        self.ElectricalErrorCount = electricalErrors;
        self.QualificationRejectCount = qualificationRejects;
        self.StateChangeCount = stateChanges;
    }
}
