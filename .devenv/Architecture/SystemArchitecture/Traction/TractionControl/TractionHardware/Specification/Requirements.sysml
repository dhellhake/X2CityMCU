package X2CitySpecification_TractionHardware_Requirements {
    private import X2CityComponent_TractionHardware::TractionHardware;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-TRQHW-001'> tractionBridgeAndStageEvidence : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/TractionHardware/TractionHardware.md#req-sys-trqhw-001
            (line 10).
            Original target: LE-TRACTION-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqhw-001"></a>`REQ-SYS-TRQHW-001` **Draft successor allocation; refined
            split**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-004`, `REQ-SYS-HSI-009`, `REQ-SYS-ENE-002`, `REQ-SYS-ENE-003`; owner
            allocation decision 2026-10-02.
            Planned verification and remaining gate: `I`, `A`, `T-FI`, `T-SYS`: DC-link
            scale/latency/window, lost voltage path, high-modulation blind zones, fault shutdown, stage
            evidence, externally driven wheel and requested-zero physical outcome. Current
            polarity/scale/window/epoch verification remains `REQ-SYS-MSM-001`. Limits, timing/headroom,
            coverage and physical acceptance remain gates.
        */
        subject owner:TractionHardware =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;
        require constraint {
            doc /*
                `LE-TRACTION-HW` shall provide the complementary three-phase bridge, locally observed
                DC-link voltage, independently acting hardware fault shutdown, and physical
                output/energy-path evidence for the Hall-sensored FOC realization. It shall distinguish
                unavailable/saturated/out-of-window voltage observations from valid same-epoch feedback and
                expose `TractionStageEvidence` separately from `PhaseExcitationCommand`. The three low-side
                current observation channels and their valid-sample evidence remain exclusively allocated to
                `REQ-SYS-MSM-001` under `LE-MOTOR-SIGNAL`.
            */
        }
    }
    satisfy tractionBridgeAndStageEvidence by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;

    requirement <'REQ-SYS-TRQHW-002'> independentTractionHardwareInhibit : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/TractionHardware/TractionHardware.md#req-sys-trqhw-002
            (line 11).
            Original target: LE-TRACTION-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqhw-002"></a>`REQ-SYS-TRQHW-002` **Draft successor allocation; relocated**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-009`, `REQ-SYS-TRQHW-001`; allocated traction HSI.
            Planned verification and remaining gate: `I`, `A`, `T-FI`: inspect pins and returns; remove
            supplies and assert fault sources; measure PWM inputs, inhibit indication and physical energy
            outcome. Component selection, thresholds, coverage and response remain gates.
        */
        subject owner:TractionHardware =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;
        require constraint {
            doc /*
                `LE-TRACTION-HW` shall realize the established traction-HSI six-gate `PERMIT`/inhibit
                topology, including the normally-inhibited six-channel PWM gate, `RUN_EN`, watchdog
                contribution and 3.3-V conditioning. A loss of independent supply, supervisor or fault-latch
                health shall force every bridge PWM input low without MCU execution and shall present a
                distinct inhibit observation to MotorControl. The external 5-V Hall supply is exclusively
                allocated to `LE-MOTOR-SIGNAL` by `REQ-SYS-MSM-001`; it is not a TractionHardware logical
                responsibility.
            */
        }
    }
    satisfy independentTractionHardwareInhibit by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;

    requirement <'REQ-SYS-TRQHW-003'> tractionTemperatureAndRailEvidence : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/TractionHardware/TractionHardware.md#req-sys-trqhw-003
            (line 12).
            Original target: LE-TRACTION-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqhw-003"></a>`REQ-SYS-TRQHW-003` **Draft**
            Original obligation column: Requirement
            Derived from: Owner decision 2026-10-02; `REQ-SYS-HSI-001`, `REQ-SYS-HSI-009`,
            `REQ-SYS-TMP-001`, `REQ-SYS-TMP-002`.
            Planned verification and remaining gate: `I`, `A`, `T-FI`: source identity,
            missing/shorted/invalid evidence, fast/regular route separation and physical-reference
            preservation. Sensing circuits, calibration, thresholds, settling, detection coverage and time
            budgets remain gates.
        */
        subject owner:TractionHardware =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;
        require constraint {
            doc /*
                `LE-TRACTION-HW` shall provide source-identified physical evidence for traction-board/motor
                temperature and local PVDD/GVDD, including measurement integrity and physical observation
                reference. It shall keep fast PVDD evidence distinct from regular GVDD evidence and shall
                make unavailable physical evidence distinguishable from a valid measurement.
            */
        }
    }
    satisfy tractionTemperatureAndRailEvidence by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;

    requirement <'REQ-SYS-TRQHW-004'> hardwareExcitationProtectionPriority : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/TractionHardware/TractionHardware.md#req-sys-trqhw-004
            (line 13).
            Original target: LE-TRACTION-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqhw-004"></a>`REQ-SYS-TRQHW-004` **Draft**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-004`, `REQ-SYS-HSI-009`, `REQ-SYS-TRQHW-002`; owner allocation
            decision 2026-10-02.
            Planned verification and remaining gate: `I`, `A`, `T-FI`, `T-SYS`: missing/invalid/expired,
            asserted/deasserted command inhibition, each independent protection action, MCU loss/cessation,
            stage-evidence mismatch and qualified inhibited-state retention without MCU execution.
            Thresholds, response budgets, coverage and physical acceptance remain gates.
        */
        subject owner:TractionHardware =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;
        require constraint {
            doc /*
                `LE-TRACTION-HW` shall give `PhaseExcitationCommand.actuationInhibited` and each independent
                hardware-protection action priority over phase excitation. It shall suppress excitation for
                a missing, invalid, expired, or inhibited `PhaseExcitationCommand`, retain independently
                acting protection when MotorControl is unavailable, and publish resulting
                `TractionHardwareProtectionEvidence` and `TractionStageEvidence` separately from the
                command. When physical stage evidence establishes an inhibited state,
                `TractionStageEvidence.inhibitRetainedWithoutMcuExecution` shall indicate with current
                qualification whether that inhibition persists when MCU execution ceases.
            */
        }
    }
    satisfy hardwareExcitationProtectionPriority by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;

    requirement <'REQ-SYS-TRQDC-003'> appliedBridgeModulationEvidence : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/TractionHardware/TractionHardware.md#req-sys-trqdc-003
            (line 14).
            Original target: LE-TRACTION-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqdc-003"></a>`REQ-SYS-TRQDC-003` **Draft**
            Original obligation column: Requirement
            Derived from: `REQ-SYS-HSI-009`.
            Planned verification and remaining gate: `I`, `A`, `T-SYS`, `T-FI`: compare evidence to applied
            switching, inject permit/protection transitions, timing mismatch and missing application
            evidence. Transistor switching is not claimed as directly sensed; timing, observability and
            reconstruction error remain acceptance gates.
        */
        subject owner:TractionHardware =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;
        require constraint {
            doc /*
                `LE-TRACTION-HW` shall provide MotorControl qualified evidence of applied bridge modulation
                and effective permit/protection evidence with timing and context sufficient to match current
                acquisition and bound reconstruction error; unavailable or unproven application shall be
                indicated as unqualified. Evidence may use latched peripheral outputs and qualified
                actuation observation. Requested phase voltage and stage state alone shall not establish
                applied modulation.
            */
        }
    }
    satisfy appliedBridgeModulationEvidence by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.tractionHardware;

}
