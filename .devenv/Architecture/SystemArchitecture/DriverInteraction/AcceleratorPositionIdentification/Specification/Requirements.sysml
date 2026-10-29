package X2CitySpecification_AcceleratorPositionIdentification_Requirements {
    private import X2CityComponent_AcceleratorPositionIdentification::AcceleratorPositionIdentification;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-ACC-001'> acceleratorPositionComposite : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-001
            (line 34).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-001"></a>`REQ-SYS-ACC-001` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-001](../../../Specification/SystemHardwareSoftwareInterface.sysml)
            Related / governing contracts: Allocation children: `REQ-SYS-ACC-002`, `REQ-SYS-ACC-003`.
            Planned verification / acceptance: `I`, `T-SYS`: inspect the interface and exercise a result
            through the route; verify the composite members and measurement time.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall publish each accelerator result as one `AcceleratorPosition` record
                containing `Qualification` and `Position`, with `Position` carrying normalized accelerator
                position, physical-rest status, and actual measurement time.
            */
        }
    }
    satisfy acceleratorPositionComposite by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-004'> normalizedAcceleratorPosition : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-004
            (line 35).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-004"></a>`REQ-SYS-ACC-004` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](Requirements.sysml)
            Related / governing contracts: Rest criterion, endpoint uncertainty, and normalization
            acceptance: `WS-OI-002`.
            Planned verification / acceptance: `T-SYS`: stimulate released, full-application, intermediate,
            and rest inputs; verify normalized value and rest status.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall express each qualified physical accelerator input in `Position` as
                normalized mechanical travel of 0 percent at fully released travel and 100 percent at full
                application, with physical-rest status according to the calibrated rest criterion.
            */
        }
    }
    satisfy normalizedAcceleratorPosition by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-005'> acceleratorInitialQualificationDistinction : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-005
            (line 36).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-005"></a>`REQ-SYS-ACC-005` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-STA-003](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-FLT-003](../../../Specification/PowerStartupAndFaults.sysml)
            Related / governing contracts: —
            Planned verification / acceptance: `T-SYS`, `T-FI`: observe startup before qualification and
            inject a recognized source fault; verify distinct qualification states.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall distinguish initial-unqualified status from a recognized source fault
                in `Qualification`.
            */
        }
    }
    satisfy acceleratorInitialQualificationDistinction by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-006'> invalidAcceleratorMeasurementRejection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-006
            (line 37).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-006"></a>`REQ-SYS-ACC-006` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-001](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-FLT-003](../../../Specification/PowerStartupAndFaults.sysml)
            Related / governing contracts: Plausibility, freshness, and fault-characterization criteria:
            `WS-OI-003`, `WS-OI-007`, `WS-OI-010`.
            Planned verification / acceptance: `T-FI`, `T-SYS`: inject each named condition and verify
            neither qualified position nor physical rest.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall not represent an absent, unavailable, invalid, stale, or implausible
                measurement as physical rest or a qualified position.
            */
        }
    }
    satisfy invalidAcceleratorMeasurementRejection by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-007'> acceleratorMeasurementTimeRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-007
            (line 38).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-007"></a>`REQ-SYS-ACC-007` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](Requirements.sysml)
            Related / governing contracts: Freshness evaluation: `REQ-SYS-ACC-013`.
            Planned verification / acceptance: `T-SYS`: publish health-only updates after a measured result;
            verify the retained measurement time does not change.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall retain the actual `Position` measurement time during a health-only
                publication.
            */
        }
    }
    satisfy acceleratorMeasurementTimeRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-008'> acceleratorPositionConsumerDelivery : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-008
            (line 39).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-008"></a>`REQ-SYS-ACC-008` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](Requirements.sysml)
            Related / governing contracts: Software delivery contribution: `REQ-SYS-ACC-002`.
            Planned verification / acceptance: `I`, `T-SYS`: trace the composite to policy consumers and
            qualification to platform; verify an unusable Position remains unusable while health is
            delivered.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall provide `AcceleratorPosition` to settings, session, and demand and
                provide its `Qualification` health projection to platform.
            */
        }
    }
    satisfy acceleratorPositionConsumerDelivery by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-009'> acceleratorPositionErrorBound : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-009
            (line 40).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-009"></a>`REQ-SYS-ACC-009` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](Requirements.sysml)
            Related / governing contracts: Maximum-error bound and conditions: TBD under `WS-OI-002`,
            `WS-OI-003`.
            Planned verification / acceptance: `T-SYS`: measure electrical-signal-to-qualified-position
            error at endpoints and rest under the qualifying conditions.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall limit end-to-end accelerator-position error to the maximum-error
                bound, in percent of full scale, at qualifying electrical and physical reference conditions.
            */
        }
    }
    satisfy acceleratorPositionErrorBound by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-022'> acceleratorPositionResponseTime : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-022
            (line 41).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-022"></a>`REQ-SYS-ACC-022` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](Requirements.sysml)
            Related / governing contracts: Maximum-response-time bound and conditions: TBD under
            `WS-OI-003`, `WS-OI-007`; freshness is governed by `REQ-SYS-ACC-006` and `REQ-SYS-ACC-013`.
            Planned verification / acceptance: `T-SYS`: measure signal-change-to-qualified-publication
            response under the qualifying conditions.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall limit elapsed response time from a qualifying electrical-signal
                change to publication of the corresponding qualified `AcceleratorPosition` to the
                maximum-response-time bound, in milliseconds.
            */
        }
    }
    satisfy acceleratorPositionResponseTime by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-024'> independentPhysicalAcceleratorIdentification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-024
            (line 42).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-024"></a>`REQ-SYS-ACC-024` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](Requirements.sysml)
            Related / governing contracts: Torque interpretation, brake priority, and authorization remain
            at their existing owners.
            Planned verification / acceptance: `T-SYS`: vary assist level, brake state, and authorization
            for one qualified input; verify the same Position and rest result.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall identify physical accelerator position and rest independently of
                assist level, brake actuation, and drive authorization while the vehicle is powered.
            */
        }
    }
    satisfy independentPhysicalAcceleratorIdentification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-026'> startupAcceleratorPositionQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-026
            (line 43).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-026"></a>`REQ-SYS-ACC-026` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-STA-003](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-007](../../../Compute/Platform/Specification/SystemHardwareSoftwareInterface.sysml)
            Related / governing contracts: Initial qualification and recognized-fault criteria remain
            distinct.
            Planned verification / acceptance: `T-SYS`, `T-FI`: start with an old measurement visible,
            perform checks, then provide a new valid measurement; verify old evidence does not establish
            Position.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                After normal or unexpected controller startup, `LE-ACCELERATOR` shall leave `Position`
                unqualified until successful current startup checks and a new valid measurement establish
                it.
            */
        }
    }
    satisfy startupAcceleratorPositionQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-027'> acceleratorPositionRequalification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-027
            (line 44).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-027"></a>`REQ-SYS-ACC-027` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-006](Requirements.sysml), [REQ-SYS-ACC-007](Requirements.sysml)
            Related / governing contracts: Health-only source recovery does not restore Position;
            RidingControl session fault retention remains governed by `REQ-SYS-FLT-005`.
            Planned verification / acceptance: `T-SYS`, `T-FI`: invalidate a result, recover health without
            a new measurement, then provide one; verify only the final case restores Position.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                After accelerator `Position` is invalidated, `LE-ACCELERATOR` shall restore it only from a
                new valid measurement.
            */
        }
    }
    satisfy acceleratorPositionRequalification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-029'> acceleratorFaultEventRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-029
            (line 45).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-029"></a>`REQ-SYS-ACC-029` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-FLT-003](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-FLT-005](../../../Specification/PowerStartupAndFaults.sysml)
            Related / governing contracts: Existing whole-system fault-response timing remains governing;
            RidingControl owns session inhibition and retention.
            Planned verification / acceptance: `T-SYS`, `T-FI`: create a transient recognized fault and
            verify RidingControl receives its response input despite later source recovery.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall make each recognized accelerator fault qualification available to the
                RidingControl session fault-response path despite subsequent source recovery.
            */
        }
    }
    satisfy acceleratorFaultEventRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-031'> acceleratorElectricalInterfaceCompatibility : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-031
            (line 46).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-031"></a>`REQ-SYS-ACC-031` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-001](../../../Specification/SystemHardwareSoftwareInterface.sysml)
            Related / governing contracts: Selected accelerator: `CON-007`; electrical interface evidence:
            `IF-EPCS-007`.
            Planned verification / acceptance: `T-HW`, `T-SYS`: inspect and test supply, reference, and
            signal relationship through specified operating conditions.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall preserve compatibility with the selected three-wire accelerator
                supply, reference, and signal relationship across the specified operating conditions.
            */
        }
    }
    satisfy acceleratorElectricalInterfaceCompatibility by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-046'> acceleratorRestVoltageMapping : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-046
            (line 47).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-046"></a>`REQ-SYS-ACC-046` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-004](Requirements.sysml), [REQ-SYS-ACC-006](Requirements.sysml)
            Related / governing contracts: The rest-voltage band is bounded by immutable compiled
            `endpointCalibration.restVoltageMinimumVolts` and `endpointCalibration.restVoltageMaximumVolts`.
            Planned verification / acceptance: `T-SYS`: exercise otherwise qualified values at and within
            both rest-band limits; verify 0 percent and physical-rest status true.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                For each otherwise qualified accelerator measurement whose accelerator signal voltage,
                relative to the sensor reference return, is within the inclusive rest-voltage band,
                `LE-ACCELERATOR` shall publish normalized `Position` of 0 percent and physical-rest status
                true.
            */
        }
    }
    satisfy acceleratorRestVoltageMapping by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-047'> acceleratorFullThrottleVoltageMapping : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-047
            (line 48).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-047"></a>`REQ-SYS-ACC-047` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-004](Requirements.sysml), [REQ-SYS-ACC-006](Requirements.sysml)
            Related / governing contracts: The full-throttle-voltage band is bounded by immutable compiled
            `endpointCalibration.fullThrottleVoltageMinimumVolts` and
            `endpointCalibration.fullThrottleVoltageMaximumVolts`.
            Planned verification / acceptance: `T-SYS`: exercise otherwise qualified values at and within
            both full-throttle-band limits; verify 100 percent.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                For each otherwise qualified accelerator measurement whose accelerator signal voltage,
                relative to the sensor reference return, is within the inclusive full-throttle-voltage band,
                `LE-ACCELERATOR` shall publish normalized `Position` of 100 percent.
            */
        }
    }
    satisfy acceleratorFullThrottleVoltageMapping by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-048'> acceleratorNonRestVoltageMapping : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-048
            (line 49).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-048"></a>`REQ-SYS-ACC-048` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-004](Requirements.sysml), [REQ-SYS-ACC-006](Requirements.sysml)
            Related / governing contracts: This criterion does not define intermediate position mapping,
            signal polarity, or treatment of unqualified measurements.
            Planned verification / acceptance: `T-SYS`: exercise otherwise qualified values immediately
            outside each rest-band limit and at the full-throttle band; verify physical-rest status false.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                For each otherwise qualified accelerator measurement whose accelerator signal voltage,
                relative to the sensor reference return, is outside the inclusive rest-voltage band,
                `LE-ACCELERATOR` shall publish physical-rest status false.
            */
        }
    }
    satisfy acceleratorNonRestVoltageMapping by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

    requirement <'REQ-SYS-ACC-049'> acceleratorVoltageBandValidation : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-049
            (line 50).
            Original target: LE-ACCELERATOR.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-049"></a>`REQ-SYS-ACC-049` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-046](Requirements.sysml), [REQ-SYS-ACC-047](Requirements.sysml)
            Related / governing contracts: `endpointCalibration` is an immutable compiled calibration set
            and its four members are TBD; each band has ordered bounds and the inclusive bands do not
            overlap. Polarity and intermediate mapping remain characterization work.
            Planned verification / acceptance: `T-SYS`: record fixed-stop voltage variation at both stops,
            establish all four bounds, and verify ordered, non-overlapping inclusive bands.
        */
        subject owner:AcceleratorPositionIdentification =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;
        require constraint {
            doc /*
                `LE-ACCELERATOR` shall use rest and full-throttle voltage bands whose minimum and maximum
                limits are established during vehicle validation from accelerator signal voltage, relative
                to the sensor reference return, observed while the handle is held stationary at each
                mechanical released and full-throttle stop.
            */
        }
    }
    satisfy acceleratorVoltageBandValidation by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator;

}
