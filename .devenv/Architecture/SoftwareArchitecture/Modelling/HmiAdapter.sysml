package X2CitySoftwareContract_HmiAdapter {
    private import X2CitySharedSoftwareTypes::*;
    // P-HMI-TRANSPORT-I/O is a stable ARCH-003 port identifier.
    item def PHmiTransportIoInformation:>ContextualSoftwareInformation;
    port def PHmiTransportIo { inout item payload:PHmiTransportIoInformation; }
    // P-HMI-SETTINGS-O is a stable ARCH-003 port identifier.
    item def PHmiSettingsOInformation:>ContextualSoftwareInformation;
    port def PHmiSettingsO { out item payload:PHmiSettingsOInformation; }
    // P-HMI-LIGHT-O is a stable ARCH-003 port identifier.
    item def PHmiLightOInformation:>ContextualSoftwareInformation;
    port def PHmiLightO { out item payload:PHmiLightOInformation; }
    // P-HMI-REPORT-I is a stable ARCH-003 port identifier.
    port def PHmiReportI { in item payload:ContextualSoftwareInformation; }
}

package X2CitySoftwareComponent_HmiAdapter {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_HmiAdapter::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-HMI; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def HmiAdapter {
        /* Interprets the supplied VD18MT byte exchange into qualified settings/light information
           and consumes session/battery reports for outgoing information. It owns protocol parsing
           and link-loss interpretation, while the supplied display firmware remains opaque. */
        port pHmiTransportIo:PHmiTransportIo;
        port pHmiSettingsO:PHmiSettingsO;
        port pHmiLightO:PHmiLightO;
        port pHmiReportI:PHmiReportI;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
