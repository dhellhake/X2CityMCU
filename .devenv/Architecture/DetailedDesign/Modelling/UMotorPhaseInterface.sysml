package X2CityDetailedUnit_MotorPhaseInterface {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def PhaseFeedbackV1 :> PhaseCurrentEpochV1;
    item def PhaseVoltageDiagnosticRecord :> PhaseVoltageDiagnosticV1;
    port def PhaseFeedbackOut { out item payload:PhaseFeedbackV1; }
    port def PhaseVoltageDiagnosticOut { out item payload:PhaseVoltageDiagnosticRecord; }
    port def InjectedEpochIn { in item payload:InjectedEpochV1; }
    port def RegularScanIn { in item payload:RegularScanV1; }
    port def CalibrationIn { in item payload:CalibrationBundleRecord; }
    port def SensorHealthOut { out item payload:SensorHealthConditionV1; }
    part def UMotorPhaseFast { port injectedEpochIn:InjectedEpochIn; port calibrationIn:CalibrationIn; port phaseFeedbackOut:PhaseFeedbackOut; port sensorHealthOut:SensorHealthOut; }
    part def UMotorPhaseDiag { port regularScanIn:RegularScanIn; port calibrationIn:CalibrationIn; port phaseVoltageDiagnosticOut:PhaseVoltageDiagnosticOut; port sensorHealthOut:SensorHealthOut; }
    // SC-MOTOR-PHASE-IF.V owns calibrated fast current and separate regular diagnostics.
}
