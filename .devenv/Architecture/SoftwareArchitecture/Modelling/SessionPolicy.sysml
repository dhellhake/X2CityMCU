package X2CitySoftwareContract_SessionPolicy {
    private import X2CitySharedSoftwareTypes::*;
    // P-SES-READY-I is a heterogeneous current-context fact contract.
    port def PSesReadyI { in item payload:ContextualSoftwareInformation; }
    attribute def AuthorityGeneration;
    attribute def AuthorityExpiry;
    // P-SES-AUTH-O carries independent authority generation, validity and expiry.
    item def PSesAuthOInformation:>ContextualSoftwareInformation {
        attribute authorityGeneration:AuthorityGeneration;
        attribute authorityExpiry:AuthorityExpiry;
    }
    port def PSesAuthO { out item payload:PSesAuthOInformation; }
    // P-SES-REPORT-O is a stable ARCH-003 port identifier.
    item def PSesReportOInformation:>ContextualSoftwareInformation;
    port def PSesReportO { out item payload:PSesReportOInformation; }
}

package X2CitySoftwareComponent_SessionPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-SESSION; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def SessionPolicy {
        /* Forms Ready eligibility, retains current riding-session inhibition, and selects the
           reportable fault/session status. It issues authority generation and expiry for consumers;
           physical torque withdrawal and input self-test execution remain allocated elsewhere. */
        port pSesReadyI:PSesReadyI;
        port pSesAuthO:PSesAuthO;
        port pSesReportO:PSesReportO;
        // R-V08 is the startup/reset context dependency; R-V31 is the common local family.
        port startupContextRequired:~PPltContextO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
