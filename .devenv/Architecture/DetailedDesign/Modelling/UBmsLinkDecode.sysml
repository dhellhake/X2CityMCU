package X2CityDetailedUnit_BmsLinkDecode {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-BMS-LINK.V; DD-002. Decodes only accepted selected-unit payloads.
    item def BmsDecodedRecord :> UnitInformationEnvelope;
    port def BmsAcceptedPayloadIn { in item payload:BmsAcceptedPayload; }
    port def BmsDecodedOut { out item payload:BmsDecodedRecord; }
    part def UBmsLinkDecode {
        /* Decodes accepted BMS payloads into independently qualified observations, preserving command, layout, scale, and field identity. Malformed or unsupported payloads produce no qualifying update. */
        port acceptedPayloadIn:BmsAcceptedPayloadIn; port decodedOut:BmsDecodedOut; }
}
