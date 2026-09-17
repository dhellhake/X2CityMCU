package X2CityDetailedUnit_TractionAccept {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_TractionControl::*;
    // Owner: SC-TRACTION-CTRL.V; DD-001; REQ-SYS-TRQACC-001; SW-I-004/005.
    port def TractionAuthorityInputPort {
        doc /* Receives Session authority with generation, expiry and clock context for independent acceptance checks. */
        in item payload:RidingAuthority;
    }
    port def TractionCommandInputPort {
        doc /* Receives Demand's signed wheel request with its decision sequence and command expiry; a current command cannot extend authority. */
        in item payload:WheelTorqueRequest;
    }
    port def TractionActualOutputInputPort {
        doc /* Receives the independently produced qualified actual-output estimate for forwarding and observation; it is never derived from acceptance. */
        in item payload:ActualTractionOutputV1;
    }
    port def AppliedTractionStateForwardOutputPort {
        doc /* Forwards the actual-output estimate to Demand across startup, disarmed and withdrawal states without gating or refreshing it. */
        out item payload:ActualTractionOutputV1;
    }
    item def AcceptedTractionCommandRecord :> WheelTorqueRequest {
        // Calculated only when authority and command clock/context match, or their approved
        // conversion is qualified: min(authority expiry, command expiry, acceptance freshness).
        attribute effectiveAcceptedExpiryTimestampTicks:Integer;
        attribute acceptanceClockId:String;
        attribute acceptanceClockContextId:String;
    }
    port def AcceptedTractionCommandOutputPort {
        doc /* Sends the accepted signed request to U-TRACTION-CONTROL with effectiveAcceptedExpiryTimestampTicks equal to the qualified minimum of both expiries and acceptance freshness. */
        out item payload:AcceptedTractionCommandRecord;
    }
    item def TractionObservationRecord :> UnitInformationEnvelope, TractionObservation;
    port def TractionObservationOutputPort {
        doc /* Sends the generic qualified traction observation summary to legacy Session, Battery, Light and Service consumers; it cannot replace Demand's typed actual-output route. */
        out item payload:TractionObservationRecord;
    }
    part def TractionCommandAcceptor {
        /* Accepts only current authority and demand with independent valid expiry and matching
           context/configuration. It publishes AcceptedTractionCommandRecord only with effective
           expiry equal to the qualified minimum of authority expiry, command expiry and the
           acceptance freshness bound in one clock/context; otherwise its accepted record is a
           both-sign withdrawal. The separately produced qualified actual-output observation
           remains published across startup, disarmed and withdrawal states; requested torque,
           PWM/register state and acceptance never substitute for actual applied wheel torque or
           powered-forward-travel evidence. It independently publishes a
           generic qualified traction-observation summary for legacy Session/Battery/Light/Service
           consumers; that summary cannot replace the typed actual-output route to Demand. */
        port authorityIn:TractionAuthorityInputPort;
        port commandIn:TractionCommandInputPort;
        port actualOutputIn:TractionActualOutputInputPort;
        port appliedTractionStateOut:AppliedTractionStateForwardOutputPort;
        port acceptedCommandOut:AcceptedTractionCommandOutputPort;
        port observationOut:TractionObservationOutputPort;
    }
}
