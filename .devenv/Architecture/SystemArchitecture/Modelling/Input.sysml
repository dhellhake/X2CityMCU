package X2CityContract_Input {
    private import X2CitySharedContracts::*;
    enum def TemperatureSource { enum TractionBoard; enum Motor; }
    enum def SupplyVoltageSource { enum PVDD; enum GVDD; }

    item def TemperatureElectricalSignal {
        doc /* Unqualified electrical signal from the named motor or traction-board thermal source. Sensor representation and conditioning remain physical-realization decisions. */
        attribute source:TemperatureSource;
    }
    item def TemperatureMeasurement {
        doc /* Physical temperature-source evidence whose observed representation is intentionally deferred to sensing design. Celsius conversion belongs to qualification. */
        attribute source:TemperatureSource;
        attribute measurementIntegrityStatus:ValidityStatus;
    }
    item def TemperatureQualification:>QualifiedInformationRecord;
    item def QualifiedTemperature:>TemperatureQualification { attribute source:TemperatureSource; attribute temperatureCelsius:Real; }
    item def SupplyElectricalSignal {
        doc /* Unqualified local PVDD or generated GVDD electrical source from TractionHardware. */
        attribute source:SupplyVoltageSource;
    }
    item def SupplyVoltageMeasurement {
        doc /* Physical PVDD or GVDD voltage evidence. Fast PVDD and regular GVDD routes remain distinct after qualification. */
        attribute source:SupplyVoltageSource;
        attribute voltageVolts:Real;
        attribute measurementIntegrityStatus:ValidityStatus;
    }
    item def SupplyQualification:>QualifiedInformationRecord;
    item def QualifiedSupplyVoltage:>SupplyQualification { attribute source:SupplyVoltageSource; attribute voltageVolts:Real; }

    port def TemperatureElectricalSignalOutputPort { doc /* Publishes motor or traction-board thermal electrical source evidence. */ out item signal:TemperatureElectricalSignal; }
    port def TemperatureElectricalSignalInputPort { doc /* Receives a thermal electrical source for measurement. */ in item signal:TemperatureElectricalSignal; }
    port def TemperatureMeasurementOutputPort { doc /* Publishes physical thermal measurement evidence for qualification. */ out item measurement:TemperatureMeasurement; }
    port def TemperatureMeasurementInputPort { doc /* Receives physical thermal measurement evidence. */ in item measurement:TemperatureMeasurement; }
    port def QualifiedTemperatureOutputPort { doc /* Publishes a qualified motor or traction-board temperature to Session. */ out item payload:QualifiedTemperature; }
    port def QualifiedTemperatureInputPort { doc /* Receives a qualified motor or traction-board temperature. */ in item payload:QualifiedTemperature; }
    port def TemperatureHealthOutputPort { doc /* Publishes thermal-observation qualification for supervision. */ out item qualification:TemperatureQualification; }
    port def TemperatureHealthInputPort { doc /* Receives thermal-observation qualification for supervision. */ in item qualification:TemperatureQualification; }
    port def SupplyElectricalSignalOutputPort { doc /* Publishes a local PVDD or generated GVDD electrical source. */ out item signal:SupplyElectricalSignal; }
    port def SupplyElectricalSignalInputPort { doc /* Receives a local PVDD or generated GVDD source for measurement. */ in item signal:SupplyElectricalSignal; }
    port def SupplyVoltageMeasurementOutputPort { doc /* Publishes physical PVDD/GVDD voltage evidence for qualification. */ out item measurement:SupplyVoltageMeasurement; }
    port def SupplyVoltageMeasurementInputPort { doc /* Receives physical PVDD/GVDD voltage evidence. */ in item measurement:SupplyVoltageMeasurement; }
    port def FastDcLinkVoltageOutputPort { doc /* Publishes qualified PVDD for the fast traction route. */ out item payload:QualifiedSupplyVoltage; }
    port def FastDcLinkVoltageInputPort { doc /* Receives qualified PVDD for traction control. */ in item payload:QualifiedSupplyVoltage; }
    port def RegularSupplyVoltageOutputPort { doc /* Publishes qualified GVDD for Session. */ out item payload:QualifiedSupplyVoltage; }
    port def RegularSupplyVoltageInputPort { doc /* Receives qualified GVDD for Session. */ in item payload:QualifiedSupplyVoltage; }
    port def SupplyHealthOutputPort { doc /* Publishes PVDD/GVDD qualification for supervision and traction. */ out item qualification:SupplyQualification; }
    port def SupplyHealthInputPort { doc /* Receives PVDD/GVDD qualification without selecting policy. */ in item qualification:SupplyQualification; }

    interface def IfA007TemperatureElectricalSignal { end producer:TemperatureElectricalSignalOutputPort; end consumer:TemperatureElectricalSignalInputPort; flow producer.signal to consumer.signal; }
    interface def IfA007TemperatureMeasurement { end producer:TemperatureMeasurementOutputPort; end consumer:TemperatureMeasurementInputPort; flow producer.measurement to consumer.measurement; }
    interface def IfA007SupplyElectricalSignal { end producer:SupplyElectricalSignalOutputPort; end consumer:SupplyElectricalSignalInputPort; flow producer.signal to consumer.signal; }
    interface def IfA007SupplyVoltageMeasurement { end producer:SupplyVoltageMeasurementOutputPort; end consumer:SupplyVoltageMeasurementInputPort; flow producer.measurement to consumer.measurement; }
    interface def IfA008QualifiedTemperature { end producer:QualifiedTemperatureOutputPort; end consumer:QualifiedTemperatureInputPort; flow producer.payload to consumer.payload; }
    interface def IfA008TemperatureHealth { end producer:TemperatureHealthOutputPort; end consumer:TemperatureHealthInputPort; flow producer.qualification to consumer.qualification; }
    interface def IfA008FastDcLinkVoltage { end producer:FastDcLinkVoltageOutputPort; end consumer:FastDcLinkVoltageInputPort; flow producer.payload to consumer.payload; }
    interface def IfA008RegularSupplyVoltage { end producer:RegularSupplyVoltageOutputPort; end consumer:RegularSupplyVoltageInputPort; flow producer.payload to consumer.payload; }
    interface def IfA008SupplyHealth { end producer:SupplyHealthOutputPort; end consumer:SupplyHealthInputPort; flow producer.qualification to consumer.qualification; }
}

