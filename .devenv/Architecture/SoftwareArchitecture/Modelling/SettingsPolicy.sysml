package X2CitySoftwareContract_SettingsPolicy {
    private import X2CitySharedSoftwareTypes::*;
    // P-SET-REQUEST-I is a stable ARCH-003 port identifier.
    // The one architecture port accepts distinct owner-tagged qualified/settings records.
    port def PSetRequestI { in item payload:ContextualSoftwareInformation; }
    // P-SET-STATE-O is a stable ARCH-003 port identifier.
    item def PSetStateOInformation:>ContextualSoftwareInformation;
    port def PSetStateO { out item payload:PSetStateOInformation; }
}

package X2CitySoftwareComponent_SettingsPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SettingsPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-SET; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def SettingsPolicy {
        /* Validates and retains requested, pending, and active riding settings, publishing the
           applied state for session and demand policy. It preserves owner and qualification context
           across requests without selecting a concrete HMI or actuator implementation. */
        port pSetRequestI:PSetRequestI;
        port pSetStateO:PSetStateO;
        // Architectural service/event receptacles; these are not implementation APIs.
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
