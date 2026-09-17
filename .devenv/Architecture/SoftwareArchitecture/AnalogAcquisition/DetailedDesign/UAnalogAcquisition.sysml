package X2CityDetailedUnit_AnalogAcquisition {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def InjectedEpoch :> FastInjectedEpoch;
    item def AnalogSampleRecord :> AnalogSample;
    item def FastIrqDispatch :> UnitInformationEnvelope;
    port def InjectedEpochOutputPort {
        doc /* U-ANALOG-ACQ-FAST sends completed timer-triggered JEOS/JDR raw epochs to the fast phase and supply converters; partial or overwritten epochs are withheld. */
        out item payload:InjectedEpoch;
    }
    port def AnalogSampleOutputPort {
        doc /* U-ANALOG-ACQ-REGULAR sends completed regular-DMA raw scans to rider, temperature, phase-diagnostic and regular-supply qualification; it is never a substitute for the fast epoch. */
        out item payload:AnalogSampleRecord;
    }
    port def FastIrqDispatchInputPort {
        doc /* U-ANALOG-ACQ-FAST receives the platform's selected JEOS/JDR interrupt-dispatch record that authorizes its raw fast acquisition entry. */
        in item payload:FastIrqDispatch;
    }
    port def CalibrationInputPort {
        doc /* Both acquisition units receive the active acquisition configuration needed to associate a completed record with its selected channels and context. */
        in item payload:CalibrationBundleRecord;
    }
    port def SensorHealthOutputPort {
        doc /* The acquisition units publish their DMA/JEOS completion, overflow and context health for consumers that must reject affected raw records. */
        out item payload:SensorHealthCondition;
    }
    part def FastAnalogAcquisition { port irqDispatchIn:FastIrqDispatchInputPort; port calibrationIn:CalibrationInputPort; port injectedEpochOut:InjectedEpochOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    part def RegularAnalogAcquisition { port calibrationIn:CalibrationInputPort; port analogSampleOut:AnalogSampleOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    // SC-ANALOG-ACQ.V: distinct raw JEOS/JDR and regular-DMA records; no semantic conversion.
}
