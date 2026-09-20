package X2CityContract_HmiAdapter {
    private import X2CitySharedContracts::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_BatteryControl::*;
    item def RiderStatusInformation:>QualifiedInformationRecord;
    port def RiderStatusInformationOutputPort {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        out item payload:RiderStatusInformation;
    }
    port def RiderStatusInformationInputPort {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        in item payload:RiderStatusInformation;
    }
    interface def IfA006RiderStatusInformation { end producer:RiderStatusInformationOutputPort; end consumer:RiderStatusInformationInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_HmiAdapter {
    private import X2CitySharedContracts::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_HmiAdapter::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_BatteryControl::*;
    part def HmiAdapter { // LE-HMI
        /* Adapts rider-facing controls and presentation to settings, accepted normal-light request, rider information, actual SOC, and signed pack current. It translates between rider devices and policy components. */
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port normalLightRequestOut:NormalLightRequestOutputPort { doc /* Publishes HMI's accepted On/Off normal-light request with its qualification. */ }
        port riderStatusInformationIn:RiderStatusInformationInputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
        port stateOfChargeIn:BatteryStateOfChargeInputPort { doc /* Receives qualified actual SOC for HMI-002/003/009 presentation. */ }
        port batteryCurrentIn:BatteryCurrentInputPort { doc /* Receives qualified signed pack current in amperes for HMI-020 presentation. */ }
    }
}
