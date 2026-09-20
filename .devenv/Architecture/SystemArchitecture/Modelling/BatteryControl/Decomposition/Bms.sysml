package X2CityComponent_Bms {
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_Cells::*;
    port def CellGroupTapPort { doc /* Physical bidirectional tap connection for all 14 series groups for supplied BMS sensing and balancing. */ inout item cellGroupTaps:CellGroupTaps; }
    port def PackThermalObservationPort { doc /* Physical available pack thermal-observation connection for supplied BMS monitoring/protection. */ inout item packThermalObservation:PackThermalObservation; }
    port def CellBankPowerPort { doc /* Physical protected-switching connection between cell bank and supplied BMS. */ inout item cellPower:CellBankPower; }
    port def PackPowerPort { doc /* Physical bidirectional BMS pack-power connection to the external pack terminals. */ inout item packPower:BatteryPower; }
    part def Bms { // LE-BMS
        doc /* Supplied JBD BMS assembly, including opaque vendor firmware. It monitors the cell bank, balances fourteen groups, and performs its own protective switching; project software only reads selected information and cannot replace or override that protection. */
        port cellPower:CellBankPowerPort { doc /* Physical connection to the 14S5P cell bank. */ }
        port packPower:PackPowerPort { doc /* Physical protected pack terminal for discharge and regeneration. */ }
        port cellGroupTaps:CellGroupTapPort { doc /* Physical tap connections for all 14 series groups for vendor sensing and balancing. */ }
        port packThermalObservation:PackThermalObservationPort { doc /* Available physical pack-temperature observations for vendor monitoring/protection. */ }
        port bmsTelemetryOut:BmsTelemetryOutputPort { doc /* Read-only UART response carrying the selected BMS-003 source fields. */ }
        port bmsReadRequestIn:BmsReadRequestInputPort { doc /* Read-only UART request endpoint; it accepts no BMS write, override, or charger command. */ }
    }
}
