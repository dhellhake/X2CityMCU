package X2CitySoftwareContract_TractionControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_MotorControl::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CitySoftwareContract_SupplyInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    attribute def ActualOutputEstimationCalibration {
        attribute estimatorId:String;
        attribute motorTorqueConstantNewtonMetresPerAmpere:Real;
        attribute transmissionRatio:Real;
        attribute estimatorResponseBoundMicroseconds:Integer;
        attribute buildValidated:Boolean;
    }
    attribute def MotionEstimationCalibration {
        attribute electricalMapId:String;
        attribute motorPolePairCount:Integer;
        attribute finalDriveRatio:Real;
        attribute loadedWheelCircumferenceMetres:Real;
        attribute standstillObservabilityBoundMicroseconds:Integer;
        attribute buildValidated:Boolean;
    }
    port def RidingAuthorityInputPort :> X2CityContract_SessionPolicy::RidingAuthorityInputPort {
        doc /* Receives SessionPolicy authority generation and its independent validity/expiry context. TractionControl accepts commands only when this authority is current in the common host-boot monotonic microsecond domain. */
        in item payload:RidingAuthority :>> X2CityContract_SessionPolicy::RidingAuthorityInputPort::payload;
    }
    port def WheelTorqueRequestInputPort :> X2CityContract_DemandPolicy::WheelTorqueCommandInputPort {
        doc /* Receives DemandPolicy's requested signed wheel-torque command with authority linkage,
           expiry, and independently dimensioned battery charge/discharge-current bounds. Traction
           uses the amperage bounds as electrical limits; they are not wheel-torque values. */
        in item payload:WheelTorqueRequest :>> X2CityContract_DemandPolicy::WheelTorqueCommandInputPort::payload;
    }
    port def HallElectricalPositionInputPort {
        doc /* Receives complete qualified electrical Hall position from HallInterface for FOC phase alignment and direction. It is electrical position evidence, not a substitute for qualified physical vehicle motion. */
        in item payload:HallElectricalPosition;
    }
    port def PhaseCurrentEpochInputPort {
        doc /* Receives the qualified same-aperture phase-current epoch from MotorPhaseInterface for fast FOC feedback. The current record already carries calibration, rank plausibility and timing qualification. */
        in item payload:PhaseCurrentEpoch;
    }
    port def FastDcLinkVoltageInputPort {
        doc /* Receives qualified fast DC-link voltage from SupplyInterface for fast control scaling and protection. The value is produced from the dedicated injected acquisition path and its fixed compiled configuration provenance. */
        in item payload:FastDcLinkVoltage;
    }
    port def TractionSensorHealthInputPort {
        doc /* Receives qualified source-health evidence from sensor interfaces to gate traction control. Platform's independent FastSafetyState is published separately and is not recreated from this input. */
        in item payload:SensorHealthCondition;
    }
    port def MotionHealthInputPort {
        doc /* Receives Hall capture/position health only for vehicle-motion qualification. It is separate from the broader traction-control health gate and does not add a runtime check or alter the released Hall qualification criteria. */
        in item payload:SensorHealthCondition;
    }
    attribute def CurrentObservationGeneration;
    item def TractionOutputStageExchange:>ContextualSoftwareInformation {
        attribute currentObservationGeneration:CurrentObservationGeneration;
        attribute outputStageObservationAvailable:Boolean;
        attribute outputStageObservationTimeMicroseconds:Integer;
        attribute outputStageState:String;
        attribute outputStageEvidenceSourceId:String;
        attribute outputStageEvidenceConfigurationId:String;
    }
    port def TractionOutputStageExchangePort {
        doc /* Exchanges opaque traction information and physical-stage observation with the vehicle boundary in both directions. The boundary carries actuation-stage state and provenance; it is not a register or pin definition and does not turn a requested torque into actual-torque evidence. */
        inout item payload:TractionOutputStageExchange;
    }
    port def QualifiedMotionOutputPort :> QualifiedVehicleMotionOutputPort {
        doc /* Publishes qualified physical vehicle motion and standstill evidence to SettingsPolicy, SessionPolicy and DemandPolicy. The publication remains live during startup/disarm and reports unavailable until its qualification criteria are met. */
        out item payload:QualifiedMotion :>> QualifiedVehicleMotionOutputPort::payload;
    }
    port def AppliedTractionStateOutputPort :> ActualTractionOutputPort {
        doc /* Publishes qualified observed applied-output evidence, including independently qualified positive torque and powered-forward travel, to DemandPolicy. It is derived from actual output observations and remains separate from the requested command. */
        out item payload:X2CitySharedSoftwareTypes::ActualTractionOutput :>> ActualTractionOutputPort::payload;
    }
    item def TractionObservation:>ContextualSoftwareInformation;
    port def TractionObservationOutputPort {
        doc /* Publishes the traction observation envelope to SessionPolicy. It provides current traction facts for session policy, not a command or actuation channel. */
        out item payload:TractionObservation;
    }
    item def ElectricalBrakingStateRecord:>ContextualSoftwareInformation, ElectricalBrakingState {
        attribute actualOutputObservationTimeMicroseconds:Integer;
        attribute actualOutputObservationGeneration:ContextGeneration;
    }
    port def ElectricalBrakingStateOutputPort :> X2CityContract_MotorControl::ElectricalBrakingStateOutputPort {
        doc /* Publishes Traction-owned actual active motor electrical-braking state, projected from qualified applied-output evidence with its current qualification and observation time. A requested negative torque is not this state. */
        out item payload:ElectricalBrakingStateRecord :>> X2CityContract_MotorControl::ElectricalBrakingStateOutputPort::payload;
    }
}

