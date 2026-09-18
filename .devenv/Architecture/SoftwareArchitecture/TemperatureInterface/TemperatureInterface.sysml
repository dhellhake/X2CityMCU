package X2CitySoftwareContract_TemperatureInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    attribute def TemperatureCalibration {
        attribute boardTemperatureSourceId:String;
        attribute motorTemperatureSourceId:String;
        attribute engineeringUnit:String; // degC.
        attribute boardTemperatureOffsetCelsius:Real;
        attribute boardTemperatureGainCelsiusPerAdcCode:Real;
        attribute motorTemperatureOffsetCelsius:Real;
        attribute motorTemperatureGainCelsiusPerAdcCode:Real;
        attribute boardAdcRank:Integer;
        attribute motorAdcRank:Integer;
    }
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scans from AnalogAcquisition for configured temperature channels. TemperatureInterface applies accepted board or motor calibration and retains source rank, sequence and timestamp provenance. */
        in item payload:AnalogSample;
    }
    item def QualifiedTemperature:>ContextualSoftwareInformation {
        attribute temperatureSource:String; // enum: board, motor, battery-interface, other fitted channel.
        attribute temperatureCelsius:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def QualifiedTemperatureOutputPort {
        doc /* Publishes qualified temperature observations for the configured traction-board and motor sources to SessionPolicy and BatteryProtection. The output is converted semantic temperature, with source and calibration context retained; battery temperature observations come through BmsLink. */
        out item payload:QualifiedTemperature;
    }
    port def TemperatureHealthOutputPort {
        doc /* Publishes temperature conversion health evidence to Platform and SessionPolicy. It reports source qualification and freshness rather than making a thermal operating decision. */
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
        port executionTimeIn:ExecutionTimeInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort;
        port temperatureHealthOut:TemperatureHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCalibration:TemperatureCalibration;
        attribute compiledCalibrationValid:Boolean; // Startup check failure withholds usable temperature conversion.
    }
}
