package X2CityDetailedUnit_TemperatureInterface {
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_TemperatureInterface::*;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::RegularScanInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::CalibrationInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::SensorHealthOutputPort;

    item def TemperatureRecord :> QualifiedTemperatureV1;
    port def TemperatureOutputPort {
        doc /* U-TEMPERATURE-QUALIFY sends the qualified vehicle temperature observation to its thermal and battery-policy consumers. */
        out item payload:TemperatureRecord;
    }
    part def TemperatureQualifier {
        port scanIn:RegularScanInputPort;
        port calibrationIn:CalibrationInputPort;
        port temperatureOut:TemperatureOutputPort;
        port sensorHealthOut:SensorHealthOutputPort;
    }
    // Each owner interprets only its named regular scan under the active calibration/context.
}
