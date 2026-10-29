package X2CitySpecification_X2CityMCU_AuxiliaryContinuity {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-VEH-PWR-001'> auxiliarySupplyWithdrawalAtDischargeCutoff : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Auxiliary_Continuity.md#req-veh-pwr-001 (line 7).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-pwr-001"></a>`REQ-VEH-PWR-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. L: verify all-load discharge
            bound at cutoff, including withdrawal of auxiliaries and controller power; verify voltage-based
            recovery under the normal startup/Ready guards if power is lost.
            Sources: [DEC-SOC-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-soc-001),
            `OBJ-014`, `CON-050`, `OI-063`
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-010`, `WS-OI-013`,
            `WS-OI-016`, `WS-OI-017`: Physical enforcement and bootstrap/retention remain open; no
            indefinite operating duration or power architecture is specified.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                At the qualified lowest-group-voltage discharge cutoff, the system shall permit withdrawal
                of powered HMI, lighting, brake light and controller supply as needed to respect the
                qualified battery discharge-current ceiling.
            */
        }
    }
    satisfy auxiliarySupplyWithdrawalAtDischargeCutoff by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-PWR-002'> auxiliaryContinuityDuringSocUnavailability : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Auxiliary_Continuity.md#req-veh-pwr-002 (line 8).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-pwr-002"></a>`REQ-VEH-PWR-002` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`, `T-FI`. F/L: include SOC
            restoration without restart, empty fallback, retained light commands and protection no longer
            permitting operation.
            Sources: [DEC-FLT-005](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-005)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-010`, `WS-OI-016`,
            `WS-OI-018`: SOC-only loss does not inhibit torque. Auxiliary permission must be established
            independently of unavailable SOC information; an unqualified capability is not a known qualified
            voltage cutoff. Derive and verify fallback or retention consistent with this continuity
            obligation and any known qualified bound; no forced lamp-on state.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                During SOC-information unavailability, powered HMI/lighting shall continue wherever
                independent battery protection and power availability permit, subject to any known qualified
                total discharge-current bound including zero, under existing commands and indication rules.
            */
        }
    }
    satisfy auxiliaryContinuityDuringSocUnavailability by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-AUX-001'> auxiliaryContinuityDuringPoweredFaults : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Auxiliary_Continuity.md#req-veh-aux-001 (line 9).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-aux-001"></a>`REQ-VEH-AUX-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`, `T-FI`. F/L: battery,
            temperature-limit/information and other faults before/after Ready; separately exercise
            protection requiring supply withdrawal.
            Sources: [DEC-FLT-009](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-009)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-010`, `WS-OI-016`,
            `WS-OI-018`, `WS-OI-019`: An unqualified capability is not a known qualified voltage cutoff.
            Derive and verify fallback or retention consistent with this continuity obligation and any known
            qualified bound. No operation through failed display/light/supply, indefinite duration,
            off-state lighting or protection bypass is promised.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                During powered-on faults, HMI and front/rear lighting shall continue wherever power
                availability, independent electrical protection and affected functions permit, subject to
                any known qualified total discharge-current bound including zero, preserving normal commands
                and brake-light trigger/priority/release rules.
            */
        }
    }
    satisfy auxiliaryContinuityDuringPoweredFaults by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
