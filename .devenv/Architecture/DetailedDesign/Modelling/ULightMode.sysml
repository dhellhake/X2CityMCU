package X2CityDetailedUnit_LightMode {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-LIGHT-POLICY.V; DD-001; UR-LIGHT-001; SW-I-005/006.
    item def LightInputRecord :> UnitInformationEnvelope;
    item def LightIntentRecord :> UnitInformationEnvelope;
    port def LightInputIn { in item payload:UnitInformationEnvelope; }
    port def LightIntentOut { out item payload:LightIntentRecord; }
    part def ULightMode {
        /* Combines qualified rider/braking observations with the retained normal-light request to publish a logical front/rear light mode. The output is software intent and does not prove lamp power or visible behavior. */
        port inputsIn:LightInputIn; port intentOut:LightIntentOut; }
}
