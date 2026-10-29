package X2CitySpecification_X2CityMCU_PowerStartupAndFaults {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-PWR-001'> powerButtonOnOffControl : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-pwr-001 (line 13).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-pwr-001"></a>`REQ-SYS-PWR-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Demonstrate both actions on the selected
            unit.
            Sources: [DEC-PWR-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-pwr-001),
            `OBJ-007`, `CON-006`, `VS-003`, `VS-009`
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-009`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The EPCS shall support normal on/off through the VD18MT power button.
            */
        }
    }
    satisfy powerButtonOnOffControl by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-PWR-002'> movingAndStationarySwitchOff : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-pwr-002 (line 14).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-pwr-002"></a>`REQ-SYS-PWR-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Compare stationary and moving switch-off.
            Sources: [DEC-PWR-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-pwr-001)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-013`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Switch-off shall use the same rider action while moving and stationary, without a standstill
                prerequisite.
            */
        }
    }
    satisfy movingAndStationarySwitchOff by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-PWR-003'> torqueWithdrawalAtSwitchOff : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-pwr-003 (line 15).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-pwr-003"></a>`REQ-SYS-PWR-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Switch off during positive torque and
            regeneration; continue moving the accelerator.
            Sources: [DEC-PWR-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-pwr-001),
            `VS-009`
            Open dependencies / qualifications: `WS-OI-007`: Abrupt withdrawal is permitted, not required;
            completion time, residual energy and torque tolerance remain open.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Switch-off shall withdraw both commanded torque signs and prevent further accelerator
                requests while off.
            */
        }
    }
    satisfy torqueWithdrawalAtSwitchOff by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STA-001'> readyEligibilityGuards : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-001 (line 16).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-sta-001"></a>`REQ-SYS-STA-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`, `T-FI`. S: withhold each guard separately;
            late input/settings arrival after leaving standstill/rest must wait for their coincidence again.
            Sources: [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001),
            [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007),
            [DEC-TMP-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-002),
            `OBJ-003`, `VS-003`, `VS-004`, `FM-001`
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-007`, `WS-OI-008`,
            `WS-OI-010`, `WS-OI-012`, `WS-OI-015`, `WS-OI-018`, `WS-OI-019`: Unknown speed is not evidence
            of standstill. The guard applies identically after normal and unexpected restart.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Startup (`VS-003`) shall enter Ready (`VS-004`, drive enabled) only with simultaneous
                standstill and physical accelerator rest, all
                [REQ-SYS-STA-003](PowerStartupAndFaults.sysml)–[REQ-SYS-STA-007](PowerStartupAndFaults.sysml)
                prerequisites, no current-session fault inhibition and applicable operating permissives.
            */
        }
    }
    satisfy readyEligibilityGuards by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STA-002'> preReadyTorqueInhibition : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-002 (line 17).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-sta-002"></a>`REQ-SYS-STA-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`, `T-FI`. S: include regenerative-range
            pedal positions and cleared prior-session fault history.
            Sources: [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001),
            `OBJ-003`, `VS-003`
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-007`, `WS-OI-010`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Before Ready, the EPCS shall command neither positive nor negative torque.
            */
        }
    }
    satisfy preReadyTorqueInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STA-003'> startupRiderInputQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-003 (line 18).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-sta-003"></a>`REQ-SYS-STA-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. S: withhold each
            independently and together; distinguish initial unqualified information from a recognized fault.
            Sources: [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001),
            [DEC-FLT-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-002)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-007`, `WS-OI-010`,
            `WS-OI-012`: Valid lever actuation is not a fault; brake priority still prevents positive
            torque.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Ready shall require current-startup qualification of both accelerator and brake-input
                validity.
            */
        }
    }
    satisfy startupRiderInputQualification by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STA-004'> startupSettingQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-004 (line 19).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-sta-004"></a>`REQ-SYS-STA-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. S: missing either/both blocks
            Ready; previous-session receipt is insufficient. A first interpretable zero or above-40 request
            qualifies as 40 km/h.
            Sources: [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-009`, `WS-OI-010`,
            `WS-OI-015`: No fallback for absent/uninterpretable information; decoded zero normalizes to 40
            km/h; wheel size is separate.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Ready shall require valid level and speed-setting information received from the VD18MT
                during the current startup.
            */
        }
    }
    satisfy startupSettingQualification by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STA-005'> readyWithUnavailableSoc : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-005 (line 20).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-sta-005"></a>`REQ-SYS-STA-005` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`: withhold SOC alone and
            independently withhold required inputs; verify Ready follows the applicable guard.
            Sources: [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001),
            [DEC-FLT-005](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-005)
            Open dependencies / qualifications: `WS-OI-005/007/010/018`: SOC qualification remains required
            for trustworthy display.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Missing or invalid actual-SOC information alone shall not prevent Ready; required startup
                checks and other qualified operating inputs remain applicable.
            */
        }
    }
    satisfy readyWithUnavailableSoc by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STA-006'> startupSelfTestRenewal : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-006 (line 21).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-sta-006"></a>`REQ-SYS-STA-006`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. S/F: cover incomplete/failed
            checks, repaired, persistent and new faults, including temperature normalization after a startup
            fault.
            Sources: [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007),
            [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-010`, `WS-OI-012`, `WS-OI-018`:
            Self-test scope, coverage, completion criteria, duration and reset/brownout coverage remain
            open; passing tests does not prove detection of every failure.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Every normal start and unexpected restart shall perform the required self-tests anew; Ready
                shall require all checks to pass.
            */
        }
    }
    satisfy startupSelfTestRenewal by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STA-007'> startupTemperatureInformationQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-007 (line 22).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-sta-007"></a>`REQ-SYS-STA-007`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. S: withhold each required
            information item; old qualification is insufficient. Recognized loss then restoration without
            restart follows F.
            Sources: [DEC-TMP-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-002),
            [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-010`, `WS-OI-019`: Required information,
            validity and the initial-qualification/fault boundary remain open.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Ready shall require current-startup qualification of the information needed to establish
                operation within applicable temperature limits.
            */
        }
    }
    satisfy startupTemperatureInformationQualification by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-001'> settingsRetentionDuringHmiLoss : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-001 (line 28).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-001"></a>`REQ-SYS-FLT-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. Lose/restore communication
            with active/pending level and speed differences, clamped speed requests, and normal lights
            on/off; retained pending values apply when their guard is met.
            Sources: [DEC-FLT-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-001),
            [DEC-LVL-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-002),
            [DEC-SPD-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            [DEC-HMI-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-hmi-003)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-008`, `WS-OI-009`,
            `WS-OI-010`, `WS-OI-015`, `WS-OI-016`: Initial missing level/speed still blocks Ready; normal
            light requests have no standstill/rest guard.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                VD18MT communication loss shall retain last valid settings and their existing active/pending
                application rules.
            */
        }
    }
    satisfy settingsRetentionDuringHmiLoss by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-002'> functionContinuityDuringHmiLoss : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-002 (line 29).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-002"></a>`REQ-SYS-FLT-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. After Ready with supply
            intact, vary live pedal/levers and exercise speed, SOC and fault limits plus lighting;
            communication recovery adds no restart/stop prerequisite.
            Sources: [DEC-FLT-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-001)
            Open dependencies / qualifications: `WS-OI-005`, `WS-OI-007`, `WS-OI-008`, `WS-OI-010`,
            `WS-OI-012`, `WS-OI-013`: Retain settings, not frozen torque. Deliberate shutdown or actual
            supply loss is separate.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                VD18MT communication loss alone shall not inhibit otherwise permitted functions except
                unavailable VD18MT interaction.
            */
        }
    }
    satisfy functionContinuityDuringHmiLoss by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-003'> invalidAcceleratorTorqueInhibition : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-003 (line 30).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-003"></a>`REQ-SYS-FLT-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-FI`. F: defined invalidities at
            startup/operation; valid pedal displacement alone is not an accelerator fault.
            Sources: [DEC-FLT-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-002),
            `OBJ-003`, `OI-049`
            Open dependencies / qualifications: `WS-OI-002`, `WS-OI-003`, `WS-OI-007`, `WS-OI-010`,
            `WS-OI-013`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Recognized invalid accelerator input shall inhibit both torque signs with zero commanded
                torque.
            */
        }
    }
    satisfy invalidAcceleratorTorqueInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-004'> invalidBrakeTorqueInhibition : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-004 (line 31).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-004"></a>`REQ-SYS-FLT-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-FI`. F/L: exercise bounded detectable
            cases; valid finite lever codes are not faults; mechanical braking remains independent.
            Sources: [DEC-FLT-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-002),
            [DEC-REF-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-ref-002),
            `OBJ-003`, `CON-010`, `OI-037`, `OI-049`
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-010`, `WS-OI-012`, `WS-OI-013`,
            `WS-OI-016`: No complete-branch or universal detection obligation is inherited; bypass
            faults/valid-code aliases remain limitations.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Recognized invalid brake-actuation information from the shared coded loop shall inhibit both
                torque signs with zero commanded torque.
            */
        }
    }
    satisfy invalidBrakeTorqueInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-005'> sessionFaultInhibitionRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-005 (line 32).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-005"></a>`REQ-SYS-FLT-005`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. F: all defined categories,
            recognition phases and nonrestart recovery attempts; persistent/new faults in the next session
            establish fresh inhibition.
            Sources: [DEC-FLT-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-002),
            [DEC-FLT-004](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-004),
            [DEC-FLT-005](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-005),
            [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007),
            [DEC-TMP-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-001),
            [DEC-TMP-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-002),
            [DEC-STA-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-007`, `WS-OI-008`,
            `WS-OI-010`, `WS-OI-012`, `WS-OI-013`, `WS-OI-015`, `WS-OI-018`, `WS-OI-019`: Unexpected clean
            restart needs no additional rider power cycle. Report reset, brake-light release and
            charge-dependent cutoff have separate lifetimes.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                A recognized fault requiring fixing, temperature-limit fault or
                required-temperature-information fault shall retain both-sign torque inhibition throughout
                the session despite clearance. Driving shall become eligible only after a normal/unexpected
                restart with successful self-tests, the complete Ready guard and current permissives.
            */
        }
    }
    satisfy sessionFaultInhibitionRetention by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-006'> freshFaultAssessmentAtRestart : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-006 (line 33).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-006"></a>`REQ-SYS-FLT-006`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. F: repaired, persistent, new
            and reordered overlapping faults; clearing old history alone cannot establish qualified inputs
            or Ready. Communication outage is not restart.
            Sources: [DEC-FLT-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-002),
            [DEC-FLT-004](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-004),
            [DEC-FLT-005](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-005),
            [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-010`, `WS-OI-012`,
            `WS-OI-013`, `WS-OI-018`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Every restart shall assess faults afresh without assuming old faults remain present,
                applying the defined response when current fault presence is recognized.
            */
        }
    }
    satisfy freshFaultAssessmentAtRestart by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-007'> speedInformationLossTorqueInhibition : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-007 (line 34).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-007"></a>`REQ-SYS-FLT-007`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. F: unknown speed cannot
            qualify standstill; valid control speed with display wheel mismatch, unrecognized limit request
            or HMI outage alone is not this fault.
            Sources: [DEC-FLT-004](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-004),
            [DEC-SPD-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-002)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-007`, `WS-OI-008`, `WS-OI-010`,
            `WS-OI-013`, `WS-OI-015`.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Recognized loss of reliable vehicle-speed determination shall inhibit both torque signs with
                zero commanded torque.
            */
        }
    }
    satisfy speedInformationLossTorqueInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-008'> socInformationLossReporting : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-008 (line 35).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-flt-008"></a>`REQ-SYS-FLT-008` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`: lose and restore SOC alone;
            independently inject required-source and actual battery faults and verify their retained
            reactions.
            Sources: [DEC-FLT-005](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-005)
            Open dependencies / qualifications: `WS-OI-005/007/010/018`: Whole-frame loss and other
            required-field faults retain their existing rules.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Loss or invalidity of SOC information alone shall affect SOC reporting only and shall not
                inhibit either torque sign or create a battery fault. Restored qualified SOC shall restore
                its display without restart.
            */
        }
    }
    satisfy socInformationLossReporting by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-009'> commonFaultTorqueInhibition : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-009 (line 36).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-009"></a>`REQ-SYS-FLT-009`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. F: verify the EPCS physical
            torque response independently of selected report/link availability, plus assigned electrical
            protection responses. Supplied mechanical braking remains an external assumption.
            Sources: [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007),
            [DEC-TMP-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-001),
            [DEC-TMP-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-002)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-010`, `WS-OI-012`, `WS-OI-013`,
            `WS-OI-018`, `WS-OI-019`: Abrupt withdrawal is permitted in every level, not mandated. Low
            charge, normal operating restrictions and HMI communication loss retain their separate rules.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                All faults requiring fixing, including actual battery faults, plus
                temperature-limit/information faults shall inhibit both commanded torque signs identically
                at startup and during operation.
            */
        }
    }
    satisfy commonFaultTorqueInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-010'> startupSocUnavailabilityReporting : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-010 (line 37).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-flt-010"></a>`REQ-SYS-FLT-010` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`: withhold SOC through startup
            and restore it, independently injecting actual battery and required-information faults.
            Sources: [DEC-FLT-005](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-005),
            [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007)
            Open dependencies / qualifications: `WS-OI-005/007/010/018`: BMS-reported errors and other
            required-data faults retain their assigned responses and reporting.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Failure to qualify SOC at startup alone shall affect SOC reporting only; it shall not create
                battery fault 0x07 or prevent Ready.
            */
        }
    }
    satisfy startupSocUnavailabilityReporting by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-011'> failureHistoryDiscardAtRestart : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-011 (line 38).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-011"></a>`REQ-SYS-FLT-011`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. Inspect retained-state
            design; F/H: cleared faults leave no old history, report or inhibition; persistent faults must
            be detected anew.
            Sources: [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007)
            Open dependencies / qualifications: `OI-047`, `WS-OI-007`, `WS-OI-009`, `WS-OI-010`,
            `WS-OI-018`: Current-session first-fault retention remains required; the charge-dependent cutoff
            is not a failure record.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                No past-failure history, including persistent diagnostic fault records, shall survive a
                normal or unexpected restart.
            */
        }
    }
    satisfy failureHistoryDiscardAtRestart by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FLT-012'> motorOutputInformationLossResponse : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-012 (line 39).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-flt-012"></a>`REQ-SYS-FLT-012`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. Qualify output information,
            then independently lose/invalidate its required contributors during positive, negative and zero
            demand; restore information without restart and verify retained inhibition/reporting with
            independent light recovery. Repeat clean, persistent and new-fault restarts.
            Sources: [DEC-FLT-011](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-011),
            [REQ-SYS-INT-003](../Traction/Specification/InterfaceQualification.sysml),
            [REQ-VEH-HMI-016](../DriverInteraction/HMIControl/Specification/Requirements.sysml)
            Open dependencies / qualifications: WS-OI-001/006/007/010/016: derive required
            observations/inference, loss criteria, coverage and finite response. Initial unqualified
            information follows startup criteria; it is not by itself loss of a previously qualified source.
            Do not infer physical zero torque or cleared braking from zero command.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Recognized invalidity or loss of previously qualified information required to determine
                actual motor output shall inhibit both commanded torque signs and retain inhibition until a
                qualifying restart under REQ-SYS-FLT-005/006. Report the selected fault as 0x05 unless an
                existing specific project code applies.
            */
        }
    }
    satisfy motorOutputInformationLossResponse by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TMP-001'> temperatureLimitFaultResponse : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-tmp-001 (line 45).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-tmp-001"></a>`REQ-SYS-TMP-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`, `T-FI`. F: cover every
            established component hot/cold limit; normalization or repeated passing checks within the
            session does not release inhibition.
            Sources: [DEC-TMP-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-001),
            [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007),
            `PERF-007`, `OI-025`, `OI-041`, `OI-049`
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-005`, `WS-OI-007`, `WS-OI-010`,
            `WS-OI-013`, `WS-OI-019`: No reduced/selective operation after recognition. Abrupt withdrawal is
            permitted; thermal limits, margins, coverage and finite response remain open.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                A recognized violation of any applicable upper/lower temperature limit shall invoke
                [REQ-SYS-FLT-009](PowerStartupAndFaults.sysml)/[REQ-SYS-FLT-005](PowerStartupAndFaults.sysml):
                both torque signs inhibited, no Ready and recovery only after a qualifying restart.
            */
        }
    }
    satisfy temperatureLimitFaultResponse by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TMP-002'> temperatureInformationFaultResponse : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-tmp-002 (line 46).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-tmp-002"></a>`REQ-SYS-TMP-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. F: cover each defined
            detectable loss/invalidity and information recovery; startup qualification follows
            [REQ-SYS-STA-007](PowerStartupAndFaults.sysml).
            Sources: [DEC-TMP-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-002),
            [DEC-FLT-007](../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-007)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-010`, `WS-OI-019`: Invalid
            information alone does not prove hot/cold violation; use its specific assigned fault category or
            generic 0x05. Required information/classification remain open.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Recognized invalid/unavailable information required to establish operation within
                temperature limits shall invoke the same retained both-sign fault response.
            */
        }
    }
    satisfy temperatureInformationFaultResponse by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
