package X2CitySoftwareContract_HallInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    item def HallCapture:>ContextualSoftwareInformation {
        attribute capturedHallState:Integer;
        attribute captureChannel:String;
        attribute captureTimestampTicks:Integer;
        attribute captureSequence:Integer;
    }
    port def HallCaptureInputPort {
        doc /* Receives captured Hall channel state, channel identity, timer timestamp and sequence from the vehicle capture boundary. HallInterface validates transitions and capture integrity before deriving electrical position. */
        in item payload:HallCapture;
    }
    item def HallElectricalPosition:>ContextualSoftwareInformation {
        attribute electricalAngleDegrees:Real;
        attribute electricalSector:Integer;
        attribute rotationDirection:String; // enum: forward, reverse, stationary, unavailable.
        attribute captureTimestampTicks:Integer;
        attribute captureSequence:Integer;
        attribute calibrationContextId:String;
    }
    port def HallElectricalPositionOutputPort {
        doc /* Publishes complete qualified electrical angle, sector and direction with capture and calibration provenance to TractionControl and service aggregation. This is electrical position evidence, not qualified physical vehicle motion. */
        out item payload:HallElectricalPosition;
    }
    port def HallHealthOutputPort {
        doc /* Publishes Hall capture and position-estimation health evidence to Platform, SessionPolicy, TractionControl and service aggregation. Overrun, incoherence, age, context or calibration failure is represented through the health qualification. */
        out item payload:SensorHealthCondition;
    }
}

package X2CitySoftwareComponent_HallInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-HALL-IF.V; complete Hall electrical-position interface.
    part def HallInterface {
        /* Owns capture integrity, rings and bounded access; transition acceptance, direction,
           calibration map/alignment and complete qualified electrical position estimation. It
           publishes unavailable on overrun, incoherence, age, context or calibration failure;
           traction performs no partial Hall-to-position conversion. */
        port hallCaptureIn:HallCaptureInputPort;
        port hallElectricalPositionOut:HallElectricalPositionOutputPort;
        port hallHealthOut:HallHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        port calibrationIn:~CalibrationBundleOutputPort;
        // U-HALL-CAPTURE and U-HALL-POSITION retain the direct bounded fast-access path.
    }
}
