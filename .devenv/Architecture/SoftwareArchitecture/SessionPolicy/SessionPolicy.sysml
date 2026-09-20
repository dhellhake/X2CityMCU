package X2CitySoftwareContract_SessionPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_BatteryControl::*;
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
        attribute authorityDecisionTimeMicroseconds:Integer;
        attribute authorityExpiryTimeMicroseconds:ExpiryTimeMicroseconds :>> X2CityContract_SessionPolicy::RidingAuthority::expiry;
    }
    port def RidingAuthorityOutputPort {
        doc /* Publishes independently generated authority with decision sequence, host-boot monotonic decision time and independent expiry to DemandPolicy and TractionControl. A newer command or observation cannot refresh this authority. */
        out item payload:RidingAuthority;
    }
    item def SessionReport:>ContextualSoftwareInformation;
    port def SessionReportOutputPort {
        doc /* Publishes reportable session status and fault context to HmiAdapter. It explains session policy state and does not perform physical torque withdrawal or issue hardware commands. */
        out item payload:SessionReport;
    }
}

package X2CitySoftwareComponent_SessionPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorPositionInputPort;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityContract_BatteryControl::*;
    part def SessionPolicy {
        /* Forms Ready eligibility, retains current riding-session inhibition, and selects the
           reportable fault/session status. It issues authority generation and expiry for consumers;
           physical torque withdrawal and input self-test execution remain allocated elsewhere. */
        port executionTimeIn:ExecutionTimeInputPort;
        port ridingReadinessIn:RidingReadinessInputPort;
        port batteryReadinessAndFaultIn:BatteryReadinessAndFaultInputPort;
        port stateOfChargeIn:BatteryStateOfChargeInputPort;
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
