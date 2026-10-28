package X2CityComponent_Bms {
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_Cells::*;
    private import RequirementTypes::SystemRequirement;
    port def CellGroupTapPort { doc /* Physical bidirectional tap connection for all 14 series groups for supplied BMS sensing and balancing. */ inout item cellGroupTaps:CellGroupTaps; }
    port def PackThermalObservationPort { doc /* Physical available pack thermal-observation connection for supplied BMS monitoring/protection. */ inout item packThermalObservation:PackThermalObservation; }
    port def CellBankPowerPort { doc /* Physical protected-switching connection between cell bank and supplied BMS. */ inout item cellPower:CellBankPower; }
    port def PackPowerPort { doc /* Physical bidirectional BMS pack-power connection to the external pack terminals. */ inout item packPower:BatteryPower; }
    part def Bms { // LE-BMS
        doc /* Supplied JBD BMS assembly, including opaque vendor firmware. It monitors the cell bank, balances fourteen groups, and performs its own protective switching; project software only reads selected information and cannot replace or override that protection. */
        port cellPower:CellBankPowerPort { doc /* Physical connection to the 14S5P cell bank. */ }
        port packPower:PackPowerPort { doc /* Physical protected pack terminal for discharge and regeneration. */ }
        port cellGroupTaps:CellGroupTapPort { doc /* Physical tap connections for all 14 series groups for vendor sensing and balancing. */ }
        port packThermalObservation:PackThermalObservationPort { doc /* Available physical pack-temperature observations for vendor monitoring/protection. */ }
        port bmsTelemetryOut:BmsTelemetryOutputPort { doc /* Read-only UART response carrying the selected BMS-003 source fields. */ }
        port bmsReadRequestIn:BmsReadRequestInputPort { doc /* Read-only UART request endpoint; it accepts no BMS write, override, or charger command. */ }
    }

    requirement <'REQ-SYS-BMSDEV-001'> selectedBmsIdentity : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BMS.

            Parent: [REQ-SYS-BAT-002](../BatteryControl.sysml). Related integration dependency:
            [REQ-SYS-BMS-002](../BatteryControl.sysml) uses the installed BMS identity when accepting its effective
            configuration.

            Source: owner-confirmed installed unit, recorded in [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md):
            JBD SP14S004 hardware V1.0, firmware version 3.2. The earlier SP14S004P14S50A designation records the
            provenance of the 14S50A selection, not a separate or unconfirmed alternate device.

            Planned verification: I, A. For integration/commissioning acceptance, inspect the installed unit and record
            its model, board revision, firmware identity and configuration identity against the Configuration acceptance
            baseline in [Battery_Integration.md](../Battery_Integration.md#qualification-evidence-and-response-budget).
            Confirm the owner-recorded hardware V1.0 and firmware 3.2 against the installed unit. Board revision may
            require controlled commissioning evidence when it is not observable over UART. This evidence is independent
            of optional UART identity/version fields; identity recording is acceptance evidence, not additional device
            behavior.

            Open dependencies / qualifications: OI-041/049/061. The selected model, board revision and firmware version
            are owner-confirmed; installed-unit accuracy, firmware support, fixed protocol mapping and effective
            programmed values remain to be verified and accepted. Firmware version 3.2 does not establish protocol
            revision or wire encoding. Project UART reads are not assumed to expose complete device or configuration
            identity.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require constraint {
            doc /*
                Bms shall be the selected JBD SP14S004 hardware V1.0 with firmware version 3.2.
            */
        }
    }
    satisfy selectedBmsIdentity by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;

    requirement <'REQ-SYS-BMSDEV-002'> effectiveBmsConfiguration : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BMS.

            Parent: [REQ-SYS-BMS-002](../BatteryControl.sysml). Related assessment/policy dependencies:
            [REQ-SYS-BMS-006](../BatteryControl.sysml), [REQ-SYS-BMS-007](../BatteryControl.sysml), and
            [REQ-SYS-BMS-008](../BatteryControl.sysml) consume accepted configuration information; they remain
            BatteryControl/Supervision responsibilities.

            Sources:
            [BAT-001 BMS configuration derivation](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md#bms-configuration-derivation),
            [BMS integration](../Battery_Integration.md), and the qualified 14S5P35E cell-bank operating envelope.

            Planned verification: I, A, T-SYS. At commissioning, establish effective supported settings and units/scales
            from observable readback and controlled configuration evidence against the Configuration acceptance baseline
            in [Battery_Integration.md](../Battery_Integration.md#qualification-evidence-and-response-budget). Verify
            configured protection, balancing and capacity/SOC calibration behavior against that baseline's qualified
            cell and system envelopes, including representative trip and release cases; retain the settings and
            effective-behavior evidence for controlled acceptance.

            Open dependencies / qualifications: OI-041/045/049/061; actual parameter support, settings, uncertainty,
            margins, timing, balancing behavior and calibration evidence are unresolved. No family example or default
            establishes an accepted value; commissioning acceptance requires the effective settings and identity
            evidence. Complete configuration readback through the selected project UART is not assumed.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require constraint {
            doc /*
                Bms shall operate according to its effective supported protection, balancing, capacity and
                SOC-calibration settings accepted against the Configuration acceptance baseline in
                [Battery_Integration.md](../Battery_Integration.md#qualification-evidence-and-response-budget).
            */
        }
    }
    satisfy effectiveBmsConfiguration by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;

    requirement <'REQ-SYS-BMSDEV-003'> bmsMeasurementSources : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BMS.

            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Related assessment dependencies:
            [REQ-SYS-BMS-006](../BatteryControl.sysml) and [REQ-SYS-BMS-007](../BatteryControl.sysml) consume these
            source measurements after independent qualification.

            Sources:
            [BAT-001 UART information contract](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md#uart-information-contract),
            [selected-unit read acceptance contract](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            and the modeled BMS telemetry record.

            Planned verification: I, T-SYS. Exercise the installed unit's supported read records and characterize each
            provided quantity against suitable independent references under the Per-consumer information acceptance
            criteria in [Battery_Integration.md](../Battery_Integration.md#qualification-evidence-and-response-budget),
            including signed current direction/scaling and the complete fourteen-group set. Retain source qualification
            evidence for controlled acceptance; this characterization is not a runtime device behavior.

            Open dependencies / qualifications: OI-041/045/049/061; installed firmware/layout, supported fields, probe
            availability, measurement accuracy, uncertainty and update behavior remain open. Establish these before
            source values are credited. BMSIF-001 owns host decoding, validity/source-timeliness assessment and software
            treatment; reported SOC remains a candidate and does not by itself establish actual SOC.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require constraint {
            doc /*
                Bms shall provide read-only UART source information for pack voltage, signed pack current, candidate SOC
                and its relevant source evidence, all fourteen series-group voltages, available temperatures, and
                protection and charge/discharge-path state.
            */
        }
    }
    satisfy bmsMeasurementSources by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;

    requirement bmsRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the supplied Bms architectural occurrence.
        */
        subject bms:Bms = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
        require X2CityComponent_Bms::selectedBmsIdentity;
        require X2CityComponent_Bms::effectiveBmsConfiguration;
        require X2CityComponent_Bms::bmsMeasurementSources;
    }
    satisfy bmsRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batteryAssembly.bms;
}
