package X2CityContract_HmiAdapter {
    private import X2CitySharedContracts::*;
    private import X2CityContract_LightControl::*;
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
    part def HmiAdapter { // LE-HMI
        /* Adapts rider-facing controls and presentation to settings, the accepted normal-light request, and rider information contracts. It translates between rider devices and policy components. */
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port normalLightRequestOut:NormalLightRequestOutputPort { doc /* Publishes HMI's accepted On/Off normal-light request with its qualification. */ }
        port riderStatusInformationIn:RiderStatusInformationInputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
    }
}
