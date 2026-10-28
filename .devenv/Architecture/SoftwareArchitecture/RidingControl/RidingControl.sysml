package X2CitySoftwareContract_RidingControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_RidingControl::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_HmiAdapter::HmiRiderSettingsRequest;
    private import X2CitySoftwareContract_BatteryProtection::BatteryOperatingLimitsAssessment;
    private import X2CitySoftwareContract_MotorPositionEstimator::MotorPositionInputPort;
    private import X2CitySoftwareContract_BrakeInterface::SoftwareBrakeLeverState;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_Compute::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_TractionControl::*;

    // One typed boundary port per producer-owned observation. Policy state below is private
    // to RidingControl and is exchanged only among its four internal units.
    port def RidingVehicleOperationRequestInputPort :> X2CityContract_HmiControl::VehicleOperationRequestInputPort { doc /* Receives the HMI owner's qualified physical On/Off interpretation with request qualification; UART loss remains separate. */ in item request:VehicleOperationRequest :>> X2CityContract_HmiControl::VehicleOperationRequestInputPort::request; }
    port def RidingRuntimeInitializationInputPort :> X2CityContract_Compute::ComputeRuntimeInitializationInputPort { doc /* Receives Platform's current startup/runtime initialization evidence as a distinct Ready prerequisite. */ in item initialization:ComputeRuntimeInitialization :>> X2CityContract_Compute::ComputeRuntimeInitializationInputPort::initialization; }
    port def BrakeLeverStateInputPort :> X2CityContract_BrakeStateIdentification::BrakeLeverStateInputPort {
        doc /* Receives the complete state/qualification composite once; policy derives brake actuation only from a qualified lever combination. */
        in item brakeLeverState:SoftwareBrakeLeverState :>> X2CityContract_BrakeStateIdentification::BrakeLeverStateInputPort::brakeLeverState;
    }
    port def RidingQualifiedVehicleMotionInputPort :> X2CityContract_MotorControl::QualifiedVehicleMotionInputPort {
        doc /* Receives Traction's qualified physical speed, direction and standstill evidence for settings, Ready and demand guards. */
        in item payload:QualifiedMotion :>> X2CityContract_MotorControl::QualifiedVehicleMotionInputPort::payload;
    }
    port def RidingQualifiedTemperatureInputPort :> X2CityContract_TractionControl::QualifiedTemperatureInputPort { doc /* Receives Traction's source-qualified motor/board temperature with its qualification and sample context for current fault supervision. */ in item payload:X2CitySoftwareContract_TemperatureInterface::QualifiedTemperature :>> X2CityContract_TractionControl::QualifiedTemperatureInputPort::payload; }
    port def RidingTractionConditionEvidenceInputPort :> X2CityContract_MotorControl::TractionConditionEvidenceInputPort { doc /* Receives categorized local traction condition evidence; RidingControl owns the vehicle-session latch and report selection. */ in item payload:X2CitySoftwareContract_TractionControl::TractionObservation :>> X2CityContract_MotorControl::TractionConditionEvidenceInputPort::payload; }
    port def HmiRiderSettingsRequestInputPort :> X2CityContract_RidingControl::RiderSettingsRequestInputPort {
        doc /* Receives one qualified current-context HMI settings receipt. Requested, pending and active values remain separate internal state. */
        in item payload:HmiRiderSettingsRequest :>> X2CityContract_RidingControl::RiderSettingsRequestInputPort::payload;
    }
    port def RidingSettingsRequestInputPort :> X2CityContract_RidingControl::RiderSettingsRequestInputPort {
        doc /* Internal unit view of the same qualified settings receipt; it does not expose pending or active state. */
        in item payload:HmiRiderSettingsRequest :>> X2CityContract_RidingControl::RiderSettingsRequestInputPort::payload;
    }
    // Existing settings state distinction is kept wholly inside this component.
    item def RidingSettingsState :> ContextualSoftwareInformation {
        attribute requestedLevel:String;
        attribute pendingLevel:String;
        attribute activeLevel:String;
        attribute requestedSpeedLimitKilometresPerHour:Real;
        attribute pendingSpeedLimitKilometresPerHour:Real;
        attribute activeSpeedLimitKilometresPerHour:Real;
    }
    port def SettingsStateInputPort { doc /* Internal full settings view for Ready/report logic; requested, pending and active values retain separate provenance. */ in item payload:RidingSettingsState; }
    port def SettingsStateOutputPort { doc /* Internal publication of requested, pending and active state without promoting a pending request. */ out item payload:RidingSettingsState; }
    item def ActiveRidingSettings :> ContextualSoftwareInformation, X2CityContract_RidingControl::ActiveRidingSettings {
        attribute activeSettingsUpdateTimeMicroseconds:Integer;
        attribute activeSettingsGeneration:ContextGeneration;
    }
    port def ActiveRidingSettingsInputPort { doc /* Internal demand-only view of values already applied by the setting state unit; pending values are excluded. */ in item payload:ActiveRidingSettings; }
    port def ActiveRidingSettingsOutputPort { doc /* Internal projection of the applied settings and their own generation to demand arbitration. */ out item payload:ActiveRidingSettings; }
    port def QualifiedMotionInputPort { doc /* Internal typed qualified motion dependency; caller-supplied execution time is used for local freshness checks. */ in item payload:QualifiedMotion; }

    attribute def AuthorityGeneration;
    item def RidingAuthority :> ContextualSoftwareInformation, X2CityContract_RidingControl::RidingAuthority {
        attribute authorityGeneration:AuthorityGeneration;
        attribute authorityDecisionSequence:Integer;
        attribute authorityDecisionTimeMicroseconds:Integer;
        attribute authorityExpiryTimeMicroseconds:ExpiryTimeMicroseconds :>> X2CityContract_RidingControl::RidingAuthority::expiry;
    }
    port def RidingAuthorityInputPort :> X2CityContract_RidingControl::RidingAuthorityInputPort { doc /* Internal consumer view of independently generated authority with its own decision time and expiry. */ in item payload:RidingAuthority :>> X2CityContract_RidingControl::RidingAuthorityInputPort::payload; }
    port def RidingAuthorityOutputPort :> X2CityContract_RidingControl::RidingAuthorityOutputPort { doc /* Publishes independent authority; torque-command renewal never extends this expiry. */ out item payload:RidingAuthority :>> X2CityContract_RidingControl::RidingAuthorityOutputPort::payload; }
    item def SoftwareSelectedFaultIndication :> ContextualSoftwareInformation, X2CityContract_RidingControl::SelectedFaultIndication;
    port def SelectedFaultIndicationOutputPort :> X2CityContract_RidingControl::SelectedFaultIndicationOutputPort {
        doc /* Publishes the already-selected fault or no-error indication for HMI encoding; it does not claim physical inhibition. */
        out item selectedFaultIndication:SoftwareSelectedFaultIndication :>> X2CityContract_RidingControl::SelectedFaultIndicationOutputPort::selectedFaultIndication;
    }

    attribute def NormalizedResponseCurve {
        attribute inputBreakpoints:Real[1..*]; attribute outputValues:Real[1..*];
        attribute breakpointAndValueCountsMatch:Boolean; attribute inputBreakpointsStrictlyIncreasing:Boolean;
        attribute outputValuesNondecreasing:Boolean; attribute normalizedDomainFullyCovered:Boolean;
        attribute zeroAndFullScaleEndpointsPresent:Boolean;
    }
    attribute def DemandRampCalibration { attribute wheelTorqueGradientNewtonMetresPerSecond:Real; attribute responseBoundMicroseconds:Integer; }
    attribute def RegenerationDynamicGradientCalibration { attribute wheelTorqueGradientNewtonMetresPerSecond:Real; attribute responseBoundMicroseconds:Integer; }
    attribute def RegenerationTaperCalibration { attribute onsetSpeedKilometresPerHour:Real; attribute taperMap:NormalizedResponseCurve; attribute responseBoundMicroseconds:Integer; }
    attribute def DemandProfileReferenceLimits {
        attribute positiveReferenceWheelTorqueNewtonMetres:Real;
        attribute regenerativeReferenceWheelTorqueMagnitudeNewtonMetres:Real;
        attribute hardSpeedCutoffKilometresPerHour:Real;
    }
    attribute def DemandTimingBoundsCalibration {
        attribute acceleratorMaximumAgeMicroseconds:Integer; attribute brakeMaximumAgeMicroseconds:Integer;
        attribute activeSettingsMaximumAgeMicroseconds:Integer; attribute batteryOperatingLimitsPublicationTimeoutMicroseconds:Integer;
        attribute stateOfChargePublicationTimeoutMicroseconds:Integer;
        attribute motionMaximumAgeMicroseconds:Integer; attribute actualOutputMaximumAgeMicroseconds:Integer;
        attribute authorityMaximumAgeMicroseconds:Integer; attribute inputCoherenceWindowMicroseconds:Integer;
        attribute decisionPeriodMicroseconds:Integer; attribute commandValidityMicroseconds:Integer;
        attribute derivedEndToEndBoundMicroseconds:Integer; attribute allBoundsPositiveAndFinite:Boolean;
        attribute endToEndBoundDerivedAndAccepted:Boolean;
    }
    attribute def DemandPolicyCalibration {
        attribute profileId:String; attribute profileRevision:String; attribute profileBuildValidated:Boolean;
        attribute level0PositiveMap:NormalizedResponseCurve; attribute level1PositiveMap:NormalizedResponseCurve;
        attribute level2PositiveMap:NormalizedResponseCurve; attribute level3PositiveMap:NormalizedResponseCurve;
        attribute level4PositiveMap:NormalizedResponseCurve; attribute level5PositiveMap:NormalizedResponseCurve;
        attribute level1RegenerationMap:NormalizedResponseCurve; attribute level2RegenerationMap:NormalizedResponseCurve;
        attribute level3RegenerationMap:NormalizedResponseCurve; attribute level4RegenerationMap:NormalizedResponseCurve;
        attribute level5RegenerationMap:NormalizedResponseCurve; attribute level1To5NeutralPercent:Real;
        attribute samePositiveEndpointValidated:Boolean; attribute progressiveRegenerationMaximumValidated:Boolean;
        attribute level5LinearMapsValidated:Boolean; attribute level1PositiveResumptionRamp:DemandRampCalibration;
        attribute level2PositiveResumptionRamp:DemandRampCalibration; attribute level3PositiveResumptionRamp:DemandRampCalibration;
        attribute level4PositiveResumptionRamp:DemandRampCalibration;
        attribute level1RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level2RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level3RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level4RegenerationDynamicRamp:RegenerationDynamicGradientCalibration;
        attribute level1To5RegenerationTaper:RegenerationTaperCalibration;
        attribute referenceLimits:DemandProfileReferenceLimits; attribute timingBounds:DemandTimingBoundsCalibration;
        attribute postStopRegenerationGuardId:String;
    }
    port def DemandAcceleratorPositionInputPort { doc /* Supplies the full accelerator Position/Qualification composite; unavailable Position never discards current fault qualification. */ in item payload:AcceleratorPosition; }
    port def DemandBrakeLeverStateInputPort :> X2CityContract_BrakeStateIdentification::BrakeLeverStateInputPort {
        doc /* Carries the qualified mechanical-brake state to demand arbitration, preserving the shared signed wheel-torque convention. */
        in item brakeLeverState:SoftwareBrakeLeverState :>> X2CityContract_BrakeStateIdentification::BrakeLeverStateInputPort::brakeLeverState;
    }
    port def RidingBatteryOperatingLimitsInputPort :> X2CityContract_BatteryControl::BatteryOperatingLimitsInputPort {
        doc /* Receives battery policy's independently qualified MOS-disabled state plus discharge/charge current limits and reasons on the existing stream. U-SESSION-REPORT checks its own delivery-current watchdog for MOS state; MOS-state qualification is independent of discharge- and charge-branch qualification. Wheel-torque sign does not select electrical current direction and zero current limit does not imply MOS state. */
        in item operatingLimits:BatteryOperatingLimitsAssessment :>> X2CityContract_BatteryControl::BatteryOperatingLimitsInputPort::operatingLimits;
    }
    port def ActualTractionOutputInputPort :> X2CityContract_MotorControl::ActualTractionInputPort { doc /* Supplies qualified actual applied-output evidence independently of the requested torque command for regeneration rearm. */ in item payload:X2CitySharedSoftwareTypes::ActualTractionOutput :>> X2CityContract_MotorControl::ActualTractionInputPort::payload; }
    item def WheelTorqueRequest :> ContextualSoftwareInformation, X2CityContract_RidingControl::SignedWheelTorqueRequest {
        attribute requestedWheelTorqueNewtonMetres:Real :>> X2CityContract_RidingControl::SignedWheelTorqueRequest::requestedWheelTorqueNewtonMetres;
        attribute authorityGeneration:AuthorityGeneration;
        attribute decisionSequence:Integer; attribute decisionTimeMicroseconds:Integer;
        attribute commandExpiryTimeMicroseconds:ExpiryTimeMicroseconds :>> X2CityContract_RidingControl::SignedWheelTorqueRequest::expiry;
    }
    port def WheelTorqueRequestOutputPort :> X2CityContract_RidingControl::WheelTorqueCommandOutputPort {
        doc /* Publishes the signed wheel-torque request with its own decision time and expiry; command renewal does not extend authority lifetime. */
        out item payload:WheelTorqueRequest :>> X2CityContract_RidingControl::WheelTorqueCommandOutputPort::payload;
    }
    port def WheelTorqueRequestInputPort :> X2CityContract_RidingControl::WheelTorqueCommandInputPort {
        doc /* Receives the signed request only while both its own expiry and the linked authority remain current. */
        in item payload:WheelTorqueRequest :>> X2CityContract_RidingControl::WheelTorqueCommandInputPort::payload;
    }
}

