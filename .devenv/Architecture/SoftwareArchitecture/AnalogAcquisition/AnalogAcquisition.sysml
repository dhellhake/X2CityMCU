package X2CitySoftwareContract_AnalogAcquisition {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    attribute def RawAcquisitionBindingCalibration {
        attribute sourceId:String;
        attribute regularAdcRank:Integer;
        attribute injectedFirstAdcRank:Integer;
        attribute injectedSecondAdcRank:Integer;
        attribute regularTriggerId:String;
        attribute injectedTriggerId:String;
    }
    item def RawAdcAcquisition:>ContextualSoftwareInformation;
    port def RawAdcAcquisitionInputPort {
        doc /* Receives the vehicle ADC acquisition handoff. This boundary carries acquisition records only; AnalogAcquisition owns the raw regular and injected capture paths and assigns no accelerator, brake, temperature, current, voltage or rotor meaning here. */
        in item payload:RawAdcAcquisition;
    }
    item def AnalogSample:>ContextualSoftwareInformation {
        // Raw DMA scan: channel identity and ADC code, never a semantic sensor value.
        attribute adcSequence:Integer;
        attribute completionTimeMicroseconds:Integer;
        attribute rawRankIndex:Integer;
        attribute rawAdcCode:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def AnalogSampleOutputPort {
        doc /* Publishes completed regular DMA scans to the accelerator, brake, temperature, supply and phase interfaces. Each consumer applies its own channel binding and accepted calibration; the record is never a semantic sensor value. */
        out item payload:AnalogSample;
    }
    item def FastInjectedEpoch:>ContextualSoftwareInformation {
        // JEOS/JDR epoch: the paired raw rank values share the stated aperture.
        attribute adcSequence:Integer;
        attribute acquisitionTimeMicroseconds:Integer;
        attribute apertureNanoseconds:Real;
        attribute currentPairIdentity:String;
        attribute firstRawAdcCode:Integer;
        attribute secondRawAdcCode:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def FastInjectedEpochOutputPort {
        doc /* Publishes the paired raw injected JEOS/JDR epoch to MotorPhaseInterface and SupplyInterface, with the common aperture and acquisition provenance intact. These consumers perform the separate current and DC-link conversions. */
        out item payload:FastInjectedEpoch;
    }
    port def AdcAcquisitionHealthOutputPort {
        doc /* Publishes acquisition-path health evidence to Platform and SessionPolicy. The evidence qualifies capture freshness and integrity; it does not become a sensor measurement. */
        out item payload:SensorHealthCondition;
    }
}

package X2CitySoftwareComponent_AnalogAcquisition {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    part def AnalogAcquisition {
        /* Owns raw regular DMA completion and raw injected JEOS/JDR acquisition only. The regular
           and fast paths have distinct records, state, buffers and producer contexts. It assigns
           no accelerator, brake, temperature, current, voltage or rotor meaning to either record. */
        port executionTimeIn:ExecutionTimeInputPort;
        port rawAdcAcquisitionIn:RawAdcAcquisitionInputPort;
        port analogSampleOut:AnalogSampleOutputPort;
        port fastInjectedEpochOut:FastInjectedEpochOutputPort;
        port adcAcquisitionHealthOut:AdcAcquisitionHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        // Immutable build-time peripheral/rank/trigger setup.  configurationContextId is
        // fixed provenance, never a live calibration rollover or selection mechanism.
        attribute compiledConfigurationId:String;
        attribute compiledAcquisitionBinding:RawAcquisitionBindingCalibration;
        attribute compiledConfigurationValid:Boolean; // Startup check failure withholds affected raw acquisition records.
        // U-ANALOG-ACQ-REGULAR and U-ANALOG-ACQ-FAST are distinct DD owners.
    }
}
