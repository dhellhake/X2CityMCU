package X2CitySpecification_X2CityMCU_BrakeInterfaceAndPriority {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BRK-001'> brakePriorityOverAccelerator : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-001 (line
            13).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-brk-001"></a>`REQ-SYS-BRK-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Test each lever, both and release of only
            one; correlate coded states with physical handles.
            Sources: [DEC-BRK-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-001),
            [DEC-REF-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-ref-002),
            `OBJ-003`, `OS-006`, `FM-002`, `CON-010`
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-012`: The common trunk is not two
            independent channels; diagnostic coverage is downstream.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Actuation of either brake lever shall inhibit positive accelerator-requested torque.
            */
        }
    }
    satisfy brakePriorityOverAccelerator by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BRK-002'> mechanicalBrakeRegenerationSeparation : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-002 (line
            14).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-brk-002"></a>`REQ-SYS-BRK-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. At zero and negative accelerator demand,
            levers add no separate regenerative request.
            Sources: [DEC-BRK-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-001)
            Open dependencies / qualifications: `WS-OI-002`, `WS-OI-003`, `WS-OI-012`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Brake-lever actuation shall not request regeneration; only the accelerator shall request
                regenerative braking.
            */
        }
    }
    satisfy mechanicalBrakeRegenerationSeparation by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BRK-003'> regenerationDuringMechanicalBraking : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-003 (line
            15).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-brk-003"></a>`REQ-SYS-BRK-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Separate mechanical and motor torque;
            levers do not cancel permitted negative demand.
            Sources: [DEC-BRK-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-001)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-005`, `WS-OI-012`, `WS-OI-013`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Permitted accelerator-requested regeneration shall remain available in addition to
                mechanical braking with either/both levers actuated.
            */
        }
    }
    satisfy regenerationDuringMechanicalBraking by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BRK-004'> propulsionResumptionAfterBrakeRelease : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-004 (line
            16).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-brk-004"></a>`REQ-SYS-BRK-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Hold displaced pedal through normal
            braking; last held lever retains positive inhibition. Valid release after a recognized fault
            must not bypass F.
            Sources: [DEC-BRK-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-002),
            [DEC-REF-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-ref-002)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-010`, `WS-OI-012`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                After both levers are validly released, current accelerator demand shall resume
                automatically under the active profile/permissives, without pedal reset.
            */
        }
    }
    satisfy propulsionResumptionAfterBrakeRelease by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BRK-005'> assistLevelBrakeReleaseRamp : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-005 (line
            17).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-brk-005"></a>`REQ-SYS-BRK-005`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. E: compare post-release torque-time
            profiles; Level 0 retains its own static curve and no regeneration.
            Sources: [DEC-BRK-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-002),
            [DEC-LVL-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-001)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-012`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Positive torque resuming after both-lever release shall use the active level's ramp, except
                Level 0 shall use Level 1's ramp and Level 5 shall add no ramp.
            */
        }
    }
    satisfy assistLevelBrakeReleaseRamp by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BRK-012'> brakeReleaseQualificationAtStartup : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-012 (line
            28).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-brk-012"></a>`REQ-SYS-BRK-012`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. S: unknown or pressed states
            withhold positive permission; all other guards remain effective; recognized faults invoke F.
            Sources: [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001),
            [DEC-BRK-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-001),
            [DEC-FLT-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-002),
            [DEC-REF-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-ref-002)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-010`, `WS-OI-012`: This derives
            startup/brake priority without imposing a rider proof-test or historical release-confirmation
            algorithm.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                After switch-on, positive propulsion shall remain unavailable until brake validity is
                established and both levers are recognized released.
            */
        }
    }
    satisfy brakeReleaseQualificationAtStartup by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
