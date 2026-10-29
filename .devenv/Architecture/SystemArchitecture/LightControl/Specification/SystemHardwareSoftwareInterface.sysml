package X2CitySpecification_LightControl_SystemHardwareSoftwareInterface {
    private import X2CityComponent_LightControl::LightControl;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-HSI-005'> brakeAndLampObservationBoundary : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-005
            (line 13).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-hsi-005"></a>`REQ-SYS-HSI-005` **Draft successor**
            Original obligation column: Approved requirement
            Target / allocation direction: [LE-LIGHT-CONTROL](../../X2CityMCU.md#le-light-control);
            HC-LAMP-DRIVE / HC-LAMPS provide the physical output boundary; software realization remains
            pending.
            Derived from / interfaces:
            [REQ-SYS-BRK-008](../../DriverInteraction/MechanicalBrakeDetection/Specification/Requirements.sysml),
            [REQ-VEH-LGT-009](LightingBehavior.sysml),
            [REQ-SYS-LGTHW-002](../LightActuation/Specification/Requirements.sysml); IF-A-001/005/006,
            HW-I-001/004, [brake evidence](../../DriverInteraction/MechanicalBrakeDetection/BrakeSignalMeasurement/BrakeSignalMeasurement.md).
            Planned verification and open acceptance: `I`, `A`, `T-FI`, `T-SYS`: test qualified/unknown
            brake state, startup/reset, policy unavailable and lamp load/output cases. Derive lamp
            electrical/visibility behavior, output reference and response bounds; protection qualification
            and the input sensing/fault envelope remain open.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                The brake/lamp boundary shall consume the fixed passive coded two-wire brake observation as
                qualified or unknown mechanical-lever information and keep it distinct from selected
                LightModes and actual lamp output. Before policy execution following startup or reset, and
                whenever required brake-lever or actual electrical-braking information is unqualified, the
                LightControl boundary shall provide the parent-required conservative rear-light behavior
                without inferring a lever state.
            */
        }
    }
    satisfy brakeAndLampObservationBoundary by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

}
