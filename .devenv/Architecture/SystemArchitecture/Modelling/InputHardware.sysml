package X2CityComponent_InputHardware {
    private import X2CityContract_Input::*;
    part def InputHardware { // LE-INPUT-HW
        /* Physical acquisition boundary for motor/board-temperature and PVDD/GVDD signals.
           It shares front-end/controller realization as needed, but owns no BMS endpoint, calibration, timestamp or semantic qualification. */
        port temperatureElectricalSignalIn:TemperatureElectricalSignalInputPort;
        port supplyElectricalSignalIn:SupplyElectricalSignalInputPort;
        port temperatureMeasurementOut:TemperatureMeasurementOutputPort;
        port supplyVoltageMeasurementOut:SupplyVoltageMeasurementOutputPort;
    }
}
