package X2CitySoftwareContract_SessionPolicy {
    private import X2CitySharedSoftwareTypes::*;
    port def PSesReadyI {
        doc /* Receives the heterogeneous current-context facts used to determine Ready eligibility, including qualified rider inputs, settings, health and battery/traction observations. SessionPolicy evaluates the attached producer qualification and freshness rather than reconstructing physical state. */
        in item payload:ContextualSoftwareInformation;
    }
    port def PSesMotionI {
        doc /* Receives explicitly qualified physical motion and standstill evidence from TractionControl for the Ready guard. Electrical Hall edge absence, command absence or retained settings cannot substitute for this record. */
        in item payload:QualifiedMotionV1;
    }
    attribute def AuthorityGeneration;
    item def PSesAuthOInformation:>ContextualSoftwareInformation {
        attribute authorityGeneration:AuthorityGeneration;
        attribute authorityDecisionSequence:Integer;
        attribute authorityDecisionTimestampTicks:Integer;
        attribute authorityExpiryTimestampTicks:Integer;
        attribute authorityClockId:String;
        attribute authorityClockContextId:String;
    }
    port def PSesAuthO {
        doc /* Publishes independently generated authority with decision sequence, timestamp, expiry and named clock context to DemandPolicy, TractionControl and service aggregation. A newer command or telemetry record cannot refresh this authority. */
        out item payload:PSesAuthOInformation;
    }
    item def PSesReportOInformation:>ContextualSoftwareInformation;
    port def PSesReportO {
        doc /* Publishes reportable session status and fault context to HmiAdapter and service aggregation. It explains session policy state and does not perform physical torque withdrawal or issue hardware commands. */
        out item payload:PSesReportOInformation;
    }
}

package X2CitySoftwareComponent_SessionPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    part def SessionPolicy {
        /* Forms Ready eligibility, retains current riding-session inhibition, and selects the
           reportable fault/session status. It issues authority generation and expiry for consumers;
           physical torque withdrawal and input self-test execution remain allocated elsewhere. */
        port pSesReadyI:PSesReadyI;
        port pSesMotionI:PSesMotionI;
        port pSesAuthO:PSesAuthO;
        port pSesReportO:PSesReportO;
        // R-V08 is the startup/reset context dependency; R-V31 is the common local family.
        port startupContextRequired:~PPltContextO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
