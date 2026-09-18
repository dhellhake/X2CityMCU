package X2CitySoftwareContract_BatteryProtection {
    private import X2CitySharedSoftwareTypes::*;
    // Payload covers BMS observations, input/output/path observations, effective configuration,
    // current local operating context, and validity-tagged retention candidate (reached10% state).
    port def BatteryObservationsAndContextInputPort {
        doc /* Receives the qualified battery and operating context assembled from BMS, path observations, configuration, platform context and retained state. BatteryProtection uses relevant observation age, timeout and validity evidence for independent positive propulsion and negative regeneration decisions. */
        in item payload:ContextualSoftwareInformation;
    }
    // Each sign branch carries its own value, qualification and restriction evidence. Consumers
    // must use the relevant branch, never the aggregate envelope validity, when deciding one sign.
    item def PositivePropulsionCapability:>ContextualSoftwareInformation {
        attribute positivePropulsionPermitted:Boolean;
        attribute maximumPositiveWheelTorqueNewtonMetres:Real;
        attribute maximumForwardSpeedKilometresPerHour:Real;
        attribute restrictionReason:String;
        attribute restrictionEpisodeGeneration:ContextGeneration;
    }
    item def NegativeRegenerationCapability:>ContextualSoftwareInformation {
        attribute negativeRegenerationPermitted:Boolean;
        attribute maximumRegenerativeWheelTorqueMagnitudeNewtonMetres:Real;
        attribute restrictionReason:String;
        attribute restrictionEpisodeGeneration:ContextGeneration;
    }
    item def BatteryCapabilityEnvelope:>ContextualSoftwareInformation {
        attribute capabilityAssessmentTimeMicroseconds:Integer;
        item positivePropulsion:PositivePropulsionCapability;
        item negativeRegeneration:NegativeRegenerationCapability;
        attribute lowSocPropulsionCutoffLatched:Boolean;
        attribute activeRestrictionSummary:String;
        attribute batteryFaultSummary:String;
    }
    port def BatteryCapabilityEnvelopeOutputPort {
        doc /* Publishes separate qualified positive propulsion and negative regeneration capability branches, together with aggregate restriction and battery-fault context, to SessionPolicy, DemandPolicy, HmiAdapter and service aggregation. A restriction on one sign branch does not invalidate or withdraw the other branch. */
        out item payload:BatteryCapabilityEnvelope;
    }
}

package X2CitySoftwareComponent_BatteryProtection {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BatteryProtection::*;
    private import X2CitySoftwareContract_Platform::*;
    part def BatteryProtection {
        /* Derives separate charge and discharge capability envelopes from qualified BMS,
           path, configuration, and operating observations, selecting the most restrictive valid
           limits and publishing an unavailable/invalid result when required inputs are unusable.
           Distinguishes operation-specific restrictions from battery-fault information and owns
           the vehicle reached-10% restriction/recovery above 20% with retained-context validity.
           Supplied BMS hardware remains
           the independent physical protection, while this component owns the software policy role. */
        port executionTimeIn:ExecutionTimeInputPort;
        port batteryObservationsAndContextIn:BatteryObservationsAndContextInputPort;
        port batteryCapabilityEnvelopeOut:BatteryCapabilityEnvelopeOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
