package X2CityContract_SessionPolicy {
    private import X2CitySharedContracts::*;
    item def RidingAuthority:>QualifiedInformationRecord { attribute expiry:Expiry; }
    port def RidingAuthorityOutputPort {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        out item payload:RidingAuthority;
    }
    port def RidingAuthorityInputPort {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        in item payload:RidingAuthority;
    }
    interface def IfA004RidingAuthority { end producer:RidingAuthorityOutputPort; end consumer:RidingAuthorityInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_SessionPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_HmiAdapter::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_ServiceInformation::*;
    part def SessionPolicy { // LE-SESSION
        /* Evaluates qualified rider inputs, vehicle motion, settings, battery capability, and observed outputs into riding authority and rider information. It publishes authority, presentation, and service reporting while leaving traction actuation to Traction. */
        port qualifiedRiderInputIn:RiderControlInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port inputRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port batteryCapabilityEnvelopeIn:BatteryCapabilityEnvelopeInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port ridingAuthorityOut:RidingAuthorityOutputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }
}
