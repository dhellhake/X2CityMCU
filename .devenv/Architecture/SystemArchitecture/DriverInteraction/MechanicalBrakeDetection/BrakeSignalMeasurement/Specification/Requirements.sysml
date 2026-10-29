package X2CitySpecification_BrakeSignalMeasurement_Requirements {
    private import X2CityComponent_BrakeSignalMeasurement::BrakeSignalMeasurement;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BRKHW-001'> brakeElectricalMeasurement : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeSignalMeasurement/BrakeSignalMeasurement.md#req-sys-brkhw-001
            (line 10).
            Original target: LE-BRAKE-SIGNAL.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-brkhw-001"></a>`REQ-SYS-BRKHW-001` **Draft**
            Original obligation column: Requirement
            Derived from / governing contracts: [REQ-SYS-BRK-006](../../Specification/Requirements.sysml),
            [REQ-SYS-HSI-001](../../../../Specification/SystemHardwareSoftwareInterface.sysml).
            Planned verification and remaining gate: `T-HW`, `I`: apply known interface conditions and
            nonusable evidence; verify the electrical-response value and integrity evidence are available.
            Electrical envelope and acquisition realization remain qualification gates.
        */
        subject owner:BrakeSignalMeasurement =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.signalMeasurement;
        require constraint {
            doc /*
                `LE-BRAKE-SIGNAL` shall transform the fixed passive shared two-wire brake terminal interface
                into a `BrakeMeasurement` with an observable electrical-response value and available
                measurement-integrity evidence for software use.
            */
        }
    }
    satisfy brakeElectricalMeasurement by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.signalMeasurement;

    requirement <'REQ-SYS-BRKHW-002'> sharedBrakeInterfaceCompatibility : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/MechanicalBrakeDetection/BrakeSignalMeasurement/BrakeSignalMeasurement.md#req-sys-brkhw-002
            (line 11).
            Original target: LE-BRAKE-SIGNAL.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-brkhw-002"></a>`REQ-SYS-BRKHW-002` **Draft**
            Original obligation column: Requirement
            Derived from / governing contracts: [REQ-SYS-BRK-006](../../Specification/Requirements.sysml),
            `CON-010`.
            Planned verification and remaining gate: `I`, `T-HW`: inspect and test the physical boundary
            over the qualified integration conditions. Electrical protection performance and diagnostic
            coverage remain qualification work; `REQ-SYS-BRK-009`–011 are deferred proposals only.
        */
        subject owner:BrakeSignalMeasurement =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.signalMeasurement;
        require constraint {
            doc /*
                `LE-BRAKE-SIGNAL` shall provide physical compatibility, conditioning/protection, and
                measurement responsibility for the fixed shared two-wire brake terminal interface over the
                qualified vehicle integration conditions, preserving it as one shared measurement boundary.
            */
        }
    }
    satisfy sharedBrakeInterfaceCompatibility by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.mechanicalBrakeDetection.signalMeasurement;

}
