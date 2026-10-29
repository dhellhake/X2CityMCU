package X2CitySpecification_RidingPolicy_SettingsAndControlPolicy {
    private import X2CityComponent_RidingPolicy::RidingPolicy;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-LVL-001'> hmiAssistLevelSelection : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-lvl-001
            (line 11).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-lvl-001"></a>`REQ-SYS-LVL-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`. Exercise all six requests after
            normal shutdown, pending selections, unexpected restart and power/battery interruption; a
            different VD18MT selection is authoritative under the existing guards; decoder initialization is
            not received selection.
            Sources:
            [DEC-LVL-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-001),
            [DEC-LVL-003](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-003),
            [DEC-REF-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-ref-001),
            `OBJ-007`, `CON-006`, `CON-012`
            Open dependencies / qualifications: `WS-OI-008`, `WS-OI-009`, `WS-OI-010`.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                The EPCS shall take the VD18MT's Level 0–5 selection as the requested level, including every
                normal/unexpected startup, without a scooter-defined default or required restoration of a
                prior selection.
            */
        }
    }
    satisfy hmiAssistLevelSelection by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-LVL-002'> assistLevelApplicationGuard : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-lvl-002
            (line 12).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-lvl-002"></a>`REQ-SYS-LVL-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Attempt moving/resting,
            stationary/displaced and noncoincident stop/rest events.
            Sources:
            [DEC-LVL-002](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-002),
            `OBJ-003`
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-003`.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                The active level shall change only at simultaneous standstill and physical accelerator rest.
            */
        }
    }
    satisfy assistLevelApplicationGuard by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-LVL-003'> pendingAssistLevelRetention : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-lvl-003
            (line 13).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-lvl-003"></a>`REQ-SYS-LVL-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Observe the new displayed selection while
            torque still follows the prior profile under equivalent conditions.
            Sources:
            [DEC-LVL-002](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-002)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-009`.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                While either application condition is unmet, the previous active level shall remain
                effective and the latest VD18MT selection shall remain pending.
            */
        }
    }
    satisfy pendingAssistLevelRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-LVL-004'> automaticPendingLevelApplication : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-lvl-004
            (line 14).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-lvl-004"></a>`REQ-SYS-LVL-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Cover multiple pending selections; apply
            the latest without replaying obsolete requests.
            Sources:
            [DEC-LVL-002](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-002)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-003`, `WS-OI-009`.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                At simultaneous standstill/rest, the current pending level shall apply automatically without
                another selection action.
            */
        }
    }
    satisfy automaticPendingLevelApplication by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-SPD-002'> speedRequestNormalization : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-spd-002
            (line 22).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-002"></a>`REQ-SYS-SPD-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. With 25 active and 50 requested,
            retain active 25 until the guard, then apply 40. Cover replaced pending lower requests,
            repeated/exact-40 requests, and zero/above-40 requests during startup, while moving and at the
            application guard.
            Sources:
            [DEC-SPD-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-008`, `WS-OI-009`,
            `WS-OI-015`: Clamping supersedes ignoring above-40 requests; it supplies no fallback for
            absent/uninterpretable information.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                Every interpretable VD18MT speed request of zero (no limit requested) or above 40 km/h shall
                become 40 km/h, including the first request after any startup; active/pending limits shall
                never exceed 40.
            */
        }
    }
    satisfy speedRequestNormalization by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-SPD-004'> speedLimitApplicationGuard : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-spd-004
            (line 23).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-004"></a>`REQ-SYS-SPD-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Attempt increases/decreases, including
            clamped requests, while moving/resting or stationary/displaced/at 35% neutral.
            Sources:
            [DEC-SPD-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            [DEC-LVL-002](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-002)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-008`, `WS-OI-009`,
            `WS-OI-015`: This guard does not delay cutoff/recovery at the existing limit or unconditional 40
            km/h ceiling.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                The active VD18MT speed limit shall remain unchanged unless standstill and physical
                accelerator rest coincide.
            */
        }
    }
    satisfy speedLimitApplicationGuard by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-SPD-005'> automaticPendingSpeedApplication : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-spd-005
            (line 24).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-005"></a>`REQ-SYS-SPD-005`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Cover already-eligible requests, later
            guard entry and multiple pending requests without replay.
            Sources:
            [DEC-SPD-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            [DEC-LVL-002](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-002)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-002`, `WS-OI-008`, `WS-OI-009`,
            `WS-OI-015`: No cross-boot speed persistence, absent-data fallback or storage mechanism is
            specified.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                At simultaneous standstill/rest, the latest interpretable VD18MT speed request, normalized
                under [REQ-SYS-SPD-002](SettingsAndControlPolicy.sysml), shall apply automatically without
                another selection.
            */
        }
    }
    satisfy automaticPendingSpeedApplication by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-SPD-008'> invalidSpeedSettingRetention : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-spd-008
            (line 25).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-spd-008"></a>`REQ-SYS-SPD-008`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. Test unrecognized requests
            with a distinct active/pending pair, both moving and at the guard. An interpretable zero or
            above-40 request instead becomes 40 and replaces the pending request.
            Sources:
            [DEC-SPD-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            [DEC-FLT-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-001)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-009`, `WS-OI-010`,
            `WS-OI-015`: Decoded zero means no limit requested and normalizes to 40 km/h; other special
            encodings and whole-frame handling remain open.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                After valid speed-setting receipt, unrecognized speed values shall preserve the existing
                valid active/pending setting state and its application guards.
            */
        }
    }
    satisfy invalidSpeedSettingRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-CTL-001'> ridingEligibilityAndBudgetCoordination : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-ctl-001
            (line 37).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-ctl-001"></a>`REQ-SYS-CTL-001` **Draft successor**
            Original obligation column: Requirement
            Target / realized by: `LE-RIDING-POLICY`
            Derived from: [REQ-SYS-STA-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-STA-002](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-FLT-005](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-FLT-006](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-INT-002](../../../Specification/InterfaceQualification.sysml),
            [REQ-SYS-SOC-008](../../Specification/Requirements.sysml)
            Planned verification / acceptance: I, A, T-SYS, T-FI plus software-interface tests: vary
            discharge-branch evidence, missing initial checks and later requalification while a fault latch
            remains set; reset with old inputs present; use independently qualified zero and nonzero
            directional capabilities; independently invalidate charge-only and HMI-only information while
            propulsion inputs remain valid; and clear faults without restart. Compare outputs with parent
            state/transition cases; verify physical inhibition separately.
            Open dependencies / qualifications: IF-A-001/003/004; WS-OI-007/010/018/019. Self-test scope,
            qualification/recognition timing, reset domains, output freshness and execution budget remain
            open. The policy consumes justified results; it does not establish diagnostic coverage by
            declaring pass.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                RidingPolicy shall publish current-startup drive-eligibility and current-session
                fault-inhibition outputs, initially ineligible, under the complete Ready guard and
                restart/retention rules of its system parents. Ready requires qualified discharge-limit
                evidence and the other applicable parent guards; charge-only or HMI-only battery information
                is not a Ready prerequisite. RidingPolicy shall apply the independently qualified
                coordinator-issued traction current budgets to demand and forward them with the torque
                command for Traction to enforce by actual electrical-transfer direction; it shall apply
                capability recovery under REQ-SYS-SOC-008 without independently calculating SOC cutoffs.
                Qualification loss or return alone shall neither set nor clear the current-session fault
                latch. A qualified zero traction budget means no capability in that electrical-transfer
                direction and does not by itself suppress all positive wheel torque; an unqualified budget
                remains distinct even when its conservative current is zero. Pack-current unavailability
                alone does not invalidate an otherwise qualified capability or reserve-based budget.
            */
        }
    }
    satisfy ridingEligibilityAndBudgetCoordination by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-CTL-005'> sessionClosureOnOffRequest : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-ctl-005
            (line 38).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-ctl-005"></a>`REQ-SYS-CTL-005` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Target / realized by: `LE-RIDING-POLICY`
            Derived from: [REQ-SYS-PWR-002](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-PWR-003](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-STA-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-004](../../../Traction/TractionControl/MotorControl/Specification/SystemHardwareSoftwareInterface.sysml);
            current HMI request input
            [REQ-SYS-CMP-001](../../../DriverInteraction/HMIControl/Specification/Requirements.sysml).
            Planned verification / acceptance: `T-SW`, `T-FI`, `T-SYS`: qualified Off during operation
            immediately withdraws Session eligibility and the authorization context; test stationary and
            moving cases and unavailable/nonqualified requests. Verify physical output separately.
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-010`: selected-unit Off qualification
            and finite authority withdrawal remain gates. Withdrawn authority is not proof of physical
            output safety.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                On a current qualified Off request, RidingPolicy shall immediately close the operation
                session, clear Ready eligibility and withdraw riding authority.
            */
        }
    }
    satisfy sessionClosureOnOffRequest by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-CTL-006'> qualifiedSleepEligibilityGrant : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-ctl-006
            (line 39).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-ctl-006"></a>`REQ-SYS-CTL-006` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Target / realized by: `LE-RIDING-POLICY`
            Derived from: [REQ-SYS-CTL-005](SettingsAndControlPolicy.sysml),
            [REQ-SYS-TRQACT-003](../../../Traction/TractionControl/MotorControl/Specification/Requirements.sysml),
            [REQ-SYS-PWR-003](../../../Specification/PowerStartupAndFaults.sysml); execution sibling
            contract [REQ-SYS-PLT-005](../../../Compute/Platform/Specification/Requirements.sysml).
            Planned verification / acceptance: `T-SW`, `T-FI`, `T-SYS`: vary explicit Off qualification and
            physical sleep permission independently; verify false, missing, invalid, stale or changed
            evidence revokes/cancels and only their current qualified conjunction grants. Verify expiry,
            supersession, handoff cancellation, and that no revoked/expired permission initiates sleep.
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-010`, `WS-OI-018`: numeric lifetime,
            finite handoff and race/order acceptance remain gates; revocation publication alone does not
            establish that a previously accepted handoff cannot execute. Residual/generated-energy response
            remains with its existing owners.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                RidingPolicy is the sole sleep-eligibility owner. It shall grant sleep only while the
                current qualified `VehicleOperationRequest` explicitly requests Off and current qualified
                `TractionConditionEvidence.computeSleepPermitted` is true. It shall publish a
                `ComputeSleepRequest` carrying the qualification, source context, and an `expiry: Expiry`
                lifetime; it shall revoke the grant and publish `enterSleep=false` when either current
                condition ceases to qualify. An absent, invalid, stale, expired, mismatched, or superseded
                grant shall not authorize sleep execution.
            */
        }
    }
    satisfy qualifiedSleepEligibilityGrant by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-CTL-007'> freshStartupAfterWake : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-ctl-007
            (line 40).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-ctl-007"></a>`REQ-SYS-CTL-007` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Target / realized by: `LE-RIDING-POLICY`
            Derived from: [REQ-SYS-STA-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-STA-006](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-FLT-011](../../../Specification/PowerStartupAndFaults.sysml); runtime sibling contract
            [REQ-SYS-PLT-003](../../../Compute/Platform/Specification/Requirements.sysml), current HMI
            request input
            [REQ-SYS-CMP-001](../../../DriverInteraction/HMIControl/Specification/Requirements.sysml).
            Planned verification / acceptance: `T-SW`, `T-FI`, `T-SYS`: test On before sleep entry, wake
            with retained memory and full power restart; independently withhold runtime readiness and each
            existing Ready guard; verify self-tests rerun and old authority/results/history are unavailable.
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-010`, `WS-OI-018`: selected wake/reset
            domains and finite initialization remain gates. Startup requirements retain ownership of
            diagnostic coverage and physical protection.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                After a qualified On request following Off or controller wake, RidingPolicy shall begin
                fresh normal-startup qualification. It shall not make Ready eligibility or riding authority
                available until the current `ComputeRuntimeInitialization.requiredRuntimeReady` is qualified
                true and the full existing startup/Ready guard is satisfied; it shall not reuse prior
                authority, self-test results or past-failure history.
            */
        }
    }
    satisfy freshStartupAfterWake by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-CTL-002'> signedWheelTorqueArbitration : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-ctl-002
            (line 41).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-ctl-002"></a>`REQ-SYS-CTL-002` **Draft successor — 2026-10-24**
            Original obligation column: Requirement
            Target / realized by: `LE-RIDING-POLICY`
            Derived from: [REQ-SYS-TRQ-001](../../../Specification/RiderControl.sysml),
            [REQ-SYS-BRK-001](../../../Specification/BrakeInterfaceAndPriority.sysml),
            [REQ-SYS-REG-001](../../../Specification/RiderControl.sysml),
            [REQ-SYS-SPD-003](../../../Specification/RiderControl.sysml),
            [REQ-SYS-PWR-003](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-SOC-008](../../Specification/Requirements.sysml)
            Planned verification / acceptance: I, A, T-SYS, T-FI plus software-interface tests: compare
            signed commands at simultaneous brake/limit/fault/Ready transitions, each level and both motion
            directions with parent requirements. Include zero discharge budget during rollback with
            independently permitted charging and positive wheel torque, as well as positive-only
            restrictions and allowed negative torque; verify actual output separately.
            Open dependencies / qualifications: IF-A-001–005; WS-OI-003/005/006/007/010/015/017. Derive
            representation, full profile/calibration contracts, update/transfer bounds and physical
            response. This partial arbitration contribution does not claim complete decomposition of all
            rider requirements or select a motor-control algorithm.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                RidingPolicy shall produce one signed rear-wheel torque command from qualified
                rider/settings information, eligibility and permitted capability, using the parent torque
                interpretation and overrides; positive command denotes forward torque, and any applicable
                both-sign inhibition produces zero command. It shall apply independently qualified
                directional current budgets by actual electrical-transfer direction and the capability
                recovery rule in REQ-SYS-SOC-008, while preserving independently permitted regenerative
                demand.
            */
        }
    }
    satisfy signedWheelTorqueArbitration by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

    requirement <'REQ-SYS-CTL-004'> sessionFaultAndWarningSelection : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md#req-sys-ctl-004
            (line 55).
            Original target: LE-RIDING-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-ctl-004"></a>`REQ-SYS-CTL-004` **Draft successor — 2026-10-26**
            Original obligation column: Requirement
            Target / realized by: `LE-RIDING-POLICY`
            Derived from: [REQ-VEH-HMI-006](../../Specification/SessionReportPolicy.sysml),
            [REQ-VEH-HMI-007](../../Specification/SessionReportPolicy.sysml),
            [REQ-VEH-HMI-009](../../Specification/SessionReportPolicy.sysml),
            [REQ-VEH-HMI-010](../../Specification/SessionReportPolicy.sysml),
            [REQ-VEH-HMI-018](../../Specification/SessionReportPolicy.sysml)
            Planned verification / acceptance: `A`, `T-SW`, `T-SYS`. Cover all pairs and larger tied sets,
            distinguishable arrival orders, existing selections, cleared conditions, both 0x01 causes
            before/after faults, stale/missing deliveries and independent cause clearance. A tied 0x06/0x07
            selects 0x06; distinguishably earlier 0x07 remains selected. Verify every recognized fault still
            produces its assigned physical response.
            Open dependencies / qualifications: DEC-FLT-008 / DEC-FLT-010; WS-OI-009/010/019. Tie rule is
            now specified; recognition timing, indistinguishability resolution, classification coverage and
            actual VD18MT presentation remain open. Numerical tie order applies only to the existing group,
            after category assignment.
        */
        subject owner:RidingPolicy =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;
        require constraint {
            doc /*
                When no fault-group report is yet selected, RidingPolicy shall select the earliest
                recognized reportable group fault; if the earliest faults have indistinguishable recognition
                order, it shall select the numerically lowest assigned code among that tied set. It shall
                retain the selected group report until restart, above composed low-priority 0x01 (known true
                low-discharge-voltage warning OR known true MOS-disabled warning), without replacement by a
                later lower-numbered code. With no group fault, report 0x01 while either cause is active and
                automatically clear each cause under its own qualification rule without restart. Each
                BatteryStatus warning cause activates on known true, clears on known false, and withdraws
                evidence when absent, stale or unknown without implying a healthy state or retaining stale
                0x01. Voltage warning is independent of SOC and aggregate capability.
            */
        }
    }
    satisfy sessionFaultAndWarningSelection by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.ridingPolicy;

}
