package X2CityDetailedUnit_BatteryProtectionEvaluate {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-BAT-POLICY.V; DD-002; SW-I-003/009.
    item def BatteryEnvelopeCandidate :> UnitInformationEnvelope;
    port def BatteryObservationsAndContextIn { in item payload:UnitInformationEnvelope; }
    port def EnvelopeCandidateOut { out item payload:BatteryEnvelopeCandidate; }
    part def UBatteryProtectionEvaluate {
        /* Evaluates qualified battery observations and operating context into independent charge/discharge envelope candidates. It preserves reason and qualification metadata; it does not implement physical protection or current regulation. */
        port observationsAndContextIn:BatteryObservationsAndContextIn; port candidateOut:EnvelopeCandidateOut; }
}
