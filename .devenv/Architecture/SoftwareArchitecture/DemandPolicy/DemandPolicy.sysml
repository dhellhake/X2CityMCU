package X2CitySoftwareContract_DemandPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_SettingsPolicy::*;
    private import X2CitySoftwareContract_BatteryProtection::*;
    attribute def NormalizedResponseCurve {
        attribute inputBreakpoints:Real[1..*];
        attribute outputValues:Real[1..*];
        attribute breakpointAndValueCountsMatch:Boolean;
        attribute inputBreakpointsStrictlyIncreasing:Boolean;
        attribute outputValuesNondecreasing:Boolean;
        attribute normalizedDomainFullyCovered:Boolean;
        attribute zeroAndFullScaleEndpointsPresent:Boolean;
    }
    attribute def DemandRampCalibration {
        attribute wheelTorqueGradientNewtonMetresPerSecond:Real;
        attribute responseBoundMicroseconds:Integer;
    }
    attribute def RegenerationDynamicGradientCalibration {
        attribute wheelTorqueGradientNewtonMetresPerSecond:Real;
        attribute responseBoundMicroseconds:Integer;
    }
    attribute def RegenerationTaperCalibration {
        attribute onsetSpeedKilometresPerHour:Real;
        attribute taperMap:NormalizedResponseCurve;
        attribute responseBoundMicroseconds:Integer;
    }
    attribute def DemandProfileReferenceLimits {
        attribute positiveReferenceWheelTorqueNewtonMetres:Real;
        attribute regenerativeReferenceWheelTorqueMagnitudeNewtonMetres:Real;
        // References the fixed 40 km/h parent-rule cutoff; a compiled profile cannot redefine it.
        attribute hardSpeedCutoffKilometresPerHour:Real;
    }
    attribute def DemandTimingBoundsCalibration {
        attribute acceleratorMaximumAgeMicroseconds:Integer;
        attribute brakeMaximumAgeMicroseconds:Integer;
        attribute activeSettingsMaximumAgeMicroseconds:Integer;
        attribute batteryCapabilityMaximumAgeMicroseconds:Integer;
        attribute motionMaximumAgeMicroseconds:Integer;
        attribute actualOutputMaximumAgeMicroseconds:Integer;
        attribute authorityMaximumAgeMicroseconds:Integer;
        attribute inputCoherenceWindowMicroseconds:Integer;
        attribute decisionPeriodMicroseconds:Integer;
        attribute commandValidityMicroseconds:Integer;
        attribute derivedEndToEndBoundMicroseconds:Integer;
        attribute allBoundsPositiveAndFinite:Boolean;
        attribute endToEndBoundDerivedAndAccepted:Boolean;
    }
    // The component's fixed build-time profile retains every map, endpoint, ramp, taper and
    // timing bound.  Any malformed or unvalidated compiled value withholds demand output.
    attribute def DemandPolicyCalibration {
        attribute profileId:String;
        attribute profileRevision:String;
        attribute profileBuildValidated:Boolean;
        attribute level0PositiveMap:NormalizedResponseCurve;
        attribute level1PositiveMap:NormalizedResponseCurve;
        attribute level2PositiveMap:NormalizedResponseCurve;
        attribute level3PositiveMap:NormalizedResponseCurve;
        attribute level4PositiveMap:NormalizedResponseCurve;
        attribute level5PositiveMap:NormalizedResponseCurve;
        attribute level1RegenerationMap:NormalizedResponseCurve;
        attribute level2RegenerationMap:NormalizedResponseCurve;
        attribute level3RegenerationMap:NormalizedResponseCurve;
        attribute level4RegenerationMap:NormalizedResponseCurve;
        attribute level5RegenerationMap:NormalizedResponseCurve;
        attribute level1To5NeutralPercent:Real;
        attribute samePositiveEndpointValidated:Boolean;
        attribute progressiveRegenerationMaximumValidated:Boolean;
        attribute level5LinearMapsValidated:Boolean;
        attribute level1PositiveResumptionRamp:DemandRampCalibration;
        attribute level2PositiveResumptionRamp:DemandRampCalibration;
        attribute level3PositiveResumptionRamp:DemandRampCalibration;
        attribute level4PositiveResumptionRamp:DemandRampCalibration;
        // Level 0 uses Level 1's resumption ramp; Level 5 has no ramp record.
        attribute level1RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level2RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level3RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level4RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        // Level 5 has no regenerative torque-time gradient record.
        attribute level1To5RegenerationTaper:RegenerationTaperCalibration;
        attribute referenceLimits:DemandProfileReferenceLimits;
        attribute timingBounds:DemandTimingBoundsCalibration;
        attribute postStopRegenerationGuardId:String;
    }
    port def AcceleratorPositionInputPort {
        doc /* Receives AcceleratorInterface's composite. DemandPolicy uses Position as rider input only when the contained Qualification supports its source, age and calibration context, and processes the contained health even when Position is unavailable. */
        in item payload:AcceleratorPosition;
    }
    port def BrakeStateInputPort {
        doc /* Receives the qualified coded brake state from BrakeInterface. A valid applied state constrains positive demand, while an invalid or unavailable brake observation is a common invalid contributor that withdraws both positive and regenerative demand. */
        in item payload:BrakeState;
    }
    port def ActiveRidingSettingsInputPort {
        doc /* Receives only the already active riding level and speed limit from SettingsPolicy. Pending or merely requested settings cannot enter torque-demand calculation through this port. */
        in item payload:ActiveRidingSettings;
    }
    port def RidingAuthorityInputPort {
        doc /* Receives SessionPolicy authority generation, decision time and expiry in the common host-boot monotonic microsecond domain. DemandPolicy checks authority independently from command age and never obtains authority through diagnostics. */
        in item payload:RidingAuthority;
    }
    port def BatteryCapabilityInputPort {
        doc /* Receives BatteryProtection's separate positive propulsion and negative regeneration capability branches. DemandPolicy applies the relevant sign branch and its own qualification evidence rather than using aggregate envelope validity for both signs. */
        in item payload:BatteryCapabilityEnvelope;
    }
    port def QualifiedMotionInputPort {
        doc /* Receives qualified physical vehicle motion from TractionControl for speed cutoffs, standstill, rollback and post-stop guards. Electrical Hall direction or command absence cannot substitute for this observation. */
        in item payload:QualifiedMotion;
    }
    port def ActualTractionOutputInputPort {
        doc /* Receives qualified actual applied-output evidence from TractionControl, separate from the requested command. DemandPolicy uses positive applied torque and powered-forward travel evidence for regeneration rearm decisions. */
        in item payload:ActualTractionOutput;
    }
    item def WheelTorqueRequest:>ContextualSoftwareInformation, X2CityContract_DemandPolicy::SignedWheelTorqueRequest {
        attribute requestedWheelTorqueNewtonMetres:Real;
        attribute authorityGeneration:AuthorityGeneration;
        attribute decisionSequence:Integer;
        attribute decisionTimeMicroseconds:Integer;
        attribute commandExpiryTimeMicroseconds:ExpiryTimeMicroseconds :>> X2CityContract_DemandPolicy::SignedWheelTorqueRequest::expiry;
    }
    port def WheelTorqueRequestOutputPort {
        doc /* Publishes the requested signed wheel torque to TractionControl with decision sequence, authority generation, decision time and independent command expiry. Consumers validate both authority and command expiry in the common host-boot monotonic microsecond domain. */
        out item payload:WheelTorqueRequest;
    }
    item def DemandPolicyDiagnostic:>ContextualSoftwareInformation {
        attribute activeLevel:String;
        attribute activeSpeedLimitKilometresPerHour:Real;
        attribute positiveDemandDisposition:String;
        attribute regenerationDisposition:String;
        attribute applicableRestrictionEpisodeGeneration:ContextGeneration;
        attribute regenerationRecoveryEpisodeGeneration:ContextGeneration;
        attribute regenerationRecoveryQualified:Boolean;
        attribute postStopRegenerationRearmState:String;
        attribute profileId:String;
    }
    port def DemandPolicyDiagnosticOutputPort {
        doc /* Publishes the current demand-policy explanation, including active settings, sign dispositions, restriction and recovery generations, to ServiceInformation. This record is diagnostic context and cannot authorize or refresh a command. */
        out item payload:DemandPolicyDiagnostic;
    }
}