package X2CitySoftwareComponent_TractionControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityComponent_MotorControl::*;
    part def TractionControl :> X2CityComponent_MotorControl::MotorControl {
        /* Owns fast orchestration, authority/command acceptance, Hall-sensored FOC and the next
           sampling plan. It consumes complete qualified electrical position, current and fast Vdc;
           it performs no sensor conversion. Output alone stages and writes CCR1..4/JSQR. A
           component boundary does not imply a task, queue or delayed fast handoff. Its physical
           output boundary provides physical-stage state/provenance evidence. U-TRACTION-ACTUAL-
           OUTPUT combines it with qualified phase current, electrical position, physical motion
           and compiled estimation calibration before publishing an actual wheel-torque estimate;
           it never turns a requested torque command into actual-torque evidence. */
        port executionTimeIn:ExecutionTimeInputPort;
        port ridingAuthorityIn:RidingAuthorityInputPort :>> MotorControl::ridingAuthorityIn;
        port wheelTorqueRequestIn:WheelTorqueRequestInputPort :>> MotorControl::wheelTorqueCommandIn;
        port hallElectricalPositionIn:HallElectricalPositionInputPort;
        port phaseCurrentEpochIn:PhaseCurrentEpochInputPort;
        port fastDcLinkVoltageIn:FastDcLinkVoltageInputPort;
        port sensorHealthIn:TractionSensorHealthInputPort;
        port motionHealthIn:MotionHealthInputPort;
        port tractionOutputStageExchange:TractionOutputStageExchangePort;
        // Existing Hall/capture-health evidence and calibration may support this interpretation;
        // static or absent Hall edges alone never establish standstill. This publication remains
        // live during startup/disarm, reporting unavailable until validated qualification criteria
        // support it, so a later Ready guard has no circular command dependency.
        port qualifiedMotionOut:QualifiedMotionOutputPort :>> MotorControl::qualifiedVehicleMotionOut;
        port appliedTractionStateOut:AppliedTractionStateOutputPort :>> MotorControl::actualTractionOutputOut;
        port tractionObservationOut:TractionObservationOutputPort;
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort :>> MotorControl::electricalBrakingStateOut;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        // Fixed build-time estimation and motion parameters. The ID is read-only provenance and
        // does not select or activate calibration at runtime.
        attribute compiledCalibrationId:String;
        attribute compiledActualOutputEstimationCalibration:ActualOutputEstimationCalibration;
        attribute compiledMotionEstimationCalibration:MotionEstimationCalibration;
        attribute compiledCalibrationValid:Boolean; // Build/startup validation failure withholds dependent estimate/motion results.
        // JEOS-to-output fast handoffs are Detailed Design-owned unit internals; no public SC
        // fast ports or ARCH-003 routes exist here.
    }
}
