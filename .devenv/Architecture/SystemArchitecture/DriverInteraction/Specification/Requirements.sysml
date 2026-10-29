package X2CitySpecification_DriverInteraction_Requirements {
    private import X2CityComponent_DriverInteraction::DriverInteraction;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-DRI-001'> groupedDriverElectricalConnections : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/DriverInteraction.md#req-sys-dri-001
            (line 10).
            Original target: LE-INPUT.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-dri-001"></a>`REQ-SYS-DRI-001` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-HSI-001](../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-HSI-002](../../Specification/SystemHardwareSoftwareInterface.sysml). The parent
            grouping rationale is recorded in [ARCH-001](../../X2CityMCU.md#le-input).
            Related child interface contracts: See the coverage table below; these references identify
            endpoint obligations, not additional derivation parents.
            Planned verification / remaining gate: `I`, `T-SYS`: inspect the typed members, directions, and
            bindings against the responsible child ports; trace representative signals through each
            delegation. Electrical compatibility and child acceptance remain open under the linked
            contracts.
        */
        subject owner:DriverInteraction =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction;
        require constraint {
            doc /*
                `LE-INPUT` shall provide one grouped `DriverElectricalConnectionPort` containing distinct
                typed `acceleratorConnection`, `brakeLeverConnection`, and `vd18mtConnection` members, bind
                each member to its responsible child function, and preserve each constituent electrical
                contract.
            */
        }
    }
    satisfy groupedDriverElectricalConnections by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction;

}
