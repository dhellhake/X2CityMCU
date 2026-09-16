package X2CityComponent_BmsLink {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Bms::*;
    private import X2CityContract_ServiceInformation::*;
    part def BmsLink { // LE-BMS-LINK
        /* Adapts the vehicle-side BMS read and telemetry endpoint to the supplied BMS assembly. It exposes the selected read path and contributes service configuration information. */
        port telemetryIn:BmsTelemetryIn;
        port readRequestOut:BmsReadRequestOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
