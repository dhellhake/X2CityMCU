package X2CityComponent_RiderDevices {
    private import X2CitySharedContracts::*;
    private import X2CityContract_HmiAdapter::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    part def RiderDevices { // LE-RIDER-DEVICES
        /* Represents rider-facing devices that present rider information and the unqualified accelerator electrical signal. Device implementation is outside the logical policy model. */
        port riderStatusInformationIn:RiderStatusInformationInputPort;
        port acceleratorElectricalSignalOut:AcceleratorElectricalSignalOutputPort;
    }
}
