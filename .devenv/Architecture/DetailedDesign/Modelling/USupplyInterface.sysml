package X2CityDetailedUnit_SupplyInterface {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_SupplyInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def FastVdcV1 :> FastDcLinkVoltageV1;
    item def RegularSupplyV1 :> SupplyVoltageV1;
    port def FastVdcOut {
        doc /* U-SUPPLY-FAST sends calibrated current local Vdc derived from the same fast epoch to traction control; regular supply data cannot substitute for it. */
        out item payload:FastVdcV1;
    }
    port def RegularSupplyOut {
        doc /* U-SUPPLY-REGULAR sends slower supply and rail diagnostics to policy and service consumers. */
        out item payload:RegularSupplyV1;
    }
    port def InjectedEpochIn {
        doc /* U-SUPPLY-FAST receives the selected current JEOS/JDR raw epoch from fast acquisition for Vdc conversion. */
        in item payload:InjectedEpochV1;
    }
    port def RegularScanIn {
        doc /* U-SUPPLY-REGULAR receives the distinct completed regular-DMA scan for non-fast supply conversion. */
        in item payload:RegularScanV1;
    }
    port def CalibrationIn {
        doc /* Receives active supply channel scaling, plausibility and configuration data for the corresponding fast or regular conversion. */
        in item payload:CalibrationBundleRecord;
    }
    port def SensorHealthOut {
        doc /* Publishes fast Vdc and regular supply conversion health so consumers can reject the affected electrical observation. */
        out item payload:SensorHealthConditionV1;
    }
    part def USupplyFast { port injectedEpochIn:InjectedEpochIn; port calibrationIn:CalibrationIn; port fastVdcOut:FastVdcOut; port sensorHealthOut:SensorHealthOut; }
    part def USupplyRegular { port regularScanIn:RegularScanIn; port calibrationIn:CalibrationIn; port regularSupplyOut:RegularSupplyOut; port sensorHealthOut:SensorHealthOut; }
    // SC-SUPPLY-IF.V owns rank-2 fast Vdc conversion and non-fast regular supplies separately.
}
