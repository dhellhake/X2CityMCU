package X2CityComponent_Platform {
    private import X2CitySharedContracts::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_BrakeStateIdentification::*;
    part def Platform { // LE-PLATFORM
        /* Provides runtime platform services for Compute and owns platform-level health aggregation. It configures the selected low-power/wake source and, after wake, initializes clocks, peripherals, retained context and timebase before existing startup/Ready criteria are applied. It is execution support rather than a vehicle policy component; exact wake mode/pin and sleep-entry mechanism remain open, and power-lock deassertion handling is undecided. Existing VD18MT on/off and shutdown requirements remain in effect. */
        port acceleratorHealthIn:AcceleratorHealthInputPort;
        port motorPositionIn:MotorPositionInputPort { doc /* Receives the estimator's full Position/Qualification composite for the existing platform fault-supervision path. */ }
        port brakeHealthIn:BrakeHealthInputPort;
        port qualifiedTemperatureIn:QualifiedTemperatureInputPort { doc /* Value-carrying qualified traction thermal observations for platform supervision. */ }
        port fastDcLinkVoltageIn:FastDcLinkVoltageInputPort { doc /* Value-carrying qualified PVDD observation for platform supervision. */ }
    }
}
