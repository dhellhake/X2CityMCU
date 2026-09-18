package X2CitySoftwareContract_ServiceInformation {
    private import X2CitySharedSoftwareTypes::*;
    // Producer-specific records retain their owner types while this collector accepts the common envelope.
    port def ServiceRecordInputPort {
        doc /* Receives non-accelerator producer-owned observations, policy records and platform context through the common contextual base type. Accelerator composites use the dedicated acceleratorPositionIn port. */
        in item payload:ContextualSoftwareInformation;
    }
    item def ServiceSnapshot:>ContextualSoftwareInformation;
    port def ServiceSnapshotOutputPort {
        doc /* Publishes the read-only aggregated service snapshot to the vehicle maintenance boundary. The snapshot is a presentation result and carries no return or control path to producers. */
        out item payload:ServiceSnapshot;
    }
}

package X2CitySoftwareComponent_ServiceInformation {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorPositionInputPort;
    private import X2CitySoftwareContract_ServiceInformation::*;
    private import X2CitySoftwareContract_Platform::*;
    part def ServiceInformation {
        /* Collects current producer observations together with identity, qualification, reset, and
           configuration context, then presents a read-only service snapshot. It does not perform
           the producer diagnostics or provide a return/control path. */
        port executionTimeIn:ExecutionTimeInputPort;
        port serviceRecordIn:ServiceRecordInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port serviceSnapshotOut:ServiceSnapshotOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
