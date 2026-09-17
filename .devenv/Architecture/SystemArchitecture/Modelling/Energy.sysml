package X2CityComponent_Energy {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_Cells::*;
    private import X2CityComponent_Bms::*;
    private import X2CityComponent_BatteryProtection::*;
    private import X2CityComponent_EnergyPath::*;
    private import X2CityContract_BatteryProtection::*;
    part def Energy { // LE-ENERGY
        /* Composes cells, the supplied BMS, battery protection policy, and the energy path. It supplies battery observations to input qualification and provides the energy-side boundary for capability evaluation. */
        part cells:Cells;
        part bms:Bms;
        part batteryProtection:BatteryProtection;
        part energyPath:EnergyPath;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
    }
}
