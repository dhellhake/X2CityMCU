package X2CityDetailedUnit_AnalogAcquisition {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def InjectedEpochV1 :> FastInjectedEpochV1;
    item def RegularScanV1 :> RegularAdcScanV1;
    item def FastIrqDispatch :> UnitInformationEnvelope;
    port def InjectedEpochOut { out item payload:InjectedEpochV1; }
    port def RegularScanOut { out item payload:RegularScanV1; }
    port def FastIrqDispatchIn { in item payload:FastIrqDispatch; }
    port def CalibrationIn { in item payload:CalibrationBundleRecord; }
    port def SensorHealthOut { out item payload:SensorHealthConditionV1; }
    part def UAnalogAcqFast { port irqDispatchIn:FastIrqDispatchIn; port calibrationIn:CalibrationIn; port injectedEpochOut:InjectedEpochOut; port sensorHealthOut:SensorHealthOut; }
    part def UAnalogAcqRegular { port calibrationIn:CalibrationIn; port regularScanOut:RegularScanOut; port sensorHealthOut:SensorHealthOut; }
    // SC-ANALOG-ACQ.V: distinct raw JEOS/JDR and regular-DMA records; no semantic conversion.
}
