package X2CitySpecification_Traction_InterfaceQualification {
    private import X2CitySystemArchitecture::Traction;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-INT-003'> actualMotorOutputDistinction : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Interface_Qualification.md#req-sys-int-003 (line 13).
            Original target: LE-TRACTION.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-int-003"></a>`REQ-SYS-INT-003`
            Original obligation column: Requirement
            Derived from: [REQ-SYS-REG-011](../../Specification/RiderControl.sysml),
            [REQ-VEH-LGT-004](../../LightControl/Specification/LightingBehavior.sysml)
            Planned verification / acceptance: A, T-SYS, T-FI: compare command with independent
            motion/output references during blocked demand, rollback, hand pushing, torque at standstill,
            permitted powered travel and actual electrical braking; verify the respective regeneration and
            light events.
            Sources and open dependencies: DEC-REG-006, DEC-LGT-001; WS-OI-001/006/016. Define
            applied-output criteria, uncertainty and latency. Qualified inference is permitted if
            substantiated; no torque sensor, estimator or brake-input sensing realization is selected.
        */
        subject owner:Traction =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction;
        require constraint {
            doc /*
                Motion and applied-motor-output information used to qualify powered forward travel or active
                electrical braking shall distinguish actual qualified output from a requested torque that is
                blocked, limited or unrealized.
            */
        }
    }
    satisfy actualMotorOutputDistinction by X2CitySystemArchitecture::x2CityVehicle.epcs.traction;

    requirement <'REQ-SYS-INT-004'> torqueCommandAuthorizationValidity : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Interface_Qualification.md#req-sys-int-004 (line 14).
            Original target: LE-TRACTION.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-int-004"></a>`REQ-SYS-INT-004`
            Original obligation column: Requirement
            Derived from: [REQ-SYS-STA-002](../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-PWR-003](../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-FLT-009](../../Specification/PowerStartupAndFaults.sysml)
            Planned verification / acceptance: `A`, `T-SYS`, `T-FI`. Withdraw authorization, interrupt
            updates, supply invalid/late commands and restart each producer/consumer while commands are
            queued; verify no stale authorization/command combination grants torque. Verify both-sign
            command withdrawal and physical response separately. Fresh commands cannot clear recognized
            session inhibition.
            Sources and open dependencies: Target LE-TRACTION; IF-A-004; WS-OI-007/010/015, OI-043/049.
            Derive authority identity, validity, command age, transfer/recognition/response bounds and
            failure coverage; no watchdog, communication medium or host is selected. The VD18MT
            last-settings exception does not authorize retained actuator commands. Physical
            stuck-output/generated-energy protection remains ENE-002/003.
        */
        subject owner:Traction =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction;
        require constraint {
            doc /*
                The torque-realization function shall accept a motor-torque command only with current
                qualified drive authorization and a valid, unexpired command belonging to that authorization
                context. Withdrawn authorization or an absent, invalid or expired command shall cause zero
                commanded torque of both signs within the allocated response bound; an earlier accepted
                nonzero command shall not extend authorization or bypass this withdrawal.
            */
        }
    }
    satisfy torqueCommandAuthorizationValidity by X2CitySystemArchitecture::x2CityVehicle.epcs.traction;

}
