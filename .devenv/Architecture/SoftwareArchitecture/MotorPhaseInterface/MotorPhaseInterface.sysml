package X2CitySoftwareContract_MotorPhaseInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    port def FastInjectedEpochInputPort {
        doc /* Receives paired raw injected ADC values from AnalogAcquisition for same-aperture phase-current reconstruction. MotorPhaseInterface applies accepted current calibration and plausibility checks before publishing feedback. */
        in item payload:FastInjectedEpoch;
    }
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scans from AnalogAcquisition for slow phase-voltage diagnostics. These scans are not fast FOC current feedback and retain their own acquisition context. */
        in item payload:AnalogSample;
    }
    item def PhaseCurrentEpoch:>ContextualSoftwareInformation {
        attribute phaseACurrentAmperes:Real;
        attribute phaseBCurrentAmperes:Real;
        attribute phaseCCurrentAmperes:Real;
        attribute reconstructedCurrentAmperes:Real;
        attribute currentPairIdentity:String;
        attribute firstSourceAdcRank:Integer;
        attribute secondSourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute apertureNanoseconds:Real;
        attribute sampleTimestampTicks:Integer;
        attribute currentWindowAccepted:Boolean;
        attribute calibrationContextId:String;
    }
    port def PhaseCurrentEpochOutputPort {
        doc /* Publishes the qualified same-aperture three-phase current epoch to TractionControl and service aggregation. The record includes reconstruction, rank, timing and calibration context required by the fast control consumer. */
        out item payload:PhaseCurrentEpoch;
    }
    item def PhaseVoltageDiagnostic:>ContextualSoftwareInformation {
        attribute phaseIdentifier:String; // enum: A, B, C or a fitted diagnostic phase.
        attribute phaseVoltageVolts:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def PhaseVoltageDiagnosticOutputPort {
        doc /* Publishes separately qualified phase-voltage diagnostic observations to BatteryProtection and service aggregation. This slow diagnostic output is not used as fast FOC feedback. */
        out item payload:PhaseVoltageDiagnostic;
    }
    port def MotorPhaseHealthOutputPort {
        doc /* Publishes phase-current and phase-voltage conversion health evidence to Platform, SessionPolicy, TractionControl and service aggregation. It carries qualification state rather than a phase command. */
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
           owns separate slow regular phase-voltage diagnostics, which are never fast FOC feedback. */
        port fastInjectedEpochIn:FastInjectedEpochInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        port phaseCurrentEpochOut:PhaseCurrentEpochOutputPort;
        port phaseVoltageDiagnosticOut:PhaseVoltageDiagnosticOutputPort;
        port motorPhaseHealthOut:MotorPhaseHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        port calibrationIn:~CalibrationBundleOutputPort;
        // U-MOTOR-PHASE-FAST and U-MOTOR-PHASE-DIAG have distinct contexts.
    }
}