package X2CityComponent_Input {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RiderDevices::*;
    private import X2CityComponent_InputHardware::*;
    private import X2CityComponent_InputQualification::*;
    private import X2CityComponent_AcceleratorPositionIdentification::*;
    private import X2CityComponent_MechanicalBrakeDetection::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_BrakeSignalMeasurement::*;
    private import X2CityContract_BrakeStateIdentification::*;
    part def Input { // LE-INPUT
        /* Composes rider devices, temperature/supply measurement and qualification, and the accelerator and mechanical-brake functions.
           Battery read/qualification belongs to BatterySupervision; Traction owns motion and its physical temperature/PVDD/GVDD sources. */
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part accelerator:AcceleratorPositionIdentification;
        part mechanicalBrakeDetection:MechanicalBrakeDetection;
        port brakeLeverStateOut:BrakeLeverStateOutputPort;
        port brakeHealthOut:BrakeHealthOutputPort;
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort;
        port temperatureHealthOut:TemperatureHealthOutputPort;
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort;
        port regularSupplyVoltageOut:RegularSupplyVoltageOutputPort;
        port supplyHealthOut:SupplyHealthOutputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
        port acceleratorHealthOut:AcceleratorHealthOutputPort;
        flow brakeLeverStateFromFunction from mechanicalBrakeDetection.brakeLeverStateOut.brakeLeverState to brakeLeverStateOut.brakeLeverState;
        flow brakeHealthFromFunction from mechanicalBrakeDetection.brakeHealthOut.qualification to brakeHealthOut.qualification;
        flow qualifiedTemperatureFromInputQualification from inputQualification.qualifiedTemperatureOut.payload to qualifiedTemperatureOut.payload;
        flow temperatureHealthFromInputQualification from inputQualification.temperatureHealthOut.qualification to temperatureHealthOut.qualification;
        flow fastDcLinkVoltageFromInputQualification from inputQualification.fastDcLinkVoltageOut.payload to fastDcLinkVoltageOut.payload;
        flow regularSupplyVoltageFromInputQualification from inputQualification.regularSupplyVoltageOut.payload to regularSupplyVoltageOut.payload;
        flow supplyHealthFromInputQualification from inputQualification.supplyHealthOut.qualification to supplyHealthOut.qualification;
        flow acceleratorPositionFromFunction from accelerator.acceleratorPositionOut.acceleratorPosition to acceleratorPositionOut.acceleratorPosition;
        flow acceleratorHealthFromFunction from accelerator.acceleratorHealthOut.qualification to acceleratorHealthOut.qualification;
        flow riderElectricalToAccelerator from riderDevices.acceleratorElectricalSignalOut.signal to accelerator.electricalSignalIn.signal;
        interface brakeElectricalSignalToDetection : IfA007BrakeElectricalSignal
            connect riderDevices.brakeElectricalSignalOut to mechanicalBrakeDetection.brakeElectricalSignalIn;
        interface temperatureMeasurementToQualification : IfA007TemperatureMeasurement
            connect inputHardware.temperatureMeasurementOut to inputQualification.temperatureMeasurementIn;
        interface supplyMeasurementToQualification : IfA007SupplyVoltageMeasurement
            connect inputHardware.supplyVoltageMeasurementOut to inputQualification.supplyVoltageMeasurementIn;
    }
}
