package X2CitySpecification_BatteryControl_RequirementSet {
    private import X2CityComponent_BatteryControl::*;
    private import RequirementTypes::*;

    requirement batteryControlRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryControl architectural
            occurrence.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatteryControl_AssemblySelection::removableBatteryAssemblySelection;
        require X2CitySpecification_BatteryControl_BmsIntegration::integratedBmsConfiguration;
        require X2CitySpecification_BatteryControl_BmsIntegration::batteryInterfaceProvision;
        require X2CitySpecification_BatteryControl_StartupAndClassification::batteryStartupQualification;
        require X2CitySpecification_BatteryControl_StartupAndClassification::batteryOperatingClassification;
        require X2CitySpecification_BatteryControl_OperatingPolicy::dischargePermissiveChargeRestriction;
        require X2CitySpecification_BatteryControl_OperatingPolicy::dischargeVoltageCutoff;
        require X2CitySpecification_BatteryControl_OperatingPolicy::currentBranchIndependence;
        require X2CitySpecification_BatteryControl_OperatingPolicy::dischargeVoltageRecovery;
        require X2CitySpecification_BatteryControl_OperatingPolicy::regenerativeVoltageCutoff;
        require X2CitySpecification_BatteryAssembly_RequirementSet::batteryAssemblyRequirements;
        require X2CitySpecification_BatterySupervision_RequirementSet::batterySupervisionRequirements;
        require X2CitySpecification_BatteryControl_Reporting::batteryStatusReporting;
        require X2CitySpecification_BatteryControl_OperatingPolicy::regenerativeVoltageRecovery;
    }
    satisfy batteryControlRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
}
