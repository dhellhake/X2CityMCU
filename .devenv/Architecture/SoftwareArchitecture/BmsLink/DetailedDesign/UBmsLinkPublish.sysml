package X2CityDetailedUnit_BmsLinkPublish {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_BmsLinkDecode::*;
    // Owner: SC-BMS-LINK.V; DD-002. Publishes qualified observations; no BMS write/control capability.
    item def BmsObservationRecord :> UnitInformationEnvelope;
    port def BmsDecodedInputPort {
        doc /* Receives source-identified decoded BMS fields from the decoder, including their per-field qualification. */
        in item payload:BmsDecodedRecord;
    }
    port def BmsObservationOutputPort {
        doc /* Publishes qualified BMS observations to battery policy consumers and marks them for requalification after source loss or reset; it exposes no BMS write path. */
        out item payload:BmsObservationRecord;
    }
    part def BmsObservationPublisher {
        /* Publishes accepted BMS observations with producer context, validity, freshness, and measurement metadata. It marks affected information for requalification after relevant reset or source loss without exposing BMS write/control capability. */
        port decodedIn:BmsDecodedInputPort; port observationOut:BmsObservationOutputPort; }
}
