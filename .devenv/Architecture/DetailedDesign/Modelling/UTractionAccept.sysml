package X2CityDetailedUnit_TractionAccept {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-TRACTION-CTRL.V; DD-001; REQ-SYS-TRQACC-001; SW-I-004/005.
    item def TractionAuthorityRecord :> UnitInformationEnvelope;
    item def TractionCommandRecord :> UnitInformationEnvelope;
    item def TractionObservationRecord :> UnitInformationEnvelope;
    port def TractionAuthorityIn { in item payload:UnitInformationEnvelope; }
    port def TractionCommandIn { in item payload:UnitInformationEnvelope; }
    port def TractionObservationIn { in item payload:UnitInformationEnvelope; }
    port def TractionObservationOut { out item payload:TractionObservationRecord; }
    part def UTractionAccept {
        /* Accepts only current authority and demand with valid context/configuration, and publishes qualified traction/output observations. Missing or expired inputs lead to unavailable or zero-request behavior; the unit does not prove physical torque. */
        port authorityIn:TractionAuthorityIn; port commandIn:TractionCommandIn; port outputObservationIn:TractionObservationIn; port observationOut:TractionObservationOut; }
}
