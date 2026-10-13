package X2CitySoftwareContract_LightPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_LightControl::*;
    private import X2CitySoftwareContract_BrakeInterface::SoftwareBrakeLeverState;
    private import X2CityContract_MotorControl::*;
    private import X2CitySoftwareContract_HmiAdapter::HmiNormalLightRequest;
    private import X2CitySoftwareContract_TractionControl::*;
    port def NormalLightRequestInputPort :> X2CityContract_LightControl::NormalLightRequestInputPort {
        doc /* Receives the qualified current-session normal-light request. */
        in item normalLightRequest:HmiNormalLightRequest :>> X2CityContract_LightControl::NormalLightRequestInputPort::normalLightRequest;
    }
    port def BrakeLeverStateInputPort :> X2CityContract_BrakeStateIdentification::BrakeLeverStateInputPort {
        doc /* Receives BrakeInterface's exact `BrakeLeverState` State/Qualification composite. */
        in item brakeLeverState:SoftwareBrakeLeverState :>> X2CityContract_BrakeStateIdentification::BrakeLeverStateInputPort::brakeLeverState;
    }
    port def ElectricalBrakingStateInputPort {
        doc /* Receives actual active motor electrical-braking state from Traction; a torque request is not this state. */
        in item payload:ElectricalBrakingStateRecord;
    }
    port def LightModesOutputPort {
        doc /* Publishes selected Front Off/On and Rear Off/Dim/Full modes to LightActuation. Physical lamp drive, power and visible behavior remain outside this policy contract. */
        out item payload:LightModes;
    }
}

package X2CitySoftwareComponent_LightPolicy {
    private import X2CitySoftwareContract_LightPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    part def LightPolicy {
        /* Retains the normal light request in the current session and selects independent front
           and rear logical modes from qualified brake-lever and actual electrical-braking inputs.
           It publishes LightModes; physical lamp
           drive and unpowered-state behavior remain outside this software policy component. */
        port executionTimeIn:ExecutionTimeInputPort;
        port runningLightStateIn:NormalLightRequestInputPort;
        port brakeLeverStateIn:BrakeLeverStateInputPort;
        port electricalBrakingStateIn:ElectricalBrakingStateInputPort;
        port lightModesOut:LightModesOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
