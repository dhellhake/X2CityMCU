package X2CityContract_Input {
    private import X2CitySharedContracts::*;
    enum def BrakeLeverState { enum Neither; enum Left; enum Right; enum Both; }
    enum def TemperatureSource { enum TractionBoard; enum Motor; }
    enum def SupplyVoltageSource { enum PVDD; enum GVDD; }

    item def CodedBrakeElectricalSignal {
        doc /* Unqualified two-wire brake electrical signal from RiderDevices. Its excitation, loading and electrical representation remain open. */
    }
    item def CodedBrakeMeasurement {
        doc /* Physical coded-brake measurement evidence whose observed representation is intentionally deferred to sensing design. Conversion to resistance and four-state classification belong to qualification; no excitation, threshold, timing or diagnostic realization is selected. */
        attribute measurementIntegrityStatus:ValidityStatus;
    }
    item def BrakeQualification:>QualifiedInformationRecord;
    item def QualifiedBrakeInput:>BrakeQualification {
        doc /* Qualified mechanical lever identity. `brakeLeverActuated` is an exact projection: true for Left, Right or Both, false only for Neither. Unknown or unavailable remains in Qualification and never projects as released. */
        attribute brakeLeverState:BrakeLeverState;
        attribute brakeLeverActuated:Boolean;
    }
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

    port def CodedBrakeElectricalSignalOutputPort { doc /* Publishes the unqualified coded-brake electrical source. */ out item signal:CodedBrakeElectricalSignal; }
    port def CodedBrakeElectricalSignalInputPort { doc /* Receives the unqualified coded-brake electrical source for measurement. */ in item signal:CodedBrakeElectricalSignal; }
    port def CodedBrakeMeasurementOutputPort { doc /* Publishes physical coded-brake measurement evidence for qualification. */ out item measurement:CodedBrakeMeasurement; }
    port def CodedBrakeMeasurementInputPort { doc /* Receives physical coded-brake measurement evidence. */ in item measurement:CodedBrakeMeasurement; }
    port def BrakeStateOutputPort {
        doc /* Carries InputQualification's qualified four-state mechanical lever identity to policy consumers. */
        out item payload:QualifiedBrakeInput;
    }
    port def BrakeStateInputPort {
        doc /* Receives InputQualification's qualified four-state mechanical lever identity. */
        in item payload:QualifiedBrakeInput;
    }
    port def BrakeHealthOutputPort { doc /* Publishes qualified brake-observation health without changing lever identity. */ out item qualification:BrakeQualification; }
    port def BrakeHealthInputPort { doc /* Receives brake-observation health for supervision. */ in item qualification:BrakeQualification; }
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

    interface def IfA001QualifiedBrakeInput { end producer:BrakeStateOutputPort; end consumer:BrakeStateInputPort; flow producer.payload to consumer.payload; }
    interface def IfA007CodedBrakeElectricalSignal { end producer:CodedBrakeElectricalSignalOutputPort; end consumer:CodedBrakeElectricalSignalInputPort; flow producer.signal to consumer.signal; }
    interface def IfA007CodedBrakeMeasurement { end producer:CodedBrakeMeasurementOutputPort; end consumer:CodedBrakeMeasurementInputPort; flow producer.measurement to consumer.measurement; }
    interface def IfA007TemperatureElectricalSignal { end producer:TemperatureElectricalSignalOutputPort; end consumer:TemperatureElectricalSignalInputPort; flow producer.signal to consumer.signal; }
    interface def IfA007TemperatureMeasurement { end producer:TemperatureMeasurementOutputPort; end consumer:TemperatureMeasurementInputPort; flow producer.measurement to consumer.measurement; }
    interface def IfA007SupplyElectricalSignal { end producer:SupplyElectricalSignalOutputPort; end consumer:SupplyElectricalSignalInputPort; flow producer.signal to consumer.signal; }
    interface def IfA007SupplyVoltageMeasurement { end producer:SupplyVoltageMeasurementOutputPort; end consumer:SupplyVoltageMeasurementInputPort; flow producer.measurement to consumer.measurement; }
    interface def IfA008BrakeHealth { end producer:BrakeHealthOutputPort; end consumer:BrakeHealthInputPort; flow producer.qualification to consumer.qualification; }
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
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_Input::*;
    part def Input { // LE-INPUT
        /* Composes rider devices, non-accelerator measurement/qualification and the accelerator function.
           Battery read/qualification belongs to BatterySupervision; Traction owns motion and its physical temperature/PVDD/GVDD sources. */
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part accelerator:AcceleratorPositionIdentification;
        port qualifiedBrakeInputOut:BrakeStateOutputPort;
        port brakeHealthOut:BrakeHealthOutputPort;
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort;
        port temperatureHealthOut:TemperatureHealthOutputPort;
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort;
        port regularSupplyVoltageOut:RegularSupplyVoltageOutputPort;
        port supplyHealthOut:SupplyHealthOutputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
        port acceleratorHealthOut:AcceleratorHealthOutputPort;
        flow qualifiedBrakeFromInputQualification from inputQualification.brakeLeverStateOut.payload to qualifiedBrakeInputOut.payload;
        flow brakeHealthFromInputQualification from inputQualification.brakeHealthOut.qualification to brakeHealthOut.qualification;
        flow qualifiedTemperatureFromInputQualification from inputQualification.qualifiedTemperatureOut.payload to qualifiedTemperatureOut.payload;
        flow temperatureHealthFromInputQualification from inputQualification.temperatureHealthOut.qualification to temperatureHealthOut.qualification;
        flow fastDcLinkVoltageFromInputQualification from inputQualification.fastDcLinkVoltageOut.payload to fastDcLinkVoltageOut.payload;
        flow regularSupplyVoltageFromInputQualification from inputQualification.regularSupplyVoltageOut.payload to regularSupplyVoltageOut.payload;
        flow supplyHealthFromInputQualification from inputQualification.supplyHealthOut.qualification to supplyHealthOut.qualification;
        flow acceleratorPositionFromFunction from accelerator.acceleratorPositionOut.acceleratorPosition to acceleratorPositionOut.acceleratorPosition;
        flow acceleratorHealthFromFunction from accelerator.acceleratorHealthOut.qualification to acceleratorHealthOut.qualification;
        flow riderElectricalToAccelerator from riderDevices.acceleratorElectricalSignalOut.signal to accelerator.electricalSignalIn.signal;
        interface codedBrakeToMeasurement : IfA007CodedBrakeElectricalSignal
            connect riderDevices.codedBrakeElectricalSignalOut to inputHardware.codedBrakeElectricalSignalIn;
        interface codedBrakeMeasurementToQualification : IfA007CodedBrakeMeasurement
            connect inputHardware.codedBrakeMeasurementOut to inputQualification.codedBrakeMeasurementIn;
        interface temperatureMeasurementToQualification : IfA007TemperatureMeasurement
            connect inputHardware.temperatureMeasurementOut to inputQualification.temperatureMeasurementIn;
        interface supplyMeasurementToQualification : IfA007SupplyVoltageMeasurement
            connect inputHardware.supplyVoltageMeasurementOut to inputQualification.supplyVoltageMeasurementIn;
    }
}
