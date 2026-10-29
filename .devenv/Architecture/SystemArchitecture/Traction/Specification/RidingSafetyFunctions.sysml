package X2CitySpecification_Traction_RidingSafetyFunctions {
    private import X2CitySystemArchitecture::Traction;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-FSC-001'> physicalWheelTorqueEnvelope : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Riding_Safety_Functions.md#req-sys-fsc-001 (line 9).
            Original target: LE-TRACTION.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-fsc-001"></a>`REQ-SYS-FSC-001`
            Original obligation column: Requirement
            Derived from: [SG-001](../../../../Safety/SG-001_Safety_Goals.md#sg-001),
            [SG-002](../../../../Safety/SG-001_Safety_Goals.md#sg-002)
            Target: [LE-TRACTION](../../X2CityMCU.md#le-traction)
            Planned verification / acceptance: `A`, `T-SYS`, `T-FI`: compare qualified wheel output against
            authorization and demand through stale/incorrect commands, sign/magnitude error, control loss
            and credible power-stage faults. Establish detection/prevention coverage, permitted transient
            torque, response duration and residual drag. Verify physical output; requested zero is
            insufficient evidence.
            Supporting sources / open gate: [INT-003/004](InterfaceQualification.sysml),
            [CTL-002](../../RidingControl/RidingPolicy/Specification/SettingsAndControlPolicy.sysml),
            [ENE-003](../../Specification/EnergyAndProtection.sysml); HA-OI-002/003, WS-OI-003/007/010/015.
            Qualify the credible fault envelope and numeric bounds before traction safety acceptance; no
            torque sensor or independent hardware channel is selected.
        */
        subject owner:Traction =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction;
        require constraint {
            doc /*
                **Draft:** The traction function shall keep actual motor-produced wheel torque within the
                qualified current authorization, direction and magnitude envelope. For a departure caused by
                a control, command-transfer or output-stage fault, its protective response shall bound the
                hazardous positive/negative torque and wheel restraint within the event-specific physical
                torque/time envelope, including when normal torque control cannot perform the requested
                withdrawal.
            */
        }
    }
    satisfy physicalWheelTorqueEnvelope by X2CitySystemArchitecture::x2CityVehicle.epcs.traction;

}
