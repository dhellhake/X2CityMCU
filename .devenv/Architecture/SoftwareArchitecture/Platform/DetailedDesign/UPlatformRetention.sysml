package X2CityDetailedUnit_PlatformRetention {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-PLATFORM.V; DD-001/DD-002; SW-I-009. Candidate validity and context only, never fault history.
    item def RetentionCandidateRecord :> UnitInformationEnvelope;
    port def RetentionCandidateOutputPort {
        doc /* Publishes the platform-provided retention candidate and its context for policy requalification after reset or battery handling; it does not itself retain an operating restriction. */
        out item payload:RetentionCandidateRecord;
    }
    part def RetentionCandidateManager {
        /* Publishes a platform-provided retention candidate with validity and context for policy requalification after reset or battery handling. It does not own the retained operating restriction. */
        port executionTimeIn:ExecutionTimeInputPort; port candidateOut:RetentionCandidateOutputPort; }
}
