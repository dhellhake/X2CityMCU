package X2CitySoftwareContract_SuppliedVd18mt {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_HmiAdapter::*;
}

package X2CitySoftwareComponent_SuppliedVd18mt {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SuppliedVd18mt::*;
    private import X2CitySoftwareContract_HmiAdapter::*;
    // SC-VD18MT; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def SuppliedVd18mt {
        /* Represents the supplied VD18MT display assembly and its opaque firmware as an external
           transport role. The project-facing responsibility is limited to the UART byte/framing
           boundary consumed and produced by HmiAdapter. */
        // R-X01 opaque UART framing/byte endpoint; supplied firmware remains absent.
        port hmiTransportIo:~PHmiTransportIo;
    }
}
