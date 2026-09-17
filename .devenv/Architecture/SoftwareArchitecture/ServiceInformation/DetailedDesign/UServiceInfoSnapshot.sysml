package X2CityDetailedUnit_ServiceInfoSnapshot {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_ServiceInfoCollect::*;
    // Owner: SC-SERVICE-INFO.V; DD-002. Atomic read-only current snapshot; no control return.
    item def ServiceSnapshotRecord :> UnitInformationEnvelope;
    port def ServiceCollectedInputPort {
        doc /* Receives the source-aware service collection to be captured atomically for read-only service access. */
        in item payload:ServiceCollectedRecord;
    }
    port def ServiceSnapshotOutputPort {
        doc /* Publishes an atomic service snapshot with source, qualification and context metadata and no control or authority return path. */
        out item payload:ServiceSnapshotRecord;
    }
    part def ServiceSnapshotPublisher {
        /* Forms an atomic, read-only service snapshot from collected records, preserving availability, qualification, freshness, and source context. It has no control or authority return path. */
        port collectedIn:ServiceCollectedInputPort; port snapshotOut:ServiceSnapshotOutputPort; }
}
