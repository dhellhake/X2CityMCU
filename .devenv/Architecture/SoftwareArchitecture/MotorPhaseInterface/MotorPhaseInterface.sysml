package X2CitySoftwareContract_MotorPhaseInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityContract_MotorPositionProcessing::*;
    attribute def CurrentPhaseCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // A and A/ADC-code as applicable.
        attribute phaseAssociation:String;
        attribute currentOffsetAmperes:Real;
        attribute currentGainAmperesPerAdcCode:Real;
        attribute currentPolarity:String;
        attribute referenceCurrentAmperes:Real;
        attribute firstAdcRank:Integer;
        attribute secondAdcRank:Integer;
    }
    port def FastInjectedEpochInputPort {
        doc /* Receives paired raw injected ADC values from AnalogAcquisition for same-aperture phase-current reconstruction. MotorPhaseInterface applies accepted current calibration and plausibility checks before publishing feedback. */
        in item payload:FastInjectedEpoch;
    }
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scans from AnalogAcquisition for slow phase-voltage diagnostics. These scans are not fast FOC current feedback and retain their own acquisition context. */
        in item payload:AnalogSample;
    }
    item def PhaseCurrentEpoch:>ContextualSoftwareInformation, PhaseCurrentMeasurements {
        attribute phaseACurrentAmperes:Real :>> PhaseCurrentMeasurements::phaseACurrentAmperes;
        attribute phaseBCurrentAmperes:Real :>> PhaseCurrentMeasurements::phaseBCurrentAmperes;
        attribute phaseCCurrentAmperes:Real :>> PhaseCurrentMeasurements::phaseCCurrentAmperes;
        attribute reconstructedCurrentAmperes:Real :>> PhaseCurrentMeasurements::reconstructedCurrentAmperes;
        attribute currentPairIdentity:String;
        attribute firstSourceAdcRank:Integer;
        attribute secondSourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute apertureNanoseconds:Real;
        attribute sampleTimeMicroseconds:Integer :>> PhaseCurrentMeasurements::measurementTimeMicroseconds;
        attribute currentWindowAccepted:Boolean;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def PhaseCurrentEpochOutputPort :> PhaseCurrentMeasurementsOutputPort {
        doc /* Publishes the qualified same-aperture three-phase current epoch to TractionControl. The record includes reconstruction, rank, timing and calibration context required by the fast control consumer. */
        out item payload:PhaseCurrentEpoch :>> PhaseCurrentMeasurementsOutputPort::phaseCurrentMeasurements;
    }
    item def PhaseVoltageDiagnostic:>ContextualSoftwareInformation {
        attribute phaseIdentifier:String; // enum: A, B, C or a fitted diagnostic phase.
        attribute phaseVoltageVolts:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def PhaseVoltageDiagnosticOutputPort {
        doc /* Publishes separately qualified phase-voltage diagnostic observations to SessionPolicy. This slow diagnostic output is not used as fast FOC feedback or battery supervision evidence. */
        out item payload:PhaseVoltageDiagnostic;
    }
    item def QualifiedAppliedPhaseVoltage:>ContextualSoftwareInformation {
        // The observer source is deliberately distinct from regular ADC diagnostics.  Until a
        // PWM/output-stage referenced source is qualified this record is unavailable.
        attribute phaseAVolts:Real;
        attribute phaseBVolts:Real;
        attribute phaseCVolts:Real;
        attribute appliedVoltageReferenceFrameId:String;
        attribute appliedVoltageEvidenceTimeMicroseconds:Integer;
        attribute outputStageProvenanceId:String;
        attribute bandwidthBoundMicroseconds:Integer;
        attribute skewBoundMicroseconds:Integer;
        attribute errorBoundVolts:Real;
        attribute sourceAvailable:Boolean;
        attribute configurationContextId:String;
    }
    item def AppliedPhaseVoltageEvidence:>ContextualSoftwareInformation {
        // Acquisition/reconstruction is intentionally an open HSI derivation.  This record is
        // the explicit source boundary and is unavailable until that source is qualified.
        attribute phaseAVolts:Real;
        attribute phaseBVolts:Real;
        attribute phaseCVolts:Real;
        attribute appliedVoltageReferenceFrameId:String;
        attribute appliedVoltageEvidenceTimeMicroseconds:Integer;
        attribute outputStageProvenanceId:String;
        attribute bandwidthBoundMicroseconds:Integer;
        attribute skewBoundMicroseconds:Integer;
        attribute errorBoundVolts:Real;
        attribute sourceAvailable:Boolean;
        attribute configurationContextId:String;
    }
    port def AppliedPhaseVoltageEvidenceInputPort {
        doc /* Receives the distinct applied-voltage evidence boundary. The selected direct
           acquisition or calibrated PWM/output-stage reconstruction remains open HSI work; an
           absent or unqualified source is represented as unavailable. */
        in item payload:AppliedPhaseVoltageEvidence;
    }
    port def QualifiedAppliedPhaseVoltageOutputPort {
        doc /* Publishes observer-quality applied winding-voltage evidence only after its distinct
           source, PWM/output-stage provenance, reference frame, timing/skew/bandwidth and error
           bounds are qualified. It is unavailable until then. PhaseVoltageDiagnostic is never
           converted, renamed or routed through this port. */
        out item payload:QualifiedAppliedPhaseVoltage;
    }
    port def MotorPhaseHealthOutputPort {
        doc /* Publishes phase-current and phase-voltage conversion health evidence to Platform, SessionPolicy and TractionControl. It carries qualification state rather than a phase command. */
        out item payload:SensorHealthCondition;
    }
}

package X2CitySoftwareComponent_MotorPhaseInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-MOTOR-PHASE-IF.V; semantic phase-current and phase-voltage interface.
    part def MotorPhaseInterface {
        /* Owns current scaling, accepted offset/gain/polarity calibration, valid-window checks,
           same-aperture reconstruction and rank plausibility for the fast current epoch. It also
           owns separate slow regular phase-voltage diagnostics and a separately qualified
           observer-voltage contract, which remain different sources. */
        port executionTimeIn:ExecutionTimeInputPort;
        port fastInjectedEpochIn:FastInjectedEpochInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        port appliedPhaseVoltageEvidenceIn:AppliedPhaseVoltageEvidenceInputPort;
        port phaseCurrentEpochOut:PhaseCurrentEpochOutputPort;
        port phaseVoltageDiagnosticOut:PhaseVoltageDiagnosticOutputPort;
        port qualifiedAppliedPhaseVoltageOut:QualifiedAppliedPhaseVoltageOutputPort;
        port motorPhaseHealthOut:MotorPhaseHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCurrentPhaseCalibration:CurrentPhaseCalibration;
        attribute compiledCalibrationValid:Boolean; // Startup check failure withholds affected phase conversion.
        // U-MOTOR-PHASE-FAST and U-MOTOR-PHASE-DIAG have distinct contexts.
    }
}
