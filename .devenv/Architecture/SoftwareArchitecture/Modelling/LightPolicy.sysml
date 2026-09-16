package X2CitySoftwareContract_LightPolicy {
    private import X2CitySharedSoftwareTypes::*;
    // P-LGT-INPUT-I is a stable ARCH-003 port identifier.
    port def PLgtInputI { in item payload:ContextualSoftwareInformation; }
    // P-LGT-INTENT-O is a stable ARCH-003 port identifier.
    item def PLgtIntentOInformation:>ContextualSoftwareInformation;
    port def PLgtIntentO { out item payload:PLgtIntentOInformation; }
}

package X2CitySoftwareComponent_LightPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_LightPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-LIGHT-POLICY; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def LightPolicy {
        /* Retains the normal light request in the current session and selects independent front
           and rear logical modes from qualified inputs. It publishes light intent; physical lamp
           drive and unpowered-state behavior remain outside this software policy component. */
        port pLgtInputI:PLgtInputI;
        port pLgtIntentO:PLgtIntentO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
