package X2CityContract_HmiAdapter {
    private import X2CitySharedContracts::*;
    item def RiderInformation:>ContextualInformation;
    item def LightInputInformation:>ContextualInformation;
    port def RiderInformationOut { out item payload:RiderInformation; }
    port def RiderInformationIn { in item payload:RiderInformation; }
    port def LightInputOut { out item payload:LightInputInformation; }
    port def LightInputIn { in item payload:LightInputInformation; }
    interface def IfA006RiderInformation { end producer:RiderInformationOut; end consumer:RiderInformationIn; flow producer.payload to consumer.payload; }
    interface def IfA006LightInput { end producer:LightInputOut; end consumer:LightInputIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_HmiAdapter {
    private import X2CitySharedContracts::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_HmiAdapter::*;
    private import X2CityContract_ServiceInformation::*;
    part def HmiAdapter { // LE-HMI
        /* Adapts rider-facing controls and presentation to settings, lighting input, and rider information contracts. It translates between rider devices and policy components and publishes service configuration information. */
        port settingsOut:SettingsOut;
        port lightInputOut:LightInputOut;
        port riderInformationIn:RiderInformationIn;
        port riderInformationOut:RiderInformationOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
