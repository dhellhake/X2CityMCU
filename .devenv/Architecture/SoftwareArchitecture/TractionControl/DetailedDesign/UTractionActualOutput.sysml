package X2CityDetailedUnit_TractionActualOutput {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityDetailedUnit_TractionControl::*;
    private import X2CityDetailedUnit_MotorPhaseInterface::*;
    private import X2CityDetailedUnit_HallInterface::*;
    private import X2CityDetailedUnit_PlatformContext::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    // Owner: SC-TRACTION-CTRL.V. It estimates/publishes, and never commands, actual output.
    port def PhaseFeedbackInputPort {
        doc /* Receives same-operation qualified phase-current feedback used by the wheel-torque estimator. */
        in item payload:PhaseCurrentEpoch;
    }
    port def ElectricalPositionInputPort {
        doc /* Receives map-qualified electrical position associated with the current phase evidence for estimation. */
        in item payload:HallElectricalPosition;
    }
    port def QualifiedMotionInputPort {
        doc /* Receives qualified vehicle speed and direction used to establish powered-forward travel; it is not inferred from a torque command. */
        in item payload:QualifiedMotion;
    }
    port def OutputStageEvidenceInputPort {
        doc /* Receives U-TRACTION-OUTPUT's physical-stage availability, state, generation and provenance; it contains no wheel-torque claim by itself. */
        in item payload:TractionOutputStageExchange;
    }
    port def PlatformContextInputPort {
        doc /* Receives the platform context that must match all estimator contributors before an applied-torque estimate is qualified. */
        in item payload:PlatformContext;
    }
    port def PlatformHealthInputPort {
        doc /* Receives platform health that invalidates the estimate when the estimator's required operating context is unavailable. */
        in item payload:PlatformHealth;
    }
    port def AppliedTractionStateOutputPort {
        doc /* Publishes the qualified applied-wheel-torque estimate, active electrical-braking state and powered-forward evidence to Traction Accept and Demand. */
        out item payload:ActualTractionOutput;
    }
    part def ActualTractionOutputEstimator {
        /* Publishes an explicitly qualified applied-wheel-torque estimate only from a current
           post-stage output observation, same-operation current/position evidence, qualified
           vehicle motion and fixed compiled torque-estimation calibration. It preserves estimate
           provenance, observation generation and availability. A demand command, FOC reference,
           acceptance result, CCR/PWM state or output-stage event alone yields unavailable, never
           actual torque/braking/travel. */
        port executionTimeIn:ExecutionTimeInputPort;
        port phaseFeedbackIn:PhaseFeedbackInputPort;
        port electricalPositionIn:ElectricalPositionInputPort;
        port qualifiedMotionIn:QualifiedMotionInputPort;
        port outputStageEvidenceIn:OutputStageEvidenceInputPort;
        attribute compiledCalibrationId:String;
        attribute compiledActualOutputEstimationCalibration:ActualOutputEstimationCalibration;
        attribute compiledCalibrationValid:Boolean;
        port platformContextIn:PlatformContextInputPort;
        port platformHealthIn:PlatformHealthInputPort;
        port appliedTractionStateOut:AppliedTractionStateOutputPort;
    }
}
