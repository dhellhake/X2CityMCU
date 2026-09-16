package X2CitySoftwareContract_HallInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    item def PHallCaptureIInformation:>ContextualSoftwareInformation {
        attribute capturedHallState:Integer;
        attribute captureChannel:String;
        attribute captureTimestampTicks:Integer;
        attribute captureSequence:Integer;
    }
    port def PHallCaptureI { in item payload:PHallCaptureIInformation; }
    item def HallElectricalPositionV1:>ContextualSoftwareInformation {
        attribute electricalAngleDegrees:Real;
        attribute electricalSector:Integer;
        attribute rotationDirection:String; // enum: forward, reverse, stationary, unavailable.
        attribute captureTimestampTicks:Integer;
        attribute captureSequence:Integer;
        attribute calibrationContextId:String;
    }
    port def PHallPositionO { out item payload:HallElectricalPositionV1; }
    port def PHallHealthO { out item payload:SensorHealthConditionV1; }
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
        port pHallCaptureI:PHallCaptureI;
        port pHallPositionO:PHallPositionO;
        port pHallHealthO:PHallHealthO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
        // U-HALL-CAPTURE and U-HALL-POSITION retain the direct bounded fast-access path.
    }
}
