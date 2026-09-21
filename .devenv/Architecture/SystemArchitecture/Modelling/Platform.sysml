package X2CityComponent_Platform {
    private import X2CitySharedContracts::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_Input::*;
    part def Platform { // LE-PLATFORM
        /* Provides the runtime platform services used by the compute boundary and owns platform-level health aggregation. It is the execution support boundary rather than a vehicle policy component. */
        port acceleratorHealthIn:AcceleratorHealthInputPort;
        port motorPositionHealthIn:MotorPositionHealthInputPort { doc /* Receives estimator health for the existing platform fault-supervision path. */ }
        port brakeHealthIn:BrakeHealthInputPort;
        port temperatureHealthIn:TemperatureHealthInputPort;
        port supplyHealthIn:SupplyHealthInputPort;
    }
}
