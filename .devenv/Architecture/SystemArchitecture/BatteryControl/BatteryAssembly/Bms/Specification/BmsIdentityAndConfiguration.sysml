package X2CitySpecification_Bms_BmsIdentityAndConfiguration {
    private import X2CityComponent_Bms::*;
    private import RequirementTypes::*;

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
}
