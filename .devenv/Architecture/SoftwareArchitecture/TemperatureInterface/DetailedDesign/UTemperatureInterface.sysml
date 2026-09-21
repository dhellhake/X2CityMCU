package X2CityDetailedUnit_TemperatureInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_TemperatureInterface::*;
    private import X2CityDetailedUnit_RegularSensorQualification::AnalogSampleInputPort;
    private import X2CityDetailedUnit_RegularSensorQualification::SensorHealthOutputPort;

    item def TemperatureRecord :> QualifiedTemperature;
    port def TemperatureOutputPort {
        doc /* U-TEMPERATURE-QUALIFY sends qualified traction-board and motor temperature observations to its assigned policy consumers. Battery temperature remains a BmsLink observation. */
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
