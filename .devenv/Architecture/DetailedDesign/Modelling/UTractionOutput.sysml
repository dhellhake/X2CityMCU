package X2CityDetailedUnit_TractionOutput {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_TractionControl::*;
    private import X2CitySoftwareContract_TractionControl::*;
    // Owner: SC-TRACTION-CTRL.V; DD-001/DD-003 and Runtime Integration Contract; UR-TRACTION-OUTPUT-001.
    // Sole owner of literal TIM8 CCR1..4 and JSQR stage/commit; hardware break and external inhibit remain independent.
    port def PWMAndADCSamplingPlanInputPort {
        doc /* Receives U-TRACTION-CONTROL's compare, JSQR sampling-plan and context data for guarded TIM8 stage/commit; literal register ownership remains here. */
        in item payload:PWMAndADCSamplingPlanV1;
    }
    port def OutputObservationOutputPort {
        doc /* Publishes current physical-stage state, availability, generation and provenance to actual-output estimation even at startup, disarmed or withdrawn states; it is not torque evidence. */
        out item payload:TractionOutputStageExchange;
    }
    part def TractionOutputCommitter {
        /* Solely stages and commits literal TIM8 CCR1..4 and JSQR data from PWMAndADCSamplingPlanV1 under the selected inhibit/ordering contract. It owns publication of current physical-stage observation/provenance independently of a new PWM/ADC sampling plan, including startup, disarmed and withdrawn states; a stage fact may be unavailable but is never suppressed merely because no plan was accepted. That evidence feeds the separate actual-output estimator and does not claim physical PWM, gate behavior, braking, travel or torque. */
        port pwmAndAdcSamplingPlanIn:PWMAndADCSamplingPlanInputPort; port outputObservationOut:OutputObservationOutputPort; }
}
