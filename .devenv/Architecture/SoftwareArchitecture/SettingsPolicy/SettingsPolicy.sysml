package X2CitySoftwareContract_SettingsPolicy {
    private import X2CitySharedSoftwareTypes::*;
    port def SettingsRequestInputPort {
        doc /* Receives owner-tagged HMI settings requests through the common contextual base type. Accelerator composites use the dedicated acceleratorPositionIn port. */
        in item payload:ContextualSoftwareInformation;
    }
    // The application guard consumes a real qualified physical-motion record. It must not infer
    // standstill from command absence, electrical Hall edge absence, or a retained setting.
    port def QualifiedMotionInputPort {
        doc /* Receives qualified physical motion and standstill evidence from TractionControl for the setting-application guard. The guard must use this record and cannot infer standstill from command absence, Hall edge absence or a retained setting. */
        in item payload:QualifiedMotion;
    }
    item def RidingSettingsState:>ContextualSoftwareInformation {
        attribute requestedLevel:String;
        attribute pendingLevel:String;
        attribute activeLevel:String;
        attribute requestedSpeedLimitKilometresPerHour:Real;
        attribute pendingSpeedLimitKilometresPerHour:Real;
        attribute activeSpeedLimitKilometresPerHour:Real;
    }
    port def RidingSettingsStateOutputPort {
        doc /* Publishes the complete requested, pending and active settings view to SessionPolicy and service aggregation. DemandPolicy does not consume this broad view for torque profiles, preventing a pending request from becoming active demand. */
        out item payload:RidingSettingsState;
    }
    item def ActiveRidingSettings:>ContextualSoftwareInformation {
        attribute activeLevel:String;
        attribute activeSpeedLimitKilometresPerHour:Real;
        attribute activeSettingsGeneration:ContextGeneration;
    }
    port def ActiveRidingSettingsOutputPort {
        doc /* Publishes only the already-applied riding level, speed limit and active-settings generation to DemandPolicy. This projection is the demand input and excludes pending or merely requested settings. */
        out item payload:ActiveRidingSettings;
    }
}

package X2CitySoftwareComponent_SettingsPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorPositionInputPort;
    private import X2CitySoftwareContract_SettingsPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    part def SettingsPolicy {
        /* Validates and retains requested, pending, and active riding settings, publishing the
           applied state for session and demand policy. It preserves owner and qualification context
           across requests without selecting a concrete HMI or actuator implementation. */
        port settingsRequestIn:SettingsRequestInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedMotionIn:QualifiedMotionInputPort;
        port ridingSettingsStateOut:RidingSettingsStateOutputPort;
        port activeRidingSettingsOut:ActiveRidingSettingsOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
