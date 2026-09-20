package X2CityDetailedUnit_TractionAccept {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_TractionControl::*;
    // Owner: SC-TRACTION-CTRL.V; DD-001; REQ-SYS-TRQACC-001; SW-I-004/005.
    port def TractionAuthorityInputPort {
        doc /* Receives Session authority with generation and expiry in the common host-boot monotonic microsecond domain for independent acceptance checks. */
        in item payload:RidingAuthority;
    }
    port def TractionCommandInputPort {
        doc /* Receives Demand's signed wheel request with decision sequence, expiry, and both battery current limits. A current command cannot extend authority; the current limits remain amperes and are forwarded unchanged. */
        in item payload:WheelTorqueRequest;
    }
    port def TractionActualOutputInputPort {
        doc /* Receives the independently produced qualified actual-output estimate for forwarding and observation; it is never derived from acceptance. */
        in item payload:ActualTractionOutput;
    }
    port def AppliedTractionStateForwardOutputPort {
        doc /* Forwards the actual-output estimate to Demand across startup, disarmed and withdrawal states without gating or refreshing it. */
        out item payload:ActualTractionOutput;
    }
    item def AcceptedTractionCommandRecord :> WheelTorqueRequest {
        // Calculated from the common-domain minimum of authority expiry and command expiry.
        attribute effectiveAcceptedExpiryTimeMicroseconds:Integer;
    }
    port def AcceptedTractionCommandOutputPort {
        doc /* Sends the accepted signed request and both electrical current limits to U-TRACTION-CONTROL with effectiveAcceptedExpiryTimeMicroseconds equal to the qualified minimum of authority and command expiry. A failed local timeout independently rejects or withdraws the accepted record. */
        out item payload:AcceptedTractionCommandRecord;
    }
    item def TractionObservationRecord :> UnitInformationEnvelope, TractionObservation;
    port def TractionObservationOutputPort {
        doc /* Sends the generic qualified traction observation summary to Session and Light consumers; it cannot replace Demand's typed actual-output route. */
        out item payload:TractionObservationRecord;
    }
    part def TractionCommandAcceptor {
        /* Accepts only current authority and demand with independent valid expiry and matching
           context/configuration. It publishes AcceptedTractionCommandRecord only with effective
            expiry equal to the qualified minimum of authority expiry and command expiry in the
            common host-boot monotonic microsecond domain. A failed local timeout independently
            rejects or withdraws the accepted record; any other failed acceptance condition also
            produces both-sign withdrawal. The separately produced qualified actual-output observation
           remains published across startup, disarmed and withdrawal states; requested torque,
           PWM/register state and acceptance never substitute for actual applied wheel torque or
           powered-forward-travel evidence. The accepted record retains both battery amperage
           limits unchanged for downstream actual-electrical-transfer enforcement. It independently publishes a
           generic qualified traction-observation summary for Session/Light
           consumers; that summary cannot replace the typed actual-output route to Demand. */
        port executionTimeIn:ExecutionTimeInputPort;
        port authorityIn:TractionAuthorityInputPort;
        port commandIn:TractionCommandInputPort;
        port actualOutputIn:TractionActualOutputInputPort;
        port appliedTractionStateOut:AppliedTractionStateForwardOutputPort;
        port acceptedCommandOut:AcceptedTractionCommandOutputPort;
        port observationOut:TractionObservationOutputPort;
    }
}
