package X2CitySoftwareContract_MotorPhaseInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    port def PPhaseFastRawI { in item payload:FastInjectedEpochV1; }
    port def PPhaseRegularRawI { in item payload:RegularAdcScanV1; }
    item def PhaseCurrentEpochV1:>ContextualSoftwareInformation {
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
    port def PPhaseCurrentO { out item payload:PhaseCurrentEpochV1; }
    item def PhaseVoltageDiagnosticV1:>ContextualSoftwareInformation {
        attribute phaseIdentifier:String; // enum: A, B, C or a fitted diagnostic phase.
        attribute phaseVoltageVolts:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def PPhaseVoltageDiagnosticO { out item payload:PhaseVoltageDiagnosticV1; }
    port def PPhaseHealthO { out item payload:SensorHealthConditionV1; }
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
        port pPhaseFastRawI:PPhaseFastRawI;
        port pPhaseRegularRawI:PPhaseRegularRawI;
        port pPhaseCurrentO:PPhaseCurrentO;
        port pPhaseVoltageDiagnosticO:PPhaseVoltageDiagnosticO;
        port pPhaseHealthO:PPhaseHealthO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
        // U-MOTOR-PHASE-FAST and U-MOTOR-PHASE-DIAG have distinct contexts.
    }
}
