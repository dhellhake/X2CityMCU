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

            Parent: [REQ-SYS-BAT-002](../BatteryControl.sysml). Related integration dependencies:
            [REQ-SYS-BMS-002](../BatteryControl.sysml) and [REQ-SYS-BMS-003](../BatteryControl.sysml) depend on the
            integrated BMS and assembly interfaces.

            Sources: [REQ-SYS-CELL-001](Cells.sysml),
            [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md), and the selected power, group-tap and
            available thermal-observation connections modeled above.

            Planned verification: I, A. Inspect the as-built removable assembly and verify continuity/correct routing of
            cell-bank power, all fourteen series-group taps, available thermal observations, BMS cell-bank power, and
            the BMS protected pack terminal to the assembly boundary.

            Open dependencies / qualifications: OI-041/045/049/061. Preserve the fixed bank and selected BMS;
            electrical-interface compatibility, protection coverage, and physical integration acceptance remain open.
            This requirement selects no connector, wiring, insulation, enclosure, or protection topology.
        */
        subject assembly:BatteryAssembly = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require constraint {
            doc /*
                BatteryAssembly shall integrate the fixed 14S5P35E cell bank and supplied BMS as one removable pack,
                with cell-bank power connected between cells.cellPower and bms.cellPower, all fourteen series-group taps
                connected between cells.cellGroupTaps and bms.cellGroupTaps, available pack thermal observations
                connected from cells.packThermalObservation to bms.packThermalObservation, and the protected BMS
                pack-power path connected between bms.packPower and batteryPower.
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
