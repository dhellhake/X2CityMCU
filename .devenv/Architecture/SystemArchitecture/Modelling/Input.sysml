package X2CityContract_Input {
    private import X2CitySharedContracts::*;
    item def QualifiedRiderMotionInformation:>ContextualInformation;
    port def QualifiedRiderMotionOut {
        doc /* Carries input-qualified accelerator/rest and coded-brake facts to SettingsPolicy, SessionPolicy, DemandPolicy and LightPolicy. These are rider control observations; Traction separately publishes vehicle speed, direction and standstill qualification. */
        out item payload:QualifiedRiderMotionInformation;
    }
    port def QualifiedRiderMotionIn {
        doc /* Carries input-qualified accelerator/rest and coded-brake facts to SettingsPolicy, SessionPolicy, DemandPolicy and LightPolicy. These are rider control observations; Traction separately publishes vehicle speed, direction and standstill qualification. */
        in item payload:QualifiedRiderMotionInformation;
    }
    interface def IfA001QualifiedRiderMotion { end producer:QualifiedRiderMotionOut; end consumer:QualifiedRiderMotionIn; flow producer.payload to consumer.payload; }
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
    part def Input { // LE-INPUT
        /* Composes rider devices, input hardware, qualification, and the BMS link. It acquires
           qualified rider/settings and battery observations. Traction owns motion and actual-output
           feedback; LE-INPUT does not republish those observations. */
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part bmsLink:BmsLink;
        port riderMotionOut:QualifiedRiderMotionOut;
        port settingsOut:SettingsOut;
        port energyObservationIn:BatteryObservationIn;
        port tractionObservationIn:BatteryObservationIn;
        port batteryObservationOut:BatteryObservationOut;
        port lightInputOut:LightInputOut;
    }
}
