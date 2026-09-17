package X2CityDetailedUnit_TractionActualOutput {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityDetailedUnit_TractionControl::*;
    private import X2CityDetailedUnit_MotorPhaseInterface::*;
    private import X2CityDetailedUnit_HallInterface::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    private import X2CityDetailedUnit_PlatformContext::*;
    // Owner: SC-TRACTION-CTRL.V. It estimates/publishes, and never commands, actual output.
    port def PhaseFeedbackIn {
        doc /* Receives same-operation qualified phase-current feedback used by the wheel-torque estimator. */
        in item payload:PhaseFeedbackV1;
    }
    port def ElectricalPositionIn {
        doc /* Receives map-qualified electrical position associated with the current phase evidence for estimation. */
        in item payload:ElectricalPositionV1;
    }
    port def QualifiedMotionIn {
        doc /* Receives qualified vehicle speed and direction used to establish powered-forward travel; it is not inferred from a torque command. */
        in item payload:QualifiedMotionV1;
    }
    port def OutputStageEvidenceIn {
        doc /* Receives U-TRACTION-OUTPUT's physical-stage availability, state, generation and provenance; it contains no wheel-torque claim by itself. */
        in item payload:PTrOutputIoInformation;
    }
    port def CalibrationIn {
        doc /* Receives activated ActualOutputEstimationCalibration including motor constant, transmission ratio and estimator response bound. */
        in item payload:CalibrationBundleRecord;
    }
    port def PlatformContextIn {
        doc /* Receives the platform context that must match all estimator contributors before an applied-torque estimate is qualified. */
        in item payload:PlatformContextRecord;
    }
    port def PlatformHealthIn {
        doc /* Receives platform health that invalidates the estimate when the estimator's required operating context is unavailable. */
        in item payload:PPltHealthOInformation;
    }
    port def ActualOutputOut {
        doc /* Publishes the qualified applied-wheel-torque estimate, active electrical-braking state and powered-forward evidence to Traction Accept and Demand. */
        out item payload:ActualTractionOutputV1;
    }
    part def UTractionActualOutput {
        /* Publishes an explicitly qualified applied-wheel-torque estimate only from a current
           post-stage output observation, same-operation current/position evidence, qualified
           vehicle motion and released torque-estimation calibration. It preserves estimate
           provenance, observation generation and availability. A demand command, FOC reference,
           acceptance result, CCR/PWM state or output-stage event alone yields unavailable, never
           actual torque/braking/travel. */
        port phaseFeedbackIn:PhaseFeedbackIn;
        port electricalPositionIn:ElectricalPositionIn;
        port qualifiedMotionIn:QualifiedMotionIn;
        port outputStageEvidenceIn:OutputStageEvidenceIn;
        port calibrationIn:CalibrationIn;
        port platformContextIn:PlatformContextIn;
        port platformHealthIn:PlatformHealthIn;
        port actualOutputOut:ActualOutputOut;
    }
}
