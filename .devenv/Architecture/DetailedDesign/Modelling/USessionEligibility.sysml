package X2CityDetailedUnit_SessionEligibility {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_TractionControl::*;
    // Owner: SC-SESSION; DD-001; UR-SESSION-001; SW-I-004.
    item def SessionEligibilityRecord :> PSesAuthOInformation;
    item def SessionEligibilityObservationRecord :> UnitInformationEnvelope;
    port def SessionEligibilityIn {
        doc /* Receives source-specific Ready prerequisites, sensor health and inhibition evidence used to issue or withdraw Session authority. */
        in item payload:ContextualSoftwareInformation;
    }
    port def SessionEligibilityOut {
        doc /* Publishes the authority record with its generation and expiry for Demand and Traction; it does not prove physical safety. */
        out item payload:SessionEligibilityRecord;
    }
    port def SessionEligibilityObservationOut {
        doc /* Publishes the generic eligibility observation for reporting and legacy consumers without weakening the typed authority route. */
        out item payload:SessionEligibilityObservationRecord;
    }
    port def QualifiedMotionIn {
        doc /* Receives U-TRACTION-MOTION's qualified speed, direction and standstill result for existing Session guards; no demand or Hall absence is inferred as standstill. */
        in item payload:QualifiedMotionV1;
    }
    part def USessionEligibility {
        /* Evaluates current Ready prerequisites and riding-session inhibition to publish authority only when all required facts are current and qualified. Direct sensor-health conditions retain producer source/reason for the existing first-recognized-fault policy, while the independent PlatformHealthRecord retains platform fault/readiness input; this unit owns neither physical proof nor sensor aggregation. */
        port prerequisitesIn:SessionEligibilityIn;
        // A typed current physical-motion result gates Ready; absence is not standstill.
        port motionIn:QualifiedMotionIn;
        port authorityOut:SessionEligibilityOut;
        port eligibilityObservationOut:SessionEligibilityObservationOut;
    }
}
