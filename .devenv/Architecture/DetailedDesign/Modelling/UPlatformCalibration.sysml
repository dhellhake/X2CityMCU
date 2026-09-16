package X2CityDetailedUnit_PlatformCalibration {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_PlatformContext::*;
    private import X2CitySoftwareContract_Platform::*;
    item def CalibrationBundleRecord :> PPltCalibrationOInformation;
    port def PlatformContextIn { in item payload:PlatformContextRecord; }
    port def CalibrationBundleOut { out item payload:CalibrationBundleRecord; }
    part def UPlatformCalibration {
        /* Owns immutable calibration-bundle validation, context rollover and disarmed activation.
           It invalidates dependent records before publishing a new bundle; it performs neither
           signal conversion nor output commit. */
        port contextIn:PlatformContextIn;
        port calibrationOut:CalibrationBundleOut;
    }
}
