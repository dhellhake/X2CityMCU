package X2CitySoftwareContract_TemperatureInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scans from AnalogAcquisition for configured temperature channels. TemperatureInterface applies accepted board or motor calibration and retains source rank, sequence and timestamp provenance. */
        in item payload:AnalogSample;
    }
    item def QualifiedTemperature:>ContextualSoftwareInformation {
        attribute temperatureSource:String; // enum: board, motor, battery-interface, other fitted channel.
        attribute temperatureCelsius:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def QualifiedTemperatureOutputPort {
        doc /* Publishes qualified temperature observations for the configured traction-board and motor sources to SessionPolicy, BatteryProtection and service aggregation. The output is converted semantic temperature, with source and calibration context retained; battery temperature observations come through BmsLink. */
        out item payload:QualifiedTemperature;
    }
    port def TemperatureHealthOutputPort {
        doc /* Publishes temperature conversion health evidence to Platform, SessionPolicy and service aggregation. It reports source qualification and freshness rather than making a thermal operating decision. */
        out item payload:SensorHealthCondition;
    }
}

package X2CitySoftwareComponent_TemperatureInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TemperatureInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-TEMPERATURE-IF.V; semantic temperature interface.
    part def TemperatureInterface {
        /* Converts regular-scan temperature channels under accepted calibration and publishes
           qualified temperature/current health. It owns no thermal operating decision or
           battery restriction. */
        port analogSampleIn:AnalogSampleInputPort;
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort;
        port temperatureHealthOut:TemperatureHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        port calibrationIn:~CalibrationBundleOutputPort;
    }
}
