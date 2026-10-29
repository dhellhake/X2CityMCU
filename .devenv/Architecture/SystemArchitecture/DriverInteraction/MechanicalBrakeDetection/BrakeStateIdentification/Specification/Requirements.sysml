package X2CitySpecification_BrakeStateIdentification_Requirements {
    private import X2CityComponent_BrakeStateIdentification::BrakeStateIdentification;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BRKSW-001'> brakeResistanceStateClassification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeStateIdentification/BrakeStateIdentification.md#req-sys-brksw-001
            (line 10).
            Original target: LE-BRAKE-STATE.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-brksw-001"></a>`REQ-SYS-BRKSW-001` **Draft allocation**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-BRK-006](../../Specification/Requirements.sysml),
            [REQ-SYS-BRKDET-001](../../Specification/Requirements.sysml),
            [REQ-SYS-HSI-001](../../../../Specification/SystemHardwareSoftwareInterface.sysml).
            Related / governing contracts:
            [REQ-SYS-BRKHW-001](../../BrakeSignalMeasurement/Specification/Requirements.sysml),
            `REQ-SYS-INP-002`.
            Planned verification and remaining gate: `T-SW`: exercise the qualified transfer relation, all
            four band boundaries, and representative values. Values outside all bands or in an overlap are
            not qualified states.
        */
        subject owner:BrakeStateIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;
        require constraint {
            doc /*
                `LE-BRAKE-STATE` shall transform `BrakeMeasurement` into the `BrakeLeverState` required by
                [REQ-SYS-BRKDET-001](../../Specification/Requirements.sysml): it shall derive terminal
                resistance in ohms from the measured electrical response using its qualified transfer
                relationship, then classify an otherwise usable resistance only into the corresponding
                inclusive `BrakeStateCalibration` band for `Neither`, `Left`, `Right`, or `Both`. When
                accepting a measurement, it shall establish and retain its actual measurement time as
                `State.measurementTimeMicroseconds`.
            */
        }
    }
    satisfy brakeResistanceStateClassification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;

    requirement <'REQ-SYS-BRKSW-002'> brakeCalibrationStartupValidation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeStateIdentification/BrakeStateIdentification.md#req-sys-brksw-002
            (line 11).
            Original target: LE-BRAKE-STATE.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-brksw-002"></a>`REQ-SYS-BRKSW-002` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-BRK-007](../../Specification/Requirements.sysml),
            [REQ-SYS-BRK-008](../../Specification/Requirements.sysml).
            Related / governing contracts: `REQ-SYS-PLT-CAL-001`.
            Planned verification and remaining gate: `T-SW`: exercise reversed bounds and every overlap
            pair; verify unavailable State and available Qualification.
        */
        subject owner:BrakeStateIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;
        require constraint {
            doc /*
                `LE-BRAKE-STATE` shall validate `BrakeStateCalibration` during current-startup self-test:
                each band has ordered bounds and the four inclusive bands do not overlap. Failed validation
                shall make State unusable without granting a released or actuated state, while keeping
                Qualification publication available.
            */
        }
    }
    satisfy brakeCalibrationStartupValidation by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;

    requirement <'REQ-SYS-BRKSW-003'> brakeMeasurementAgeQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeStateIdentification/BrakeStateIdentification.md#req-sys-brksw-003
            (line 12).
            Original target: LE-BRAKE-STATE.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-brksw-003"></a>`REQ-SYS-BRKSW-003` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-BRK-008](../../Specification/Requirements.sysml).
            Related / governing contracts: `REQ-SYS-PLT-002`.
            Planned verification and remaining gate: `T-SW`, `T-FI`: test time below, at, and above the
            derived bound and each nonusable evidence condition. The age bound remains open under the parent
            interface qualification.
        */
        subject owner:BrakeStateIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;
        require constraint {
            doc /*
                `LE-BRAKE-STATE` shall classify a measurement as stale when elapsed time from its actual
                `measurementTimeMicroseconds` to caller-supplied `executionTimeIn.currentTimeMicroseconds`
                exceeds the brake maximum-measurement-age bound; stale, absent, invalid, implausible,
                ambiguous, or foreign-context evidence shall not yield usable State.
            */
        }
    }
    satisfy brakeMeasurementAgeQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;

    requirement <'REQ-SYS-BRKSW-004'> brakeStateRequalification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeStateIdentification/BrakeStateIdentification.md#req-sys-brksw-004
            (line 13).
            Original target: LE-BRAKE-STATE.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-brksw-004"></a>`REQ-SYS-BRKSW-004` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-BRKDET-002](../../Specification/Requirements.sysml),
            [REQ-SYS-INT-002](../../../../Specification/InterfaceQualification.sysml),
            [REQ-SYS-HSI-007](../../../../Compute/Platform/Specification/SystemHardwareSoftwareInterface.sysml).
            Related / governing contracts: `REQ-SYS-INP-002`, `REQ-SYS-PLT-002`.
            Planned verification and remaining gate: `T-SW`, `T-FI`: start with old evidence available,
            perform startup checks, recover health without a measurement, then supply a new measurement;
            verify only the final case restores State.
        */
        subject owner:BrakeStateIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;
        require constraint {
            doc /*
                After normal or unexpected controller startup, `LE-BRAKE-STATE` shall keep State unusable
                with `initialQualificationPending` until current-startup checks and a new valid measurement
                establish it. After State is invalidated, health-only recovery shall not restore State; only
                a new valid measurement may do so.
            */
        }
    }
    satisfy brakeStateRequalification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;

    requirement <'REQ-SYS-BRKSW-005'> brakeMeasurementTimeRetention : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeStateIdentification/BrakeStateIdentification.md#req-sys-brksw-005
            (line 14).
            Original target: LE-BRAKE-STATE.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-brksw-005"></a>`REQ-SYS-BRKSW-005` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-BRKDET-001](../../Specification/Requirements.sysml).
            Related / governing contracts: `REQ-SYS-PLT-002`.
            Planned verification and remaining gate: `T-SW`, `T-FI`: change Qualification without a
            measurement; verify unchanged measurement time.
        */
        subject owner:BrakeStateIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;
        require constraint {
            doc /*
                `LE-BRAKE-STATE` shall publish a Qualification-only change without changing the retained
                actual measurement time.
            */
        }
    }
    satisfy brakeMeasurementTimeRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;

    requirement <'REQ-SYS-BRKSW-006'> brakeMeasurementFaultDelivery : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeStateIdentification/BrakeStateIdentification.md#req-sys-brksw-006
            (line 15).
            Original target: LE-BRAKE-STATE.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-brksw-006"></a>`REQ-SYS-BRKSW-006` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-BRKDET-002](../../Specification/Requirements.sysml).
            Related / governing contracts: `REQ-SYS-PLT-002`.
            Planned verification and remaining gate: `T-SW`, `T-SYS`, `T-FI`: create a transient recognized
            fault and verify Session receipt despite recovery. RidingControl owns session fault retention.
        */
        subject owner:BrakeStateIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;
        require constraint {
            doc /*
                `LE-BRAKE-STATE` shall deliver each recognized measurement fault to the RidingControl
                session fault-response path so a subsequent recovery cannot lose the event.
            */
        }
    }
    satisfy brakeMeasurementFaultDelivery by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.stateIdentification;

}
