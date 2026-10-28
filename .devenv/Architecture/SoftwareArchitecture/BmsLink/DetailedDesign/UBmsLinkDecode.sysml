package X2CityDetailedUnit_BmsLinkDecode {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_BmsLinkTransaction::*;
    // Owner: SC-BMS-LINK.V; DD-002. Decodes the fixed SP14S004 V1.0 / firmware 3.2 profile.
    item def BmsDecodedRecord :> UnitInformationEnvelope;
    port def BmsAcceptedPayloadInputPort {
        doc /* Receives only a frame-valid response that also matched the current request and reported success. Per-command fixed schema validation remains mandatory here. */
        in item payload:BmsAcceptedPayload;
    }
    port def BmsDecodedOutputPort {
        doc /* Sends decoded fields with command, fixed schema, scale and field identity to publication; wrong payload length, field count or encoding qualifies no dependent value. */
        out item payload:BmsDecodedRecord;
    }
    part def BmsResponseDecoder {
        /* Implements only the fixed SP14S004 V1.0 read protocol. Generic frame-integrity and
           current-request transaction acceptance have already been decided upstream. On every
           normal or unexpected vehicle-controller startup, startup qualification requires
           exactly two values together in the current startup's accepted 0x03 reply: firmware version
           3.2 and reported series-group count 14. Missing, invalid, or mismatching either value
           withholds dependent BmsLink observations; BatteryProtection consumes those qualifications
           and produces zero effective current for unqualified dependent limits. Startup qualification
           is private and adds no public flag or port. Every accepted response, including the startup
           0x03 response, is checked against its implemented payload length, field count, and encoding.
           Regular observation checks also require series count 14 for dependent pack data; apply only
           a supported current/capacity scale selected by that same 0x03 response; match decoded
           temperature count to declared NTC count and require unique profile-matched probe IDs; and
           require complete fourteen-group data where used. These are not additional dedicated
           startup checks. A semantic failure withholds only the affected
           observation; transaction/schema rejection supplies no new qualifying evidence. Firmware
           3.2 is identity evidence, not a protocol version. For the selected qualified 0x03
           protection-path representation, bit 0 means charge path enabled and bit 1 means discharge
           path enabled (1=enabled); preserve separate Boolean source states. Do not infer capability
           magnitude or physical path protection from either state. */
        port executionTimeIn:ExecutionTimeInputPort; port acceptedPayloadIn:BmsAcceptedPayloadInputPort; port decodedOut:BmsDecodedOutputPort; }
}
