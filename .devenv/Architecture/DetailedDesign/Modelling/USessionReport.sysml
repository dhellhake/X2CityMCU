package X2CityDetailedUnit_SessionReport {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-SESSION; DD-001; UR-SESSION-002.
    item def SessionReportRecord :> UnitInformationEnvelope;
    port def SessionReportInputPort {
        doc /* Receives the eligibility and related observation envelope used to select the current Session report group; the envelope is report input, not authority. */
        in item payload:UnitInformationEnvelope;
    }
    port def SessionReportOutputPort {
        doc /* Sends the selected Session report group to HMI and service consumers without granting authority or changing inhibition. */
        out item payload:SessionReportRecord;
    }
    part def SessionReportPublisher {
        /* Selects and publishes the current session report group from eligibility and related observations. It reports state without granting authority or changing session inhibition. */
        port eligibilityIn:SessionReportInputPort; port reportOut:SessionReportOutputPort; }
}
