package X2CityDetailedUnit_SessionEligibility {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorPositionInputPort;
    private import X2CitySoftwareContract_TractionControl::*;
    // Owner: SC-SESSION; DD-001; UR-SESSION-001; SW-I-004.
    item def SessionEligibilityRecord :> RidingAuthority;
    item def SessionEligibilityObservationRecord :> UnitInformationEnvelope;
    port def SessionEligibilityInputPort {
        doc /* Receives non-accelerator source-specific Ready prerequisites, sensor health and inhibition evidence used to issue or withdraw Session authority. Accelerator composites use acceleratorPositionIn. */
        in item payload:ContextualSoftwareInformation;
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
    part def SessionEligibilityEvaluator {
        /* Evaluates current Ready prerequisites and riding-session inhibition to publish authority only when all required facts are current and qualified. Direct sensor-health conditions retain producer source/reason for the existing first-recognized-fault policy, while the independent PlatformHealthRecord retains platform fault/readiness input; this unit owns neither physical proof nor sensor aggregation. */
        port prerequisitesIn:SessionEligibilityInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        // A typed current physical-motion result gates Ready; absence is not standstill.
        port motionIn:QualifiedMotionInputPort;
        port authorityOut:SessionEligibilityOutputPort;
        port eligibilityObservationOut:SessionEligibilityObservationOutputPort;
    }
}
