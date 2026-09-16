package X2CityDetailedUnit_BatteryProtectionRestriction {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_BatteryProtectionEvaluate::*;
    private import X2CityDetailedUnit_PlatformRetention::*;
    // Owner: SC-BAT-POLICY.V; DD-002. It owns reached10% restriction and retains no battery-fault history.
    item def BatteryEnvelopeRecord :> UnitInformationEnvelope;
    port def BatteryEnvelopeCandidateIn { in item payload:BatteryEnvelopeCandidate; }
    port def RetentionCandidateIn { in item payload:RetentionCandidateRecord; }
    port def BatteryEnvelopeOut { out item payload:BatteryEnvelopeRecord; }
    part def UBatteryProtectionRestriction {
        /* Applies operation context to battery envelope candidates and publishes propulsion and regeneration consequences. Vehicle scope owns the reached10% restriction until qualified actual SOC exceeds 20%; retention is accepted only after requalification, and this unit does not provide physical protection. */
        port candidateIn:BatteryEnvelopeCandidateIn; port retentionCandidateIn:RetentionCandidateIn; port envelopeOut:BatteryEnvelopeOut; }
}
