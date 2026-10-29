package X2CitySpecification_Compute_Requirements {
    private import X2CityComponent_Compute::Compute;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-CMP-002'> computeElectricalPowerSupply : SystemRequirement {
        doc /*
            Original source: .devenv/Architecture/SystemArchitecture/Compute/Compute.md#req-sys-cmp-002
            (line 54).
            Original target: LE-COMPUTE.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-cmp-002"></a>`REQ-SYS-CMP-002` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-ENE-001](../../Specification/EnergyAndProtection.sysml);
            `IfA010VehicleElectricalPower`, `IF-EPCS-010`.
            Planned verification / remaining gate: `I`, `A`, `T-HW`, `T-SYS`: trace the vehicle
            electrical-power path to Compute's input and characterize compatibility and powered/unpowered
            behavior for the selected configuration. Supply, rail and load values, protection, and physical
            acceptance remain open.
        */
        subject owner:Compute =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute;
        require constraint {
            doc /*
                Compute shall receive vehicle electrical power supplied from the EPCS `EnergyPath` through
                `vehicleElectricalPowerIn` for operation of the controller hardware.
            */
        }
    }
    satisfy computeElectricalPowerSupply by X2CitySystemArchitecture::x2CityVehicle.epcs.compute;

}
