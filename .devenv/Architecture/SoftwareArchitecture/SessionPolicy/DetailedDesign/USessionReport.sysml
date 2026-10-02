package X2CityDetailedUnit_SessionReport {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CityContract_SessionPolicy::*;
    // Owner: SC-SESSION; DD-001; UR-SESSION-002.
    item def SelectedFaultIndicationRecord :> UnitInformationEnvelope, X2CitySoftwareContract_SessionPolicy::SoftwareSelectedFaultIndication;
    port def SessionReportInputPort {
        doc /* Receives the eligibility and related observation envelope used to select the current Session report group; the envelope is report input, not authority. */
        in item payload:UnitInformationEnvelope;
    }
    port def SelectedFaultIndicationOutputPort {
        doc /* Sends Session's already-selected qualified fault/no-error indication to HMI without granting authority or changing inhibition. */
        out item selectedFaultIndication:SelectedFaultIndicationRecord;
    }
    part def SessionReportPublisher {
        /* Selects and publishes the current Session fault/no-error indication from eligibility and related observations. It reports state without granting authority or changing session inhibition. */
        port executionTimeIn:ExecutionTimeInputPort; port eligibilityIn:SessionReportInputPort; port selectedFaultOut:SelectedFaultIndicationOutputPort; }
}
