package X2CityComponent_RiderDevices {
    private import X2CitySharedContracts::*;
    private import X2CityContract_HmiElectricalInterface::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_BrakeSignalMeasurement::*;
    part def RiderDevices { // LE-RIDER-DEVICES
        /* Represents the supplied VD18MT grouped energy, information and raw power-lock endpoint plus unqualified accelerator and brake electrical signals. VD18MT firmware remains opaque; display status is not a logical feedback route. */
        port vd18mtConnection:~HmiDevicePort { doc /* Supplied VD18MT logical energy and information endpoint. */ }
        port acceleratorElectricalSignalOut:AcceleratorElectricalSignalOutputPort;
        port brakeElectricalSignalOut:BrakeElectricalSignalOutputPort { doc /* Presents the passive coded-brake network's unqualified electrical signal. */ }
    }
}
