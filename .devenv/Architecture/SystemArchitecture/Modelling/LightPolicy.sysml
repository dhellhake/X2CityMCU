package X2CityContract_LightPolicy {
    private import X2CitySharedContracts::*;
    item def LightIntentInformation:>ContextualInformation;
    port def LightIntentOut {
        doc /* Carries LightPolicy's selected front and rear logical lamp modes to the Auxiliary actuation boundary. Auxiliary applies the intent to lamp hardware; this contract does not define the physical drive implementation. */
        out item payload:LightIntentInformation;
    }
    port def LightIntentIn {
        doc /* Carries LightPolicy's selected front and rear logical lamp modes to the Auxiliary actuation boundary. Auxiliary applies the intent to lamp hardware; this contract does not define the physical drive implementation. */
        in item payload:LightIntentInformation;
    }
    interface def IfA006LightIntent { end producer:LightIntentOut; end consumer:LightIntentIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_LightPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_HmiAdapter::*;
    private import X2CityContract_LightPolicy::*;
    private import X2CityContract_ServiceInformation::*;
    part def LightPolicy { // LE-LIGHT-POLICY
        /* Evaluates qualified rider information, traction-owned actual output, and HMI/input light
           requests into a logical light intent. */
        port riderMotionIn:QualifiedRiderMotionIn;
        port tractionOutputIn:ActualOutputIn;
        port hmiLightInputIn:LightInputIn;
        port inputLightInputIn:LightInputIn;
        port lightIntentOut:LightIntentOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
