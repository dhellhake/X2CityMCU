package X2CityDetailedUnit_MotorPhaseInterface {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def PhaseFeedbackV1 :> PhaseCurrentEpochV1;
    item def PhaseVoltageDiagnosticRecord :> PhaseVoltageDiagnosticV1;
    port def PhaseFeedbackOut {
        doc /* U-MOTOR-PHASE-FAST sends same-aperture qualified phase-current feedback to traction control and actual-output estimation. */
        out item payload:PhaseFeedbackV1;
    }
    port def PhaseVoltageDiagnosticOut {
        doc /* U-MOTOR-PHASE-DIAG sends regular-scan phase-voltage diagnostics for policy and service use; it cannot replace fast current feedback. */
        out item payload:PhaseVoltageDiagnosticRecord;
    }
    port def InjectedEpochIn {
        doc /* U-MOTOR-PHASE-FAST receives the identified JEOS/JDR epoch from fast acquisition and rejects a different operation epoch. */
        in item payload:InjectedEpochV1;
    }
    port def RegularScanIn {
        doc /* U-MOTOR-PHASE-DIAG receives the separate regular-DMA scan for non-fast voltage diagnostics. */
        in item payload:RegularScanV1;
    }
    port def CalibrationIn {
        doc /* Receives active phase channel, sign, offset, gain and reconstruction calibration for the appropriate fast or diagnostic conversion. */
        in item payload:CalibrationBundleRecord;
    }
    port def SensorHealthOut {
        doc /* Publishes current-feedback or phase-diagnostic conversion health while leaving Session fault policy to its owner. */
        out item payload:SensorHealthConditionV1;
    }
    part def UMotorPhaseFast { port injectedEpochIn:InjectedEpochIn; port calibrationIn:CalibrationIn; port phaseFeedbackOut:PhaseFeedbackOut; port sensorHealthOut:SensorHealthOut; }
    part def UMotorPhaseDiag { port regularScanIn:RegularScanIn; port calibrationIn:CalibrationIn; port phaseVoltageDiagnosticOut:PhaseVoltageDiagnosticOut; port sensorHealthOut:SensorHealthOut; }
    // SC-MOTOR-PHASE-IF.V owns calibrated fast current and separate regular diagnostics.
}
