package X2CitySpecification_MotorPositionProcessing_Requirements {
    private import X2CityComponent_MotorPositionProcessing::MotorPositionProcessing;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-TRQPOS-001'> hallRotorSectorQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-trqpos-001
            (line 10).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft, Approved.
            ID: <a id="req-sys-trqpos-001"></a>`REQ-SYS-TRQPOS-001` **Draft allocation of approved body**
            Original obligation column: Requirement
            Derived from: REQ-SYS-HSI-001, REQ-SYS-HSI-004, REQ-SYS-MPE-001, REQ-SYS-MPE-002
            Governing dependencies / consumers: It remains Hall evidence, not final `MotorPosition`.
            `REQ-SYS-MPP-001` is the final-estimator consumer.
            Planned verification and remaining gate: `A`, `T-SW`, `T-SYS`: static startup, capture edge
            sequence, stale/reset/map loss and final-estimator consumer-withhold cases.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                Hall-interface software shall transform its owned current sampled-state/edge capture and a
                qualified configuration map/alignment into a configuration-qualified electrical
                rotor-sector, direction and edge-time record. It shall withhold that record when required
                capture, map/alignment or context is unavailable; a static state may be accepted at rest
                without an edge. It shall not represent a fixed Hall truth table, mechanical angle/speed,
                pole count, phase alignment or control algorithm as qualified without separate evidence.
            */
        }
    }
    satisfy hallRotorSectorQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

    requirement <'REQ-SYS-MPP-001'> finalMotorPositionPublication : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-mpp-001
            (line 11).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpp-001"></a>`REQ-SYS-MPP-001` **Draft**
            Original obligation column: Requirement
            Derived from: REQ-SYS-MPE-001
            Governing dependencies / consumers: `REQ-SYS-TRQPOS-001` provides Hall evidence;
            `REQ-SYS-PLT-CAL-001` governs immutable compiled calibration; all three consumers receive the
            complete composite. Hall observation alone is not the final angle.
            Planned verification and remaining gate: `T-SW`, `A`: final-owner inspection, all-consumer
            route, initial/reset/context loss, source-time preservation, calibration validation and
            angle-unavailable composite delivery.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION-PROC` shall publish the sole final `MotorPosition` Position/Qualification
                composite to MotorControl, Platform, and Session. It shall make electrical angle available
                only from current qualified Hall observation with matching source/configuration/reset
                context and immutable validated estimator calibration; unavailable or invalid angle evidence
                shall not suppress the composite or its `Qualification`. It shall retain actual position
                reference/transition times, accepted angle uncertainty and Hall sector/edge evidence and
                shall use caller-supplied `executionTimeIn` for local age/timeout decisions.
            */
        }
    }
    satisfy finalMotorPositionPublication by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

    requirement <'REQ-SYS-MPP-002'> staticHallAngleAndInterpolation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-mpp-002
            (line 12).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpp-002"></a>`REQ-SYS-MPP-002` **Draft**
            Original obligation column: Requirement
            Derived from: REQ-SYS-MPE-002
            Governing dependencies / consumers: `REQ-SYS-PLT-CAL-001` governs the immutable bounds. Static
            state, absent transition, command, PWM state or accepted angle does not alone prove speed,
            vehicle motion or standstill.
            Planned verification and remaining gate: `T-SW`, `A`, `T-FI`: static startup sector, accepted
            forward/reverse transition, interpolation bound, independent speed validity and absent-edge
            cases.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION-PROC` shall accept a static qualified Hall sector as a bounded
                electrical-angle estimate at startup without waiting for an edge or qualified vehicle
                standstill and interpolate only between accepted Hall transitions within immutable compiled
                bounds. It shall publish signed electrical speed only when independently qualified.
            */
        }
    }
    satisfy staticHallAngleAndInterpolation by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

    requirement <'REQ-SYS-MPP-003'> modelBasedHallAngleRefinement : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-mpp-003
            (line 13).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpp-003"></a>`REQ-SYS-MPP-003` **Draft**
            Original obligation column: Requirement
            Derived from: REQ-SYS-MPE-003
            Governing dependencies / consumers: `REQ-SYS-MPP-007` supplies applied-voltage qualification;
            `REQ-SYS-MSM-002` supplies only physical bridge observation; `REQ-SYS-PLT-CAL-001` governs
            immutable model parameters. Regular phase-voltage diagnostic information is excluded, and angle
            cannot be available without accepted Hall evidence.
            Planned verification and remaining gate: `T-SW`, `A`, `T-FI`: accepted observable branch,
            timing/provenance mismatch, diagnostic isolation, Hall-required gate and calibration validation.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                When current qualified Hall observation, same-operation phase current, qualified
                applied-winding-voltage evidence, immutable motor-model parameters and observability
                acceptance are all current, `LE-MOTOR-POSITION-PROC` shall refine or check the Hall-based
                angle using the current/voltage model.
            */
        }
    }
    satisfy modelBasedHallAngleRefinement by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

    requirement <'REQ-SYS-MPP-004'> motorPositionFaultQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-mpp-004
            (line 14).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpp-004"></a>`REQ-SYS-MPP-004` **Draft**
            Original obligation column: Requirement
            Derived from: REQ-SYS-MPE-001, REQ-SYS-MPE-004, REQ-SYS-FLT-003
            Governing dependencies / consumers: Existing Session/platform policy owns fault latching and
            reporting. Weak back-EMF or unavailable observer voltage alone, while a Hall-only estimate
            remains within accepted error, withholds observer contribution without representing a fault.
            Planned verification and remaining gate: `T-SW`, `A`, `T-FI`: each recognized failure,
            low-observability Hall-only estimate, complete-composite delivery, angle withholding,
            reference-time retention on qualification-only change, and existing fault-path delivery.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION-PROC` shall publish the complete `MotorPosition` composite to
                MotorControl, Platform, and Session for each result/update, including when electrical angle
                is unavailable or only `Qualification` changes. Qualification-only changes shall preserve
                the actual `Position.referenceTimeMicroseconds` of the position evidence. For a recognized
                Hall loss, required-source failure, source contradiction, context mismatch or
                accepted-angle-error breach, it shall indicate unusable/unavailable position through
                `Qualification` while withholding the dependent electrical angle, and preserve the existing
                fault evidence for Session/platform supervision.
            */
        }
    }
    satisfy motorPositionFaultQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

    requirement <'REQ-SYS-MPP-005'> fastPhaseCurrentFeedbackPath : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-mpp-005
            (line 15).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpp-005"></a>`REQ-SYS-MPP-005` **Draft**
            Original obligation column: Requirement
            Derived from: REQ-SYS-MPE-005, REQ-SYS-HSI-009
            Governing dependencies / consumers: `REQ-SYS-PHASE-IF-001` governs semantic current conversion;
            `REQ-SYS-TRQCTL-001` consumes it. The estimation responsibility may consume that same evidence
            internally but shall not forward, aggregate or reconvert it on the MotorControl path. Fast Vdc
            remains on its separate route to TractionControl.
            Planned verification and remaining gate: `I`, `T-SW`, `A`: one producer-to-consumer route,
            same-epoch/context preservation, estimator fan-out without pass-through, and separate Vdc route.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION-PROC` shall preserve one qualified semantic `PhaseCurrentMeasurements`
                path from the current raw fast acquisition epoch to MotorControl.
            */
        }
    }
    satisfy fastPhaseCurrentFeedbackPath by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

    requirement <'REQ-SYS-MPP-006'> motorPositionAngleContinuity : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-mpp-006
            (line 16).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpp-006"></a>`REQ-SYS-MPP-006` **Draft**
            Original obligation column: Requirement
            Derived from: REQ-SYS-MPE-006
            Governing dependencies / consumers: `REQ-SYS-MPP-002` supplies Hall interpolation;
            `REQ-SYS-MPP-003` supplies accepted model assistance. No uncontrolled phase jump is permitted.
            Planned verification and remaining gate: `T-SW`, `T-FI`: observer enable/disable and Hall-edge
            correction at the established boundary conditions; verify continuity and accepted error.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION-PROC` shall keep published electrical angle within the validated
                continuity and accepted-error bounds while enabling or disabling accepted current/voltage
                assistance or applying Hall-edge correction.
            */
        }
    }
    satisfy motorPositionAngleContinuity by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

    requirement <'REQ-SYS-MPP-007'> appliedWindingVoltageQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-mpp-007
            (line 17).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-mpp-007"></a>`REQ-SYS-MPP-007` **Draft**
            Original obligation column: Requirement
            Derived from: REQ-SYS-MPE-003, REQ-SYS-HSI-009
            Governing dependencies / consumers: Physical bridge observation is `REQ-SYS-MSM-002`; the source
            remains unavailable until the HSI acceptance gate is met. This record is distinct from regular
            phase-voltage diagnostic information, fast Vdc and MotorControl output. `REQ-SYS-MPP-003` is its
            estimator consumer.
            Planned verification and remaining gate: `T-SW`, `A`, `T-FI`: direct/reconstructed source
            absence, frame/provenance/timing/skew/error mismatch, parameter-validation failure and
            regular-diagnostic substitution.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION-PROC` shall qualify a distinct applied-winding-voltage record for
                estimator use only after its selected direct-sensing or calibrated bridge-reconstruction
                source has current frame/reference, output-stage/configuration provenance, timing/skew/error
                evidence and immutable parameter validation.
            */
        }
    }
    satisfy appliedWindingVoltageQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

    requirement <'REQ-SYS-PHASE-IF-001'> phaseCurrentFeedbackQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorPositionProcessing/MotorPositionProcessing.md#req-sys-phase-if-001
            (line 18).
            Original target: LE-MOTOR-POSITION-PROC.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-phase-if-001"></a>`REQ-SYS-PHASE-IF-001` **Draft**
            Original obligation column: Requirement
            Derived from: REQ-SYS-HSI-009,
            [REQ-SYS-TRQIO-001](../../../../Specification/SystemHardwareSoftwareInterface.sysml) (qualified
            phase-current conversion), REQ-SYS-MPE-005
            Governing dependencies / consumers: `REQ-SYS-MPP-005` is its MotorControl route. It shall expose
            current health/reasons without deciding RidingControl session fault policy and shall not
            substitute regular phase voltage or an earlier epoch for fast feedback.
            Planned verification and remaining gate: `T-SW`, `A`, `T-FI`: phase map/sign/offset/gain cases,
            startup parameter-validation failure, direct-third plausibility, regular diagnostic loss,
            stale/foreign epoch and health/report routing.
        */
        subject owner:MotorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;
        require constraint {
            doc /*
                `LE-MOTOR-POSITION-PROC` shall transform only a current raw fast epoch and its immutable
                compiled phase-calibration parameters into qualified same-aperture phase-current feedback,
                reconstruction/plausibility information and distinct regular phase-voltage diagnostics. It
                shall validate those parameters during startup self-test against the firmware build
                identity/static initialization; failed validation makes its dependent result unavailable.
            */
        }
    }
    satisfy phaseCurrentFeedbackQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.positionProcessing;

}
