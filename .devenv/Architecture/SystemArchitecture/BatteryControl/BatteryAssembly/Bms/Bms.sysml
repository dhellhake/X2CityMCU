package X2CityComponent_Bms {
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_Cells::*;
    private import RequirementTypes::SystemRequirement;

    port def CellGroupTapPort {
        doc /*
            Physical bidirectional tap connection for all 14 series groups for supplied BMS sensing and
            balancing.
        */
        inout item cellGroupTaps:CellGroupTaps;
    }

    port def PackThermalObservationPort {
        doc /*
            Physical available pack thermal-observation connection for supplied BMS monitoring/protection.
        */
        inout item packThermalObservation:PackThermalObservation;
    }

    port def CellBankPowerPort {
        doc /*
            Physical protected-switching connection between cell bank and supplied BMS.
        */
        inout item cellPower:CellBankPower;
    }

    port def PackPowerPort {
        doc /*
            Physical bidirectional BMS pack-power connection to the external pack terminals.
        */
        inout item packPower:BatteryPower;
    }

    part def Bms { // LE-BMS
        doc /*
            Supplied JBD BMS assembly, including opaque vendor firmware. It monitors the cell bank, balances
            fourteen groups, and performs its own protective switching; project software only reads selected
            information and cannot replace or override that protection.
        */
        port cellPower:CellBankPowerPort {
            doc /*
                Physical connection to the 14S5P cell bank.
            */
        }
        port packPower:PackPowerPort {
            doc /*
                Physical protected pack terminal for discharge and regeneration.
            */
        }
        port cellGroupTaps:CellGroupTapPort {
            doc /*
                Physical tap connections for all 14 series groups for vendor sensing and balancing.
            */
        }
        port packThermalObservation:PackThermalObservationPort {
            doc /*
                Available physical pack-temperature observations for vendor monitoring/protection.
            */
        }
        port bmsTelemetryOut:BmsTelemetryOutputPort {
            doc /*
                Read-only UART response carrying the selected BMS-003 source fields.
            */
        }
        port bmsReadRequestIn:BmsReadRequestInputPort {
            doc /*
                Read-only UART request endpoint; it accepts no BMS write, override, or charger command.
            */
        }
    }

    requirement <'REQ-SYS-BMSDEV-001'> selectedBmsIdentity : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BMS.
            Parent: REQ-SYS-BAT-002. Source: owner-confirmed installed unit in BAT-001.
            Planned verification: I, A. Inspect the installed unit and record model, hardware revision and
            firmware identity against the owner-confirmed selection.
            Open: installed-unit identity and effective configuration remain to be accepted under
            OI-041/049/061; firmware identity does not establish protocol revision or wire encoding.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require constraint {
            doc /*
                Bms shall be the selected JBD SP14S004 unit, hardware V1.0, with firmware version 3.2.
            */
        }
    }
    satisfy selectedBmsIdentity by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;

    requirement <'REQ-SYS-BMSDEV-002'> effectiveBmsConfiguration : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BMS.
            Parent: REQ-SYS-BMS-002. Sources: BAT-001 BMS configuration derivation; Battery_Integration
            configuration/SOC acceptance criteria; qualified 14S5P35E operating envelope.
            Planned verification: I, A. Establish the installed configuration identity and effective
            supported settings/units/scales from observable readback and controlled commissioning evidence
            against the linked acceptance criteria; retain this record for integration/service acceptance.
            Open: supported settings, balancing behavior, capacity/SOC calibration and acceptance evidence
            remain under OI-041/049/061; family defaults are not accepted values.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require constraint {
            doc /*
                Bms shall operate using effective supported voltage, current-protection,
                temperature-protection, balancing, capacity and SOC-calibration settings that meet the
                accepted configuration and SOC-source criteria for the fixed 14S5P35E assembly.
            */
        }
    }
    satisfy effectiveBmsConfiguration by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;

    requirement <'REQ-SYS-BMSDEV-004'> effectiveBmsCurrentProtection : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BMS.
            Parent: REQ-SYS-BMS-002. Sources: BAT-001 BMS configuration derivation; Battery_Integration;
            qualified 14S5P35E cell-bank operating envelope.
            Planned verification: A, T-SYS. Exercise charge and discharge current trip, response and release
            criteria against accepted direction-specific thresholds, including host/UART unavailable.
            Open: accepted thresholds, delays, releases, uncertainty and margins remain under
            OI-041/045/049/061.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require constraint {
            doc /*
                Bms shall detect excessive pack charge or discharge current at the accepted
                direction-specific protection thresholds and perform the configured protective action within
                accepted response and release criteria, including when the host and UART are unavailable.
            */
        }
    }
    satisfy effectiveBmsCurrentProtection by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;

    requirement <'REQ-SYS-BMSDEV-005'> effectiveBmsTemperatureProtection : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BMS.
            Parent: REQ-SYS-BMS-002. Sources: BAT-001 BMS configuration derivation; Battery_Integration;
            qualified 14S5P35E operating envelope; REQ-SYS-TMP-001/002.
            Planned verification: A, T-SYS. Exercise applicable hot and cold charge/discharge protection,
            response and release with host/UART unavailable.
            Open: accepted thresholds, delays, release criteria, probes and thermal margins remain under
            OI-041/045/049/061; no numerical values are assumed.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require constraint {
            doc /*
                Bms shall detect battery temperatures outside the accepted charge and discharge protection
                limits and perform the configured protective action within accepted response and release
                criteria, including when the host and UART are unavailable.
            */
        }
    }
    satisfy effectiveBmsTemperatureProtection by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;

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

    requirement bmsRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the supplied Bms architectural
            occurrence.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require X2CityComponent_Bms::selectedBmsIdentity;
        require X2CityComponent_Bms::effectiveBmsConfiguration;
        require X2CityComponent_Bms::bmsMeasurementSources;
        require X2CityComponent_Bms::effectiveBmsCurrentProtection;
        require X2CityComponent_Bms::effectiveBmsTemperatureProtection;
    }
    satisfy bmsRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
}
