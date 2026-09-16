package X2CitySoftwareContract_ServiceInformation {
    private import X2CitySharedSoftwareTypes::*;
    // P-SVC-RECORD-I is a stable ARCH-003 port identifier.
    // Producer-specific records retain their owner types while this collector accepts the common envelope.
    port def PSvcRecordI { in item payload:ContextualSoftwareInformation; }
    // P-SVC-SNAPSHOT-O is a stable ARCH-003 port identifier.
    item def PSvcSnapshotOInformation:>ContextualSoftwareInformation;
    port def PSvcSnapshotO { out item payload:PSvcSnapshotOInformation; }
}

package X2CitySoftwareComponent_ServiceInformation {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_ServiceInformation::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-SERVICE-INFO; static architecture only. No unit-local API, task, or hardware pin is declared here.
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
