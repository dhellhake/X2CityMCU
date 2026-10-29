package X2CityComponent_Platform {
    private import X2CitySharedContracts::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityContract_Compute::*;
    part def Platform { // LE-PLATFORM
        /* Provides runtime Platform services and owns platform-level health aggregation. It validates the latest Session-issued ComputeSleepRequest contract, current context, lifetime and cancellation at actual sleep entry, then forwards the unchanged grant qualification, source context and expiry to ComputeHardware. This is request validity checking at execution; sleep eligibility remains owned by RidingControl, and Platform does not recompute HMI or traction conditions. After wake it initializes clocks, peripherals and runtime monotonic timebase independently of vehicle startup/Ready. Wake mode/pin compatibility and sleep-entry mechanism remain characterization/derivation gates. */
        port acceleratorHealthIn:AcceleratorHealthInputPort;
        port motorPositionIn:MotorPositionInputPort { doc /* Receives the estimator's full Position/Qualification composite for the existing platform fault-supervision path. */ }
        port brakeHealthIn:BrakeHealthInputPort;
        port qualifiedTemperatureIn:QualifiedTemperatureInputPort { doc /* Value-carrying qualified traction thermal observations for platform supervision. */ }
        port fastDcLinkVoltageIn:FastDcLinkVoltageInputPort { doc /* Value-carrying qualified PVDD observation for platform supervision. */ }
        port runtimeInitializationOut:ComputeRuntimeInitializationOutputPort { doc /* Reports required clocks, peripherals, and the runtime monotonic timebase used by caller-supplied time references, distinct from vehicle Ready and other startup self-tests. */ }
        port sleepRequestIn:ComputeSleepRequestInputPort { doc /* Receives RidingControl's current qualified grant or revocation. At actual entry, checks request validity: the request must be present, valid, current-context, unexpired and the latest unrevoked true request. False, absent, invalid, expired, context-mismatched, superseded or cancelled requests clear any older pending true request; it cannot be replayed or renewed. Preserves qualification, sourceContext and expiry in the hardware handoff. This does not recheck HMI or traction evidence. */ }
        port computeHardwareSleepRequestOut:ComputeSleepRequestOutputPort { doc /* Hands the unchanged latest Session grant or revocation to ComputeHardware after request validity checking at entry. Invalid, absent, expired, context-mismatched, superseded or cancelled requests clear any older pending true request; it cannot be replayed or renewed. Does not recompute eligibility or renew the grant. */ }
    }
}
