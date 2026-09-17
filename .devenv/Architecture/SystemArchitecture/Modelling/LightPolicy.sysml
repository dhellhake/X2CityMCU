package X2CityContract_LightPolicy {
    private import X2CitySharedContracts::*;
    item def LightActuationIntent:>QualifiedInformationRecord;
    port def LightActuationIntentOutputPort {
        doc /* Carries LightPolicy's selected front and rear logical lamp modes to the Auxiliary actuation boundary. Auxiliary applies the intent to lamp hardware; this contract does not define the physical drive implementation. */
        out item payload:LightActuationIntent;
    }
    port def LightActuationIntentInputPort {
        doc /* Carries LightPolicy's selected front and rear logical lamp modes to the Auxiliary actuation boundary. Auxiliary applies the intent to lamp hardware; this contract does not define the physical drive implementation. */
        in item payload:LightActuationIntent;
    }
    interface def IfA006LightActuationIntent { end producer:LightActuationIntentOutputPort; end consumer:LightActuationIntentInputPort; flow producer.payload to consumer.payload; }
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
        port qualifiedRiderInputIn:RiderControlInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port hmiLightingContextIn:LightingContextInputPort;
        port inputLightingContextIn:LightingContextInputPort;
        port lightActuationIntentOut:LightActuationIntentOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }
}
