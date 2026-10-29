package X2CitySpecification_Cells_CellBankComposition {
    private import X2CityComponent_Cells::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-CELL-001'> fixedCellBankComposition : AbstractHardwareRequirement {
        doc /*
            Status: Draft successor allocation; historical R1.6 approval is provenance only. Allocation:
            LE-CELLS.
            Parent: REQ-SYS-BAT-002. Sources: DEC-BAT-002; BAT-001.
            Planned verification: I, A. Record the as-built 70-cell inventory and verify the series/parallel
            group arrangement.
            Open: interconnection, insulation, thermal and integration acceptance remain system work.
        */
        subject fixedCells:Cells =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.cells;
        require constraint {
            doc /*
                Cells shall comprise fourteen series-connected groups, each containing five parallel Samsung
                INR18650-35E cells.
            */
        }
    }
    satisfy fixedCellBankComposition by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.cells;
}
