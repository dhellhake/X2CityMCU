package X2CityComponent_BatteryAssembly {
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_Cells::*;
    private import X2CityComponent_Bms::*;

    part def BatteryAssembly { // LE-BATTERY-ASSEMBLY
        doc /* Removable physical pack composite. It contains the fixed owner-built 14S5P35E Cells and supplied BMS, including vendor firmware for monitoring, balancing, and protective switching. */
        part cells:Cells { doc /* Fixed owner-built 14S5P Samsung INR18650-35E cell bank. */ }
        part bms:Bms { doc /* Supplied JBD BMS with vendor firmware and its monitoring, balancing, and protective-switching function. */ }
        port batteryPower:BatteryPowerPort { doc /* Physical bidirectional pack terminal to BatteryControl's EnergyPath boundary. */ }
        flow cellsPowerToBms from cells.cellPower.cellPower to bms.cellPower.cellPower;
        flow bmsPowerToCells from bms.cellPower.cellPower to cells.cellPower.cellPower;
        flow bmsPowerToBoundary from bms.packPower.packPower to batteryPower.batteryPower;
        flow boundaryPowerToBms from batteryPower.batteryPower to bms.packPower.packPower;
        flow cellGroupTapsToBms from cells.cellGroupTaps.cellGroupTaps to bms.cellGroupTaps.cellGroupTaps;
        flow bmsBalancingToCellGroupTaps from bms.cellGroupTaps.cellGroupTaps to cells.cellGroupTaps.cellGroupTaps;
        flow thermalObservationToBms from cells.packThermalObservation.packThermalObservation to bms.packThermalObservation.packThermalObservation;
    }
}
