package X2CityDetailedUnit_BmsLinkTransaction {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-BMS-LINK.V; DD-002. Read-only 0x03/0x04/0x05 transaction envelope gate.
    item def BmsAcceptedPayload :> UnitInformationEnvelope;
    port def BmsFrameInputPort {
        doc /* Receives the raw BMS transport frame envelope for selected read-transaction validation; this generic envelope does not imply decoded measurements. */
        in item payload:UnitInformationEnvelope;
    }
    port def BmsAcceptedPayloadOutputPort {
        doc /* Sends a whole validated read payload to decoding only after command echo, status, length, checksum and framing checks succeed. */
        out item payload:BmsAcceptedPayload;
    }
    part def BmsTransaction {
        /* Gates selected read transactions and validates framing, command echo, status, length, checksum, and frame boundaries. Only a whole accepted payload proceeds to decoding. */
        port executionTimeIn:ExecutionTimeInputPort; port frameIn:BmsFrameInputPort; port acceptedPayloadOut:BmsAcceptedPayloadOutputPort; }
}
