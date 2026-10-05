package X2CityContract_MotorControl {
    private import X2CitySharedContracts::*;

    item def ActualTractionOutput:>QualifiedInformationRecord;
    item def ElectricalBrakingState:>QualifiedInformationRecord {
        doc /* Traction-owned projection of actual electrical braking at the output boundary. Present includes recuperative braking, rollback retardation, and constant-speed descent control; it does not require net battery charging or a particular requested torque sign. */
        attribute actualElectricalBrakingPresent:Boolean;
    }
    item def QualifiedVehicleMotion:>QualifiedInformationRecord {
        doc /* Traction-owned vehicle motion evidence. Speed is the sole System producer for HMI presentation as well as SettingsPolicy, SessionPolicy and DemandPolicy. */
        attribute vehicleSpeedKilometresPerHour:Real;
        attribute travelDirection:String;
        attribute standstill:Boolean;
    }
    item def RequestedPhaseVoltageVector {
        doc /* Requested physical three-phase voltage vector in volts relative to motor electrical neutral. Common-mode interpretation belongs downstream in the physical stage. It selects no PWM timing, duty encoding, pin, inverter topology or switching realization. */
        attribute phaseAVoltageVolts:Real;
        attribute phaseBVoltageVolts:Real;
        attribute phaseCVoltageVolts:Real;
    }
    item def PhaseExcitationCommand:>QualifiedInformationRecord {
        doc /* Typed requested phase excitation for the physical output stage. The vector requests physical phase voltage; actuationInhibited overrides every requested excitation in both signs. An inhibition is neither a zero torque request nor proof of physical zero torque, isolation, or an unenergized motor. expiry bounds command usability. */
        item requestedPhaseVoltageVector:RequestedPhaseVoltageVector;
        attribute actuationInhibited:Boolean;
        attribute expiry:Expiry;
    }
    enum def PhysicalOutputStageState { enum Unknown; enum Inhibited; enum Energized; enum Deenergized; enum Unavailable; }
    item def ObservedOutputStageState {
        doc /* Observed physical stage state. It is physical evidence only and is never inferred from requested excitation. Its sensing/protection mechanism and switching details remain realization decisions. */
        attribute state:PhysicalOutputStageState;
    }
    item def TractionStageEvidence:>QualifiedInformationRecord {
        doc /* Qualified physical output-stage evidence. It is distinct from PhaseExcitationCommand and does not prove the requested command was applied. */
        item observedOutputStageState:ObservedOutputStageState;
    }
    item def TractionHardwareProtectionEvidence:>QualifiedInformationRecord {
        doc /* Independent hardware protection evidence. Hardware protection can constrain its stage regardless of a software command. */
        attribute hardwareProtectionActive:Boolean;
    }
    enum def TractionConditionCategory { enum TemperatureLimit; enum TemperatureInformation; enum SupplyCondition; enum SupplyInformation; enum OutputStage; enum HardwareProtection; }
    item def TractionConditionEvidence:>QualifiedInformationRecord {
        doc /* Local traction condition/fault evidence for Session. Session owns the common fault latch, selection, priority and restart lifetime. */
        attribute startupTractionConditionsAccepted:Boolean;
        attribute recognizedFault:Boolean;
        attribute actuationInhibited:Boolean;
        attribute conditionCategory:TractionConditionCategory[0..*];
    }
    item def PhysicalMotorActuation {
        doc /* Physical motor-actuation boundary between the traction output stage and motor. It does not claim a particular winding, switching, isolation or torque realization. */
    }

    port def ActualTractionOutputPort { doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy and DemandPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command; MotorControl's electrical-braking projection provides LightControl's dedicated input. */ out item payload:ActualTractionOutput; }
    port def ActualTractionInputPort { doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy and DemandPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command; MotorControl's electrical-braking projection provides LightControl's dedicated input. */ in item payload:ActualTractionOutput; }
    port def ElectricalBrakingStateOutputPort { doc /* Carries Traction's qualified actual electrical-braking present/absent projection. It is derived from actual output-stage evidence, retains that evidence's qualification, and is distinct from a brake-lever request and from battery charging. */ out item payload:ElectricalBrakingState; }
    port def ElectricalBrakingStateInputPort { doc /* Receives Traction's qualified actual electrical-braking present/absent projection. It is derived from actual output-stage evidence, retains that evidence's qualification, and is distinct from a brake-lever request and from battery charging. */ in item payload:ElectricalBrakingState; }
    port def QualifiedVehicleMotionOutputPort { doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy, DemandPolicy and HmiInformationProcessing. This physical-motion qualification is separate from accelerator/brake facts and HMI protocol encoding. */ out item payload:QualifiedVehicleMotion; }
    port def QualifiedVehicleMotionInputPort { doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy, DemandPolicy or HmiInformationProcessing. This physical-motion qualification is separate from accelerator/brake facts and HMI protocol encoding. */ in item payload:QualifiedVehicleMotion; }
    port def PhaseExcitationCommandOutputPort { doc /* Publishes requested phase excitation and overriding inhibition to traction hardware. */ out item payload:PhaseExcitationCommand; }
    port def PhaseExcitationCommandInputPort { doc /* Receives requested phase excitation and overriding inhibition; it does not prove physical output. */ in item payload:PhaseExcitationCommand; }
    port def TractionStageEvidenceOutputPort { doc /* Publishes qualified physical output-stage evidence independently of command. */ out item payload:TractionStageEvidence; }
    port def TractionStageEvidenceInputPort { doc /* Receives qualified physical output-stage evidence independently of command. */ in item payload:TractionStageEvidence; }
    port def TractionHardwareProtectionEvidenceOutputPort { doc /* Publishes independent hardware protection evidence. */ out item payload:TractionHardwareProtectionEvidence; }
    port def TractionHardwareProtectionEvidenceInputPort { doc /* Receives independent hardware protection evidence. */ in item payload:TractionHardwareProtectionEvidence; }
    port def TractionConditionEvidenceOutputPort { doc /* Publishes local traction condition/fault evidence to Session; it does not latch it. */ out item payload:TractionConditionEvidence; }
    port def TractionConditionEvidenceInputPort { doc /* Receives local traction condition/fault evidence for Session policy. */ in item payload:TractionConditionEvidence; }
    port def PhysicalMotorActuationPort { doc /* Physical motor-actuation boundary; bidirectional physical interaction is distinct from command and evidence. */ inout item actuation:PhysicalMotorActuation; }

    interface def IfA005ActualTractionOutput { end producer:ActualTractionOutputPort; end consumer:ActualTractionInputPort; flow producer.payload to consumer.payload; }
    interface def IfA005ElectricalBrakingState { end producer:ElectricalBrakingStateOutputPort; end consumer:ElectricalBrakingStateInputPort; flow producer.payload to consumer.payload; }
    interface def IfA005QualifiedVehicleMotion { end producer:QualifiedVehicleMotionOutputPort; end consumer:QualifiedVehicleMotionInputPort; flow producer.payload to consumer.payload; }
    interface def IfA005PhaseExcitationCommand { end controller:PhaseExcitationCommandOutputPort; end hardware:PhaseExcitationCommandInputPort; flow controller.payload to hardware.payload; }
    interface def IfA005TractionStageEvidence { end hardware:TractionStageEvidenceOutputPort; end controller:TractionStageEvidenceInputPort; flow hardware.payload to controller.payload; }
    interface def IfA005TractionHardwareProtectionEvidence { end hardware:TractionHardwareProtectionEvidenceOutputPort; end controller:TractionHardwareProtectionEvidenceInputPort; flow hardware.payload to controller.payload; }
    interface def IfA005TractionConditionEvidence { end producer:TractionConditionEvidenceOutputPort; end consumer:TractionConditionEvidenceInputPort; flow producer.payload to consumer.payload; }
    interface def IfA005PhysicalMotorActuation { end tractionHardware:PhysicalMotorActuationPort; end motor:PhysicalMotorActuationPort; flow tractionHardware.actuation to motor.actuation; flow motor.actuation to tractionHardware.actuation; }
}

