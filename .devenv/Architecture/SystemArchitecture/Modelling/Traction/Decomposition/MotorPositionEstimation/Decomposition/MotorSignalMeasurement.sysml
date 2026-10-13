package X2CityContract_MotorSignalMeasurement {
    private import X2CitySharedContracts::*;

    item def HallSignals {
        doc /* Raw physical Hall electrical levels. They are not capture evidence, electrical angle, speed, motor map or semantic motion result. */
        attribute hallALevel:Boolean;
        attribute hallBLevel:Boolean;
        attribute hallCLevel:Boolean;
    }
    item def BridgeVoltageObservation {
        doc /* Raw physical winding-voltage or bridge-state observation. Software derives any qualified applied-winding-voltage evidence; this item is not a slow diagnostic voltage scan. */
        attribute phaseAVolts:Real;
        attribute phaseBVolts:Real;
        attribute phaseCVolts:Real;
        attribute observationReference:Integer;
        attribute observationIntegrityStatus:ValidityStatus;
    }
    item def MotorPhaseElectrical {
        doc /* Raw physical phase electrical quantities. Values remain physical until the software leaf establishes timing, semantic conversion and acceptance. */
        attribute phaseACurrentAmperes:Real;
        attribute phaseBCurrentAmperes:Real;
        attribute phaseCCurrentAmperes:Real;
        item bridgeVoltageObservation:BridgeVoltageObservation;
    }
    item def MotorSignalMeasurements {
        doc /* Physical signal measurement evidence. Capture references and integrity preserve physical evidence; software maps them into its host-monotonic timestamp/context and performs semantic conversion. */
        attribute capturedHallState:Integer;
        attribute hallCaptureReference:Integer;
        attribute hallCaptureIntegrityStatus:ValidityStatus;
        attribute phaseACurrentAmperes:Real;
        attribute phaseBCurrentAmperes:Real;
        attribute phaseCCurrentAmperes:Real;
        attribute currentCaptureReference:Integer;
        attribute currentWindowStatus:ValidityStatus;
        item bridgeVoltageObservation:BridgeVoltageObservation;
    }
    port def HallSignalsOutputPort { doc /* Presents raw physical Hall electrical levels from the direct Traction boundary. */ out item hallSignals:HallSignals; }
    port def HallSignalsInputPort { doc /* Receives raw physical Hall electrical levels for measurement. */ in item hallSignals:HallSignals; }
    port def MotorPhaseElectricalOutputPort { doc /* Presents raw physical phase-current and bridge-voltage quantities from the direct Traction boundary. */ out item motorPhaseElectrical:MotorPhaseElectrical; }
    port def MotorPhaseElectricalInputPort { doc /* Receives raw physical phase-current and bridge-voltage quantities for measurement. */ in item motorPhaseElectrical:MotorPhaseElectrical; }
    port def MotorSignalMeasurementsOutputPort { doc /* Publishes physical Hall/current/bridge measurement and capture evidence to software processing. */ out item motorSignalMeasurements:MotorSignalMeasurements; }
    port def MotorSignalMeasurementsInputPort { doc /* Receives physical Hall/current/bridge measurement and capture evidence for software processing. */ in item motorSignalMeasurements:MotorSignalMeasurements; }
    interface def IfA005MotorSignalMeasurements { end producer:MotorSignalMeasurementsOutputPort; end consumer:MotorSignalMeasurementsInputPort; flow producer.motorSignalMeasurements to consumer.motorSignalMeasurements; }
}

package X2CityComponent_MotorSignalMeasurement {
    private import X2CityContract_MotorSignalMeasurement::*;

    part def MotorSignalMeasurement { // LE-MOTOR-SIGNAL
        /* Hardware responsibility from physical Hall/current/applied-winding-voltage sources to observable evidence.
           It has no firmware timestamp/reset policy, electrical-angle estimation, semantic phase-current conversion,
           torque command or observer acceptance decision. */
        port hallSignalsIn:HallSignalsInputPort;
        port motorPhaseElectricalIn:MotorPhaseElectricalInputPort;
        port motorSignalMeasurementsOut:MotorSignalMeasurementsOutputPort;
    }
}
