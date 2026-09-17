package X2CityDetailedUnit_PlatformCalibration {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_PlatformContext::*;
    private import X2CitySoftwareContract_Platform::*;
    item def CalibrationBundleRecord :> PPltCalibrationOInformation;
    port def PlatformContextIn {
        doc /* Receives the current platform context that controls calibration activation and invalidates a bundle across a context rollover. */
        in item payload:PlatformContextRecord;
    }
    port def CalibrationBundleOut {
        doc /* Publishes the immutable validated calibration bundle to dependent detailed units only after disarmed activation; missing or rejected data remains unavailable. */
        out item payload:CalibrationBundleRecord;
    }
    part def UPlatformCalibration {
        /* Owns immutable calibration-bundle validation, context rollover and disarmed activation.
           It invalidates dependent records before publishing a new bundle; it performs neither
           signal conversion nor output commit. */
        port contextIn:PlatformContextIn;
        port calibrationOut:CalibrationBundleOut;
    }
}
