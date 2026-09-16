package X2CityDetailedUnit_BmsLinkTransaction {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-BMS-LINK.V; DD-002. Read-only 0x03/0x04/0x05 transaction envelope gate.
    item def BmsAcceptedPayload :> UnitInformationEnvelope;
    port def BmsFrameIn { in item payload:UnitInformationEnvelope; }
    port def BmsAcceptedPayloadOut { out item payload:BmsAcceptedPayload; }
    part def UBmsLinkTransaction {
        /* Gates selected read transactions and validates framing, command echo, status, length, checksum, and frame boundaries. Only a whole accepted payload proceeds to decoding. */
        port frameIn:BmsFrameIn; port acceptedPayloadOut:BmsAcceptedPayloadOut; }
}
