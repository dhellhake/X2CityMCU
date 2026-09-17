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
    item def PWMAndADCSamplingPlanV1 :> UnitInformationEnvelope;
    port def ElectricalPositionInputPort {
        doc /* Receives current Hall-derived electrical position for bounded FOC angle use. */
        in item payload:HallElectricalPositionRecord;
    }
    port def PhaseFeedbackInputPort {
        doc /* Receives same-epoch qualified phase-current feedback for current regulation. */
        in item payload:PhaseCurrentFeedbackRecord;
    }
    port def FastDcLinkVoltageInputPort {
        doc /* Receives the same-operation fast local Vdc needed for vector limiting; regular supply diagnostics cannot replace it. */
        in item payload:FastDcLinkVoltageRecord;
    }
    port def SensorHealthInputPort {
        doc /* Receives producer health that causes traction realization to withhold when required feedback or supply evidence is invalid. */
        in item payload:SensorHealthConditionV1;
    }
    port def AcceptedDemandInputPort {
        doc /* Receives the signed accepted wheel request and rechecks effective expiry in its accepted clock/context before Nm-to-Iq realization. */
        in item payload:AcceptedTractionCommandRecord;
    }
    port def PWMAndADCSamplingPlanOutputPort {
        doc /* Sends compare values, sampling-plan data and the next ADC context epoch to U-TRACTION-OUTPUT; it performs no direct register write. */
        out item payload:PWMAndADCSamplingPlanV1;
    }
    part def FocControl {
        /* Consumes only a current accepted signed demand with matched context/expiry, plus
           complete electrical position, phase feedback and fast Vdc for FOC/current-control
           calculation. It independently rejects stale/foreign acceptance or an expired
           effectiveAcceptedExpiryTimestampTicks in the accepted clock/context before Nm-to-Iq
           realization. It produces PWMAndADCSamplingPlanV1 including compare and sampling-plan data; output
           register commit belongs to TractionOutputCommitter. */
        port electricalPositionIn:ElectricalPositionInputPort; port phaseFeedbackIn:PhaseFeedbackInputPort; port fastDcLinkVoltageIn:FastDcLinkVoltageInputPort; port sensorHealthIn:SensorHealthInputPort; port acceptedDemandIn:AcceptedDemandInputPort; port pwmAndAdcSamplingPlanOut:PWMAndADCSamplingPlanOutputPort; }
}
