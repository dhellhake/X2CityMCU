package X2CityDetailedUnit_AnalogAcquisition {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def InjectedEpochV1 :> FastInjectedEpochV1;
    item def RegularScanV1 :> RegularAdcScanV1;
    item def FastIrqDispatch :> UnitInformationEnvelope;
    port def InjectedEpochOut {
        doc /* U-ANALOG-ACQ-FAST sends completed timer-triggered JEOS/JDR raw epochs to the fast phase and supply converters; partial or overwritten epochs are withheld. */
        out item payload:InjectedEpochV1;
    }
    port def RegularScanOut {
        doc /* U-ANALOG-ACQ-REGULAR sends completed regular-DMA raw scans to rider, temperature, phase-diagnostic and regular-supply qualification; it is never a substitute for the fast epoch. */
        out item payload:RegularScanV1;
    }
    port def FastIrqDispatchIn {
        doc /* U-ANALOG-ACQ-FAST receives the platform's selected JEOS/JDR interrupt-dispatch record that authorizes its raw fast acquisition entry. */
        in item payload:FastIrqDispatch;
    }
    port def CalibrationIn {
        doc /* Both acquisition units receive the active acquisition configuration needed to associate a completed record with its selected channels and context. */
        in item payload:CalibrationBundleRecord;
    }
    port def SensorHealthOut {
        doc /* The acquisition units publish their DMA/JEOS completion, overflow and context health for consumers that must reject affected raw records. */
        out item payload:SensorHealthConditionV1;
    }
    part def UAnalogAcqFast { port irqDispatchIn:FastIrqDispatchIn; port calibrationIn:CalibrationIn; port injectedEpochOut:InjectedEpochOut; port sensorHealthOut:SensorHealthOut; }
    part def UAnalogAcqRegular { port calibrationIn:CalibrationIn; port regularScanOut:RegularScanOut; port sensorHealthOut:SensorHealthOut; }
    // SC-ANALOG-ACQ.V: distinct raw JEOS/JDR and regular-DMA records; no semantic conversion.
}
