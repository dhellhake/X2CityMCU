package X2CitySoftwareContract_BmsLink {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_BatteryControl::*;
    item def BmsTransportExchange:>ContextualSoftwareInformation;
    port def BmsTransportExchangePort {
        doc /* Exchanges read transaction requests and responses with the supplied BMS endpoint through the vehicle boundary. The transport payload is opaque at this software contract; BmsLink interprets accepted responses and provides no BMS write or physical protection capability. */
        inout item payload:BmsTransportExchange;
    }
}

package X2CitySoftwareComponent_BmsLink {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BmsLink::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CitySoftwareContract_Platform::*;
    part def BmsLink {
        /* Exchanges read transactions with the supplied BMS endpoint and interprets accepted
           responses into qualified BatteryMeasurements. It provides no vendor BMS firmware,
           BMS write path, or physical protection. Each field retains qualification and its
           host-monotonic last-accepted update reference; that reference is never asserted as a
           BMS measurement time. */
        port executionTimeIn:ExecutionTimeInputPort;
        port bmsTransportExchange:BmsTransportExchangePort;
        port batteryMeasurementsOut:BatteryMeasurementsOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
