package X2CityComponent_RiderDevices {
    private import X2CitySharedContracts::*;
    private import X2CityContract_HmiAdapter::*;
    part def RiderDevices { // LE-RIDER-DEVICES
        /* Represents rider-facing devices that present rider information. It consumes the HMI adapter’s rider-information output; device implementation is outside the logical policy model. */
        port riderStatusInformationIn:RiderStatusInformationInputPort;
    }
}
