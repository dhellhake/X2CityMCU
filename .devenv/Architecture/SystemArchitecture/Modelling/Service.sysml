package X2CityComponent_Service {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_ServiceInformation::*;
    private import X2CityComponent_ServiceAccess::*;
    part def Service { // LE-SERVICE
        /* Composes service information aggregation and service access. It collects configuration information from producing components and exposes it at the service boundary. */
        part serviceInformation:ServiceInformation;
        part serviceAccess:ServiceAccess;
    }
}
