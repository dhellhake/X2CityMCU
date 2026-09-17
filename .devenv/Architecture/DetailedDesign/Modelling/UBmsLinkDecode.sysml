package X2CityDetailedUnit_BmsLinkDecode {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-BMS-LINK.V; DD-002. Decodes only accepted selected-unit payloads.
    item def BmsDecodedRecord :> UnitInformationEnvelope;
    port def BmsAcceptedPayloadIn {
        doc /* Receives only a whole frame already accepted by the transaction gate for selected-unit field decoding. */
        in item payload:BmsAcceptedPayload;
    }
    port def BmsDecodedOut {
        doc /* Sends decoded BMS fields with their command, layout, scale and field identity to the BMS publication unit; malformed fields create no qualifying update. */
        out item payload:BmsDecodedRecord;
    }
    part def UBmsLinkDecode {
        /* Decodes accepted BMS payloads into independently qualified observations, preserving command, layout, scale, and field identity. Malformed or unsupported payloads produce no qualifying update. */
        port acceptedPayloadIn:BmsAcceptedPayloadIn; port decodedOut:BmsDecodedOut; }
}
