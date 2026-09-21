package X2CityContract_MotorPositionProcessing {
    private import X2CitySharedContracts::*;
    private import X2CityContract_MotorSignalMeasurement::*;

    item def MotorElectricalPosition {
        doc /* The estimate's usable position content. Angle and signed electrical speed have independent availability. */
        attribute electricalAngleRadians:Real[0..1];
        attribute signedElectricalSpeedRadiansPerSecond:Real[0..1];
        attribute electricalSpeedValid:Boolean;
        attribute referenceTimeMicroseconds:Integer;
        attribute acceptedAngleUncertaintyRadians:Real[0..1];
        attribute hallSector:Integer[0..1];
        attribute hallEdgeTimeMicroseconds:Integer[0..1];
    }
    item def MotorPositionQualification:>QualifiedInformationRecord {
        attribute angleAvailable:Boolean;
        attribute hallEvidenceAccepted:Boolean;
        attribute observerAssistanceAccepted:Boolean;
        attribute recognizedRequiredSignalFault:Boolean;
    }
    item def MotorPosition {
        doc /* Single electrical rotor Position/Qualification composite. Qualification controls angle usability; speed validity remains an independent Position member. */
        item Position:MotorElectricalPosition;
        item Qualification:MotorPositionQualification;
    }
    item def PhaseCurrentMeasurements:>QualifiedInformationRecord {
        doc /* Semantic same-epoch phase-current feedback. This preserves the existing MotorPhaseInterface contribution rather than creating another conversion. */
        attribute phaseACurrentAmperes:Real;
        attribute phaseBCurrentAmperes:Real;
        attribute phaseCCurrentAmperes:Real;
        attribute reconstructedCurrentAmperes:Real;
        attribute measurementTimeMicroseconds:Integer;
    }
    port def MotorPositionOutputPort { doc /* Publishes the paired electrical Position and Qualification record to MotorControl. */ out item motorPosition:MotorPosition; }
    port def MotorPositionInputPort { doc /* Receives the paired electrical Position and Qualification record. */ in item motorPosition:MotorPosition; }
    port def PhaseCurrentMeasurementsOutputPort { doc /* Publishes qualified semantic phase-current feedback to MotorControl. */ out item phaseCurrentMeasurements:PhaseCurrentMeasurements; }
    port def PhaseCurrentMeasurementsInputPort { doc /* Receives qualified semantic phase-current feedback. */ in item phaseCurrentMeasurements:PhaseCurrentMeasurements; }
    port def MotorPositionHealthOutputPort { doc /* Publishes the exact Position Qualification projection to existing fault supervision. */ out item health:MotorPositionQualification; }
    port def MotorPositionHealthInputPort { doc /* Receives Position Qualification without manufacturing an angle result. */ in item health:MotorPositionQualification; }
    interface def IfA005MotorPosition { end producer:MotorPositionOutputPort; end consumer:MotorPositionInputPort; flow producer.motorPosition to consumer.motorPosition; }
    interface def IfA005PhaseCurrentMeasurements { end producer:PhaseCurrentMeasurementsOutputPort; end consumer:PhaseCurrentMeasurementsInputPort; flow producer.phaseCurrentMeasurements to consumer.phaseCurrentMeasurements; }
    interface def IfA005MotorPositionHealth { end producer:MotorPositionHealthOutputPort; end consumer:MotorPositionHealthInputPort; flow producer.health to consumer.health; }
    attribute def MotorPositionEstimatorCalibration {
        doc /* Immutable compiled calibration/model set; numerical limits and acceptance values are established later. */
        attribute hallMapId:String;
        attribute motorModelId:String;
    }
}

package X2CityComponent_MotorPositionProcessing {
    private import X2CityContract_MotorSignalMeasurement::*;
    private import X2CityContract_MotorPositionProcessing::*;

    part def MotorPositionProcessing { // LE-MOTOR-POSITION-PROC
        /* Software responsibility for timestamped acquisition, immutable-calibration validation and semantic conversion.
           It uses caller-supplied monotonic ExecutionTime in its software realization, receives no generic System context/service port,
           preserves static Hall-sector startup, and owns neither sensorless fallback, forced alignment, holding nor Session fault policy. */
        attribute estimatorCalibration:MotorPositionEstimatorCalibration;
        port motorSignalMeasurementsIn:MotorSignalMeasurementsInputPort;
        port motorPositionOut:MotorPositionOutputPort;
        port phaseCurrentOut:PhaseCurrentMeasurementsOutputPort;
        port motorPositionHealthOut:MotorPositionHealthOutputPort;
        flow healthProjectionFromPosition from motorPositionOut.motorPosition.Qualification to motorPositionHealthOut.health;
    }
}
