package X2CityDetailedUnit_HallInterface {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def HallCaptureRecord :> PHallCaptureIInformation;
    item def ElectricalPositionV1 :> HallElectricalPositionV1;
    port def HallCaptureOut {
        doc /* U-HALL-CAPTURE sends current sampled Hall state, edges and capture integrity to U-HALL-POSITION; it does not claim mechanical vehicle motion. */
        out item payload:HallCaptureRecord;
    }
    port def ElectricalPositionOut {
        doc /* U-HALL-POSITION sends map/alignment-qualified electrical rotor sector, direction and edge timing to traction consumers. */
        out item payload:ElectricalPositionV1;
    }
    port def HallCaptureIn {
        doc /* U-HALL-POSITION receives U-HALL-CAPTURE's current raw Hall record for map, transition and direction interpretation. */
        in item payload:HallCaptureRecord;
    }
    port def CalibrationIn {
        doc /* U-HALL-POSITION receives the approved Hall truth-table, alignment and map configuration required before it may qualify electrical position. */
        in item payload:CalibrationBundleRecord;
    }
    port def SensorHealthOut {
        doc /* Hall capture and position publish capture, transition or map health so downstream units withhold their dependent result. */
        out item payload:SensorHealthConditionV1;
    }
    part def UHallCapture { port hallCaptureOut:HallCaptureOut; port sensorHealthOut:SensorHealthOut; }
    part def UHallPosition { port hallCaptureIn:HallCaptureIn; port calibrationIn:CalibrationIn; port electricalPositionOut:ElectricalPositionOut; port sensorHealthOut:SensorHealthOut; }
    // SC-HALL-IF.V owns capture integrity through map/alignment/transition/direction/timestamp result.
}
