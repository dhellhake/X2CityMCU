package X2CityDetailedUnit_TractionControl {
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_HallInterface::*;
    private import X2CityDetailedUnit_MotorPhaseInterface::*;
    private import X2CityDetailedUnit_SupplyInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // Owner: SC-TRACTION-CTRL.V; DD-001/DD-003 and Runtime Integration Contract; UR-TRACTION-CONTROL-001.
    // Produces command data only; it never writes a literal compare register.
    item def FastCommandV1 :> UnitInformationEnvelope;
    port def ElectricalPositionIn { in item payload:ElectricalPositionV1; }
    port def PhaseFeedbackIn { in item payload:PhaseFeedbackV1; }
    port def FastVdcIn { in item payload:FastVdcV1; }
    port def SensorHealthIn { in item payload:SensorHealthConditionV1; }
    port def FastCommandOut { out item payload:FastCommandV1; }
    part def UTractionControl {
        /* Consumes complete electrical position, phase feedback and fast Vdc for FOC/current-control calculation. It produces FastCommandV1 including compare and sampling-plan data; output register commit belongs to UTractionOutput. */
        port electricalPositionIn:ElectricalPositionIn; port phaseFeedbackIn:PhaseFeedbackIn; port fastVdcIn:FastVdcIn; port sensorHealthIn:SensorHealthIn; port fastCommandOut:FastCommandOut; }
}
