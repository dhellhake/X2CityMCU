package X2CitySoftwareContract_AcceleratorInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    attribute def AcceleratorCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // percent.
        attribute minimumPositionPercent:Real;
        attribute maximumPositionPercent:Real;
        attribute restThresholdPercent:Real;
        attribute adcRank:Integer;
    }
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scan records from AnalogAcquisition. The accelerator interface uses the source rank, sequence, timestamp and fixed compiled configuration provenance to produce a semantic position; the inbound record remains raw ADC evidence. */
        in item payload:AnalogSample;
    }
    item def AcceleratorPositionValue {
        attribute acceleratorPositionPercent:Real; // percent, 0..100 after qualified scaling.
        attribute acceleratorAtRest:Boolean;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    item def AcceleratorPositionQualification :> SensorHealthCondition {
        // This is the sole authoritative measurement-status set for Position. Inherited
        // SensorHealthCondition fields preserve current source, reason, severity, health evidence
        // and immediate inhibit request even when Position values are unusable.
        attribute measurementValidity:Validity;
        attribute measurementQualification:Qualification;
    }
    item def AcceleratorPosition:>ContextualSoftwareInformation {
        // The inherited contextual qualification describes this composite publication. Position
        // status is carried only by Qualification, so a current publication can report an
        // unavailable Position (whose values are unusable) without masking source-health evidence.
        // A health-only publication retains the actual Position sample provenance and age; updating
        // this envelope or health evidence never rejuvenates the Position sample.
        item Position:AcceleratorPositionValue;
        item Qualification:AcceleratorPositionQualification;
    }
    port def AcceleratorPositionOutputPort {
        doc /* Publishes one current composite record to SettingsPolicy, SessionPolicy, DemandPolicy and service aggregation. Consumers use Position only when its contained Qualification supports it, and process health evidence even when Position is unavailable. A health-only publication retains Position sample provenance/age and never rejuvenates it. */
        out item payload:AcceleratorPosition;
    }
    port def AcceleratorPositionInputPort {
        doc /* Receives AcceleratorInterface's single position-and-health composite. Consumers use Position only when contained Qualification supports it, while processing Qualification even when Position is unavailable. */
        in item payload:AcceleratorPosition;
    }
    port def AcceleratorQualificationInputPort {
        doc /* Receives the SensorHealthCondition-compatible Qualification projected from AcceleratorPosition for platform health aggregation. */
        in item payload:AcceleratorPositionQualification;
    }
}

package X2CitySoftwareComponent_AcceleratorInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-ACCELERATOR-IF.V; semantic rider-position interface.
    part def AcceleratorInterface {
        /* Accepts a completed regular scan with its fixed compiled calibration in the current context,
           then publishes position/rest plus current measurement and source-health qualification.
           It also publishes unavailability and health when no new ADC sample is available, without
           rejuvenating the prior Position sample. It owns no DMA storage or rider demand
           decision. Its compiled parameter set is immutable; invalid build/startup validation
           withholds the semantic result. */
        port executionTimeIn:ExecutionTimeInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCalibration:AcceleratorCalibration;
        attribute compiledCalibrationValid:Boolean; // Startup check failure withholds position and qualification results.
    }
}
