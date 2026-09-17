package X2CitySoftwareContract_SessionPolicy {
    private import X2CitySharedSoftwareTypes::*;
    port def RidingReadinessInputPort {
        doc /* Receives heterogeneous non-accelerator current-context facts used to determine Ready eligibility, including rider inputs, settings, health and battery/traction observations. Accelerator composites use the dedicated acceleratorPositionIn port. */
        in item payload:ContextualSoftwareInformation;
    }
    port def QualifiedMotionInputPort {
        doc /* Receives explicitly qualified physical motion and standstill evidence from TractionControl for the Ready guard. Electrical Hall edge absence, command absence or retained settings cannot substitute for this record. */
        in item payload:QualifiedMotion;
    }
    attribute def AuthorityGeneration;
    item def RidingAuthority:>ContextualSoftwareInformation, X2CityContract_SessionPolicy::RidingAuthority {
        attribute authorityGeneration:AuthorityGeneration;
        attribute authorityDecisionSequence:Integer;
        attribute authorityDecisionTimestampTicks:Integer;
        attribute authorityExpiryTimestampTicks:ExpiryTimestampTicks :>> X2CityContract_SessionPolicy::RidingAuthority::expiry;
        attribute authorityClockId:String;
        attribute authorityClockContextId:String;
    }
    port def RidingAuthorityOutputPort {
        doc /* Publishes independently generated authority with decision sequence, timestamp, expiry and named clock context to DemandPolicy, TractionControl and service aggregation. A newer command or telemetry record cannot refresh this authority. */
        out item payload:RidingAuthority;
    }
    item def SessionReport:>ContextualSoftwareInformation;
    port def SessionReportOutputPort {
        doc /* Publishes reportable session status and fault context to HmiAdapter and service aggregation. It explains session policy state and does not perform physical torque withdrawal or issue hardware commands. */
        out item payload:SessionReport;
    }
}

package X2CitySoftwareComponent_SessionPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorPositionInputPort;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    part def SessionPolicy {
        /* Forms Ready eligibility, retains current riding-session inhibition, and selects the
           reportable fault/session status. It issues authority generation and expiry for consumers;
           physical torque withdrawal and input self-test execution remain allocated elsewhere. */
        port ridingReadinessIn:RidingReadinessInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedMotionIn:QualifiedMotionInputPort;
        port ridingAuthorityOut:RidingAuthorityOutputPort;
        port sessionReportOut:SessionReportOutputPort;
        // R-V08 is the startup/reset context dependency; R-V31 is the common local family.
        port startupContextIn:~PlatformContextOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
