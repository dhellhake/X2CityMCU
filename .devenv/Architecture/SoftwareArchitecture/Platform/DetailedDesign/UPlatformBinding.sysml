package X2CityDetailedUnit_PlatformBinding {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    // Owner: SC-PLATFORM.V only; DD-001/DD-003 and Runtime Integration Contract; UR-PLATFORM-BINDING-001.
    // Owns B-PLATFORM-BOOT and B-PLATFORM-IRQ-DISPATCH plus fixed build-time rank/trigger setup; it does not produce ADC data or select calibration.
    port def FastIrqDispatchOutputPort {
        doc /* Sends the selected project JEOS/JDR interrupt dispatch to U-ANALOG-ACQ-FAST; the dispatch is an entry contract, not an ADC result. */
        out item payload:FastIrqDispatch;
    }
    part def PlatformBinding {
        /* Owns selected project resource configuration and interrupt/vector dispatch, including entry to raw fast analog acquisition. It binds generic operations to the vehicle platform and is not a producer of the ADC epoch. */
        attribute compiledConfigurationId:String;
        attribute compiledAcquisitionBinding:RawAcquisitionBindingCalibration;
        attribute compiledConfigurationValid:Boolean; // Startup consistency failure withholds dispatch.
        port executionTimeIn:ExecutionTimeInputPort; port fastIrqDispatchOut:FastIrqDispatchOutputPort; }
}
