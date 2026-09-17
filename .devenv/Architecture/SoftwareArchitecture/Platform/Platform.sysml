package X2CitySoftwareContract_Platform {
    private import X2CitySharedSoftwareTypes::*;
    item def PlatformContext:>ContextualSoftwareInformation;
    port def PlatformContextOutputPort {
        doc /* Publishes the current execution, reset and context generation information to software components that require a coherent local operating context. Consumers use it to qualify observations and reject records from another context. */
        out item payload:PlatformContext;
    }
    item def RetentionCandidate:>ContextualSoftwareInformation;
    port def RetentionCandidateOutputPort {
        doc /* Publishes retained-state information to policy components and service aggregation. BatteryProtection uses the retained candidate with its validity context for reached-10% recovery handling. */
        out item payload:RetentionCandidate;
    }
    item def PlatformHealth:>ContextualSoftwareInformation {
        attribute fastSafetyState:String; // enum: inactive, armed, inhibited, latched.
    }
    port def PlatformHealthOutputPort {
        doc /* Publishes Platform health and its independent FastSafetyState to component service/event receptacles and service aggregation. This platform result is not routed back as a sensor root cause. */
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
        attribute evidenceTimestampTicks:Integer;
        attribute relatedAdcSequence:Integer;
        attribute calibrationContextId:String;
    }
    port def SensorHealthInputPort {
        doc /* Receives normalized health evidence from AnalogAcquisition and semantic sensor interfaces. Platform consumes producer source, severity, timestamp and calibration context to update its separate fast-safety state. */
        in item payload:SensorHealthCondition;
    }
    // Typed calibration entries carry logical coefficients/identities, never selected numeric
    // values. U-PLATFORM-CALIBRATION validates and freezes the bundle before publication.
    attribute def RawAcquisitionBindingCalibration {
        attribute sourceId:String;
        attribute regularAdcRank:Integer;
        attribute injectedFirstAdcRank:Integer;
        attribute injectedSecondAdcRank:Integer;
        attribute regularTriggerId:String;
        attribute injectedTriggerId:String;
    }
    attribute def CurrentPhaseCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // A and A/ADC-code as applicable.
        attribute phaseAssociation:String;
        attribute currentOffsetAmperes:Real;
        attribute currentGainAmperesPerAdcCode:Real;
        attribute currentPolarity:String;
        attribute referenceCurrentAmperes:Real;
        attribute firstAdcRank:Integer;
        attribute secondAdcRank:Integer;
    }
    attribute def SupplyCalibration {
        attribute fastDcLinkSourceId:String;
        attribute fastDcLinkGainVoltsPerAdcCode:Real;
        attribute fastDcLinkOffsetVolts:Real;
        attribute fastDcLinkAdcRank:Integer;
        attribute regularRailSourceId:String;
        attribute regularRailGainVoltsPerAdcCode:Real;
        attribute regularRailOffsetVolts:Real;
        attribute regularRailAdcRank:Integer;
    }
    attribute def HallCalibration {
        attribute sourceId:String;
        attribute electricalMapId:String;
        attribute alignmentElectricalDegrees:Real;
        attribute captureTimerId:String;
        attribute captureTimerTickNanoseconds:Real;
    }
    attribute def AcceleratorCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // percent.
        attribute minimumPositionPercent:Real;
        attribute maximumPositionPercent:Real;
        attribute restThresholdPercent:Real;
        attribute adcRank:Integer;
    }
    attribute def BrakeCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // ohm.
        attribute resistanceClassificationId:String;
        attribute releasedResistanceLimitOhms:Real;
        attribute appliedResistanceLimitOhms:Real;
        attribute adcRank:Integer;
    }
    attribute def TemperatureCalibration {
        attribute boardTemperatureSourceId:String;
        attribute motorTemperatureSourceId:String;
        attribute engineeringUnit:String; // degC.
        attribute boardTemperatureOffsetCelsius:Real;
        attribute boardTemperatureGainCelsiusPerAdcCode:Real;
        attribute motorTemperatureOffsetCelsius:Real;
        attribute motorTemperatureGainCelsiusPerAdcCode:Real;
        attribute boardAdcRank:Integer;
        attribute motorAdcRank:Integer;
    }
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
        attribute responseBoundTicks:Integer;
    }
    attribute def RegenerationDynamicGradientCalibration {
        attribute wheelTorqueGradientNewtonMetresPerSecond:Real;
        attribute responseBoundTicks:Integer;
    }
    attribute def RegenerationTaperCalibration {
        attribute onsetSpeedKilometresPerHour:Real;
        attribute taperMap:NormalizedResponseCurve;
        attribute responseBoundTicks:Integer;
    }
    attribute def DemandProfileReferenceLimits {
        attribute positiveReferenceWheelTorqueNewtonMetres:Real;
        attribute regenerativeReferenceWheelTorqueMagnitudeNewtonMetres:Real;
        // This references the fixed 40 km/h parent-rule cutoff for validation; a profile cannot
        // redefine it. The value remains populated/verified with the activated bundle.
        attribute hardSpeedCutoffKilometresPerHour:Real;
    }
    attribute def ActualOutputEstimationCalibration {
        attribute estimatorId:String;
        attribute motorTorqueConstantNewtonMetresPerAmpere:Real;
        attribute transmissionRatio:Real;
        attribute estimatorResponseBoundTicks:Integer;
        attribute activationPermitted:Boolean;
    }
    attribute def DemandTimingBoundsCalibration {
        attribute clockId:String;
        attribute clockContextId:String;
        attribute acceleratorMaximumAgeTicks:Integer;
        attribute brakeMaximumAgeTicks:Integer;
        attribute activeSettingsMaximumAgeTicks:Integer;
        attribute batteryCapabilityMaximumAgeTicks:Integer;
        attribute motionMaximumAgeTicks:Integer;
        attribute actualOutputMaximumAgeTicks:Integer;
        attribute authorityMaximumAgeTicks:Integer;
        attribute inputCoherenceWindowTicks:Integer;
        attribute decisionPeriodTicks:Integer;
        attribute commandValidityTicks:Integer;
        attribute derivedEndToEndBoundTicks:Integer;
        attribute allBoundsPositiveAndFinite:Boolean;
        attribute endToEndBoundDerivedAndAccepted:Boolean;
    }
    // This immutable resolved profile carries the actual maps, neutral, ramps, taper, reference
    // limits and symbolic timing bounds. Activation requires paired ordered full-range endpoint
    // maps, the stated cross-level validations, positive finite accepted bounds and a derived
    // end-to-end bound. No field receives an architecture-selected value: missing, malformed or
    // unvalidated values make profileActivationPermitted false.
    attribute def DemandPolicyCalibration {
        attribute profileId:String;
        attribute profileRevision:String;
        attribute profileActivationPermitted:Boolean;
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
        // Level 0 uses Level 1's resumption ramp; Level 5 intentionally has no ramp record.
        attribute level1RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level2RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level3RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level4RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        // Level 5 intentionally has no regenerative torque-time gradient record.
        attribute level1To5RegenerationTaper:RegenerationTaperCalibration;
        attribute referenceLimits:DemandProfileReferenceLimits;
        attribute timingBounds:DemandTimingBoundsCalibration;
        attribute postStopRegenerationGuardId:String;
    }
    item def CalibrationBundle:>ContextualSoftwareInformation {
        attribute immutable:Boolean;
        attribute bundleId:String;
        attribute bundleRevision:String;
        attribute activationContextId:String;
        attribute rawAcquisitionBinding:RawAcquisitionBindingCalibration;
        attribute currentPhaseCalibration:CurrentPhaseCalibration;
        attribute supplyCalibration:SupplyCalibration;
        attribute hallCalibration:HallCalibration;
        attribute acceleratorCalibration:AcceleratorCalibration;
        attribute brakeCalibration:BrakeCalibration;
        attribute temperatureCalibration:TemperatureCalibration;
        attribute demandPolicyCalibration:DemandPolicyCalibration;
        attribute actualOutputEstimationCalibration:ActualOutputEstimationCalibration;
    }
    item def ActiveCalibrationBundle:>CalibrationBundle;
    port def CalibrationBundleOutputPort {
        doc /* Publishes the immutable, validated typed calibration bundle to acquisition, conversion, demand and traction consumers. Components accept their applicable entries only in the matching activation context; missing or unvalidated bundle data cannot be treated as selected defaults. */
        out item payload:ActiveCalibrationBundle;
    }
}

package X2CitySoftwareComponent_Platform {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    part def Platform {
        /* Establishes local execution/reset context, retained-state access, and platform-health
           information for its host instance. U-PLATFORM-BINDING owns static peripheral/IRQ/rank/
           trigger configuration; U-PLATFORM-CALIBRATION owns immutable typed calibration-bundle
           lifecycle and activation only while disarmed in a new context. Vehicle sensor interfaces read
           their applicable entry and accept semantic
           calibration. It consumes qualified sensor evidence to drive its separate FastSafetyState
           without feeding its health publication back as a new sensor root cause. Platform does
           not own ADC sampling, control math, or PWM/JSQR writes. */
        port platformContextOut:PlatformContextOutputPort;
        port retentionCandidateOut:RetentionCandidateOutputPort;
        port platformHealthOut:PlatformHealthOutputPort;
        port calibrationBundleOut:CalibrationBundleOutputPort;
        port sensorHealthIn:SensorHealthInputPort;
        // A platform instance also consumes its own generation/health service events.
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
