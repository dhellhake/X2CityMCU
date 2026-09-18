package X2CityDetailedUnit_TemperatureInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_TemperatureInterface::*;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::AnalogSampleInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::SensorHealthOutputPort;

    item def TemperatureRecord :> QualifiedTemperature;
    port def TemperatureOutputPort {
        doc /* U-TEMPERATURE-QUALIFY sends the qualified vehicle temperature observation to its thermal and battery-policy consumers. */
        out item payload:TemperatureRecord;
    }
    part def TemperatureQualifier {
        port executionTimeIn:ExecutionTimeInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCalibration:TemperatureCalibration;
        attribute compiledCalibrationValid:Boolean;
        port temperatureOut:TemperatureOutputPort;
        port sensorHealthOut:SensorHealthOutputPort;
    }
    // The owner's fixed build-time set qualifies its named regular scan; configuration provenance is not live state.
}
