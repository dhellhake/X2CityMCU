package X2CitySoftwareContract_AcceleratorInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    port def RegularAdcScanInputPort {
        doc /* Receives completed regular ADC scan records from AnalogAcquisition. The accelerator interface uses the source rank, sequence, timestamp and active calibration context to produce a semantic position; the inbound record remains raw ADC evidence. */
        in item payload:RegularAdcScan;
    }
    item def AcceleratorPosition:>ContextualSoftwareInformation {
        attribute acceleratorPositionPercent:Real; // percent, 0..100 after qualified scaling.
        attribute acceleratorAtRest:Boolean;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def AcceleratorPositionOutputPort {
        doc /* Publishes the qualified accelerator percentage, rest indication and source provenance to SettingsPolicy, SessionPolicy, DemandPolicy and service aggregation. Consumers must treat the position as unavailable when the source or calibration qualification carried by the record is not valid. */
        out item payload:AcceleratorPosition;
    }
    port def AcceleratorHealthOutputPort {
        doc /* Publishes accelerator-source health evidence to Platform, SessionPolicy and service aggregation. The record identifies the producer condition and evidence context; it is a health observation, not a rider-position command. */
        out item payload:SensorHealthCondition;
    }
}

package X2CitySoftwareComponent_AcceleratorInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-ACCELERATOR-IF.V; semantic rider-position interface.
    part def AcceleratorInterface {
        /* Accepts a completed regular scan and active calibration only in the current context,
           then publishes accelerator position/rest/availability. It owns no DMA storage or rider
           demand decision. */
        port regularAdcScanIn:RegularAdcScanInputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
        port acceleratorHealthOut:AcceleratorHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        port calibrationIn:~CalibrationBundleOutputPort;
    }
}
