package X2CitySoftwareContract_DemandPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    // P-DEM-INPUT-I is a heterogeneous current-context fact contract.
    port def PDemInputI { in item payload:ContextualSoftwareInformation; }
    attribute def SignedWheelTorque;
    attribute def CommandExpiry;
    // P-DEM-COMMAND-O is signed wheel torque with independent authority linkage and expiry.
    item def PDemCommandOInformation:>ContextualSoftwareInformation {
        attribute signedWheelTorque:SignedWheelTorque;
        attribute authorityGeneration:AuthorityGeneration;
        attribute commandExpiry:CommandExpiry;
    }
    port def PDemCommandO { out item payload:PDemCommandOInformation; }
}

package X2CitySoftwareComponent_DemandPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-DEMAND; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def DemandPolicy {
        /* Arbitrates rider demand with settings, authority, battery capability, and current
           observations, then publishes a signed wheel-torque command with generation and expiry.
           It supplies command policy rather than directly accepting or writing motor hardware. */
        port pDemInputI:PDemInputI;
        port pDemCommandO:PDemCommandO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
