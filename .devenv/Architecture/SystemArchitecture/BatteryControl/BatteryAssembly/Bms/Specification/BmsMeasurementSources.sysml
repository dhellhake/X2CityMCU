package X2CitySpecification_Bms_BmsMeasurementSources {
    private import X2CityComponent_Bms::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMSDEV-003'> bmsMeasurementSources : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BMS.
            Parent: REQ-SYS-BMS-003. Sources: BAT-001 UART information contract; selected-unit read
            acceptance contract; modeled telemetry record.
            Planned verification: I, T-SYS. Characterize each provided quantity against suitable independent
            references and retain source qualification evidence.
            Open: firmware/layout, supported fields, probe availability, accuracy, uncertainty and update
            behavior remain under OI-041/045/049/061; source qualification is not a runtime BMS behavior.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require constraint {
            doc /*
                Bms shall provide read-only UART source information for pack voltage, signed pack current,
                candidate SOC and its source evidence, all fourteen series-group voltages, available
                temperatures, and protection and charge/discharge-path state.
            */
        }
    }
    satisfy bmsMeasurementSources by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
}
