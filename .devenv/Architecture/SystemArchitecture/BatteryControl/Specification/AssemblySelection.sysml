package X2CitySpecification_BatteryControl_AssemblySelection {
    private import X2CityComponent_BatteryControl::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BAT-002'> removableBatteryAssemblySelection : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Source: DEC-BAT-002; BAT-001; PD CON-041–042, §10.8.
            Planned verification: I, T-SYS. Reconcile the installed removable pack and its BMS against
            BAT-001 and record the observed configuration.
            Open: initial bay fit, effective configuration and interface qualification remain under
            OI-040/041/062.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatteryAssembly_RequirementSet::assemblySelectionRequirements;
        require constraint {
            doc /*
                BatteryControl shall use the owner-selected removable 14S5P Samsung INR18650-35E battery
                assembly with the JBD SP14S004 BMS and UART interface, as defined in BAT-001.
            */
        }
    }
    satisfy removableBatteryAssemblySelection by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
}
