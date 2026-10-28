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
    private import X2CitySoftwareContract_BmsLink::*;
    private import X2CitySoftwareContract_Platform::*;
    part def BmsLink {
        /* Implements the fixed SP14S004 V1.0 read protocol. On every normal or unexpected host
           startup, dependent output qualification requires exactly
           two startup checks, both from the current startup's accepted 0x03 reply: firmware
           version 3.2 and reported series-group count 14. Missing, invalid, or mismatching either
           check leaves dependent BmsLink observations unqualified; BatteryProtection consequently
           publishes unqualified dependent limits with effective current zero. Startup qualification
           is private and is not a public flag or port. Every accepted 0x03/0x04/0x05 response still
           receives its exact schema and field qualification checks; scale, NTC/probe validity, and
           complete fourteen-group data remain regular observation qualifications, not additional
           dedicated startup checks. On every normal invocation BmsLink checks private
           per-field source timers, including without a frame. These stay private: publications expose
           values and qualification only. No vendor firmware, BMS write path, or physical protection. */
        port executionTimeIn:ExecutionTimeInputPort;
        port bmsTransportExchange:BmsTransportExchangePort;
        port batteryMeasurementsOut:BatteryMeasurementsOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