package X2CitySoftwareComponent_DemandPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    part def DemandPolicy {
        /* Arbitrates typed qualified rider inputs, applied settings, authority, battery capability,
           qualified physical motion and actual applied-output evidence. It publishes a requested
           signed wheel-torque command with generation and expiry plus a read-only policy diagnostic.
           Brake actuation blocks positive demand only; accelerator alone can request regeneration.
           Demand never owns actual torque, ADC/FOC/hardware or authority issuance. */
        port executionTimeIn:ExecutionTimeInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port brakeStateIn:BrakeStateInputPort;
        port activeRidingSettingsIn:ActiveRidingSettingsInputPort;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port batteryCapabilityIn:BatteryCapabilityInputPort;
        port qualifiedMotionIn:QualifiedMotionInputPort;
        port actualTractionOutputIn:ActualTractionOutputInputPort;
        port wheelTorqueRequestOut:WheelTorqueRequestOutputPort;
        port demandPolicyDiagnosticOut:DemandPolicyDiagnosticOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        // This parameter set is compiled into SC-DEMAND; its identity is provenance only and
        // never selects or activates a profile at runtime.
        attribute compiledCalibrationId:String;
        attribute compiledDemandPolicyCalibration:DemandPolicyCalibration;
        attribute compiledCalibrationValid:Boolean; // Build/startup validation failure withholds demand command publication.
    }
}
