package X2CityDetailedUnit_PlatformHealth {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorQualificationInputPort;
    // Owner: SC-PLATFORM.V; DD-001; Draft REQ-SYS-PLT-002; SW-I-009.
    item def PlatformHealthRecord :> PlatformHealth;
    port def PlatformHealthOutputPort {
        doc /* Publishes platform scheduling and local-health status to policy consumers without asserting a physical reaction or reclassifying sensor cause. */
        out item payload:PlatformHealthRecord;
    }
    port def SensorHealthInputPort {
        doc /* Receives normalized producer health as an input to platform readiness aggregation; it preserves the producer's source and reason. */
        in item payload:SensorHealthCondition;
    }
    part def PlatformHealthManager {
        /* Receives normalized sensor health without returning it as a sensor cause, then publishes
           platform health/dispatch/resource events. Session and service consumers retain fault
           recognition and reporting policy; this unit creates no feedback route to a sensor. */
        port executionTimeIn:ExecutionTimeInputPort; port sensorHealthIn:SensorHealthInputPort; port acceleratorQualificationIn:AcceleratorQualificationInputPort; port healthOut:PlatformHealthOutputPort; }
}
