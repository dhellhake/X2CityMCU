package X2CityContract_BrakeSignalMeasurement {
    private import X2CitySharedContracts::*;

    item def CodedBrakeElectricalSignal {
        doc /* Unqualified passive coded-brake electrical signal at the vehicle function boundary. Its excitation, loading, electrical range, and representation remain open. */
    }
    item def BrakeMeasurement {
        doc /* Coherent abstract physical brake-response evidence with response value and integrity indication. It selects no excitation, circuit, ADC, DMA, timestamp, or diagnostic realization. */
        attribute measuredElectricalResponse:Real;
        attribute measurementIntegrityStatus:ValidityStatus;
    }
    port def BrakeElectricalSignalInputPort { doc /* Receives the unqualified passive coded-brake electrical signal at the vehicle function boundary. */ in item signal:CodedBrakeElectricalSignal; }
    port def BrakeMeasurementOutputPort { doc /* Publishes coherent abstract physical brake-response evidence. */ out item measurement:BrakeMeasurement; }
    port def BrakeMeasurementInputPort { doc /* Receives abstract physical brake-response evidence for state identification. */ in item measurement:BrakeMeasurement; }
    interface def IfA007BrakeMeasurement { end producer:BrakeMeasurementOutputPort; end consumer:BrakeMeasurementInputPort; flow producer.measurement to consumer.measurement; }
}

package X2CityComponent_BrakeSignalMeasurement {
    private import X2CityContract_BrakeSignalMeasurement::*;
    part def BrakeSignalMeasurement { // LE-BRAKE-SIGNAL
        /* Hardware responsibility for physical compatibility, conditioning/protection, and measurement from the coded electrical signal to coherent response evidence. Circuit, excitation, and acquisition selections are deferred to its hardware realization; firmware timestamps, state classification, and semantic qualification belong elsewhere. */
        port brakeElectricalSignalIn:BrakeElectricalSignalInputPort { doc /* Receives the unqualified passive coded-brake electrical signal at the vehicle function boundary. */ }
        port brakeMeasurementOut:BrakeMeasurementOutputPort { doc /* Provides abstract brake-response evidence with integrity. */ }
    }
}
