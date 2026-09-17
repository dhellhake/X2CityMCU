package X2CityContract_Input {
    private import X2CitySharedContracts::*;
    item def QualifiedRiderInput:>QualifiedInformationRecord;
    port def RiderControlOutputPort {
        doc /* Carries input-qualified accelerator/rest and coded-brake facts to SettingsPolicy, SessionPolicy, DemandPolicy and LightPolicy. These are rider control observations; Traction separately publishes vehicle speed, direction and standstill qualification. */
        out item payload:QualifiedRiderInput;
    }
    port def RiderControlInputPort {
        doc /* Carries input-qualified accelerator/rest and coded-brake facts to SettingsPolicy, SessionPolicy, DemandPolicy and LightPolicy. These are rider control observations; Traction separately publishes vehicle speed, direction and standstill qualification. */
        in item payload:QualifiedRiderInput;
    }
    interface def IfA001QualifiedRiderInput { end producer:RiderControlOutputPort; end consumer:RiderControlInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_Input {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RiderDevices::*;
    private import X2CityComponent_InputHardware::*;
    private import X2CityComponent_InputQualification::*;
    private import X2CityComponent_BmsLink::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_HmiAdapter::*;
    part def Input { // LE-INPUT
        /* Composes rider devices, input hardware, qualification, and the BMS link. It acquires
           qualified rider-input/settings and battery observations. Traction owns vehicle motion and actual-output
           feedback; LE-INPUT does not republish those observations. */
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part bmsLink:BmsLink;
        port qualifiedRiderInputOut:RiderControlOutputPort;
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port energyBatteryObservationIn:BatteryConditionObservationInputPort;
        port tractionBatteryObservationIn:BatteryConditionObservationInputPort;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
        port lightingContextOut:LightingContextOutputPort;
    }
}
