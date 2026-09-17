package X2CitySoftwareContract_ServiceInformation {
    private import X2CitySharedSoftwareTypes::*;
    // Producer-specific records retain their owner types while this collector accepts the common envelope.
    port def PSvcRecordI {
        doc /* Receives producer-owned observations, policy records and platform context through the common contextual base type. ServiceInformation preserves producer identity and qualification while aggregating current records. */
        in item payload:ContextualSoftwareInformation;
    }
    item def PSvcSnapshotOInformation:>ContextualSoftwareInformation;
    port def PSvcSnapshotO {
        doc /* Publishes the read-only aggregated service snapshot to the vehicle maintenance boundary. The snapshot is a presentation result and carries no return or control path to producers. */
        out item payload:PSvcSnapshotOInformation;
    }
}

package X2CitySoftwareComponent_ServiceInformation {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_ServiceInformation::*;
    private import X2CitySoftwareContract_Platform::*;
    part def ServiceInformation {
        /* Collects current producer observations together with identity, qualification, reset, and
           configuration context, then presents a read-only service snapshot. It does not perform
           the producer diagnostics or provide a return/control path. */
        port pSvcRecordI:PSvcRecordI;
        port pSvcSnapshotO:PSvcSnapshotO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
