package X2CityComponent_Platform {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ServiceInformation::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    part def Platform { // LE-PLATFORM
        /* Provides the runtime platform services used by the compute boundary and owns platform-level health aggregation. It is the execution support boundary rather than a vehicle policy component. */
        port serviceReportOut:ServiceReportOutputPort;
        port acceleratorHealthIn:AcceleratorHealthInputPort;
    }
}
