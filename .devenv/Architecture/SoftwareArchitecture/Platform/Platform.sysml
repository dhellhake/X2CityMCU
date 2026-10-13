package X2CitySoftwareContract_Platform {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_Compute::*;
    private import X2CitySoftwareContract_BrakeInterface::SoftwareBrakeQualification;
    item def PlatformContext:>ContextualSoftwareInformation;
    port def PlatformContextOutputPort {
        doc /* Publishes the current execution, reset and context generation information to software components that require a coherent local operating context. Consumers use it to qualify observations and reject records from another context. */
        out item payload:PlatformContext;
    }
    port def RuntimeInitializationOutputPort :> X2CityContract_Compute::ComputeRuntimeInitializationOutputPort;
    port def SleepRequestInputPort :> X2CityContract_Compute::ComputeSleepRequestInputPort;
    item def RetentionCandidate:>ContextualSoftwareInformation;
    port def RetentionCandidateOutputPort {
        doc /* Publishes retained-state information to policy components. BatteryProtection uses the retained candidate with its validity context for reached-10% recovery handling. */
        out item payload:RetentionCandidate;
    }
    item def PlatformHealth:>ContextualSoftwareInformation {
        attribute fastSafetyState:String; // enum: inactive, armed, inhibited, latched.
    }
    port def PlatformHealthOutputPort {
        doc /* Publishes Platform health and its independent FastSafetyState to component event receptacles. This platform result is not routed back as a sensor root cause. */
        out item payload:PlatformHealth;
    }
    // Normalized qualified evidence from one producer. Platform consumes this evidence without
    // publishing it back as a new sensor cause; a platform fast-safety state is separate from a
    // Session-recognized fault and its fault-code policy.
    item def SensorHealthCondition:>ContextualSoftwareInformation {
        attribute source:String;
        attribute reason:String;
        attribute severity:String;
        attribute immediateFastInhibitRequested:Boolean;
        attribute evidenceTimeMicroseconds:Integer;
        attribute relatedAdcSequence:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def SensorHealthInputPort {
        doc /* Receives normalized health evidence from AnalogAcquisition and semantic sensor interfaces. Platform consumes producer source, severity, timestamp and fixed configuration provenance to update its separate fast-safety state. */
        in item payload:SensorHealthCondition;
    }
    port def BrakeQualificationInputPort :> X2CityContract_BrakeStateIdentification::BrakeHealthInputPort {
        doc /* Receives the exact BrakeQualification projection with its software source/reason/event-time/context refinement. */
        in item qualification:SoftwareBrakeQualification :>> X2CityContract_BrakeStateIdentification::BrakeHealthInputPort::qualification;
    }
}

package X2CitySoftwareComponent_Platform {
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorQualificationInputPort;
    private import X2CitySoftwareContract_MotorPositionEstimator::MotorPositionInputPort;
    private import X2CitySoftwareContract_Platform::*;
    part def Platform {
        /* Establishes local execution/reset context, retained-state access, and platform-health
           information for its host instance. U-PLATFORM-BINDING owns static peripheral/IRQ/rank/
           trigger configuration. Each SoftwareComponent owns immutable compiled calibration
           parameters and validates them during build/startup; Platform has no calibration
           publication or selection lifecycle. It consumes qualified sensor evidence to drive its separate FastSafetyState
           without feeding its health publication back as a new sensor root cause. Platform does
           not own ADC sampling, control math, or PWM/JSQR writes. */
        port executionTimeIn:ExecutionTimeInputPort;
        port platformContextOut:PlatformContextOutputPort;
        port runtimeInitializationOut:RuntimeInitializationOutputPort;
        port sleepRequestIn:SleepRequestInputPort;
        port retentionCandidateOut:RetentionCandidateOutputPort;
        port platformHealthOut:PlatformHealthOutputPort;
        port sensorHealthIn:SensorHealthInputPort;
        port acceleratorQualificationIn:AcceleratorQualificationInputPort;
        // Current estimator qualification reaches Platform only inside the complete record;
        // it is not added to the generic SensorHealthCondition fan-in.
        port motorPositionIn:MotorPositionInputPort;
        // Exact brake Qualification projection/refinement; BrakeLeverState itself remains with its policy consumers.
        port brakeQualificationIn:BrakeQualificationInputPort;
        // A platform instance also consumes its own generation/health service events.
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
