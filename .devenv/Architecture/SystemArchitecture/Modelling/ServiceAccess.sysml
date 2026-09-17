package X2CityComponent_ServiceAccess {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ServiceInformation::*;
    part def ServiceAccess { // LE-SERVICE-ACCESS
        /* Provides the external service/configuration access boundary. It consumes the aggregated service report for service-facing use. */
        port serviceReportIn:ServiceReportInputPort;
    }
}
