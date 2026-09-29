package X2CityComponent_RiderDevices {
    private import X2CitySharedContracts::*;
    private import X2CityContract_HmiAdapter::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_BrakeSignalMeasurement::*;
    part def RiderDevices { // LE-RIDER-DEVICES
        /* Represents rider-facing devices that present rider information and unqualified accelerator and brake electrical signals. Device implementation is outside the logical policy model. */
        port riderStatusInformationIn:RiderStatusInformationInputPort;
        port acceleratorElectricalSignalOut:AcceleratorElectricalSignalOutputPort;
        port brakeElectricalSignalOut:BrakeElectricalSignalOutputPort { doc /* Presents the passive coded-brake network's unqualified electrical signal. */ }
    }
}
