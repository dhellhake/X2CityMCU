package X2CityComponent_MechanicalBrakeDetection {
    private import X2CityComponent_BrakeSignalMeasurement::*;
    private import X2CityComponent_BrakeStateIdentification::*;
    private import X2CityContract_BrakeSignalMeasurement::*;
    private import X2CityContract_BrakeStateIdentification::*;

    part def MechanicalBrakeDetection { // LE-MECHANICAL-BRAKE
        /* End-to-end logical mechanical-brake detection from the passive coded-brake electrical input boundary to one qualified lever-state composite. It owns no brake-force interpretation, torque mapping, riding authorization, or lighting policy. */
        part signalMeasurement:BrakeSignalMeasurement;
        part stateIdentification:BrakeStateIdentification;
        port brakeElectricalSignalIn:BrakeElectricalSignalInputPort { doc /* Receives the unqualified passive coded-brake electrical signal at the vehicle function boundary. */ }
        port brakeLeverStateOut:BrakeLeverStateOutputPort { doc /* Publishes one State/Qualification composite to Session, Demand, and lighting. */ }
        port brakeHealthOut:BrakeHealthOutputPort { doc /* Publishes the composite Qualification projection to Platform. */ }
        flow electricalSignalToSignalMeasurement from brakeElectricalSignalIn.signal to signalMeasurement.brakeElectricalSignalIn.signal;
        interface measurementToStateIdentification : IfA007BrakeMeasurement
            connect signalMeasurement.brakeMeasurementOut to stateIdentification.brakeMeasurementIn;
        flow stateFromStateIdentification from stateIdentification.brakeLeverStateOut.brakeLeverState to brakeLeverStateOut.brakeLeverState;
        flow healthFromStateIdentification from stateIdentification.brakeHealthOut.qualification to brakeHealthOut.qualification;
    }
}
