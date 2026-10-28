package X2CityDetailedUnit_SessionEligibility {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_RidingControl::*;
    private import X2CitySoftwareContract_HmiAdapter::HmiRiderSettingsRequest;
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorPositionInputPort;
    private import X2CitySoftwareContract_MotorPositionEstimator::MotorPositionInputPort;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityContract_Compute::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CitySoftwareContract_BatteryProtection::BatteryOperatingLimitsAssessment;
    private import X2CitySoftwareContract_BrakeInterface::SoftwareBrakeLeverState;
    // Owner: SC-RIDING-CONTROL; DD-001; UR-SESSION-001; SW-I-004.
    item def SessionEligibilityRecord :> X2CitySoftwareContract_RidingControl::RidingAuthority;
    item def SessionEligibilityObservationRecord :> UnitInformationEnvelope;
    port def RiderSettingsRequestInputPort :> X2CityContract_RidingControl::RiderSettingsRequestInputPort {
        doc /* Receives HMI's concrete qualified level/speed receipt for the current-startup Ready guard. It is not a retained active setting or initialization state. */
        in item payload:HmiRiderSettingsRequest :>> X2CityContract_RidingControl::RiderSettingsRequestInputPort::payload;
    }
    port def SessionEligibilityOutputPort {
        doc /* Publishes the authority record with its generation and expiry for Demand and Traction; it does not prove physical safety. */
        out item payload:SessionEligibilityRecord;
    }
    port def SessionEligibilityObservationOutputPort {
        doc /* Publishes the generic eligibility observation for reporting and legacy consumers without weakening the typed authority route. */
        out item payload:SessionEligibilityObservationRecord;
    }
    port def QualifiedMotionInputPort {
        doc /* Receives U-TRACTION-MOTION's qualified speed, direction and standstill result for existing Session guards; no demand or Hall absence is inferred as standstill. */
        in item payload:QualifiedMotion;
    }
    port def RidingSleepRequestOutputPort :> X2CityContract_Compute::ComputeSleepRequestOutputPort { doc /* Publishes the current qualified Off/sleep eligibility grant or revocation with its qualification; Platform checks it at actual sleep entry. */ }
    port def EligibilityBatteryOperatingLimitsInputPort { doc /* Receives BatteryProtection's current assessed operating limits for the existing Ready guard; the same record is also broadcast to Demand. SessionEligibility owns a last-delivery timer and its own maximum-silence bound, evaluated with caller-supplied ExecutionTime independently of Demand and BmsLink. */ in item payload:BatteryOperatingLimitsAssessment; }
    port def BatteryStateOfChargeInputPort { doc /* Receives qualified actual SOC for Session's existing low-charge selection; it is not the supplied BMS SOC candidate. */ in item payload:BatteryStateOfCharge; }
    port def BrakeLeverStateInputPort :> X2CitySoftwareContract_RidingControl::BrakeLeverStateInputPort { doc /* Receives the exact `BrakeLeverState` composite once, including its software Qualification refinement for source/reason/event-time/context checks. */ in item brakeLeverState:SoftwareBrakeLeverState :>> X2CitySoftwareContract_RidingControl::BrakeLeverStateInputPort::brakeLeverState; }
    part def SessionEligibilityEvaluator {
        /* Evaluates current Ready prerequisites and riding-session inhibition. It checks required discharge-branch qualification for startup, configuration, all 14 groups and applicable protection/path checks. Ready does not require positive current capability, regenerative-charge qualification, or HMI-only battery-current data; a qualified zero discharge limit remains valid capability data. Direct sensor-health conditions retain producer source/reason for the existing first-recognized-fault policy, while the independent PlatformHealthRecord retains platform fault/readiness input; this unit owns neither physical proof nor sensor aggregation. */
        port executionTimeIn:ExecutionTimeInputPort;
        port vehicleOperationRequestIn:RidingVehicleOperationRequestInputPort;
        port runtimeInitializationIn:RidingRuntimeInitializationInputPort;
        port qualifiedTemperatureIn:RidingQualifiedTemperatureInputPort;
        port tractionConditionEvidenceIn:RidingTractionConditionEvidenceInputPort;
        port settingsStateIn:SettingsStateInputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        port ridingSettingsIn:RiderSettingsRequestInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port brakeLeverStateIn:BrakeLeverStateInputPort;
        port motorPositionIn:MotorPositionInputPort;
        // A typed current physical-motion result gates Ready; absence is not standstill.
        port motionIn:QualifiedMotionInputPort;
        port batteryOperatingLimitsIn:EligibilityBatteryOperatingLimitsInputPort;
        port stateOfChargeIn:BatteryStateOfChargeInputPort;
        port authorityOut:SessionEligibilityOutputPort;
        port eligibilityObservationOut:SessionEligibilityObservationOutputPort;
        port sleepRequestOut:RidingSleepRequestOutputPort;
    }
}
