package X2CityContract_SessionPolicy {
    private import X2CitySharedContracts::*;
    item def RidingAuthorityInformation:>ContextualInformation { attribute expiry:Expiry; }
    port def RidingAuthorityOut {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        out item payload:RidingAuthorityInformation;
    }
    port def RidingAuthorityIn {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        in item payload:RidingAuthorityInformation;
    }
    interface def IfA004RidingAuthority { end producer:RidingAuthorityOut; end consumer:RidingAuthorityIn; flow producer.payload to consumer.payload; }
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
        /* Evaluates rider motion, settings, battery capability, and observed outputs into riding authority and rider information. It publishes authority, presentation, and service configuration while leaving traction actuation to Traction. */
        port riderMotionIn:QualifiedRiderMotionIn;
        port qualifiedMotionIn:QualifiedMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port batteryEnvelopeIn:BatteryEnvelopeIn;
        port tractionOutputIn:ActualOutputIn;
        port authorityOut:RidingAuthorityOut;
        port riderInformationOut:RiderInformationOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
