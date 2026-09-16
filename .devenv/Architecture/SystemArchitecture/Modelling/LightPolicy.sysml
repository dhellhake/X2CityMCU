package X2CityContract_LightPolicy {
    private import X2CitySharedContracts::*;
    item def LightIntentInformation:>ContextualInformation;
    port def LightIntentOut { out item payload:LightIntentInformation; }
    port def LightIntentIn { in item payload:LightIntentInformation; }
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
        /* Evaluates rider motion, actual outputs, and HMI/input light requests into a logical light intent. It publishes that intent and service configuration; lamp actuation remains in auxiliary/lamp hardware. */
        port riderMotionIn:QualifiedRiderMotionIn;
        port tractionOutputIn:ActualOutputIn;
        port inputOutputIn:ActualOutputIn;
        port hmiLightInputIn:LightInputIn;
        port inputLightInputIn:LightInputIn;
        port lightIntentOut:LightIntentOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
