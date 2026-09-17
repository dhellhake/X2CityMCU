package X2CityDetailedUnit_LightMode {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    // Owner: SC-LIGHT-POLICY.V; DD-001; UR-LIGHT-001; SW-I-005/006.
    item def LightInputRecord :> UnitInformationEnvelope;
    item def LightIntentRecord :> UnitInformationEnvelope;
    // Brake, traction and HMI records preserve their typed owner payload at this policy fan-in.
    port def LightInputIn {
        doc /* Receives source-typed brake, traction and HMI records used to choose logical front/rear modes; a missing brake fact selects the parent conservative behavior. */
        in item payload:ContextualSoftwareInformation;
    }
    port def LightIntentOut {
        doc /* Sends the selected logical front/rear light intent to its consumer; it does not prove lamp power or visible behavior. */
        out item payload:LightIntentRecord;
    }
    part def ULightMode {
        /* Combines qualified rider/braking observations with the retained normal-light request to publish a logical front/rear light mode. The output is software intent and does not prove lamp power or visible behavior. */
        port inputsIn:LightInputIn; port intentOut:LightIntentOut; }
}
