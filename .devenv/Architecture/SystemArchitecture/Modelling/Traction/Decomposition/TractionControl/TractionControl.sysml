package X2CityContract_TractionControl {
    private import X2CitySharedContracts::*;
    enum def TemperatureSource { enum TractionBoard; enum Motor; }
    enum def SupplyVoltageSource { enum PVDD; enum GVDD; }
    item def PhysicalTemperatureSensorResponse {
        doc /* Physical observed sensor response. Its electrical representation, conditioning and conversion scale remain sensing-realization decisions. */
        attribute source:TemperatureSource;
        attribute responseIntegrityStatus:ValidityStatus;
    }
    item def TemperatureMeasurement {
        doc /* Physical motor or traction-board temperature evidence. It retains the observed sensor response without selecting a sensor circuit or Celsius conversion. */
        attribute source:TemperatureSource;
        item observedSensorResponse:PhysicalTemperatureSensorResponse;
        attribute measurementIntegrityStatus:ValidityStatus;
    }
    item def TemperatureQualification:>QualifiedInformationRecord;
    item def QualifiedTemperature:>TemperatureQualification { attribute source:TemperatureSource; attribute temperatureCelsius:Real; }
    item def SupplyVoltageMeasurement {
        doc /* Physical PVDD or GVDD voltage evidence. Fast PVDD and regular GVDD remain distinct after qualification. */
        attribute source:SupplyVoltageSource;
        attribute voltageVolts:Real;
        attribute measurementIntegrityStatus:ValidityStatus;
    }
    item def SupplyQualification:>QualifiedInformationRecord;
    item def QualifiedSupplyVoltage:>SupplyQualification { attribute source:SupplyVoltageSource; attribute voltageVolts:Real; }
    port def TemperatureMeasurementOutputPort { doc /* Publishes physical motor or traction-board temperature measurement evidence to MotorControl. */ out item measurement:TemperatureMeasurement; }
    port def TemperatureMeasurementInputPort { doc /* Receives physical motor or traction-board temperature measurement evidence for conversion and qualification. */ in item measurement:TemperatureMeasurement; }
    port def QualifiedTemperatureOutputPort { doc /* Publishes value-carrying qualified motor or traction-board temperature observations. */ out item payload:QualifiedTemperature; }
    port def QualifiedTemperatureInputPort { doc /* Receives value-carrying qualified motor or traction-board temperature observations. */ in item payload:QualifiedTemperature; }
    port def SupplyVoltageMeasurementOutputPort { doc /* Publishes physical PVDD/GVDD voltage evidence to MotorControl. */ out item measurement:SupplyVoltageMeasurement; }
    port def SupplyVoltageMeasurementInputPort { doc /* Receives physical PVDD/GVDD voltage evidence for conversion and qualification. */ in item measurement:SupplyVoltageMeasurement; }
    port def FastDcLinkVoltageOutputPort { doc /* Publishes value-carrying qualified PVDD for the fast control route. */ out item payload:QualifiedSupplyVoltage; }
    port def FastDcLinkVoltageInputPort { doc /* Receives value-carrying qualified PVDD for the fast control route. */ in item payload:QualifiedSupplyVoltage; }
    interface def IfA007TemperatureMeasurement { end producer:TemperatureMeasurementOutputPort; end consumer:TemperatureMeasurementInputPort; flow producer.measurement to consumer.measurement; }
    interface def IfA007SupplyVoltageMeasurement { end producer:SupplyVoltageMeasurementOutputPort; end consumer:SupplyVoltageMeasurementInputPort; flow producer.measurement to consumer.measurement; }
    interface def IfA008QualifiedTemperature { end producer:QualifiedTemperatureOutputPort; end consumer:QualifiedTemperatureInputPort; flow producer.payload to consumer.payload; }
    interface def IfA008FastDcLinkVoltage { end producer:FastDcLinkVoltageOutputPort; end consumer:FastDcLinkVoltageInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_TractionControl {
    private import X2CityComponent_MotorControl::*;
    private import X2CityComponent_TractionHardware::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_MotorPositionProcessing::*;

    part def TractionControl { // LE-TRACTION-CONTROL
        /* Logical composite for software motor control and traction hardware. It owns local temperature/supply conversion and qualification with values, delegates energy routing to hardware, and forwards local condition evidence to Session without latching it. */
        part motorControl:MotorControl;
        part tractionHardware:TractionHardware;
        port ridingAuthorityIn:RidingAuthorityInputPort { doc /* Delegated Session authorization. */ }
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort { doc /* Delegated signed wheel-torque demand. */ }
        port motorPositionIn:MotorPositionInputPort { doc /* Qualified electrical rotor position from sibling MotorPositionEstimation. */ }
        port phaseCurrentIn:PhaseCurrentMeasurementsInputPort { doc /* Qualified phase-current feedback from sibling MotorPositionEstimation. */ }
        port tractionElectricalPower:TractionElectricalPowerPort { doc /* Bidirectional traction-energy boundary delegated to TractionHardware. */ }
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort { doc /* Delegated value-carrying qualified temperature. */ }
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort { doc /* Delegated value-carrying qualified PVDD. */ }
        port tractionConditionEvidenceOut:TractionConditionEvidenceOutputPort { doc /* Delegated local condition evidence for Session. */ }
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort { doc /* Delegated qualified physical-motion evidence. */ }
        port actualTractionOutputOut:ActualTractionOutputPort { doc /* Delegated actual output-stage evidence. */ }
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort { doc /* Delegated actual electrical-braking projection. */ }
        port physicalMotorActuation:PhysicalMotorActuationPort { doc /* Physical motor-actuation boundary delegated to TractionHardware. */ }
        flow ridingAuthorityToMotorControl from ridingAuthorityIn.payload to motorControl.ridingAuthorityIn.payload;
        flow wheelTorqueCommandToMotorControl from wheelTorqueCommandIn.payload to motorControl.wheelTorqueCommandIn.payload;
        flow motorPositionToMotorControl from motorPositionIn.motorPosition to motorControl.motorPositionIn.motorPosition;
        flow phaseCurrentToMotorControl from phaseCurrentIn.phaseCurrentMeasurements to motorControl.phaseCurrentIn.phaseCurrentMeasurements;
        interface phaseExcitationToHardware : IfA005PhaseExcitationCommand
            connect motorControl.phaseExcitationCommandOut to tractionHardware.phaseExcitationCommandIn;
        interface stageEvidenceToMotorControl : IfA005TractionStageEvidence
            connect tractionHardware.tractionStageEvidenceOut to motorControl.tractionStageEvidenceIn;
        interface protectionEvidenceToMotorControl : IfA005TractionHardwareProtectionEvidence
            connect tractionHardware.tractionHardwareProtectionEvidenceOut to motorControl.tractionHardwareProtectionEvidenceIn;
        interface energyToHardware : IfA010TractionElectricalPower
            connect tractionElectricalPower to tractionHardware.tractionElectricalPower;
        interface motorActuationBoundary : IfA005PhysicalMotorActuation
            connect tractionHardware.physicalMotorActuation to physicalMotorActuation;
        interface temperatureMeasurementToMotorControl : IfA007TemperatureMeasurement
            connect tractionHardware.temperatureMeasurementOut to motorControl.temperatureMeasurementIn;
        interface supplyMeasurementToMotorControl : IfA007SupplyVoltageMeasurement
            connect tractionHardware.supplyVoltageMeasurementOut to motorControl.supplyVoltageMeasurementIn;
        flow qualifiedTemperatureFromMotorControl from motorControl.qualifiedTemperatureOut.payload to qualifiedTemperatureOut.payload;
        flow fastDcLinkVoltageFromMotorControl from motorControl.fastDcLinkVoltageOut.payload to fastDcLinkVoltageOut.payload;
        flow localConditionFromMotorControl from motorControl.tractionConditionEvidenceOut.payload to tractionConditionEvidenceOut.payload;
        flow qualifiedMotionFromMotorControl from motorControl.qualifiedVehicleMotionOut.payload to qualifiedVehicleMotionOut.payload;
        flow actualOutputFromMotorControl from motorControl.actualTractionOutputOut.payload to actualTractionOutputOut.payload;
        flow electricalBrakingFromMotorControl from motorControl.electricalBrakingStateOut.payload to electricalBrakingStateOut.payload;
    }
}
