package X2CityContract_Input {
    private import X2CitySharedContracts::*;
    // Interface definitions establish the reusable producer and consumer roles.
    item def QualifiedRiderMotionInformation:>ContextualInformation;
    port def QualifiedRiderMotionOut { out item payload:QualifiedRiderMotionInformation; }
    port def QualifiedRiderMotionIn { in item payload:QualifiedRiderMotionInformation; }
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
        /* Composes rider devices, input hardware, qualification, and the BMS link. It acquires and qualifies rider motion/settings and observations, then publishes canonical motion, settings, light, output, and battery-observation information. */
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part bmsLink:BmsLink;
        port riderMotionOut:QualifiedRiderMotionOut;
        port settingsOut:SettingsOut;
        port energyObservationIn:BatteryObservationIn;
        port tractionObservationIn:BatteryObservationIn;
        port batteryObservationOut:BatteryObservationOut;
        port actualOutputOut:ActualOutputOut;
        port lightInputOut:LightInputOut;
    }
}
