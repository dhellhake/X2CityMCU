package X2CitySoftwareContract_BmsLink {
    private import X2CitySharedSoftwareTypes::*;
    item def PBmsTransportIoInformation:>ContextualSoftwareInformation;
    port def PBmsTransportIo {
        doc /* Exchanges read transaction requests and responses with the supplied BMS endpoint through the vehicle boundary. The transport payload is opaque at this software contract; BmsLink interprets accepted responses and provides no BMS write or physical protection capability. */
        inout item payload:PBmsTransportIoInformation;
    }
    attribute def BmsSourceQualificationContext;
    item def PBmsObsOInformation:>ContextualSoftwareInformation {
        attribute sourceQualificationContext:BmsSourceQualificationContext;
    }
    port def PBmsObsO {
        doc /* Publishes accepted BMS observations with field and source qualification to BatteryProtection and service aggregation. Consumers use the attached qualification context before treating a value as battery evidence. */
        out item payload:PBmsObsOInformation;
    }
}

package X2CitySoftwareComponent_BmsLink {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BmsLink::*;
    private import X2CitySoftwareContract_Platform::*;
    part def BmsLink {
        /* Exchanges read transactions with the supplied BMS endpoint and interprets accepted
           responses into qualified, provenance-preserving battery observations. It does not
           implement vendor BMS firmware or physical protection. */
        port pBmsTransportIo:PBmsTransportIo;
        port pBmsObsO:PBmsObsO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
