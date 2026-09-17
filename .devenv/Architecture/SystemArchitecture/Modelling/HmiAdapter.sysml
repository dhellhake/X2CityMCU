package X2CityContract_HmiAdapter {
    private import X2CitySharedContracts::*;
    item def RiderStatusInformation:>QualifiedInformationRecord;
    item def LightingContext:>QualifiedInformationRecord;
    port def RiderStatusInformationOutputPort {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        out item payload:RiderStatusInformation;
    }
    port def RiderStatusInformationInputPort {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        in item payload:RiderStatusInformation;
    }
    port def LightingContextOutputPort {
        doc /* Carries the HMI normal-light request or Input-qualified rider and brake lighting facts to LightPolicy. LightPolicy combines these context inputs with traction observations before producing logical light intent. */
        out item payload:LightingContext;
    }
    port def LightingContextInputPort {
        doc /* Carries the HMI normal-light request or Input-qualified rider and brake lighting facts to LightPolicy. LightPolicy combines these context inputs with traction observations before producing logical light intent. */
        in item payload:LightingContext;
    }
    interface def IfA006RiderStatusInformation { end producer:RiderStatusInformationOutputPort; end consumer:RiderStatusInformationInputPort; flow producer.payload to consumer.payload; }
    interface def IfA006LightingContext { end producer:LightingContextOutputPort; end consumer:LightingContextInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_HmiAdapter {
    private import X2CitySharedContracts::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_HmiAdapter::*;
    private import X2CityContract_ServiceInformation::*;
    part def HmiAdapter { // LE-HMI
        /* Adapts rider-facing controls and presentation to settings, lighting input, and rider information contracts. It translates between rider devices and policy components and publishes service report information. */
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port lightingContextOut:LightingContextOutputPort;
        port riderStatusInformationIn:RiderStatusInformationInputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }
}