package X2CityComponent_MotorControl {
    private import X2CitySharedContracts::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_TractionControl::*;

    part def MotorControl { // LE-MOTOR-CTRL
        /* Software logical responsibility for controlled traction output. It derives requested phase excitation from authority, demand and qualified feedback. It must inhibit both propulsion and regenerative signs until required startup traction conditions, including GVDD, are qualified and accepted; any recognized fault remains inhibited until a clean restart. Measurement remains active while actuation is disarmed, so startup evidence does not depend on activation. Session owns the common fault latch. */
        port ridingAuthorityIn:RidingAuthorityInputPort { doc /* Session authorization boundary for excitation. */ }
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort { doc /* Signed demand input; a zero request remains distinct from inhibition. */ }
        port motorPositionIn:MotorPositionInputPort { doc /* Qualified electrical position/qualification composite from the estimator. */ }
        port phaseCurrentIn:PhaseCurrentMeasurementsInputPort { doc /* Qualified semantic phase-current feedback from the estimator. */ }
        port temperatureMeasurementIn:TemperatureMeasurementInputPort { doc /* Raw motor/board temperature measurement for local conversion and qualification. */ }
        port supplyVoltageMeasurementIn:SupplyVoltageMeasurementInputPort { doc /* Raw PVDD/GVDD measurement for local conversion and qualification. */ }
        port tractionStageEvidenceIn:TractionStageEvidenceInputPort { doc /* Actual physical-stage evidence, separate from requested excitation. */ }
        port tractionHardwareProtectionEvidenceIn:TractionHardwareProtectionEvidenceInputPort { doc /* Independent hardware-protection evidence. */ }
        port phaseExcitationCommandOut:PhaseExcitationCommandOutputPort { doc /* Requested phase-voltage vector with software inhibition override. */ }
        port tractionConditionEvidenceOut:TractionConditionEvidenceOutputPort { doc /* Local categorized condition/fault evidence for Session; no latch is created here. */ }
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort { doc /* Value-carrying qualified temperature observation. */ }
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort { doc /* Value-carrying qualified PVDD for the existing fast route. */ }
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort { doc /* Qualified physical-motion evidence. */ }
        port actualTractionOutputOut:ActualTractionOutputPort { doc /* Qualified actual output evidence derived from physical-stage evidence. */ }
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort { doc /* Qualified actual electrical-braking projection. */ }
    }
}
