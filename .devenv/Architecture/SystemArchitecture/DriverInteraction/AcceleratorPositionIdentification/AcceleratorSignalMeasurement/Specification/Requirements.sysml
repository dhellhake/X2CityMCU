package X2CitySpecification_AcceleratorSignalMeasurement_Requirements {
    private import X2CityComponent_AcceleratorSignalMeasurement::AcceleratorSignalMeasurement;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-ACC-003'> acceleratorElectricalSignalMeasurement : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorSignalMeasurement/AcceleratorSignalMeasurement.md#req-sys-acc-003
            (line 10).
            Original target: LE-ACCELERATOR-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-003"></a>`REQ-SYS-ACC-003` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-001](../../Specification/Requirements.sysml),
            [REQ-SYS-HSI-001](../../../../Specification/SystemHardwareSoftwareInterface.sysml)
            Related / governing contracts: Electrical-domain gate: `WS-OI-002`; evidence: `REQ-SYS-ACC-014`.
            Planned verification / acceptance: `T-HW`: stimulate the approved range and verify a measured
            value.
        */
        subject owner:AcceleratorSignalMeasurement =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.signalMeasurement;
        require constraint {
            doc /*
                `LE-ACCELERATOR-HW` shall transform the rider electrical accelerator signal into an
                observable measured signal value over the allocated electrical input domain.
            */
        }
    }
    satisfy acceleratorElectricalSignalMeasurement by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.signalMeasurement;

    requirement <'REQ-SYS-ACC-014'> acceleratorMeasurementPublication : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorSignalMeasurement/AcceleratorSignalMeasurement.md#req-sys-acc-014
            (line 11).
            Original target: LE-ACCELERATOR-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-014"></a>`REQ-SYS-ACC-014` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-006](../../Specification/Requirements.sysml),
            [REQ-SYS-HSI-001](../../../../Specification/SystemHardwareSoftwareInterface.sysml)
            Related / governing contracts: Software consumer: `REQ-SYS-ACC-002`.
            Planned verification / acceptance: `I`, `T-HW`: present usable and nonusable evidence; verify
            the integrity indication is available.
        */
        subject owner:AcceleratorSignalMeasurement =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.signalMeasurement;
        require constraint {
            doc /*
                `LE-ACCELERATOR-HW` shall provide a coherent `AcceleratorMeasurement` with measured signal
                value, defined interpretation, and an available integrity indication for software use.
            */
        }
    }
    satisfy acceleratorMeasurementPublication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.signalMeasurement;

    requirement <'REQ-SYS-ACC-043'> acceleratorSensorElectricalCompatibility : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/AcceleratorPositionIdentification/AcceleratorSignalMeasurement/AcceleratorSignalMeasurement.md#req-sys-acc-043
            (line 12).
            Original target: LE-ACCELERATOR-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-acc-043"></a>`REQ-SYS-ACC-043` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-ACC-031](../../Specification/Requirements.sysml)
            Related / governing contracts: Characterize electrical limits under `WS-OI-002`, `WS-OI-007`.
            Planned verification / acceptance: `T-HW`, `T-FI`: verify the boundary in each integration
            state.
        */
        subject owner:AcceleratorSignalMeasurement =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.signalMeasurement;
        require constraint {
            doc /*
                `LE-ACCELERATOR-HW` shall be electrically compatible with the selected accelerator sensor's
                allocated supply, reference, signal, and loading domain in powered, startup, shutdown, and
                unpowered integration states.
            */
        }
    }
    satisfy acceleratorSensorElectricalCompatibility by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.accelerator.signalMeasurement;

}
