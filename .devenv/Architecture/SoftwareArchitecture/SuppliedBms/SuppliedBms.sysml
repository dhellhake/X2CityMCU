package X2CitySoftwareContract_SuppliedBms {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BmsLink::*;
}

package X2CitySoftwareComponent_SuppliedBms {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SuppliedBms::*;
    private import X2CitySoftwareContract_BmsLink::*;
    part def SuppliedBms {
        /* Represents the supplied battery monitoring, balancing, and protective-switching assembly
           as an opaque external role. Its vendor firmware and internal protection behavior are not
           decomposed here; the project connects to it through the protected read transaction. */
        // R-X02 opaque protected read-transaction endpoint; vendor internals remain absent.
        port bmsTransportIo:~BmsTransportExchangePort;
    }
}
