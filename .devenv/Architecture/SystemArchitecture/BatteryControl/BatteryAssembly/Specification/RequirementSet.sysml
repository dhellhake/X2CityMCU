package X2CitySpecification_BatteryAssembly_RequirementSet {
    private import X2CityComponent_BatteryAssembly::*;
    private import RequirementTypes::*;

    requirement assemblySelectionRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryAssembly architectural
            occurrence.
        */
        subject assembly:BatteryAssembly =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require X2CitySpecification_BatteryAssembly_AssemblyIntegration::removablePackIntegration;
        require X2CitySpecification_Cells_CellBankComposition::fixedCellBankComposition;
        require X2CitySpecification_Bms_BmsIdentityAndConfiguration::selectedBmsIdentity;
    }
    satisfy assemblySelectionRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;

    requirement assemblyConfigurationRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryAssembly architectural
            occurrence.
        */
        subject assembly:BatteryAssembly =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require X2CitySpecification_Bms_BmsIdentityAndConfiguration::effectiveBmsConfiguration;
    }
    satisfy assemblyConfigurationRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;

    requirement assemblySourceInformationRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryAssembly architectural
            occurrence.
        */
        subject assembly:BatteryAssembly =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require X2CitySpecification_Bms_BmsMeasurementSources::bmsMeasurementSources;
    }
    satisfy assemblySourceInformationRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;

    requirement batteryAssemblyRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryAssembly architectural
            occurrence.
        */
        subject assembly:BatteryAssembly =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require X2CitySpecification_BatteryAssembly_AssemblyIntegration::removablePackIntegration;
        require X2CitySpecification_Cells_RequirementSet::cellsRequirements;
        require X2CitySpecification_Bms_RequirementSet::bmsRequirements;
    }
    satisfy batteryAssemblyRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
}
