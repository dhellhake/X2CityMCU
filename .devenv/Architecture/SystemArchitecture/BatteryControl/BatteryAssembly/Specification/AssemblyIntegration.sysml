package X2CitySpecification_BatteryAssembly_AssemblyIntegration {
    private import X2CityComponent_BatteryAssembly::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BATASM-001'> removablePackIntegration : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-ASSEMBLY.
            Parent: REQ-SYS-BAT-002. Sources: REQ-SYS-CELL-001; BAT-001; modeled cell-bank power, group-tap,
            thermal-observation and protected pack-power interfaces.
            Planned verification: I, A. Inspect the as-built removable assembly and trace each named
            interface end to end.
            Open: electrical compatibility, protection coverage and physical integration acceptance remain
            under OI-041/045/049/061.
        */
        subject assembly:BatteryAssembly =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
        require constraint {
            doc /*
                BatteryAssembly shall provide at its boundary the modeled connections for cell-bank power,
                all fourteen series-group taps, available pack thermal observations, and the protected BMS
                pack-power path.
            */
        }
    }
    satisfy removablePackIntegration by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly;
}
