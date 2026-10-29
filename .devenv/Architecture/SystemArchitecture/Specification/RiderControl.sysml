package X2CitySpecification_X2CityMCU_RiderControl {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-TRQ-001'> acceleratorSignedTorqueDemand : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-001 (line
            21).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-001"></a>`REQ-SYS-TRQ-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. E: vary load/speed and compare
            wheel torque to demand and applicable limits.
            Sources: [DEC-TRQ-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-001),
            `OBJ-003`
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-013`: Separate PD performance
            requirements still apply.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The accelerator shall request signed motor-produced rear-wheel torque, not travel speed or
                vehicle acceleration/deceleration.
            */
        }
    }
    satisfy acceleratorSignedTorqueDemand by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-002'> commonMaximumPositiveTorque : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-002 (line
            22).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-002"></a>`REQ-SYS-TRQ-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. E: compare all six endpoints at
            equivalent speed, SOC, temperature and limits.
            Sources: [DEC-TRQ-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-001)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-013`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Full accelerator shall request the same maximum permitted positive wheel torque in Levels
                0–5 under equivalent conditions.
            */
        }
    }
    satisfy commonMaximumPositiveTorque by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-003'> positiveTorqueLevelProfiles : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-003 (line
            23).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-003"></a>`REQ-SYS-TRQ-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. E: compare normalized shapes,
            ordering and endpoints.
            Sources: [DEC-LVL-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-001),
            [DEC-TRQ-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-001)
            Open dependencies / qualifications: `WS-OI-002`, `WS-OI-003`: Exponential-like response is an
            owner preference, not a prescribed equation; quantitative curves and tolerances remain open.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Positive-branch profiles shall become progressively more linear from Level 0 to 5: lower
                levels gentler initially and steeper later, Level 5 fully linear.
            */
        }
    }
    satisfy positiveTorqueLevelProfiles by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-004'> levelZeroTorqueProfile : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-004 (line
            24).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-004"></a>`REQ-SYS-TRQ-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Sweep travel and release fully;
            distinguish passive drag from commanded torque.
            Sources: [DEC-LVL-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-001),
            [DEC-TRQ-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-002)
            Open dependencies / qualifications: `WS-OI-002`, `WS-OI-003`: Level 0 is not assistance-off.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Level 0 shall use full accelerator travel for positive torque, command zero at physical rest
                and have no regenerative branch.
            */
        }
    }
    satisfy levelZeroTorqueProfile by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-005'> virtualNeutralTorqueProfile : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-005 (line
            25).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-005"></a>`REQ-SYS-TRQ-005`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Verify signs/zero crossing in each
            level; exercise startup, braking, low-speed and operating restrictions separately.
            Sources: [DEC-TRQ-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-002),
            [DEC-LVL-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-001)
            Open dependencies / qualifications: `WS-OI-002`, `WS-OI-003`: 35% may change after system
            validation; calibration, tolerances and any deadband remain open.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Levels 1–5 shall share a provisional neutral at 35% travel: negative demand below, zero at
                and positive above it, subject to torque permissives and
                [REQ-SYS-REG-009](RiderControl.sysml).
            */
        }
    }
    satisfy virtualNeutralTorqueProfile by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-006'> regenerativeTorqueLevelProfiles : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-006 (line
            26).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-006"></a>`REQ-SYS-TRQ-006`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. E: compare negative branches
            normalized to their respective maximum magnitudes, outside taper/other limits.
            Sources: [DEC-TRQ-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-001)
            Open dependencies / qualifications: `WS-OI-002`, `WS-OI-003`: “1:1” selects neither torque units
            nor zero physical latency.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Regenerative profiles shall become progressively more linear from Level 1 to 5; Level 5
                shall be proportional to displacement below virtual neutral.
            */
        }
    }
    satisfy regenerativeTorqueLevelProfiles by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-007'> regenerativeTorqueLevelMagnitude : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-007 (line
            27).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-007"></a>`REQ-SYS-TRQ-007`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. E: compare maxima outside low-speed
            taper; distinguish requested progression from a common overriding output limit.
            Sources: [DEC-TRQ-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-001),
            [DEC-REG-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-001)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-005`, `WS-OI-013`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Maximum requested regenerative magnitude shall increase from Level 1 to 5, with Level 5
                requesting the maximum permitted regenerative torque.
            */
        }
    }
    satisfy regenerativeTorqueLevelMagnitude by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-008'> levelFiveDirectTorqueResponse : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-008 (line
            28).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-008"></a>`REQ-SYS-TRQ-008`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. Inspect deliberate shaping and
            measure response against the derived latency/tolerance criteria.
            Sources: [DEC-TRQ-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-001)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-006`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Level 5 shall follow accelerator torque demand without intentionally added ramp, delay or
                comfort smoothing, subject to operating/safety limits and low-speed taper.
            */
        }
    }
    satisfy levelFiveDirectTorqueResponse by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-009'> regenerativeTorqueResponseGradients : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-009 (line
            29).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-009"></a>`REQ-SYS-TRQ-009`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Compare equivalent demand changes
            against the derived ordered dynamic profiles.
            Sources: [DEC-LVL-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-001),
            [DEC-TRQ-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-001)
            Open dependencies / qualifications: `WS-OI-003`: Dynamic gradient and static curve shape are
            separate; specified cutoff exceptions still apply.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Levels 1–4 shall provide progressively more direct regenerative torque-time response through
                level-dependent gradients.
            */
        }
    }
    satisfy regenerativeTorqueResponseGradients by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQ-010'> forwardTorqueDuringRollback : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-trq-010 (line
            30).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-trq-010"></a>`REQ-SYS-TRQ-010`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. In every level, vary demand
            while rolling backwards and through zero into forward travel; no intermediate stop or extra
            pedal reset. Return to regenerative range invokes [REQ-SYS-REG-009](RiderControl.sysml).
            Sources: [DEC-TRQ-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-003),
            [DEC-TRQ-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-001),
            [DEC-BRK-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-001),
            [DEC-BRK-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-002),
            `OBJ-003`, `PERF-004`, `OI-048`, `OI-054`
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-003`, `WS-OI-005`,
            `WS-OI-006`, `WS-OI-012`, `WS-OI-013`: No automatic rollback hold, stopping-distance guarantee
            or new ramp law; reversal capability and energy flow require validation.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                After Ready, valid positive demand during rollback shall apply forward torque according to
                accelerator position, active profile, brake priority and operating permissives.
            */
        }
    }
    satisfy forwardTorqueDuringRollback by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-001'> regenerationOperatingPermissives : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-001 (line
            36).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-001"></a>`REQ-SYS-REG-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. E: permitted, partially limited and
            inhibited cases; accepted VD18MT/40 km/h cutoff requires zero even with otherwise valid negative
            demand.
            Sources: [DEC-REG-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-001),
            [DEC-SPD-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            `OBJ-003`, `OBJ-005`, `OI-048`
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-005`, `WS-OI-013`, `WS-OI-015`: Complete
            permissive set and permitted torque envelope remain open.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Regeneration shall act only within all applicable operating and safety permissives.
            */
        }
    }
    satisfy regenerationOperatingPermissives by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-003'> regenerationStandstillTaper : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-003 (line
            37).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-003"></a>`REQ-SYS-REG-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Determine onset during system
            validation; compare levels outside masking limits, then progressive reduction and zero endpoint.
            Sources: [DEC-REG-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-002),
            `VS-006`
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-003`, `WS-OI-006`, `WS-OI-013`: Common
            onset does not require equal torque or identical taper shapes; Level 5 also tapers. Numerical
            onset, shape and tolerances remain open.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Regeneration toward standstill shall taper from a common forward-speed onset for Levels 1–5
                to zero negative torque at standstill.
            */
        }
    }
    satisfy regenerationStandstillTaper by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-004'> stationaryMotorHoldProhibition : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-004 (line
            38).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-004"></a>`REQ-SYS-REG-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Test stationary regenerative demand and
            capability recovery without a positive launch request; deliberate launch remains permitted.
            Sources: [DEC-REG-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-002),
            `PERF-004`
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-003`, `WS-OI-006`, `WS-OI-013`: Holding
            is distinct from valid launch torque and passive drag.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Motor torque shall not hold the scooter stationary.
            */
        }
    }
    satisfy stationaryMotorHoldProhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-005'> regenerativeCapabilityRecoveryInhibition : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-005 (line
            39).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-005"></a>`REQ-SYS-REG-005`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Test full disable, partial reduction and
            partial relaxation; permitted reduced torque may continue following demand.
            Sources: [DEC-REG-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-003)
            Open dependencies / qualifications: `WS-OI-002`, `WS-OI-003`, `WS-OI-005`: Capability is
            limited, not frozen actual torque. Restart-required faults follow F instead.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Clearing/relaxing an operating restriction shall not restore/increase regenerative
                capability while the scooter has remained moving and the accelerator continuously in the
                regenerative range since reduction.
            */
        }
    }
    satisfy regenerativeCapabilityRecoveryInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-006'> regenerativeCapabilityRecoveryQualification : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-006 (line
            40).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-006"></a>`REQ-SYS-REG-006`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Exit/re-enter before clearance; stop
            before clearance; restriction begins while stationary. Repeat full/partial cases; a prior
            episode's stop does not qualify a new episode.
            Sources: [DEC-REG-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-003)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-005`: New/overlapping
            episode boundaries remain open; these events cannot clear fault inhibition.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                For restrictions eligible for recovery without restart, leaving the regenerative range or
                being at standstill shall qualify recovery for that episode, even before the restriction
                clears/relaxes.
            */
        }
    }
    satisfy regenerativeCapabilityRecoveryQualification by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-007'> automaticRegenerativeCapabilityRecovery : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-007 (line
            41).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-007"></a>`REQ-SYS-REG-007`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Test both orders of
            qualification/clearance, partial relaxation and overlaps. Recovery alone commands no torque;
            blocked positive demand may qualify range exit but not powered-forward return.
            Sources: [DEC-REG-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-003),
            [DEC-REG-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-002),
            [DEC-REG-006](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-006)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-003`, `WS-OI-005`,
            `WS-OI-006`: Application still requires [REQ-SYS-REG-011](RiderControl.sysml); no automatic
            fault recovery.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                After qualification under [REQ-SYS-REG-006](RiderControl.sysml), regenerative capability
                shall recover automatically as remaining restrictions permit, without another rider action,
                including while stationary.
            */
        }
    }
    satisfy automaticRegenerativeCapabilityRecovery by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-008'> recoveredEnergyPropulsionAvailability : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-008 (line
            42).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-reg-008"></a>`REQ-SYS-REG-008` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. Demonstrate regeneration into
            that band and permitted discharge through 80%; inspect RQ-001 accounting for exclusion of
            above-80% energy and preliminary sizing for no regeneration credit.
            Sources: [DEC-REG-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-001),
            `OBJ-014`, `CON-048`, `RQ-001`, `OI-061`
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-005`, `WS-OI-013`: This neither enlarges
            the 10–80% qualification window nor proves upper-SOC component capability.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Energy recovered above 80% actual SOC within the qualified voltage and temperature charge
                envelope shall remain available for normal propulsion under its permissives.
            */
        }
    }
    satisfy recoveredEnergyPropulsionAvailability by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-009'> rollbackRegenerationInhibition : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-009 (line
            43).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-009"></a>`REQ-SYS-REG-009`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`. After Ready, cover all Levels 1–5,
            rest/other negative-range positions, both lever states, forward braking through zero into
            rollback, and recovered capability during rollback.
            Sources: [DEC-REG-005](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-005),
            [DEC-REG-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-002),
            `OBJ-004`, `PERF-004`, `OI-048`, `OI-054`
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-003`, `WS-OI-006`,
            `WS-OI-013`: Rider mechanical braking controls rollback; positive demand follows
            [REQ-SYS-TRQ-010](RiderControl.sysml).
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                During backward rolling with regenerative-range accelerator demand, the EPCS shall command
                zero torque.
            */
        }
    }
    satisfy rollbackRegenerationInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-010'> parkingPushRegenerationInhibition : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-010 (line
            44).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-010"></a>`REQ-SYS-REG-010`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`. Cover direction changes, physical
            rest/other regenerative positions and restriction clearance at rest/during pushing in Levels
            1–5.
            Sources: [DEC-REG-006](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-006),
            `OS-007`, `FM-003`, `OI-048`,
            [DEC-REG-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-003)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-003`, `WS-OI-005`,
            `WS-OI-006`, `WS-OI-013`: No power-off, Level 0 selection, parking detector or added rider
            control is required; positive launch remains permitted.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                After stopping from riding, the vehicle shall allow hand pushing forwards/backwards into
                parking without commanded regeneration, including while powered.
            */
        }
    }
    satisfy parkingPushRegenerationInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-REG-011'> regenerationEligibilityAfterStopping : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-reg-011 (line
            45).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-reg-011"></a>`REQ-SYS-REG-011`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`. Nonqualifying: hand push, blocked
            positive demand, torque only at standstill, forward torque only during rollback. Qualifying:
            powered forward travel, including after reversal. Test another stop and overlapping full/partial
            restrictions.
            Sources: [DEC-REG-006](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-006),
            `OS-007`, `OI-048`
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-003`, `WS-OI-005`,
            `WS-OI-006`, `WS-OI-012`, `WS-OI-013`: The qualifying event neither commands braking nor
            overrides other limits; Level 0 remains non-regenerative.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                After each stop from riding, regeneration shall remain inhibited until actual forward travel
                with applied positive motor torque resumes; thereafter it shall become eligible
                automatically under the active profile, taper and remaining permissives/recovery rules.
            */
        }
    }
    satisfy regenerationEligibilityAfterStopping by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-SPD-001'> riderSpeedLimitEnforcement : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-spd-001 (line
            53).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-001"></a>`REQ-SYS-SPD-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. B/E: apply representative supported
            lower limits at standstill/rest; verify effective cutoff while accelerator remains a torque
            request.
            Sources: [DEC-SPD-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            `OBJ-007`, `OBJ-012`, `PERF-001`, `OI-032`
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-008`, `WS-OI-009`, `WS-OI-013`,
            `WS-OI-015`: Supported encodings remain to be qualified; decoded zero requests 40 km/h; tighter
            operating limits remain effective.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Valid VD18MT speed limits strictly between 0 and 40 km/h shall constrain motor-assisted
                forward travel in every level.
            */
        }
    }
    satisfy riderSpeedLimitEnforcement by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-SPD-003'> speedCutoffTorqueWithdrawal : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-spd-003 (line
            54).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-003"></a>`REQ-SYS-SPD-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. B/E: approach with each sign,
            including externally driven motion; pending limits cannot move the active cutoff. Verify 40 km/h
            despite initial-setting uncertainty and separate regenerative recovery on falling speed.
            Sources: [DEC-SPD-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            `OBJ-012`, `PERF-001`
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-005`, `WS-OI-013`, `WS-OI-015`: Abrupt
            withdrawal is required here. Finite response/margins and the accepted sustained-speed tolerance
            just below 40 km/h remain open; no gravity-proof speed claim.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                At an accepted active lower speed limit, and unconditionally at 40 km/h forward speed, all
                commanded torque shall withdraw abruptly and remain zero at/above the cutoff, regardless of
                sign, level, pedal or brake state.
            */
        }
    }
    satisfy speedCutoffTorqueWithdrawal by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-SPD-006'> torqueResumptionBelowSpeedCutoff : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-spd-006 (line
            55).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-006"></a>`REQ-SYS-SPD-006`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. B: hold/change demand through
            cutoff/recovery at lower limits and 40; pending requests do not move recovery boundary. Repeat
            crossings and other inhibitions.
            Sources: [DEC-SPD-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001),
            [DEC-BRK-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-001)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-005`, `WS-OI-012`, `WS-OI-013`,
            `WS-OI-015`: Regenerative recovery and fault recovery remain separate.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Below the applicable speed cutoff, current valid positive demand shall resume automatically
                without pedal reset or a new stop, subject to Ready, brake priority and remaining
                permissives.
            */
        }
    }
    satisfy torqueResumptionBelowSpeedCutoff by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-SPD-007'> speedCutoffResumptionRamp : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-spd-007 (line
            56).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-007"></a>`REQ-SYS-SPD-007`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. E: compare with brake release in
            every level; coincident brake/speed recovery uses the same profile without two successive ramps;
            recrossing causes abrupt cutoff.
            Sources: [DEC-SPD-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            [DEC-BRK-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-002)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-012`, `WS-OI-013`, `WS-OI-015`: No
            numerical recovery offset, hysteresis or new ramp is selected.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Positive torque resuming below a speed cutoff shall use
                [REQ-SYS-BRK-005](BrakeInterfaceAndPriority.sysml) resumption ramps.
            */
        }
    }
    satisfy speedCutoffResumptionRamp by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-SPD-009'> nominalWheelControlSpeedBasis : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-sys-spd-009 (line
            57).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-009"></a>`REQ-SYS-SPD-009`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. At fixed physical speed/rotation
            and separate settings, vary display wheel size; verify unchanged control speed, standstill,
            cutoffs and regenerative transitions; record display error separately.
            Sources: [DEC-SPD-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-002)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-008`, `WS-OI-009`, `WS-OI-013`,
            `WS-OI-015`: Rider-induced displayed-speed error is accepted, not a speed-input fault. Validate
            loaded circumference/calibration; nominal size is not measured rolling diameter.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Control speed shall use the retained wheels' fixed nominal 16-inch basis independently of
                the VD18MT wheel-size setting.
            */
        }
    }
    satisfy nominalWheelControlSpeedBasis by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-WLK-001'> motorPoweredWalkAssistanceProhibition : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-veh-wlk-001 (line
            58).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-wlk-001"></a>`REQ-VEH-WLK-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`. Inspect functions and exercise
            supported VD18MT walk requests; these alone command no torque. Preserve valid accelerator
            propulsion/manual parking.
            Sources: [DEC-HMI-004](../../DEC-001_Decisions_and_Open_Issues.md#dec-hmi-004),
            `OI-032`, [DEC-REG-006](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-006)
            Open dependencies / qualifications: `WS-OI-008`, `WS-OI-009`, `WS-OI-010`, `WS-OI-013`: No
            whole-frame rejection, alternative level or fault policy is implied.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The vehicle shall provide no motor-powered walk assistance.
            */
        }
    }
    satisfy motorPoweredWalkAssistanceProhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
