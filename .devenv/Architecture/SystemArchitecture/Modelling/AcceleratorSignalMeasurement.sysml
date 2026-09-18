package X2CityContract_AcceleratorSignalMeasurement {
    private import X2CitySharedContracts::*;

    item def AcceleratorElectricalSignal {
        doc /* Unqualified electrical accelerator observation from RiderDevices. The abstract signal has no selected electrical range, transfer characteristic or physical realization. */
        attribute sourceId:String;
        attribute configurationContextId:String;
        attribute electricalSignalValue:Real;
    }
    item def AcceleratorMeasurement {
        doc /* Abstract accelerator measurement evidence. It records the measured value, its source and available measurement-integrity status without selecting a concrete acquisition implementation, schedule or software provenance scheme. The status concerns hardware measurement validity information; it is not semantic position qualification and implies no fault-detection or diagnostic-coverage commitment. */
        attribute sourceId:String;
        attribute configurationContextId:String;
        attribute measuredSignalValue:Real;
        attribute measurementIntegrityStatus:ValidityStatus;
    }
    port def AcceleratorElectricalSignalOutputPort { doc /* Presents RiderDevices' unqualified accelerator electrical observation. */ out item payload:AcceleratorElectricalSignal; }
    port def AcceleratorElectricalSignalInputPort { doc /* Receives RiderDevices' unqualified accelerator electrical observation. */ in item payload:AcceleratorElectricalSignal; }
    port def AcceleratorMeasurementOutputPort { doc /* Publishes adequate abstract accelerator measurement evidence for position processing. */ out item payload:AcceleratorMeasurement; }
    port def AcceleratorMeasurementInputPort { doc /* Receives abstract accelerator measurement evidence for position processing. */ in item payload:AcceleratorMeasurement; }
    interface def IfA001AcceleratorElectricalSignal { end producer:AcceleratorElectricalSignalOutputPort; end consumer:AcceleratorElectricalSignalInputPort; flow producer.payload to consumer.payload; }
    interface def IfA001AcceleratorMeasurement { end producer:AcceleratorMeasurementOutputPort; end consumer:AcceleratorMeasurementInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_AcceleratorSignalMeasurement {
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    part def AcceleratorSignalMeasurement { // LE-ACCELERATOR-HW
        /* Hardware responsibility from the electrical accelerator signal to adequate measurement evidence. It owns the hardware contribution only; position processing includes the relevant later software acquisition and transfer contribution without prescribing its component partition. */
        port electricalSignalIn:AcceleratorElectricalSignalInputPort { doc /* Receives the unqualified rider electrical signal. */ }
        port measurementOut:AcceleratorMeasurementOutputPort { doc /* Provides abstract accelerator measurement evidence. */ }
    }
}
