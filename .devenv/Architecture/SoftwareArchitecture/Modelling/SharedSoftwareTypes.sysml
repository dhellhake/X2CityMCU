package X2CitySharedSoftwareTypes {
    private import X2CitySharedContracts::*;
    private import X2CityContract_MotorControl::*;
    attribute def Validity :> ValidityStatus;
    attribute def Qualification;
    attribute def Health;
    attribute def ProducerContext :> SourceContext;
    attribute def ConfigurationContext;
    attribute def ContextGeneration;
    attribute def ExpiryTimeMicroseconds :> Integer, X2CitySharedContracts::Expiry;
    item def ExecutionTime {
        doc /* The immediate caller supplies a fixed host-boot monotonic time reference for one
           invocation. currentGeneration on contextual records distinguishes reset epochs. */
        attribute currentTimeMicroseconds:Integer;
    }
    // Software observation, assessment, decision and expiry timestamps ending in
    // TimeMicroseconds use this same host-boot monotonic domain. Hardware capture counters may
    // remain local only where their owner explicitly preserves and relates them at its boundary.
    port def ExecutionTimeInputPort {
        doc /* Canonical caller-supplied execution time. The runtime calling context samples the
           live common clock immediately before invocation; this port is neither a clock service
           nor a queued time stream. */
        in item payload:ExecutionTime;
    }
    port def ExecutionTimeOutputPort {
        doc /* Provides the current invocation's caller-sampled host-boot monotonic time
           reference to an execution boundary. */
        out item payload:ExecutionTime;
    }
    // Software-contract scalar convention: engineering values use SysML Real/Integer/Boolean
    // primitives with a unit-bearing property name; controlled enum values use String until the
    // owning HSI binds its exact vocabulary and serialization layout.
    item def ContextualSoftwareInformation :> QualifiedInformationRecord {
        // These are refinements of the logical qualification trait, retaining the software
        // record's existing context vocabulary without creating a second qualification value.
        attribute validity:Validity :>> QualifiedInformationRecord::validity;
        // Qualification and current health remain distinct from availability.
        attribute qualification:Qualification;
        attribute health:Health;
        attribute producerContext:ProducerContext :>> QualifiedInformationRecord::sourceContext;
        attribute configurationContext:ConfigurationContext;
        // Identifies the current vehicle host/reset generation; it is not a global session.
        attribute currentGeneration:ContextGeneration;
    }
    // These records are shared type definitions, while SC-TRACTION-CTRL.V exclusively owns
    // their vehicle publications. Electrical rotor direction alone is insufficient for either
    // record; validated Hall/capture interpretation criteria are required before qualification.
    item def QualifiedMotion:>ContextualSoftwareInformation, QualifiedVehicleMotion {
        attribute motionObservationTimeMicroseconds:Integer;
        attribute vehicleSpeedKilometresPerHour:Real;
        attribute travelDirection:String; // enum: forward, reverse, stationary, unavailable.
        attribute standstill:Boolean;
        attribute motionQualificationBasis:String;
    }
    item def ActualTractionOutput:>ContextualSoftwareInformation, X2CityContract_MotorControl::ActualTractionOutput {
        attribute actualOutputObservationTimeMicroseconds:Integer;
        attribute actualAppliedWheelTorqueNewtonMetres:Real;
        attribute activeElectricalBraking:Boolean;
        attribute actualOutputAvailable:Boolean;
        attribute poweredForwardTravel:Boolean;
        attribute actualOutputObservationGeneration:ContextGeneration;
        attribute torqueEstimateMethodId:String;
        attribute torqueEstimateCalibrationId:String;
        attribute outputStageEvidenceSourceId:String;
    }
}
