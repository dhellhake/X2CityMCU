package X2CitySoftwareContract_BatteryProtection {
    private import X2CitySharedSoftwareTypes::*;
    // P-BAT-FACTS-I is a stable ARCH-003 port identifier; model name: PBatObservationsAndContextI.
    // Payload covers BMS observations, input/output/path observations, effective configuration,
    // current local operating context, and validity-tagged retention candidate (reached10% state).
    port def PBatObservationsAndContextI { in item payload:ContextualSoftwareInformation; }
    // P-BAT-ENVELOPE-O is a stable ARCH-003 port identifier.
    item def PBatEnvelopeOInformation:>ContextualSoftwareInformation;
    port def PBatEnvelopeO { out item payload:PBatEnvelopeOInformation; }
}

package X2CitySoftwareComponent_BatteryProtection {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BatteryProtection::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-BAT-POLICY; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def BatteryProtection {
        /* Derives separate charge and discharge capability envelopes from qualified BMS,
           path, configuration, and operating observations, selecting the most restrictive valid
           limits and publishing an unavailable/invalid result when required inputs are unusable.
           Distinguishes operation-specific restrictions from battery-fault information and owns
           the vehicle reached-10% restriction/recovery above 20% with retained-context validity.
           Supplied BMS hardware remains
           the independent physical protection, while this component owns the software policy role. */
        port pBatObservationsAndContextI:PBatObservationsAndContextI;
        port pBatEnvelopeO:PBatEnvelopeO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
