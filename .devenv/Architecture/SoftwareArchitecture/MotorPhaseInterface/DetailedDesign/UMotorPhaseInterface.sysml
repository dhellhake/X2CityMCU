package X2CityDetailedUnit_MotorPhaseInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    item def PhaseCurrentFeedbackRecord :> PhaseCurrentEpoch;
    item def PhaseVoltageDiagnosticRecord :> PhaseVoltageDiagnostic;
    item def QualifiedAppliedPhaseVoltageRecord :> QualifiedAppliedPhaseVoltage;
    port def PhaseFeedbackOutputPort {
        doc /* U-MOTOR-PHASE-FAST sends same-aperture qualified phase-current feedback to traction control and actual-output estimation. */
        out item payload:PhaseCurrentFeedbackRecord;
    }
    port def PhaseVoltageDiagnosticOutputPort {
        doc /* U-MOTOR-PHASE-DIAG sends regular-scan phase-voltage diagnostics for policy use; it cannot replace fast current feedback. */
        out item payload:PhaseVoltageDiagnosticRecord;
    }
    port def QualifiedAppliedPhaseVoltageOutputPort {
        doc /* U-MOTOR-PHASE-OBSERVER-VOLTAGE publishes applied-voltage evidence only after the
           distinct source/frame/provenance/timing/error qualification is available. It never
           accepts a regular-scan diagnostic as observer data. */
        out item payload:QualifiedAppliedPhaseVoltageRecord;
    }
    port def AppliedPhaseVoltageEvidenceInputPort {
        doc /* Receives the explicit, as-yet HSI-qualified applied-voltage source. This is not
           the regular DMA diagnostic path. */
        in item payload:AppliedPhaseVoltageEvidence;
    }
    port def InjectedEpochInputPort {
        doc /* U-MOTOR-PHASE-FAST receives the identified JEOS/JDR epoch from fast acquisition and rejects a different operation epoch. */
        in item payload:InjectedEpoch;
    }
    port def AnalogSampleInputPort {
        doc /* U-MOTOR-PHASE-DIAG receives the separate regular-DMA scan for non-fast voltage diagnostics. */
        in item payload:AnalogSampleRecord;
    }
    port def SensorHealthOutputPort {
        doc /* Publishes current-feedback or phase-diagnostic conversion health while leaving Session fault policy to its owner. */
        out item payload:SensorHealthCondition;
    }
    part def FastPhaseCurrentProcessor { attribute compiledCalibrationId:String; attribute compiledCurrentPhaseCalibration:CurrentPhaseCalibration; attribute compiledCalibrationValid:Boolean; port executionTimeIn:ExecutionTimeInputPort; port injectedEpochIn:InjectedEpochInputPort; port phaseFeedbackOut:PhaseFeedbackOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    part def PhaseVoltageDiagnosticProcessor { attribute compiledCalibrationId:String; attribute compiledCurrentPhaseCalibration:CurrentPhaseCalibration; attribute compiledCalibrationValid:Boolean; port executionTimeIn:ExecutionTimeInputPort; port analogSampleIn:AnalogSampleInputPort; port phaseVoltageDiagnosticOut:PhaseVoltageDiagnosticOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    part def ObserverAppliedVoltageProcessor {
        /* Owns only qualification/projection of the explicit applied-winding-voltage boundary.
           It publishes unavailable until source/frame/provenance/timing/bounds are qualified,
           does not select direct sensing versus PWM/bridge reconstruction, and cannot consume
           regular phase-voltage diagnostics. */
        attribute compiledCalibrationId:String;
        attribute compiledCalibrationValid:Boolean;
        port executionTimeIn:ExecutionTimeInputPort;
        port appliedPhaseVoltageEvidenceIn:AppliedPhaseVoltageEvidenceInputPort;
        port qualifiedAppliedPhaseVoltageOut:QualifiedAppliedPhaseVoltageOutputPort;
        port sensorHealthOut:SensorHealthOutputPort;
    }
    // SC-MOTOR-PHASE-IF.V owns calibrated fast current, separate regular diagnostics and an
    // unavailable-until-qualified observer-voltage publication.
}
