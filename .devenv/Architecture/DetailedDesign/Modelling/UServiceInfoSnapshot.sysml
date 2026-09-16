package X2CityDetailedUnit_ServiceInfoSnapshot {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_ServiceInfoCollect::*;
    // Owner: SC-SERVICE-INFO.V; DD-002. Atomic read-only current snapshot; no control return.
    item def ServiceSnapshotRecord :> UnitInformationEnvelope;
    port def ServiceCollectedIn { in item payload:ServiceCollectedRecord; }
    port def ServiceSnapshotOut { out item payload:ServiceSnapshotRecord; }
    part def UServiceInfoSnapshot {
        /* Forms an atomic, read-only service snapshot from collected records, preserving availability, qualification, freshness, and source context. It has no control or authority return path. */
        port collectedIn:ServiceCollectedIn; port snapshotOut:ServiceSnapshotOut; }
}
