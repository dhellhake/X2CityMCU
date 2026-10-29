package X2CitySpecification_Cells_RequirementSet {
    private import X2CityComponent_Cells::*;
    private import RequirementTypes::*;

    requirement cellsRequirements : AbstractHardwareRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the Cells architectural
            occurrence.
        */
        subject fixedCells:Cells =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.cells;
        require X2CitySpecification_Cells_CellBankComposition::fixedCellBankComposition;
    }
    satisfy cellsRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.cells;
}
