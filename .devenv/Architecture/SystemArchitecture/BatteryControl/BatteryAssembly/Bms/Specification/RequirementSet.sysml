package X2CitySpecification_Bms_RequirementSet {
    private import X2CityComponent_Bms::*;
    private import RequirementTypes::*;

    requirement bmsRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the supplied Bms architectural
            occurrence.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require X2CitySpecification_Bms_BmsIdentityAndConfiguration::selectedBmsIdentity;
        require X2CitySpecification_Bms_BmsIdentityAndConfiguration::effectiveBmsConfiguration;
        require X2CitySpecification_Bms_BmsMeasurementSources::bmsMeasurementSources;
        require X2CitySpecification_Bms_BmsIdentityAndConfiguration::effectiveBmsCurrentProtection;
        require X2CitySpecification_Bms_BmsIdentityAndConfiguration::effectiveBmsTemperatureProtection;
    }
    satisfy bmsRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
}
