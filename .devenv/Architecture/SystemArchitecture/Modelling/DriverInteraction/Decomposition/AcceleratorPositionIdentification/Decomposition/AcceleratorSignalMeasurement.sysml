package X2CityContract_AcceleratorSignalMeasurement {
    private import X2CitySharedContracts::*;

    item def AcceleratorElectricalSignal {
        doc /* Unqualified electrical accelerator observation at the vehicle function boundary. Its scalar value does not by itself establish the selected sensor's supply, reference-return, loading, ratiometric treatment, electrical range, transfer characteristic, or physical realization. */
        attribute electricalSignalValue:Real;
    }
    item def AcceleratorMeasurement {
        doc /* Abstract coherent physical accelerator measurement evidence with value and integrity indication. It selects no acquisition implementation, timestamp, reset policy, or semantic position qualification. */
        attribute measuredSignalValue:Real;
        attribute measurementIntegrityStatus:ValidityStatus;
    }
    port def AcceleratorElectricalSignalInputPort { doc /* Receives the unqualified electrical accelerator observation at the vehicle function boundary. */ in item signal:AcceleratorElectricalSignal; }
    port def AcceleratorMeasurementOutputPort { doc /* Publishes coherent completed or unavailable abstract physical measurement evidence for software acquisition and later position processing. */ out item measurement:AcceleratorMeasurement; }
    port def AcceleratorMeasurementInputPort { doc /* Receives abstract physical measurement evidence for semantic position processing. */ in item measurement:AcceleratorMeasurement; }
    interface def IfA001AcceleratorMeasurement { end producer:AcceleratorMeasurementOutputPort; end consumer:AcceleratorMeasurementInputPort; flow producer.measurement to consumer.measurement; }
}

package X2CityComponent_AcceleratorSignalMeasurement {
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    part def AcceleratorSignalMeasurement { // LE-ACCELERATOR-HW
        /* Hardware responsibility from the electrical accelerator signal to coherent observable measurement evidence. It owns no auxiliary supply generation, firmware timestamp, reset-policy, semantic position qualification, or universal diagnostic coverage. Position processing includes the relevant later software acquisition and transfer contribution without prescribing its component partition. */
        port electricalSignalIn:AcceleratorElectricalSignalInputPort { doc /* Receives the unqualified rider electrical signal. */ }
        port measurementOut:AcceleratorMeasurementOutputPort { doc /* Provides abstract accelerator measurement evidence. */ }
    }
}
