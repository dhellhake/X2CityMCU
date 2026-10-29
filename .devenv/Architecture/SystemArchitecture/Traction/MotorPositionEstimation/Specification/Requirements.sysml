package X2CitySpecification_MotorPositionEstimation_Requirements {
    private import X2CityComponent_MotorPositionEstimation::MotorPositionEstimation;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-MPE-001'> motorPositionCompositePublication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionEstimation.md#req-sys-mpe-001
            (line 35).
            Original target: LE-MOTOR-POSITION.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpe-001"></a>`REQ-SYS-MPE-001` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-001](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-HSI-009](../../../Specification/SystemHardwareSoftwareInterface.sysml)
            Related / governing contracts: Producer: `REQ-SYS-MPP-001`; consumer/allocation:
            [REQ-SYS-TRQPOS-001](../MotorPositionProcessing/Specification/Requirements.sysml),
            `REQ-SYS-TRQCTL-001`; existing RidingControl session fault policy is unchanged.
            Planned verification / acceptance: `I`, `T-SYS`: route qualified, unavailable, and
            qualification-only updates to all three consumers; verify complete member parity, distinct speed
            validity, and unchanged Position reference time on qualification-only updates.
        */
        subject owner:MotorPositionEstimation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION` shall publish one `MotorPosition` composite containing `Position` and
                `Qualification` to `LE-MOTOR-CTRL`, `LE-PLATFORM`, and `LE-RIDING`. `Position` carries
                electrical angle, separately valid signed electrical speed, reference time, accepted angle
                uncertainty, and the Hall sector/edge evidence required for independent motion
                qualification. Every consumer receives the complete composite, including when angle is
                unavailable or only `Qualification` changes.
            */
        }
    }
    satisfy motorPositionCompositePublication by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;

    requirement <'REQ-SYS-MPE-002'> hallBasedElectricalAngle : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionEstimation.md#req-sys-mpe-002
            (line 36).
            Original target: LE-MOTOR-POSITION.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpe-002"></a>`REQ-SYS-MPE-002` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-001](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [DEC-MOTOR-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-motor-001)
            Related / governing contracts: Hall evidence: `REQ-SYS-MSM-001`; interpolation and angle-error
            bound: `REQ-SYS-MPP-002`; allocation: `REQ-SYS-TRQPOS-001`. Absence of Hall edges alone does not
            establish standstill.
            Planned verification / acceptance: `T-SYS`, `T-FI`: exercise static startup, accepted
            transitions, interpolation boundary and missing-edge cases; verify the stated availability
            behavior.
        */
        subject owner:MotorPositionEstimation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION` shall use accepted Hall signal evidence for every available
                electrical-angle result, shall permit a static accepted Hall sector at startup without an
                edge, and shall use Hall interpolation only within its established bound.
            */
        }
    }
    satisfy hallBasedElectricalAngle by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;

    requirement <'REQ-SYS-MPE-003'> modelAssistedAngleRefinement : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionEstimation.md#req-sys-mpe-003
            (line 37).
            Original target: LE-MOTOR-POSITION.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpe-003"></a>`REQ-SYS-MPE-003` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-009](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [DEC-MOTOR-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-motor-001)
            Related / governing contracts: Evidence source: `REQ-SYS-MSM-002`; observability and acceptance
            rule: `REQ-SYS-MPP-003`. Hall-only low-speed operation remains permitted. Slow phase-voltage
            diagnostics are excluded.
            Planned verification / acceptance: `T-SYS`, `T-FI`: vary observability and Hall availability;
            verify assistance under the accepted condition, Hall-only low-speed behavior, and no sensorless
            output.
        */
        subject owner:MotorPositionEstimation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;
        require constraint {
            doc /*
                When accepted Hall evidence, phase-current evidence, applied-winding-voltage evidence, model
                qualification and observability acceptance are all available, `LE-MOTOR-POSITION` shall
                refine or check its Hall-based electrical-angle estimate using the current/voltage model; it
                shall use that evidence only under this condition and shall not make electrical angle
                available from it without accepted Hall evidence.
            */
        }
    }
    satisfy modelAssistedAngleRefinement by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;

    requirement <'REQ-SYS-MPE-004'> motorPositionQualificationAndFaultEvidence : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionEstimation.md#req-sys-mpe-004
            (line 38).
            Original target: LE-MOTOR-POSITION.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpe-004"></a>`REQ-SYS-MPE-004` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-001](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-FLT-003](../../../Specification/PowerStartupAndFaults.sysml)
            Related / governing contracts: Producer and delivery: `REQ-SYS-MPP-004`; fault response and
            retention remain owned by the existing Session path. Poor low-speed observer observability alone
            is not a recognized fault.
            Planned verification / acceptance: `T-SYS`, `T-FI`: exceed the accepted bound and inject
            contradictory/lost required evidence; verify angle withholding, full-composite delivery to all
            three consumers, unchanged position reference time on qualification-only updates, and existing
            fault-path delivery.
        */
        subject owner:MotorPositionEstimation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION` shall withhold electrical angle when its accepted angle-error bound is
                not met while continuing to publish the complete `MotorPosition` composite and its
                `Qualification` to MotorControl, Platform, and Session. A qualification-only change shall
                retain the actual `Position.referenceTimeMicroseconds` of its position evidence. Recognized
                contradictory or lost required signal evidence shall remain available through
                `Qualification` to the existing fault-response path.
            */
        }
    }
    satisfy motorPositionQualificationAndFaultEvidence by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;

    requirement <'REQ-SYS-MPE-005'> phaseCurrentFeedbackPublication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionEstimation.md#req-sys-mpe-005
            (line 39).
            Original target: LE-MOTOR-POSITION.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpe-005"></a>`REQ-SYS-MPE-005` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-009](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [DEC-MOTOR-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-motor-001)
            Related / governing contracts: Producer: `REQ-SYS-MPP-005`; physical evidence:
            `REQ-SYS-MSM-001`; consumer/allocation: `REQ-SYS-PHASE-IF-001`, `REQ-SYS-TRQCTL-001`. Existing
            fast DC-link voltage remains a separate MotorControl input.
            Planned verification / acceptance: `I`, `T-SYS`: trace phase current through the software leaf
            to MotorControl; verify it is not inferred from `MotorPosition` or replaced by an earlier epoch.
        */
        subject owner:MotorPositionEstimation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION` shall provide qualified semantic phase-current feedback to
                `LE-MOTOR-CTRL` as explicit `PhaseCurrentMeasurements`, separate from `MotorPosition`.
            */
        }
    }
    satisfy phaseCurrentFeedbackPublication by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;

    requirement <'REQ-SYS-MPE-006'> electricalAngleContinuity : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionEstimation.md#req-sys-mpe-006
            (line 40).
            Original target: LE-MOTOR-POSITION.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpe-006"></a>`REQ-SYS-MPE-006` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-MPE-002](Requirements.sysml), [REQ-SYS-MPE-003](Requirements.sysml)
            Related / governing contracts: Transition rule and bounds: `REQ-SYS-MPP-006`; no uncontrolled
            phase jump is permitted.
            Planned verification / acceptance: `T-SYS`, `T-FI`: introduce observable/unobservable
            transitions and Hall-edge corrections; verify continuity and accepted error.
        */
        subject owner:MotorPositionEstimation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION` shall keep electrical angle within the validated continuity and
                accepted-error bounds while enabling or disabling current/voltage assistance or applying
                Hall-edge correction.
            */
        }
    }
    satisfy electricalAngleContinuity by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation;

}
