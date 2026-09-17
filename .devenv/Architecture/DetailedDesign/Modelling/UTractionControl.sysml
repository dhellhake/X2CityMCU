package X2CityDetailedUnit_TractionControl {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_HallInterface::*;
    private import X2CityDetailedUnit_MotorPhaseInterface::*;
    private import X2CityDetailedUnit_SupplyInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CityDetailedUnit_TractionAccept::*;
    // Owner: SC-TRACTION-CTRL.V; DD-001/DD-003 and Runtime Integration Contract; UR-TRACTION-CONTROL-001.
    // Produces command data only; it never writes a literal compare register.
    item def FastCommandV1 :> UnitInformationEnvelope;
    port def ElectricalPositionIn {
        doc /* Receives current Hall-derived electrical position for bounded FOC angle use. */
        in item payload:ElectricalPositionV1;
    }
    port def PhaseFeedbackIn {
        doc /* Receives same-epoch qualified phase-current feedback for current regulation. */
        in item payload:PhaseFeedbackV1;
    }
    port def FastVdcIn {
        doc /* Receives the same-operation fast local Vdc needed for vector limiting; regular supply diagnostics cannot replace it. */
        in item payload:FastVdcV1;
    }
    port def SensorHealthIn {
        doc /* Receives producer health that causes traction realization to withhold when required feedback or supply evidence is invalid. */
        in item payload:SensorHealthConditionV1;
    }
    port def AcceptedDemandIn {
        doc /* Receives the signed accepted wheel request and rechecks effective expiry in its accepted clock/context before Nm-to-Iq realization. */
        in item payload:AcceptedTractionCommandRecord;
    }
    port def FastCommandOut {
        doc /* Sends compare values, sampling-plan data and the next ADC context epoch to U-TRACTION-OUTPUT; it performs no direct register write. */
        out item payload:FastCommandV1;
    }
    part def UTractionControl {
        /* Consumes only a current accepted signed demand with matched context/expiry, plus
           complete electrical position, phase feedback and fast Vdc for FOC/current-control
           calculation. It independently rejects stale/foreign acceptance or an expired
           effectiveAcceptedExpiryTimestampTicks in the accepted clock/context before Nm-to-Iq
           realization. It produces FastCommandV1 including compare and sampling-plan data; output
           register commit belongs to UTractionOutput. */
        port electricalPositionIn:ElectricalPositionIn; port phaseFeedbackIn:PhaseFeedbackIn; port fastVdcIn:FastVdcIn; port sensorHealthIn:SensorHealthIn; port acceptedDemandIn:AcceptedDemandIn; port fastCommandOut:FastCommandOut; }
}
