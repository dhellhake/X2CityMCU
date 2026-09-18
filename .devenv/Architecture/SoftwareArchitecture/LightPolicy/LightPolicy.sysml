package X2CitySoftwareContract_LightPolicy {
    private import X2CitySharedSoftwareTypes::*;
    port def LightPolicyInputPort {
        doc /* Receives qualified brake, HMI-light and traction-observation records from their producers. LightPolicy uses the current session and source qualification to select logical front and rear modes. */
        in item payload:ContextualSoftwareInformation;
    }
    item def LightIntent:>ContextualSoftwareInformation;
    port def LightIntentOutputPort {
        doc /* Publishes logical light intent to the vehicle boundary. The intent describes policy selection; physical lamp drive and unpowered behavior remain outside this port contract. */
        out item payload:LightIntent;
    }
}

package X2CitySoftwareComponent_LightPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_LightPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    part def LightPolicy {
        /* Retains the normal light request in the current session and selects independent front
           and rear logical modes from qualified inputs. It publishes light intent; physical lamp
           drive and unpowered-state behavior remain outside this software policy component. */
        port executionTimeIn:ExecutionTimeInputPort;
        port lightPolicyInputIn:LightPolicyInputPort;
        port lightIntentOut:LightIntentOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
