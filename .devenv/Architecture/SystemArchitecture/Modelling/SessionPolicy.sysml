package X2CityContract_SessionPolicy {
    private import X2CitySharedContracts::*;
    item def RidingAuthorityInformation:>ContextualInformation { attribute expiry:Expiry; }
    port def RidingAuthorityOut { out item payload:RidingAuthorityInformation; }
    port def RidingAuthorityIn { in item payload:RidingAuthorityInformation; }
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
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port capabilityIn:BatteryCapabilityIn;
        port tractionOutputIn:ActualOutputIn;
        port inputOutputIn:ActualOutputIn;
        port authorityOut:RidingAuthorityOut;
        port riderInformationOut:RiderInformationOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
