package X2CitySpecification_MotorControl_Requirements {
    private import X2CityComponent_MotorControl::MotorControl;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-INP-001'> tractionInputObservationQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-sys-inp-001
            (line 10).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-inp-001"></a>`REQ-SYS-INP-001` **Draft successor allocation; relocated**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-001`, `REQ-SYS-HSI-009`, `REQ-SYS-TMP-001`, `REQ-SYS-TMP-002`.
            Planned verification and remaining gate: `A`, `T-SW`, `T-FI`, `T-SYS`: live caller time,
            initial/invalid/stale/reset cases, unchanged valid reacquisition, health-only publication,
            queued old data, source identity, fast/regular separation and requalification while inhibited.
            Electrical ranges, sensor method, age/skew, timeout and end-to-end response remain gates.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                Each MotorControl temperature or supply signal-interface software instance shall publish its
                supported semantic observation only with current producer/configuration/reset context,
                qualification and age evidence, and shall represent initial, absent, invalid, stale,
                implausible or mismatched observations as unavailable rather than qualified semantic state.
                It shall use caller-supplied `executionTimeIn` for any local per-input timeout; a valid new
                acquisition refreshes only that measurement's timer even when its value is unchanged;
                health-only/unavailability publication does not refresh measurement age. Motor and
                traction-board temperature observations are distinct from BMS battery temperature. Fast PVDD
                and regular GVDD remain distinct supply observations. Motor/board-temperature and GVDD
                qualification shall re-run from current raw evidence independently of actuation permission
                or inhibition.
            */
        }
    }
    satisfy tractionInputObservationQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-SYS-SUPPLY-IF-001'> supplyObservationQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-sys-supply-if-001
            (line 11).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-supply-if-001"></a>`REQ-SYS-SUPPLY-IF-001` **Draft successor allocation;
            relocated**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-001`, `REQ-SYS-HSI-009`,
            [REQ-SYS-TRQIO-001](../../../../Specification/SystemHardwareSoftwareInterface.sysml) (qualified
            fast Vdc conversion), `REQ-SYS-TRQRAIL-001`, `REQ-SYS-TRQRAIL-002`.
            Planned verification and remaining gate: `T-SW`, `A`, `T-FI`: scaling/range/context,
            parameter-validation failure, fast/regular separation, BMS-telemetry substitution,
            rail-diagnostic loss, and health/fault evidence routing. Thresholds, settling and detection
            budgets remain gates.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                MotorControl supply-interface software shall transform only identified raw observations and
                immutable compiled configuration/calibration parameters into qualified fast local Vdc and
                separate regular supply/rail diagnostics. It shall validate those parameters during startup
                self-test against firmware build identity/static initialization; failed validation makes
                each dependent result unavailable. It shall retain current health/reasons for debugger
                inspection and its named policy consumers without selecting RidingControl session
                fault/report policy or substituting BMS telemetry for fast Vdc.
            */
        }
    }
    satisfy supplyObservationQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-SYS-TRQACC-001'> tractionCommandAcceptance : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-sys-trqacc-001
            (line 12).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqacc-001"></a>`REQ-SYS-TRQACC-001` **Draft successor allocation;
            relocated**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-004`.
            Planned verification and remaining gate: `A`, `T-SW`, `T-FI`, `T-SYS`: producer/consumer reset,
            queued old command, independent authority-versus-command expiry, live caller time, invalidity
            and recovery. Command representation, bounded invocation/expiry, actuator contract, observation
            and coverage remain gates.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                Traction-control software shall accept authority and signed demand only when each has
                current matching context, qualification and independent authority/command expiry evidence in
                the caller-supplied host-boot monotonic microsecond domain; otherwise it shall request zero
                commanded torque of both signs and publish acceptance/output-observation state separately
                from physical output. It shall evaluate expiry with its caller-supplied `executionTimeIn`,
                retain actual decision and expiry times with meaningful `*Microseconds` names, and require
                no paired source/policy clock identifiers or conversion metadata in this one-domain host.
            */
        }
    }
    satisfy tractionCommandAcceptance by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-SYS-TRQCTL-001'> qualifiedFocTorqueRealization : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-sys-trqctl-001
            (line 13).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft, Approved.
            ID: <a id="req-sys-trqctl-001"></a>`REQ-SYS-TRQCTL-001` **Approved historical body; Draft
            successor allocation**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-001`, `REQ-SYS-HSI-004`, `REQ-SYS-HSI-009`.
            Planned verification and remaining gate: `A`, `T-SW`, `T-FI`, `T-SYS`: reference signs,
            angle/current/voltage/configuration loss, sample-window loss, vector saturation, rollback
            generation and output-observation distinction. Calibration, timing/protection, coverage and
            physical acceptance remain gates.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                Traction-control software shall realize accepted current signed wheel-torque demand through
                the selected Hall-sensored FOC contract: calibrated signed q-axis current reference, zero
                d-axis reference, bounded Hall-angle use, phase-current feedback, vector-limited PI current
                regulation and current-context physical-output observation. It shall withhold the
                realization when any required current, voltage, rotor/configuration or authority observation
                is unavailable. A current reference or PWM state shall not itself be represented as actual
                torque, electrical braking or energy direction.
            */
        }
    }
    satisfy qualifiedFocTorqueRealization by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-SYS-TRQMOTION-001'> qualifiedVehicleMotionObservation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-sys-trqmotion-001
            (line 14).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqmotion-001"></a>`REQ-SYS-TRQMOTION-001` **Draft successor allocation;
            relocated**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-SPD-003`, `REQ-SYS-SPD-009`, `REQ-SYS-REG-003`, `REQ-SYS-REG-004`,
            `REQ-SYS-REG-009`.
            Planned verification and remaining gate: `A`, `T-SW`, `T-FI`, `T-SYS`:
            forward/reverse/standstill evidence, final-position health loss, static/absent-edge cases,
            parameter failure/context reset, pre-Ready observation and consumer withholding. Conversion,
            uncertainty/age and fixed-wheel calibration remain gates.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                Traction-control software shall publish vehicle speed, travel direction and standstill only
                when current final MotorPosition evidence, health, context and immutable compiled
                motion-calibration/observability parameters support that result. It shall validate those
                parameters during startup self-test against firmware build identity/static initialization;
                failed validation makes the result unavailable. It shall perform this observation
                independently of Ready, demand acceptance and actuation; a static Hall state, absent edge
                alone, command or output-enable state is unavailable, not standstill. It shall make its
                result available to the existing RidingControl settings, eligibility and demand units guards
                without owning their policy.
            */
        }
    }
    satisfy qualifiedVehicleMotionObservation by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-SYS-TRQACT-001'> phaseExcitationInhibition : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-sys-trqact-001
            (line 15).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqact-001"></a>`REQ-SYS-TRQACT-001` **Draft**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-004`, `REQ-SYS-HSI-009`, `REQ-SYS-TRQACC-001`, `REQ-SYS-TRQCTL-001`,
            `REQ-SYS-TRQRAIL-001`.
            Planned verification and remaining gate: `T-SW`, `T-FI`, `T-SYS`:
            initial/missing/invalid/expired authority and command; each required-evidence loss; unacceptable
            temperature/rail or active hardware protection; zero demand; recovery; and distinct command
            field outcomes. Numerical execution and response bounds remain gates.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                `LE-MOTOR-CTRL` shall issue `PhaseExcitationCommand` with `actuationInhibited` true by
                default and whenever authority or signed command is absent, invalid, mismatched or expired,
                or a required current, voltage, rotor/configuration, qualified acceptable local
                temperature/rail condition, or current hardware-permit condition is unavailable. It shall
                set `actuationInhibited` false only for a current accepted command, current required control
                evidence, qualified acceptable local temperature/rails, and valid
                `TractionHardwareProtectionEvidence` showing no active independent hardware-protection
                action. A zero torque command remains distinct from `actuationInhibited`.
            */
        }
    }
    satisfy phaseExcitationInhibition by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-SYS-TRQACT-002'> tractionConditionEvidencePublication : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-sys-trqact-002
            (line 16).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqact-002"></a>`REQ-SYS-TRQACT-002` **Draft**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-004`, `REQ-SYS-HSI-009`, `REQ-SYS-TRQCTL-001`, `REQ-SYS-TRQRAIL-001`
            (startup rail prerequisite), `REQ-SYS-TRQRAIL-002` (recognized runtime rail-fault contribution).
            Planned verification and remaining gate: `I`, `T-SW`, `T-FI`, `T-SYS`: initial/startup
            qualification, authority/demand-independent temperature/rail/sensor/stage/protection cases,
            commanded inhibit, zero demand, stage-evidence loss, independent protection action and
            physical-output mismatch; verify current producer evidence reaches Session without a local
            latch. Observation accuracy and coverage remain gates.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                `LE-MOTOR-CTRL` shall independently evaluate the current local startup prerequisite and
                recognized temperature, rail, aggregate-sensor, output-stage, and hardware-protection
                conditions from qualified motor/board temperature, fast PVDD, regular GVDD, supply health,
                aggregate sensor health, and physical stage/protection envelope evidence. It shall publish
                one current `TractionConditionEvidence` with `startupTractionConditionsAccepted`,
                `recognizedFault`, `actuationInhibited`, and applicable `conditionCategory` values to
                RidingControl independently of authority/demand acceptance. It shall consume
                `TractionStageEvidence` only as physical-stage evidence and
                `TractionHardwareProtectionEvidence` only as independent hardware-protection evidence;
                neither command field proves physical zero output, torque, electrical braking, energy
                direction, or protection action. RidingControl alone latches, reports, and determines
                restart lifetime.
            */
        }
    }
    satisfy tractionConditionEvidencePublication by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-SYS-TRQACT-003'> physicalStageSleepPermission : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-sys-trqact-003
            (line 17).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqact-003"></a>`REQ-SYS-TRQACT-003` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-TRQACT-002`,
            [REQ-SYS-TRQHW-004](../../TractionHardware/Specification/Requirements.sysml),
            [REQ-SYS-PWR-003](../../../../Specification/PowerStartupAndFaults.sysml); consumed by
            RidingControl sleep-eligibility contract
            [REQ-SYS-CTL-006](../../../../RidingControl/RidingPolicy/Specification/SettingsAndControlPolicy.sysml).
            Planned verification and remaining gate: `T-SW`, `T-FI`, `T-SYS`: separately vary stage
            qualification/state, inhibition-retention evidence, zero command and software inhibit;
            permission remains false for absent, invalid, stale or mismatched physical evidence. Physical
            sleep-state output and energy behavior remain separate acceptance gates under the
            energy/protection requirements.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                `LE-MOTOR-CTRL` shall set `TractionConditionEvidence.computeSleepPermitted` true only when
                current qualified physical stage evidence reports `observedOutputStageState.state` Inhibited
                and `inhibitRetainedWithoutMcuExecution` true. A zero command or software
                `actuationInhibited` value alone shall not establish this permission.
            */
        }
    }
    satisfy physicalStageSleepPermission by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-AS-TRQDC-001'> inverterDcCurrentEstimation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-as-trqdc-001
            (line 18).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-as-trqdc-001"></a>`REQ-AS-TRQDC-001` **Draft**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-009`.
            Planned verification and remaining gate: Interface dependency:
            [REQ-SYS-TRQDC-003](../../TractionHardware/Specification/Requirements.sysml). `T-SW`, `A`,
            `T-FI`: polarity, offset, skew, reconstruction, permit transitions, stale and unobservable
            windows; validate average and response against independent reference. Accuracy, finite averaging
            and response envelope remain gates; PWM-off or inhibition alone does not establish zero current
            during wheel-driven generation.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                `LE-MOTOR-CTRL` shall qualify its local average inverter DC-branch current estimate only
                from current reconstructed phase-current evidence and matching qualified applied modulation
                and permit evidence, with aligned timing, phase sign and calibration, valid switching
                windows and a validated model of deadtime and current paths. It shall use battery-referred
                positive-charging and negative-discharge sign, and shall mark the estimate unavailable when
                required evidence or its error/averaging envelope is unavailable.
            */
        }
    }
    satisfy inverterDcCurrentEstimation by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

    requirement <'REQ-AS-TRQDC-002'> inverterDirectionalCurrentBudgetEnforcement : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/MotorControl/MotorControl.md#req-as-trqdc-002
            (line 19).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-as-trqdc-002"></a>`REQ-AS-TRQDC-002` **Draft**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-004`, `REQ-SYS-HSI-009`, `REQ-SYS-CUR-001`.
            Planned verification and remaining gate: `T-SW`, `T-FI`, `T-SYS`: independent branches,
            qualified zero versus unavailable, changing allocations, estimate loss, both signs and bounded
            response. Validate the error, averaging and response allowances in both directions against an
            independent current reference; numerical limits remain gates.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                `LE-MOTOR-CTRL` shall use its qualified average inverter DC-branch estimate to constrain FOC
                torque realization to the independently qualified `maximumDischargeCurrentAmperes` and
                `maximumRegenerativeChargeCurrentAmperes` traction allocations, accounting in both
                directions for the validated estimate error, averaging and response allowance so active
                inverter current remains within the communicated budget. It shall promptly withdraw active
                control of the affected transfer for an unqualified estimate or corresponding
                `dischargeBudgetQualified` or `regenerativeChargeBudgetQualified` false, and shall command
                no active transfer in that direction for a qualified zero budget. Independent protection
                remains applicable to residual or passive current, including diode conduction.
            */
        }
    }
    satisfy inverterDirectionalCurrentBudgetEnforcement by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

}
