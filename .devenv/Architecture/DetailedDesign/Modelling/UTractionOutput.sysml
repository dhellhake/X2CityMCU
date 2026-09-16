package X2CityDetailedUnit_TractionOutput {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_TractionControl::*;
    // Owner: SC-TRACTION-CTRL.V; DD-001/DD-003 and Runtime Integration Contract; UR-TRACTION-OUTPUT-001.
    // Sole owner of literal TIM8 CCR1..4 and JSQR stage/commit; hardware break and external inhibit remain independent.
    item def OutputObservationRecord :> UnitInformationEnvelope;
    port def FastCommandIn { in item payload:FastCommandV1; }
    port def OutputObservationOut { out item payload:OutputObservationRecord; }
    part def UTractionOutput {
        /* Solely stages and commits literal TIM8 CCR1..4 and JSQR data from FastCommandV1 under the selected inhibit/ordering contract. It publishes qualified output observations but does not claim physical PWM or gate behavior. */
        port fastCommandIn:FastCommandIn; port outputObservationOut:OutputObservationOut; }
}
