package X2CityDetailedUnit_LightMode {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_MotorControl::*;
    private import X2CitySoftwareContract_HmiAdapter::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_TractionControl::*;
    // Owner: SC-LIGHT-POLICY.V; DD-001; UR-LIGHT-001; SW-I-005/006.
    port def NormalLightRequestUnitInputPort {
        doc /* Receives HMI's qualified normal-light request with current source and reset context. */
        in item payload:HmiLightRequest;
    }
    port def BrakeLeverStateUnitInputPort {
        doc /* Receives InputQualification's qualified mechanical brake-lever state; it is not a braking-force measurement. */
        in item payload:BrakeState;
    }
    port def ElectricalBrakingStateUnitInputPort {
        doc /* Receives Traction's qualified actual motor electrical-braking state and preserves its observation timing. */
        in item payload:ElectricalBrakingStateRecord;
    }
    port def LightModesUnitOutputPort {
        doc /* Sends selected Front Off/On and Rear Off/Dim/Full modes to LightActuation; it does not prove lamp power or visible behavior. */
        out item payload:LightModes;
    }
    part def LightModePolicy {
        /* Combines the retained normal-light request with the qualified mechanical-lever and actual-electrical-braking states. The output is selected mode intent and does not prove lamp power or visible behavior. */
        port executionTimeIn:ExecutionTimeInputPort;
        port runningLightStateIn:NormalLightRequestUnitInputPort;
        port brakeLeverStateIn:BrakeLeverStateUnitInputPort;
        port electricalBrakingStateIn:ElectricalBrakingStateUnitInputPort;
        port lightModesOut:LightModesUnitOutputPort; }
}
