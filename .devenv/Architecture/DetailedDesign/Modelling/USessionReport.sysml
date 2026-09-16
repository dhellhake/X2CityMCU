package X2CityDetailedUnit_SessionReport {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-SESSION; DD-001; UR-SESSION-002.
    item def SessionReportRecord :> UnitInformationEnvelope;
    port def SessionReportIn { in item payload:UnitInformationEnvelope; }
    port def SessionReportOut { out item payload:SessionReportRecord; }
    part def USessionReport {
        /* Selects and publishes the current session report group from eligibility and related observations. It reports state without granting authority or changing session inhibition. */
        port eligibilityIn:SessionReportIn; port reportOut:SessionReportOut; }
}
