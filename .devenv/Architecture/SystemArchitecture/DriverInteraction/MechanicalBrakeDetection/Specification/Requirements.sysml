package X2CitySpecification_MechanicalBrakeDetection_Requirements {
    private import X2CityComponent_MechanicalBrakeDetection::MechanicalBrakeDetection;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BRK-006'> brakeLeverIdentityDetection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/MechanicalBrakeDetection.md#req-sys-brk-006
            (line 32).
            Original target: LE-MECHANICAL-BRAKE.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-sys-brk-006"></a>`REQ-SYS-BRK-006` **Approved body; Draft successor target**
            Original obligation column: Requirement
            Derived from / governing contracts: `DEC-REF-002`, `CON-010`;
            [Brake input reference](../BrakeSignalMeasurement/BrakeSignalMeasurement.md).
            Planned verification and remaining gate: `I`, `T-SYS`: exercise all four codes over defined
            tolerances/environment, reverse either branch polarity and verify handle identity; verify
            left/front and right/rear mechanical association. `WS-OI-012`, `WS-OI-013`: terminal
            measurements do not verify sensing.
        */
        subject owner:MechanicalBrakeDetection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;
        require constraint {
            doc /*
                Within the validated fault-free interface envelope, the EPCS shall distinguish neither,
                left, right and both levers pressed.
            */
        }
    }
    satisfy brakeLeverIdentityDetection by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;

    requirement <'REQ-SYS-BRK-007'> invalidBrakeStateRepresentation : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/MechanicalBrakeDetection.md#req-sys-brk-007
            (line 33).
            Original target: LE-MECHANICAL-BRAKE.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-sys-brk-007"></a>`REQ-SYS-BRK-007` **Approved body; Draft successor target**
            Original obligation column: Requirement
            Derived from / governing contracts: `DEC-REF-002`, `DEC-FLT-002`, `DEC-FLT-003`, `DEC-LGT-001`;
            [INT-001](../../../Specification/InterfaceQualification.sysml).
            Planned verification and remaining gate: `I`, `T-FI`: verify unknown state independently of
            torque inhibition, retained report and full rear brightness. `WS-OI-010`, `WS-OI-012`,
            `WS-OI-016`: full brightness does not establish a physical press or failed-handle identity.
        */
        subject owner:MechanicalBrakeDetection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;
        require constraint {
            doc /*
                Invalid brake information shall represent actuation and handle identity as unknown, without
                substituting a valid pressed/released state.
            */
        }
    }
    satisfy invalidBrakeStateRepresentation by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;

    requirement <'REQ-SYS-BRK-008'> unusableBrakeStateRejection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/MechanicalBrakeDetection.md#req-sys-brk-008
            (line 34).
            Original target: LE-MECHANICAL-BRAKE.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-sys-brk-008"></a>`REQ-SYS-BRK-008` **Approved body; Draft successor target**
            Original obligation column: Requirement
            Derived from / governing contracts: `DEC-REF-002`;
            [INT-001](../../../Specification/InterfaceQualification.sysml),
            [INT-002](../../../Specification/InterfaceQualification.sysml).
            Planned verification and remaining gate: `I`, `T-SYS`, `T-FI`: challenge derived validity
            criteria; distinguish initial unqualified information from recognized failure. `WS-OI-007`,
            `WS-OI-010`, `WS-OI-012`: no sensing, sampling, filter, threshold or timing realization is
            adopted.
        */
        subject owner:MechanicalBrakeDetection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;
        require constraint {
            doc /*
                Unavailable, stale, implausible or ambiguous brake information shall not be accepted as a
                valid released/actuated state.
            */
        }
    }
    satisfy unusableBrakeStateRejection by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;

    requirement <'REQ-SYS-BRKDET-001'> brakeStateCompositePublication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/MechanicalBrakeDetection.md#req-sys-brkdet-001
            (line 35).
            Original target: LE-MECHANICAL-BRAKE.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-brkdet-001"></a>`REQ-SYS-BRKDET-001` **Draft**
            Original obligation column: Requirement
            Derived from / governing contracts:
            [REQ-SYS-BRK-006](Requirements.sysml)–[008](Requirements.sysml),
            [REQ-SYS-HSI-001](../../../Specification/SystemHardwareSoftwareInterface.sysml).
            Planned verification and remaining gate: `I`, `T-SYS`: inspect the public schema and routes;
            verify State and Qualification are not separated, transformed, or duplicated for consumers.
        */
        subject owner:MechanicalBrakeDetection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;
        require constraint {
            doc /*
                `LE-MECHANICAL-BRAKE` shall publish each brake result as the one `BrakeLeverState` composite
                defined above, and shall make the full record available to RidingControl, Demand, and Light
                while providing its exact Qualification projection to Platform.
            */
        }
    }
    satisfy brakeStateCompositePublication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;

    requirement <'REQ-SYS-BRKDET-002'> brakeQualificationAndFaultRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/MechanicalBrakeDetection.md#req-sys-brkdet-002
            (line 36).
            Original target: LE-MECHANICAL-BRAKE.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-brkdet-002"></a>`REQ-SYS-BRKDET-002` **Draft**
            Original obligation column: Requirement
            Derived from / governing contracts: [REQ-SYS-BRK-007](Requirements.sysml),
            [REQ-SYS-BRK-008](Requirements.sysml),
            [REQ-SYS-INT-002](../../../Specification/InterfaceQualification.sysml).
            Planned verification and remaining gate: `T-SYS`, `T-FI`: compare initial startup waiting,
            recognized fault, source recovery, and the Session latch. Fault-recognition criteria remain
            derived work.
        */
        subject owner:MechanicalBrakeDetection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;
        require constraint {
            doc /*
                `LE-MECHANICAL-BRAKE` shall preserve the distinction between initial qualification pending
                and a recognized measurement fault in `BrakeLeverState.Qualification`; requalification of
                current information may restore consumer use but shall not clear a Session-retained fault.
            */
        }
    }
    satisfy brakeQualificationAndFaultRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection;

}
