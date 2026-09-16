package X2CityDetailedUnit_SupplyInterface {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_SupplyInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def FastVdcV1 :> FastDcLinkVoltageV1;
    item def RegularSupplyV1 :> SupplyVoltageV1;
    port def FastVdcOut { out item payload:FastVdcV1; }
    port def RegularSupplyOut { out item payload:RegularSupplyV1; }
    port def InjectedEpochIn { in item payload:InjectedEpochV1; }
    port def RegularScanIn { in item payload:RegularScanV1; }
    port def CalibrationIn { in item payload:CalibrationBundleRecord; }
    port def SensorHealthOut { out item payload:SensorHealthConditionV1; }
    part def USupplyFast { port injectedEpochIn:InjectedEpochIn; port calibrationIn:CalibrationIn; port fastVdcOut:FastVdcOut; port sensorHealthOut:SensorHealthOut; }
    part def USupplyRegular { port regularScanIn:RegularScanIn; port calibrationIn:CalibrationIn; port regularSupplyOut:RegularSupplyOut; port sensorHealthOut:SensorHealthOut; }
    // SC-SUPPLY-IF.V owns rank-2 fast Vdc conversion and non-fast regular supplies separately.
}
