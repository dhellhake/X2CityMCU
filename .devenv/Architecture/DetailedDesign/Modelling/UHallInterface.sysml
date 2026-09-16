package X2CityDetailedUnit_HallInterface {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def HallCaptureRecord :> PHallCaptureIInformation;
    item def ElectricalPositionV1 :> HallElectricalPositionV1;
    port def HallCaptureOut { out item payload:HallCaptureRecord; }
    port def ElectricalPositionOut { out item payload:ElectricalPositionV1; }
    port def HallCaptureIn { in item payload:HallCaptureRecord; }
    port def CalibrationIn { in item payload:CalibrationBundleRecord; }
    port def SensorHealthOut { out item payload:SensorHealthConditionV1; }
    part def UHallCapture { port hallCaptureOut:HallCaptureOut; port sensorHealthOut:SensorHealthOut; }
    part def UHallPosition { port hallCaptureIn:HallCaptureIn; port calibrationIn:CalibrationIn; port electricalPositionOut:ElectricalPositionOut; port sensorHealthOut:SensorHealthOut; }
    // SC-HALL-IF.V owns capture integrity through map/alignment/transition/direction/timestamp result.
}
