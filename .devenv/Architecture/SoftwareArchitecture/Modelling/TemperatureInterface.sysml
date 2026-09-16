package X2CitySoftwareContract_TemperatureInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    port def PTempRawI { in item payload:RegularAdcScanV1; }
    item def QualifiedTemperatureV1:>ContextualSoftwareInformation {
        attribute temperatureSource:String; // enum: board, motor, battery-interface, other fitted channel.
        attribute temperatureCelsius:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def PTempQualifiedO { out item payload:QualifiedTemperatureV1; }
    port def PTempHealthO { out item payload:SensorHealthConditionV1; }
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
        port pTempRawI:PTempRawI;
        port pTempQualifiedO:PTempQualifiedO;
        port pTempHealthO:PTempHealthO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
    }
}