package X2CitySoftwareComponent_RidingControl {
    private import X2CitySoftwareContract_RidingControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityComponent_RidingControl::*;
    part def RidingControl :> X2CityComponent_RidingControl::RidingControl { // SC-RIDING-CONTROL, realizing LE-RIDING
        doc /* One runtime component owns setting receipt/pending/activation, Ready and current-session fault/restart state, report selection, authority, actual-SOC 10% positive-propulsion eligibility boundary, demand-side battery-current restriction episodes and post-stop regeneration rearm. A qualified explicit physical Off closes the session immediately regardless of motion; unknown or unavailable is not Off, and a later On starts fresh qualification. It publishes a current sleep grant only while Off and qualified traction sleep permission remain true. Internal units retain separate state and behavior. Qualification, physical torque output/protection, sensor acquisition, battery capability and HMI interpretation remain with their existing owners. */
        port executionTimeIn:X2CitySharedSoftwareTypes::ExecutionTimeInputPort { doc /* Receives the enclosing caller's single host-boot monotonic reference for this invocation; internal units share this fixed snapshot. */ }
        port vehicleOperationRequestIn:RidingVehicleOperationRequestInputPort :>> X2CityComponent_RidingControl::RidingControl::vehicleOperationRequestIn;
        port runtimeInitializationIn:RidingRuntimeInitializationInputPort :>> X2CityComponent_RidingControl::RidingControl::runtimeInitializationIn;
        port brakeLeverStateIn:BrakeLeverStateInputPort :>> X2CityComponent_RidingControl::RidingControl::brakeLeverStateIn;
        port acceleratorPositionIn:X2CitySoftwareContract_AcceleratorInterface::AcceleratorPositionInputPort :>> X2CityComponent_RidingControl::RidingControl::acceleratorPositionIn;
        port qualifiedVehicleMotionIn:RidingQualifiedVehicleMotionInputPort :>> X2CityComponent_RidingControl::RidingControl::qualifiedVehicleMotionIn;
        port motorPositionIn:X2CitySoftwareContract_MotorPositionEstimator::MotorPositionInputPort :>> X2CityComponent_RidingControl::RidingControl::motorPositionIn;
        port qualifiedTemperatureIn:RidingQualifiedTemperatureInputPort :>> X2CityComponent_RidingControl::RidingControl::qualifiedTemperatureIn;
        port tractionConditionEvidenceIn:RidingTractionConditionEvidenceInputPort :>> X2CityComponent_RidingControl::RidingControl::tractionConditionEvidenceIn;
        port hmiRiderSettingsRequestIn:HmiRiderSettingsRequestInputPort :>> X2CityComponent_RidingControl::RidingControl::hmiRiderSettingsRequestIn;
        port batteryFaultStatusIn:X2CityContract_BatteryControl::BatteryFaultStatusInputPort :>> X2CityComponent_RidingControl::RidingControl::batteryFaultStatusIn;
        port stateOfChargeIn:X2CityContract_BatteryControl::BatteryStateOfChargeInputPort :>> X2CityComponent_RidingControl::RidingControl::stateOfChargeIn;
        port actualTractionOutputIn:ActualTractionOutputInputPort :>> X2CityComponent_RidingControl::RidingControl::actualTractionOutputIn;
        port batteryOperatingLimitsIn:RidingBatteryOperatingLimitsInputPort :>> X2CityComponent_RidingControl::RidingControl::batteryOperatingLimitsIn;
        port ridingAuthorityOut:RidingAuthorityOutputPort :>> X2CityComponent_RidingControl::RidingControl::ridingAuthorityOut;
        port wheelTorqueCommandOut:WheelTorqueRequestOutputPort :>> X2CityComponent_RidingControl::RidingControl::wheelTorqueCommandOut;
        port selectedFaultIndicationOut:SelectedFaultIndicationOutputPort :>> X2CityComponent_RidingControl::RidingControl::selectedFaultIndicationOut;
        port sleepRequestOut:X2CityContract_Compute::ComputeSleepRequestOutputPort :>> X2CityComponent_RidingControl::RidingControl::sleepRequestOut;
        port platformContextIn:~PlatformContextOutputPort { doc /* Receives Platform startup/reset context once for lifecycle qualification; it does not create another clock source. */ }
        port platformHealthIn:~PlatformHealthOutputPort { doc /* Receives Platform aggregated health and readiness evidence for owner-specific policy checks. */ }
        attribute compiledCalibrationId:String;
        attribute compiledDemandPolicyCalibration:DemandPolicyCalibration;
        attribute compiledCalibrationValid:Boolean;
        attribute lastBatteryOperatingLimitsReceiptTimeMicroseconds:Integer;
    }
}
