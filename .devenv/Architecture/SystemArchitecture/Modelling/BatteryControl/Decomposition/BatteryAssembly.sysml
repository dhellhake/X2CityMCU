package X2CityComponent_BatteryAssembly {
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_Cells::*;
    private import X2CityComponent_Bms::*;
    private import RequirementTypes::SystemRequirement;

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

    requirement <'REQ-SYS-BATASM-001'> removablePackIntegration : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-ASSEMBLY.
            Parent: REQ-SYS-BAT-002. Sources: REQ-SYS-CELL-001; BAT-001; modeled cell-bank power, group-tap,
            thermal-observation and protected pack-power interfaces.
            Planned verification: I, A. Inspect the as-built removable assembly and trace each named interface
            end to end.
            Open: electrical compatibility, protection coverage and physical integration acceptance remain under
            OI-041/045/049/061.
        */
        subject assembly:BatteryAssembly = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require constraint {
            doc /*
                BatteryAssembly shall provide at its boundary the modeled connections for cell-bank power, all
                fourteen series-group taps, available pack thermal observations, and the protected BMS
                pack-power path.
            */
        }
    }
    satisfy removablePackIntegration by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;

    requirement assemblySelectionRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryAssembly architectural occurrence.
        */
        subject assembly:BatteryAssembly = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require X2CityComponent_BatteryAssembly::removablePackIntegration;
        require X2CityComponent_Cells::fixedCellBankComposition;
        require X2CityComponent_Bms::selectedBmsIdentity;
    }
    satisfy assemblySelectionRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;

    requirement assemblyConfigurationRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryAssembly architectural occurrence.
        */
        subject assembly:BatteryAssembly = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require X2CityComponent_Bms::effectiveBmsConfiguration;
    }
    satisfy assemblyConfigurationRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;

    requirement assemblySourceInformationRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryAssembly architectural occurrence.
        */
        subject assembly:BatteryAssembly = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require X2CityComponent_Bms::bmsMeasurementSources;
    }
    satisfy assemblySourceInformationRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;

    requirement batteryAssemblyRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryAssembly architectural occurrence.
        */
        subject assembly:BatteryAssembly = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require X2CityComponent_BatteryAssembly::removablePackIntegration;
        require X2CityComponent_Cells::cellsRequirements;
        require X2CityComponent_Bms::bmsRequirements;
    }
    satisfy batteryAssemblyRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
}
