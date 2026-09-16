package X2CitySoftwareContract_BmsLink {
    private import X2CitySharedSoftwareTypes::*;
    // P-BMS-TRANSPORT-I/O is the selected read-only transaction boundary contract.
    item def PBmsTransportIoInformation:>ContextualSoftwareInformation;
    port def PBmsTransportIo { inout item payload:PBmsTransportIoInformation; }
    attribute def BmsSourceQualificationContext;
    // P-BMS-OBS-O owns accepted observations and their field/source qualification.
    item def PBmsObsOInformation:>ContextualSoftwareInformation {
        attribute sourceQualificationContext:BmsSourceQualificationContext;
    }
    port def PBmsObsO { out item payload:PBmsObsOInformation; }
}

package X2CitySoftwareComponent_BmsLink {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BmsLink::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-BMS-LINK; static architecture only. No unit-local API, task, or hardware pin is declared here.
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
