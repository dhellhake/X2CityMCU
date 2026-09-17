package X2CitySoftwareContract_SettingsPolicy {
    private import X2CitySharedSoftwareTypes::*;
    port def PSetRequestI {
        doc /* Receives owner-tagged qualified settings requests, including HMI requests and accelerator position information, through the common contextual base type. SettingsPolicy validates and retains requested, pending and active state before publishing either view. */
        in item payload:ContextualSoftwareInformation;
    }
    // The application guard consumes a real qualified physical-motion record. It must not infer
    // standstill from command absence, electrical Hall edge absence, or a retained setting.
    port def PSetMotionI {
        doc /* Receives qualified physical motion and standstill evidence from TractionControl for the setting-application guard. The guard must use this record and cannot infer standstill from command absence, Hall edge absence or a retained setting. */
        in item payload:QualifiedMotionV1;
    }
    item def PSetStateOInformation:>ContextualSoftwareInformation {
        attribute requestedLevel:String;
        attribute pendingLevel:String;
        attribute activeLevel:String;
        attribute requestedSpeedLimitKilometresPerHour:Real;
        attribute pendingSpeedLimitKilometresPerHour:Real;
        attribute activeSpeedLimitKilometresPerHour:Real;
    }
    port def PSetStateO {
        doc /* Publishes the complete requested, pending and active settings view to SessionPolicy and service aggregation. DemandPolicy does not consume this broad view for torque profiles, preventing a pending request from becoming active demand. */
        out item payload:PSetStateOInformation;
    }
    item def ActiveRidingSettingsV1:>ContextualSoftwareInformation {
        attribute activeLevel:String;
        attribute activeSpeedLimitKilometresPerHour:Real;
        attribute activeSettingsGeneration:ContextGeneration;
    }
    port def PSetActiveDemandO {
        doc /* Publishes only the already-applied riding level, speed limit and active-settings generation to DemandPolicy. This projection is the demand input and excludes pending or merely requested settings. */
        out item payload:ActiveRidingSettingsV1;
    }
}

package X2CitySoftwareComponent_SettingsPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SettingsPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    part def SettingsPolicy {
        /* Validates and retains requested, pending, and active riding settings, publishing the
           applied state for session and demand policy. It preserves owner and qualification context
           across requests without selecting a concrete HMI or actuator implementation. */
        port pSetRequestI:PSetRequestI;
        port pSetMotionI:PSetMotionI;
        port pSetStateO:PSetStateO;
        port pSetActiveDemandO:PSetActiveDemandO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
