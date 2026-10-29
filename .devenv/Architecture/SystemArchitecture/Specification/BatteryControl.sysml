package X2CitySpecification_X2CityMCU_BatteryControl {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMS-001'> batteryOperatingEnvelopeProtection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/BatteryControl/BatteryControl.md#req-sys-bms-001 (line
            87).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-bms-001"></a>`REQ-SYS-BMS-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Derive individual-cell/group worst
            cases and measurement/response margins; verify both current directions, weakest-group voltage,
            boundary temperatures and transient energy during riding. Verify cell-surface discharge within
            −10…60°C and charge acceptance within 0…45°C, with conservative control bounds. Commission the
            BMS protection configuration; record and read back settings; physically validate
            charge/discharge trip thresholds, delays and releases against current, sensing/shunt error,
            imbalance, transient duration and response. Verify operation within the qualified
            voltage/temperature envelope and normal enforcement of communicated budgets. No settings or
            values are yet qualified.
            Sources: PD `OBJ-005`, `OBJ-014`, `CON-040/048`; BAT-001;
            [regeneration requirements](../RidingControl/RidingPolicy/RidingPolicy.md#context-rider-control-regenerative-limits-standstill-and-recovery)
            Open dependencies / qualifications: `OI-040/041/048`, `WS-OI-005/019`: riding ambient minimum is
            revised to −10°C; derive usable current/power envelopes, thermal coverage and transitions from
            colder storage. The ideal 40 A continuous discharge and 10 A charge cell-bank figures are design
            references, not host software clamps; the BMS 50 A designation and cell noncontinuous rating
            establish neither configured protection nor a 50 A regenerative allowance. Configuration
            acceptance remains under BMSDEV-002; physical current-protection settings and validation remain
            open under BMSDEV-004.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                LE-EPCS shall operate within the qualified cell-bank and assembled-pack voltage and
                temperature envelopes and provide physical charge and discharge over-current protection
                through the configured supplied BMS. Normal vehicle control shall enforce communicated
                operating current budgets separately from physical BMS protection.
            */
        }
    }
    satisfy batteryOperatingEnvelopeProtection by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BMS-004'> nonisolatedBmsInterfaceProtection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/BatteryControl/BatteryControl.md#req-sys-bms-004 (line
            88).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-bms-004"></a>`REQ-SYS-BMS-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. Review actual pinout, electrical
            levels, grounding/power domains and permissible vehicle interface arrangement; verify relevant
            powered/unpowered/disconnected states and credible interface faults with suitably rated methods.
            Sources: PD `OBJ-005`, `OI-045/046`; BAT-001;
            [energy protection](../EnergyPath/EnergyPath.md)
            Open dependencies / qualifications: `OI-041/045/046/049`: resolve the explicit non-isolated UART
            warning before vehicle electrical interconnection. Connector B+ is not a logic supply.
            Interface/isolating realization and margins remain to be derived.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Vehicle BMS UART integration shall respect the manufacturer non-isolated-interface
                restriction and preserve battery protection across fitted, handling, shutdown, storage,
                service and BMS-disconnect configurations. Communication wiring or power paths shall not
                bypass protective switching or expose incompatible host circuitry to pack potential.
            */
        }
    }
    satisfy nonisolatedBmsInterfaceProtection by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BMS-005'> bmsProtectionRecoveryCoordination : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/BatteryControl/BatteryControl.md#req-sys-bms-005 (line
            89).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-bms-005"></a>`REQ-SYS-BMS-005` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Exercise charge/discharge path
            interruption, automatic BMS recovery, telemetry return, normal and unexpected vehicle-controller
            restart; separately, protection trip, path interruption and power loss. Verify physical energy
            outcomes and fresh riding Ready guards under their existing release events.
            Sources: PD `OI-041/045/048/049`; BAT-001; DEC-FLT-002–009;
            [energy protection](../EnergyPath/EnergyPath.md)
            Open dependencies / qualifications: `WS-OI-007/018/019`: derive event classification and finite
            protective response. A BMS-reported fault, including a BMS-reported thermal fault, contributes
            to the independent BatteryStatus battery-fault condition and uses 0x07. Physical battery thermal
            protection is allocated to BMSDEV-005; BatterySupervision recognizes BMS-reported faults under
            BATSUP-017/020. Independently recognized applicable thermal-limit faults outside this battery
            fault path use 0x06. Ordinary temperature-based charge ineligibility is a normal restriction and
            produces no fault code.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Vehicle integration shall coordinate BMS trip, disconnect, recovery and riding-controller
                restart behavior with riding fault inhibition, regenerated/residual-energy handling and
                protection-limited auxiliary continuity. BMS protection release or restored telemetry alone
                shall not clear a latched riding fault.
            */
        }
    }
    satisfy bmsProtectionRecoveryCoordination by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BMS-009'> batteryProtectionWithoutController : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/BatteryControl/BatteryControl.md#req-sys-bms-009 (line
            99).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-bms-009"></a>`REQ-SYS-BMS-009`
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ENE-002](EnergyAndProtection.sysml),
            [REQ-SYS-ENE-003](EnergyAndProtection.sysml)
            Planned verification / acceptance: `I`, `A`, `T-SYS`, `T-FI`. Analyze the energized-path
            configurations in
            [energy protection](../EnergyPath/EnergyPath.md), then
            verify loss of each vehicle host/supply/link, BMS charge-path interruption during wheel
            generation, handling and detached storage against assigned physical limits.
            Open dependencies / qualifications: OI-041/045/048/049/061/063. Identify remaining sources,
            protection dependencies, single/common faults, finite residual transfer and physical outcomes
            before protection allocation acceptance. The supplied BMS is a contributor, not proof of
            protection against every fault; no additional circuit or universal independence claim is
            selected.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Assigned battery protection for remaining energized paths shall remain effective within the
                defined fault envelope when the vehicle controller, vehicle supply or BMS UART communication
                is unavailable, and during handling or removed-pack storage. Protection of generated or
                residual energy shall not depend solely on a successfully delivered zero-torque command.
            */
        }
    }
    satisfy batteryProtectionWithoutController by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
