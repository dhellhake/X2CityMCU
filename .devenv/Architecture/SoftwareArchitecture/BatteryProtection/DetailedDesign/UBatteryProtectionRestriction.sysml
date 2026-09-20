package X2CityDetailedUnit_BatteryProtectionRestriction {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_BatteryProtectionEvaluate::*;
    private import X2CityDetailedUnit_PlatformRetention::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CitySoftwareContract_BatteryProtection::*;
    // Owner: SC-BAT-POLICY.V; DD-002. It owns reached10% restriction and retains no battery-fault history.
    port def BatteryAssessmentCandidateInputPort {
        doc /* Receives evaluated charge/discharge candidates before applying the vehicle reached-10%-SOC restriction and operation context. */
        in item payload:BatteryAssessmentCandidate;
    }
    port def RetentionCandidateInputPort {
        doc /* Receives the platform retention candidate used only after requalification; it cannot recreate a battery fault history. */
        in item payload:RetentionCandidateRecord;
    }
    port def BatteryReadinessAndFaultOutputPort { doc /* Publishes the evaluated startup assessment and distinct recognized battery/thermal fault evidence to Session. */ out item payload:BatteryReadinessAndFault; }
    port def BatteryOperatingLimitsOutputPort { doc /* Publishes independently qualified battery-side discharge and regenerative-charge limits, plus SOC positive-propulsion caps and host-local assessment reference, to Demand. An unavailable or forbidden branch publishes zero permitted current. */ out item payload:BatteryOperatingLimitsAssessment; }
    port def BatteryStateOfChargeOutputPort { doc /* Publishes BatteryProtection's qualified actual SOC for HMI presentation and Session low-charge selection. */ out item payload:BatteryStateOfCharge; }
    port def BatteryCurrentOutputPort { doc /* Publishes BatteryProtection's qualified signed pack current for HMI presentation. */ out item payload:BatteryCurrent; }
    part def BatteryCapabilityRestrictor {
        /* Applies operation context to battery envelope candidates and publishes propulsion and regeneration consequences. Vehicle scope owns the reached10% restriction until qualified actual SOC exceeds 20%; retention is accepted only after requalification, and this unit does not provide physical protection. */
        port executionTimeIn:ExecutionTimeInputPort; port candidateIn:BatteryAssessmentCandidateInputPort; port retentionCandidateIn:RetentionCandidateInputPort; port readinessAndFaultOut:BatteryReadinessAndFaultOutputPort; port operatingLimitsOut:BatteryOperatingLimitsOutputPort; port stateOfChargeOut:BatteryStateOfChargeOutputPort; port batteryCurrentOut:BatteryCurrentOutputPort; }
}
