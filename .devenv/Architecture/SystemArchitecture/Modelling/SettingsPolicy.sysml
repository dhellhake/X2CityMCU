package X2CityContract_SettingsPolicy {
    private import X2CitySharedContracts::*;
    item def SettingsInformation:>ContextualInformation;
    port def SettingsOut { out item payload:SettingsInformation; }
    port def SettingsIn { in item payload:SettingsInformation; }
    interface def IfA002Settings { end producer:SettingsOut; end consumer:SettingsIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_SettingsPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_ServiceInformation::*;
    part def SettingsPolicy { // LE-SET
        /* Evaluates rider motion and settings from HMI and input into the canonical settings information used by riding policies. It publishes that settings result and service configuration information. */
        port riderMotionIn:QualifiedRiderMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
