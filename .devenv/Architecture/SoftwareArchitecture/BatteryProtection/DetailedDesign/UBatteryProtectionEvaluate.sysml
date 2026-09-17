package X2CityDetailedUnit_BatteryProtectionEvaluate {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    // Owner: SC-BAT-POLICY.V; DD-002; SW-I-003/009.
    item def BatteryEnvelopeCandidate :> UnitInformationEnvelope;
    // BMS, temperature, supply, phase and traction producer records remain source-typed.
    port def BatteryObservationsAndContextInputPort {
        doc /* Receives source-typed BMS, temperature, supply, phase and traction observations with operating context; this heterogeneous policy fan-in does not erase producer identity. */
        in item payload:ContextualSoftwareInformation;
    }
    port def EnvelopeCandidateOutputPort {
        doc /* Sends independent charge and discharge capability candidates, including their reasons and qualification, to the restriction policy. */
        out item payload:BatteryEnvelopeCandidate;
    }
    part def BatteryCapabilityEvaluator {
        /* Evaluates qualified battery observations and operating context into independent charge/discharge envelope candidates. It preserves reason and qualification metadata; it does not implement physical protection or current regulation. */
        port observationsAndContextIn:BatteryObservationsAndContextInputPort; port candidateOut:EnvelopeCandidateOutputPort; }
}
