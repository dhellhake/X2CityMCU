package X2CityDetailedUnit_BatteryProtectionEvaluate {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_BatterySupervision::*;
    // Owner: SC-BAT-POLICY.V; DD-002; SW-I-003/009.
    item def BatteryAssessmentCandidate :> UnitInformationEnvelope {
        item status:BatteryStatus;
        item operatingLimits:BatteryOperatingLimits;
        item stateOfCharge:BatteryStateOfCharge;
        item batteryCurrent:BatteryCurrent;
    }
    port def BatteryMeasurementsInputPort {
        doc /* Receives only BmsLink's required field-qualified pack measurements. Motor, supply, phase and generic traction diagnostics remain with their owning Session/Traction fault paths. */
        in item payload:BatteryMeasurements;
    }
    port def EnvelopeCandidateOutputPort {
        doc /* Sends independent charge and discharge capability candidates, including their reasons and qualification, to the restriction policy. Applicable shared checks are internal and included in each dependent branch; branch-specific missing evidence withdraws only that branch. A qualified zero is a known capability, not a fault. */
        out item payload:BatteryAssessmentCandidate;
    }
    part def BatteryCapabilityEvaluator {
        attribute compiledVoltageDeratingCalibration:X2CityComponent_BatterySupervision::BatteryVoltageDeratingCalibration;
        attribute compiledBatteryConfigurationId:String;
        attribute compiledBatteryConfigurationValid:Boolean;
        attribute startupNominalCapacityReferenceAmpereHours:Real;
        attribute startupNominalCapacityReferenceQualified:Boolean;
        attribute regenerativeBaseCurrentAmperes:Real;
        attribute dischargeBaseCurrentAmperes:Real;
        /* On every normal invocation, check the private BatteryMeasurements-delivery
           watchdog, including when no publication arrives. Startup/reset begins without
           a usable prior snapshot; establish delivery liveness only after bounded
           resynchronization and a current publication. A current field-qualified snapshot
           may renew this watchdog, including when values are unchanged, but cannot renew
           BmsLink source timers. Expiry withdraws affected inputs and every dependent
           branch qualification/current allowance. Assess independent charge and discharge
           candidates, including applicable shared checks in each branch; publish no
           common qualification. Branch-only evidence loss withdraws only that branch;
           required shared-input loss withdraws every dependent branch. Pack current is
           not presumed mandatory for both branches. A qualified disabled path zeroes only
           its corresponding current branch and retains qualification if other checks pass;
           unknown shared path state leaves dependent branches unqualified. OFF alone is
           neither a fault nor proof of physical isolation; ON removes only the path
           restriction. Recognize restart-required battery faults from qualified operational observations and source/watchdog evidence; privately retain their effect until normal or unexpected controller startup. Publish both branch candidates unqualified with effective zero for that interval while preserving valid measured fields, and separately emit diagnostic status. Ordinary missing initial data and ordinary qualified-zero restrictions do not latch. Never use diagnostic status as a control input. Keep existing restriction and fault rules.

           Own one private per-controller-cycle startup nominal-capacity reference shared by
           charge and discharge assessment. Capture the same qualified finite positive
           reportedNominalCapacityAmpereHours once at normal or unexpected controller startup;
           retain it through the complete cycle. Do not reset, re-recognize, or reacquire it
           after live data loss, expiry, or context changes. BmsLink owns raw decode/scaling
           under UR-BMS-LINK-002; this unit owns the one cache and both calculations. Keep
           regenerativeBaseCurrentAmperes and derive dischargeBaseCurrentAmperes from the
           same C. Regenerative and discharge current curves, interpolation, voltage factors,
           lower-ceiling selection, and qualification behavior are specified by
           REQ-SYS-BATSUP-007–015. Use the compiled voltage-derating pair set owned by
           SC-BAT-POLICY and bound from the canonical BatterySupervision.voltageDeratingCalibration
           source; do not define separate voltage thresholds. During startup self-test:
           For discharge, require its full-current and cutoff thresholds finite and positive,
           with dischargeCutoffVoltageVolts < dischargeFullCurrentVoltageVolts; for regenerative
           charge, independently require its full-current and cutoff thresholds finite and
           positive, with regenerativeFullCurrentVoltageVolts < regenerativeCutoffVoltageVolts.
           Require the compiled set identity and validity to match the owning compiled battery
           configuration. A failed pair check unqualifies only its dependent current branch
           with effective current zero; the opposite branch remains independently assessable.
           A qualified zero from a valid compiled pair/formula is normal known capability.
           Compute and send each qualified branch's pack-ceiling candidate, using its
           applicable qualified measurements and the existing physical-current envelope
           and component constraints. A qualified disabled or prohibited path contributes
           a zero candidate; a missing or unqualified required input leaves that branch
           unqualified with effective zero. The restriction unit applies remaining
           applicable battery-side context constraints and publishes the exact minimum
           of the pack-ceiling candidate and every other applicable qualified battery-side
           current ceiling or restriction. With no other lower limit, that minimum is the
           computed pack ceiling. A qualified zero with required inputs valid is known zero; missing
           required evidence leaves the affected branch unqualified with effective zero.
           Do not infer cell temperature from board MOS/T1; central external T2 assignment
           remains unverified. */
        port executionTimeIn:ExecutionTimeInputPort;
        port batteryMeasurementsIn:BatteryMeasurementsInputPort;
        port candidateOut:EnvelopeCandidateOutputPort;
    }
}
