package X2CityComponent_Cells {
    private import X2CityContract_BatteryControl::*;
    private import RequirementTypes::AbstractHardwareRequirement;
    item def CellBankPower { doc /* Physical electrical energy at the fixed 14S5P cell-bank terminals. */ }
    item def CellGroupTaps { doc /* Physical tap connections for all 14 series groups to the supplied BMS for its sensing and balancing. They do not claim a connector pin count, seventy individual cell sensors, or project digitization. */ }
    item def PackThermalObservation { doc /* Physical available pack thermal observation presented to the supplied BMS. Probe count, placement, coverage, and digitization remain BMS/integration concerns. */ }
    port def CellBankPowerPort { doc /* Physical cell-bank power connection to the supplied BMS. */ inout item cellPower:CellBankPower; }
    port def CellGroupTapPort { doc /* Physical bidirectional tap connection for all 14 series groups to the supplied BMS for sensing and balancing. */ inout item cellGroupTaps:CellGroupTaps; }
    port def PackThermalObservationPort { doc /* Physical pack thermal-observation connection to the supplied BMS. */ inout item packThermalObservation:PackThermalObservation; }
    part def Cells { // LE-CELLS
        doc /* Fixed owner-built 14S5P Samsung INR18650-35E cell bank. It supplies physical stored energy and presents fourteen group and available temperature observations to the supplied BMS; it does not imply per-cell sensing or a project software implementation. */
        attribute configuration:String = "14S5P35E";
        port cellPower:CellBankPowerPort { doc /* Physical cell-bank energy terminal to BMS protective switching. */ }
        port cellGroupTaps:CellGroupTapPort { doc /* Physical tap connections for all 14 series groups for BMS sensing and balancing. */ }
        port packThermalObservation:PackThermalObservationPort { doc /* Available physical thermal observations for BMS monitoring; quantity remains open. */ }
    }

    requirement <'REQ-SYS-CELL-001'> fixedCellBankComposition : AbstractHardwareRequirement {
        doc /*
            Status: Draft successor allocation; historical R1.6 approval is provenance only. Allocation: LE-CELLS.
            Parent: REQ-SYS-BAT-002. Sources: DEC-BAT-002; BAT-001.
            Planned verification: I, A. Record the as-built 70-cell inventory and verify the series/parallel group arrangement.
            Open: interconnection, insulation, thermal and integration acceptance remain system work.
        */
        subject fixedCells:Cells = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.cells;
        require constraint {
            doc /*
                Cells shall comprise fourteen series-connected groups, each containing five parallel Samsung
                INR18650-35E cells.
            */
        }
    }
    satisfy fixedCellBankComposition by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.cells;

    requirement cellsRequirements : AbstractHardwareRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the Cells architectural occurrence.
        */
        subject fixedCells:Cells = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.cells;
        require X2CityComponent_Cells::fixedCellBankComposition;
    }
    satisfy cellsRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.cells;
}
