package X2CitySpecification_AcceleratorPositionProcessing_Requirements {
    private import X2CityComponent_AcceleratorPositionProcessing::AcceleratorPositionProcessing;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-ACC-002'> acceleratorMeasurementTransformation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-002
            (line 10).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-002"></a>`REQ-SYS-ACC-002` **Draft allocation**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-008](../../Specification/Requirements.sysml)
            Related / governing contracts: Input allocation: `REQ-SYS-ACC-014`.
            Planned verification / acceptance: `I`, `T-SW`: trace usable and unusable evidence through the
            composite and health projection.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall transform `AcceleratorMeasurement` into the
                `AcceleratorPosition` required by `REQ-SYS-ACC-001` and deliver it to settings, session, and
                demand with its `Qualification` projection to platform.
            */
        }
    }
    satisfy acceleratorMeasurementTransformation by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-010'> acceleratorPositionQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-010
            (line 11).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-010"></a>`REQ-SYS-ACC-010` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-004](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-006](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-046](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-047](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-048](../../Specification/Requirements.sysml)
            Related / governing contracts: Compiled parameter contract: `REQ-SYS-PLT-CAL-001`; endpoint
            calibration composite: `endpointCalibration`; fault, stale, and invalid evidence remains
            unqualified before band classification.
            Planned verification / acceptance: `T-SW`: test endpoints, intermediate values, both inclusive
            band boundaries, and qualified values outside the rest band; invalid or stale evidence within
            either band remains unqualified.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall qualify each usable `AcceleratorMeasurement` into normalized
                physical position and physical-rest status using its immutable compiled parameter set,
                including the validated rest and full-throttle voltage bands required by `REQ-SYS-ACC-046`
                through `REQ-SYS-ACC-048`.
            */
        }
    }
    satisfy acceleratorPositionQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-011'> acceleratorCalibrationStartupValidation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-011
            (line 12).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-011"></a>`REQ-SYS-ACC-011` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-STA-003](../../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-ACC-049](../../Specification/Requirements.sysml)
            Related / governing contracts: Compiled parameter contract: `REQ-SYS-PLT-CAL-001`; endpoint
            calibration composite: `endpointCalibration`.
            Planned verification / acceptance: `T-SW`: exercise valid and invalid endpoint-band bound and
            overlap cases.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall validate its immutable compiled parameter set, including ordered
                bounds and non-overlap of the rest and full-throttle voltage bands, during startup
                self-test.
            */
        }
    }
    satisfy acceleratorCalibrationStartupValidation by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-012'> acceleratorCalibrationFailureResponse : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-012
            (line 13).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-012"></a>`REQ-SYS-ACC-012` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-005](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-006](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-008](../../Specification/Requirements.sysml)
            Related / governing contracts: Parameter validation: `REQ-SYS-ACC-011`; health-only publication:
            `REQ-SYS-ACC-018`.
            Planned verification / acceptance: `T-SW`: force validation failure; verify health remains
            available with no usable Position.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                When compiled-parameter validation fails, `LE-ACCELERATOR-QUAL` shall mark `Position`
                unavailable or unqualified without granting physical rest or readiness, while keeping
                `Qualification` and health publication available.
            */
        }
    }
    satisfy acceleratorCalibrationFailureResponse by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-013'> acceleratorMeasurementAgeQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-013
            (line 14).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-013"></a>`REQ-SYS-ACC-013` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-006](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-007](../../Specification/Requirements.sysml)
            Related / governing contracts: Maximum age: TBD under `WS-OI-003`, `WS-OI-007`.
            Planned verification / acceptance: `T-SW`: test caller time below, at, and above the bound.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall classify a measurement as stale when elapsed time from its
                actual measurement time to caller-supplied `executionTimeIn` exceeds the
                maximum-measurement-age bound.
            */
        }
    }
    satisfy acceleratorMeasurementAgeQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-017'> acceleratorAcquisitionTimeRetention : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-017
            (line 15).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-017"></a>`REQ-SYS-ACC-017` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-007](../../Specification/Requirements.sysml)
            Related / governing contracts: Input evidence: `REQ-SYS-ACC-014`; caller time:
            `REQ-SYS-PLT-002`; publication or receipt time is not an acquisition-time substitute.
            Planned verification / acceptance: `T-SW`: compare same-value acquisitions, health-only
            publications, and invalid republishes; verify only a valid new acquisition updates the retained
            actual acquisition time.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall preserve the actual acquisition time for each accepted valid new
                measurement, including a same-value acquisition.
            */
        }
    }
    satisfy acceleratorAcquisitionTimeRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-018'> acceleratorHealthUpdatePublication : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-018
            (line 16).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-018"></a>`REQ-SYS-ACC-018` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-007](../../Specification/Requirements.sysml),
            [REQ-SYS-ACC-008](../../Specification/Requirements.sysml)
            Related / governing contracts: Output schema: `REQ-SYS-ACC-001`.
            Planned verification / acceptance: `T-SW`: change health with no measurement; verify unchanged
            time.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall publish each health or unavailability change as a coherent
                `AcceleratorPosition` update without a new measurement and without changing retained
                measurement time.
            */
        }
    }
    satisfy acceleratorHealthUpdatePublication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-020'> acceleratorQualificationStateDistinction : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-020
            (line 17).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-020"></a>`REQ-SYS-ACC-020` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-005](../../Specification/Requirements.sysml)
            Related / governing contracts: Integrity indication: `REQ-SYS-ACC-014`.
            Planned verification / acceptance: `T-SW`: verify distinct output qualifications.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall retain the distinction between initial-unqualified status and
                recognized source-fault status in `Qualification`.
            */
        }
    }
    satisfy acceleratorQualificationStateDistinction by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-021'> acceleratorMeasurementEvidenceRejection : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-021
            (line 18).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-021"></a>`REQ-SYS-ACC-021` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-006](../../Specification/Requirements.sysml)
            Related / governing contracts: Freshness: `REQ-SYS-ACC-013`.
            Planned verification / acceptance: `T-SW`: verify neither physical rest nor qualified position.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall reject absent, unavailable, invalid, stale, and implausible
                measurement evidence as a basis for physical rest or qualified position.
            */
        }
    }
    satisfy acceleratorMeasurementEvidenceRejection by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-038'> startupAcceleratorQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-038
            (line 19).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-038"></a>`REQ-SYS-ACC-038` **Draft allocation**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-026](../../Specification/Requirements.sysml)
            Related / governing contracts: Initial qualification is not automatically a recognized fault.
            Planned verification / acceptance: `T-SW`: verify old evidence cannot establish Position.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                After normal or unexpected controller startup, `LE-ACCELERATOR-QUAL` shall withhold
                `Position` until successful current startup checks and a new valid measurement are
                available.
            */
        }
    }
    satisfy startupAcceleratorQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-039'> acceleratorMeasurementRequalification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-039
            (line 20).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-039"></a>`REQ-SYS-ACC-039` **Draft allocation**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-027](../../Specification/Requirements.sysml)
            Related / governing contracts: Health-only publication: `REQ-SYS-ACC-018`.
            Planned verification / acceptance: `T-SW`: verify recovery without a measurement does not
            restore Position.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                After invalidation, `LE-ACCELERATOR-QUAL` shall retain unavailable `Position` through
                health-only source recovery and restore it only from a new valid measurement.
            */
        }
    }
    satisfy acceleratorMeasurementRequalification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

    requirement <'REQ-SYS-ACC-040'> acceleratorFaultQualificationDelivery : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionProcessing/AcceleratorPositionProcessing.md#req-sys-acc-040
            (line 21).
            Original target: LE-ACCELERATOR-QUAL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-040"></a>`REQ-SYS-ACC-040` **Draft allocation**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-029](../../Specification/Requirements.sysml)
            Related / governing contracts: RidingControl owns session fault inhibition and retention.
            Planned verification / acceptance: `T-SW`, `T-SYS`: verify RidingControl receives a transient
            fault.
        */
        subject owner:AcceleratorPositionProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;
        require constraint {
            doc /*
                `LE-ACCELERATOR-QUAL` shall deliver recognized accelerator fault qualification to the
                Session response path without losing it during source recovery.
            */
        }
    }
    satisfy acceleratorFaultQualificationDelivery by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.positionProcessing;

}
