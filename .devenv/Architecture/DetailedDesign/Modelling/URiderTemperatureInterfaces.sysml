package X2CityDetailedUnit_RiderTemperatureInterfaces {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_TemperatureInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def AcceleratorPositionRecord :> AcceleratorPositionV1;
    item def BrakeStateRecord :> BrakeStateV1;
    item def TemperatureRecord :> QualifiedTemperatureV1;
    port def RegularScanIn { in item payload:RegularScanV1; }
    port def CalibrationIn { in item payload:CalibrationBundleRecord; }
    port def AcceleratorPositionOut { out item payload:AcceleratorPositionRecord; }
    port def BrakeStateOut { out item payload:BrakeStateRecord; }
    port def TemperatureOut { out item payload:TemperatureRecord; }
    port def SensorHealthOut { out item payload:SensorHealthConditionV1; }
    part def UAcceleratorQualify { port scanIn:RegularScanIn; port calibrationIn:CalibrationIn; port positionOut:AcceleratorPositionOut; port sensorHealthOut:SensorHealthOut; }
    part def UBrakeQualify { port scanIn:RegularScanIn; port calibrationIn:CalibrationIn; port stateOut:BrakeStateOut; port sensorHealthOut:SensorHealthOut; }
    part def UTemperatureQualify { port scanIn:RegularScanIn; port calibrationIn:CalibrationIn; port temperatureOut:TemperatureOut; port sensorHealthOut:SensorHealthOut; }
    // Each owner interprets only its named regular scan under the active calibration/context.
}
