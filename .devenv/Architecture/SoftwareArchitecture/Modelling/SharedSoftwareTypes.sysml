package X2CitySharedSoftwareTypes {
    private import X2CitySharedContracts::*;
    private import X2CityContract_MotorControl::*;
    attribute def Validity :> ValidityStatus;
    attribute def Qualification;
    attribute def Freshness :> FreshnessStatus;
    attribute def Health;
    attribute def ProducerContext :> SourceContext;
    attribute def ConfigurationContext;
    attribute def ContextGeneration;
    // The software timestamp form refines the logical expiry meaning without assigning a
    // logical clock, unit, or representation to that meaning.
    attribute def ExpiryTimestampTicks :> Integer, X2CitySharedContracts::Expiry;
    // Software-contract scalar convention: engineering values use SysML Real/Integer/Boolean
    // primitives with a unit-bearing property name; controlled enum values use String until the
    // owning HSI binds its exact vocabulary and serialization layout.
    item def ContextualSoftwareInformation :> QualifiedInformationRecord {
        // These are refinements of the logical qualification trait, retaining the software
        // record's existing context vocabulary without creating a second qualification value.
        attribute validity:Validity :>> QualifiedInformationRecord::validity;
        // Qualification and current health remain distinct from availability/freshness.
        attribute qualification:Qualification;
        attribute freshness:Freshness :>> QualifiedInformationRecord::freshness;
        attribute health:Health;
        attribute producerContext:ProducerContext :>> QualifiedInformationRecord::sourceContext;
        attribute configurationContext:ConfigurationContext;
        // Identifies the current vehicle host/reset generation; it is not a global session.
        attribute currentGeneration:ContextGeneration;
        // Every policy-consumed record preserves its source timestamp/clock and, where needed,
        // its separately qualified conversion into the common policy clock. Capture-timer ticks
        // are never silently treated as policy-clock ticks.
        attribute sourceTimestampTicks:Integer;
        attribute sourceClockId:String;
        attribute sourceClockContextId:String;
        attribute policyTimestampTicks:Integer;
        attribute policyClockId:String;
        attribute policyClockContextId:String;
        attribute policyTimebaseConversionQualified:Boolean;
    }
    // These records are shared type definitions, while SC-TRACTION-CTRL.V exclusively owns
    // their vehicle publications. Electrical rotor direction alone is insufficient for either
    // record; validated Hall/capture interpretation criteria are required before qualification.
    item def QualifiedMotionV1:>ContextualSoftwareInformation, QualifiedVehicleMotion {
        attribute vehicleSpeedKilometresPerHour:Real;
        attribute travelDirection:String; // enum: forward, reverse, stationary, unavailable.
        attribute standstill:Boolean;
        attribute motionQualificationBasis:String;
    }
    item def ActualTractionOutputV1:>ContextualSoftwareInformation, ActualTractionOutput {
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
