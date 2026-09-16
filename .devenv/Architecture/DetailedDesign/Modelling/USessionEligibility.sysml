package X2CityDetailedUnit_SessionEligibility {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    // Owner: SC-SESSION; DD-001; UR-SESSION-001; SW-I-004.
    item def SessionEligibilityRecord :> UnitInformationEnvelope;
    port def SessionEligibilityIn { in item payload:ContextualSoftwareInformation; }
    port def SessionEligibilityOut { out item payload:SessionEligibilityRecord; }
    part def USessionEligibility {
        /* Evaluates current Ready prerequisites and riding-session inhibition to publish authority only when all required facts are current and qualified. Direct sensor-health conditions retain producer source/reason for the existing first-recognized-fault policy, while the independent PlatformHealthRecord retains platform fault/readiness input; this unit owns neither physical proof nor sensor aggregation. */
        port prerequisitesIn:SessionEligibilityIn;
        port authorityOut:SessionEligibilityOut;
    }
}
