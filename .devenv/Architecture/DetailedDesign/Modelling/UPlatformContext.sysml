package X2CityDetailedUnit_PlatformContext {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    // Owner: SC-PLATFORM.V; DD-001 and Runtime Integration Contract; REQ-SYS-PLT-001; SW-I-009.
    item def PlatformContextRecord :> PPltContextOInformation;
    port def PlatformContextOut { doc /* Publishes the new platform/reset context used to invalidate prior records; it coordinates lifecycle state but grants no riding authority. */ out item payload:PlatformContextRecord; }
    part def UPlatformContext {
        /* Creates and publishes the local platform/reset context used to invalidate prior observations and coordinate startup. It does not grant operating authority or restore policy state by itself. */
        port contextOut:PlatformContextOut; }
}
