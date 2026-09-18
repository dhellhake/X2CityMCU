package X2CitySoftwareContract_HmiAdapter {
    private import X2CitySharedSoftwareTypes::*;
    item def HmiTransportExchange:>ContextualSoftwareInformation;
    port def HmiTransportExchangePort {
        doc /* Exchanges opaque VD18MT transport information with the supplied display endpoint in both directions. HmiAdapter owns protocol parsing and link-loss interpretation; the supplied display firmware remains outside this contract. */
        inout item payload:HmiTransportExchange;
    }
    item def HmiSettingsRequest:>ContextualSoftwareInformation;
    port def HmiSettingsRequestOutputPort {
        doc /* Publishes the HMI settings information parsed and qualified by HmiAdapter to SettingsPolicy. The record is a settings request/context handoff, not an already active demand selection. */
        out item payload:HmiSettingsRequest;
    }
    item def HmiLightRequest:>ContextualSoftwareInformation;
    port def HmiLightRequestOutputPort {
        doc /* Publishes parsed and qualified HMI light requests to LightPolicy. HmiAdapter does not select physical lamp drive modes at this boundary. */
        out item payload:HmiLightRequest;
    }
    port def HmiReportInputPort {
        doc /* Receives session and battery report records for presentation through the HMI adapter. The input is report context consumed by the adapter and does not provide a control return path. */
        in item payload:ContextualSoftwareInformation;
    }
}

package X2CitySoftwareComponent_HmiAdapter {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_HmiAdapter::*;
    private import X2CitySoftwareContract_Platform::*;
    part def HmiAdapter {
        /* Interprets the supplied VD18MT byte exchange into qualified settings/light information
           and consumes session/battery reports for outgoing information. It owns protocol parsing
           and link-loss interpretation, while the supplied display firmware remains opaque. */
        port executionTimeIn:ExecutionTimeInputPort;
        port hmiTransportExchange:HmiTransportExchangePort;
        port hmiSettingsRequestOut:HmiSettingsRequestOutputPort;
        port hmiLightRequestOut:HmiLightRequestOutputPort;
        port hmiReportIn:HmiReportInputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
