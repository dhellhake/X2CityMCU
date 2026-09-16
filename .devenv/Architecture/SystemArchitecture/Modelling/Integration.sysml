package X2CityComponent_Integration {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_CarrierHardware::*;
    private import X2CityComponent_EnclosureHardware::*;
    private import X2CityComponent_HarnessHardware::*;
    part def Integration { // LE-INTEGRATION
        /* Composes carrier, enclosure, and harness hardware for physical installation and interconnection. It owns the mechanical/electrical integration boundary without adding software behavior. */
        part carrierHardware:CarrierHardware;
        part enclosureHardware:EnclosureHardware;
        part harnessHardware:HarnessHardware;
    }
}
