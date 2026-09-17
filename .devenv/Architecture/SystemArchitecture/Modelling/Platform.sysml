package X2CityComponent_Platform {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ServiceInformation::*;
    part def Platform { // LE-PLATFORM
        /* Provides the runtime platform services used by the compute boundary and exposes their service report information. It is the execution support boundary rather than a vehicle policy component. */
        port serviceReportOut:ServiceReportOutputPort;
    }
}
