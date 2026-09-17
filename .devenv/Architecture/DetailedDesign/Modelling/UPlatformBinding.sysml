package X2CityDetailedUnit_PlatformBinding {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    // Owner: SC-PLATFORM.V only; DD-001/DD-003 and Runtime Integration Contract; UR-PLATFORM-BINDING-001.
    // Owns B-PLATFORM-BOOT and B-PLATFORM-IRQ-DISPATCH plus static rank/trigger setup under the active calibration context; it does not produce ADC data or activate calibration.
    port def FastIrqDispatchOut {
        doc /* Sends the selected project JEOS/JDR interrupt dispatch to U-ANALOG-ACQ-FAST; the dispatch is an entry contract, not an ADC result. */
        out item payload:FastIrqDispatch;
    }
    port def CalibrationIn {
        doc /* Receives the released platform resource, trigger and vector binding needed to configure the selected project route. */
        in item payload:CalibrationBundleRecord;
    }
    part def UPlatformBinding {
        /* Owns selected project resource configuration and interrupt/vector dispatch, including entry to raw fast analog acquisition. It binds generic operations to the vehicle platform and is not a producer of the ADC epoch. */
        port calibrationIn:CalibrationIn; port fastIrqDispatchOut:FastIrqDispatchOut; }
}
