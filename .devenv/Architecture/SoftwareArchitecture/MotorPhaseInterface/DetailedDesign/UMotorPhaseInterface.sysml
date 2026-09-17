package X2CityDetailedUnit_MotorPhaseInterface {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def PhaseCurrentFeedbackRecord :> PhaseCurrentEpoch;
    item def PhaseVoltageDiagnosticRecord :> PhaseVoltageDiagnostic;
    port def PhaseFeedbackOutputPort {
        doc /* U-MOTOR-PHASE-FAST sends same-aperture qualified phase-current feedback to traction control and actual-output estimation. */
        out item payload:PhaseCurrentFeedbackRecord;
    }
    port def PhaseVoltageDiagnosticOutputPort {
        doc /* U-MOTOR-PHASE-DIAG sends regular-scan phase-voltage diagnostics for policy and service use; it cannot replace fast current feedback. */
        out item payload:PhaseVoltageDiagnosticRecord;
    }
    port def InjectedEpochInputPort {
        doc /* U-MOTOR-PHASE-FAST receives the identified JEOS/JDR epoch from fast acquisition and rejects a different operation epoch. */
        in item payload:InjectedEpoch;
    }
    port def AnalogSampleInputPort {
        doc /* U-MOTOR-PHASE-DIAG receives the separate regular-DMA scan for non-fast voltage diagnostics. */
        in item payload:AnalogSampleRecord;
    }
    port def CalibrationInputPort {
        doc /* Receives active phase channel, sign, offset, gain and reconstruction calibration for the appropriate fast or diagnostic conversion. */
        in item payload:CalibrationBundleRecord;
    }
    port def SensorHealthOutputPort {
        doc /* Publishes current-feedback or phase-diagnostic conversion health while leaving Session fault policy to its owner. */
        out item payload:SensorHealthCondition;
    }
    part def FastPhaseCurrentProcessor { port injectedEpochIn:InjectedEpochInputPort; port calibrationIn:CalibrationInputPort; port phaseFeedbackOut:PhaseFeedbackOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    part def PhaseVoltageDiagnosticProcessor { port analogSampleIn:AnalogSampleInputPort; port calibrationIn:CalibrationInputPort; port phaseVoltageDiagnosticOut:PhaseVoltageDiagnosticOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    // SC-MOTOR-PHASE-IF.V owns calibrated fast current and separate regular diagnostics.
}
