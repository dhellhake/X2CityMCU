package X2CityDetailedUnit_BmsLinkTransaction {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-BMS-LINK.V; DD-002. Fixed-profile read-only 0x03/0x04/0x05 envelope gate.
    item def BmsAcceptedPayload :> UnitInformationEnvelope;
    port def BmsFrameInputPort {
        doc /* Receives the raw BMS transport frame envelope. Generic frame integrity is independent of payload values and command-specific schemas. */
        in item payload:UnitInformationEnvelope;
    }
    port def BmsAcceptedPayloadOutputPort {
        doc /* Sends a frame-valid payload to decoding only when the response also matches the current request and reports success. Error status and wrong-command responses are transaction outcomes, not malformed frames. Command-specific schema checks run in the decoder. */
        out item payload:BmsAcceptedPayload;
    }
    part def BmsTransaction {
        /* Applies two decisions before forwarding to the decoder. Generic frame integrity requires complete and unambiguous frame boundaries, consistency between declared and received length within protocol bounds, and a valid checksum; these checks are independent of payload content and command-specific schemas. Transaction acceptance then requires a response to match the current request/command and report success. A valid error response, including a valid zero-payload response, is frame-valid but is a transaction outcome and supplies no decoded measurement. A wrong-command frame may be frame-valid but is not accepted as solicited data. The output therefore contains only frames that are both frame-valid and transaction-accepted. Per-command counts, encodings, and exact schema shapes are checked by BmsResponseDecoder. A reply timeout is transport status, supplies no accepted source update, and by itself does not expire otherwise-unexpired field evidence. */
        port executionTimeIn:ExecutionTimeInputPort; port frameIn:BmsFrameInputPort; port acceptedPayloadOut:BmsAcceptedPayloadOutputPort; }
}
