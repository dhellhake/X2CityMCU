package X2CitySoftwareContract_SuppliedBms {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BmsLink::*;
}

package X2CitySoftwareComponent_SuppliedBms {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SuppliedBms::*;
    private import X2CitySoftwareContract_BmsLink::*;
    // SC-BMS; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def SuppliedBms {
        /* Represents the supplied battery monitoring, balancing, and protective-switching assembly
           as an opaque external role. Its vendor firmware and internal protection behavior are not
           decomposed here; the project connects to it through the protected read transaction. */
        // R-X02 opaque protected read-transaction endpoint; vendor internals remain absent.
        port bmsTransportIo:~PBmsTransportIo;
    }
}
