package X2CityDetailedUnit_PlatformHealth {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    // Owner: SC-PLATFORM.V; DD-001; Draft REQ-SYS-PLT-002; SW-I-009.
    item def PlatformHealthRecord :> PPltHealthOInformation;
    port def PlatformHealthOut {
        doc /* Publishes platform scheduling and local-health status to policy consumers without asserting a physical reaction or reclassifying sensor cause. */
        out item payload:PlatformHealthRecord;
    }
    port def SensorHealthIn {
        doc /* Receives normalized producer health as an input to platform readiness aggregation; it preserves the producer's source and reason. */
        in item payload:SensorHealthConditionV1;
    }
    part def UPlatformHealth {
        /* Receives normalized sensor health without returning it as a sensor cause, then publishes
           platform health/dispatch/resource events. Session and service consumers retain fault
           recognition and reporting policy; this unit creates no feedback route to a sensor. */
        port sensorHealthIn:SensorHealthIn; port healthOut:PlatformHealthOut; }
}
