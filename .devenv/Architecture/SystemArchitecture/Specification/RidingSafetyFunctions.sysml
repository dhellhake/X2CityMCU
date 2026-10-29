package X2CitySpecification_X2CityMCU_RidingSafetyFunctions {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-VEH-FSC-002'> criticalTorqueAndCurrentResponseBounds : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Riding_Safety_Functions.md#req-veh-fsc-002 (line 10).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-fsc-002"></a>`REQ-VEH-FSC-002`
            Original obligation column: Requirement
            Derived from: [SG-003](../../../Safety/SG-001_Safety_Goals.md#sg-003),
            [SG-004](../../../Safety/SG-001_Safety_Goals.md#sg-004)
            Target: [LE-EPCS](../../REQ-001_Requirements.md#le-epcs)
            Planned verification / acceptance: `A`, `T-SYS`: derive torque/current/voltage and response
            bounds for each electrical withdrawal and coincident limit; exercise supplied speed/grade/load
            duties with electrical references. Do not establish steering, traction, brake distance, braking
            effort/fade or rider-balance acceptance.
            Supporting sources / open gate: [PERF-004/005](VehicleQualification.sysml),
            [PWR-003](PowerStartupAndFaults.sysml), [SPD-003](RiderControl.sysml),
            [SOC-003](../BatteryControl/BatteryControl.sysml); OI-048, WS-OI-013. No continued motor drive,
            automatic holding or dedicated regeneration warning is assumed.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Draft:** During the supplied riding duty, EPCS shall keep speed-cutoff withdrawal, common
                both-sign fault inhibition, moving shutdown and the qualified lowest-group-voltage
                discharge-current cutoff within derived electrical torque/current/energy response bounds,
                including electrical regenerative withdrawal during descent and deliberate launch while
                rolling backward. Mechanical platform suitability and braking remain external assumptions.
            */
        }
    }
    satisfy criticalTorqueAndCurrentResponseBounds by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-FSC-003'> torqueProfileCalibrationLimits : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Riding_Safety_Functions.md#req-veh-fsc-003 (line 11).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-fsc-003"></a>`REQ-VEH-FSC-003`
            Original obligation column: Requirement
            Derived from: [SG-001](../../../Safety/SG-001_Safety_Goals.md#sg-001),
            [SG-002](../../../Safety/SG-001_Safety_Goals.md#sg-002),
            [SG-003](../../../Safety/SG-001_Safety_Goals.md#sg-003)
            Target: [LE-EPCS](../../REQ-001_Requirements.md#le-epcs)
            Planned verification / acceptance: `A`, `T-SYS`: establish actual torque/current/response bounds
            over the supplied mass/surface/grade duty. Exercise demand endpoints, steps, both-lever release
            as an electrical input event, and overlapping electrical recovery events in Levels 0–5;
            distinguish physical electrical limits from comfort shaping.
            Supporting sources / open gate:
            [Profile acceptance](../RidingControl/RidingPolicy/RidingPolicy.md#context-rider-control-torque-profile-calibration-acceptance),
            [BRK-003/005](BrakeInterfaceAndPriority.sysml), [ENV-002](EnvironmentAndStorage.sysml);
            HA-OI-002, WS-OI-003/005/006/013. Derive EPCS numeric envelopes before profile acceptance. No
            mechanical brake adequacy or rider-balance qualification is added.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Draft:** The electrical propulsion system's torque capability and profile calibration
                shall keep commanded motor torque, positive-torque resumption and regenerative withdrawal
                within qualified EPCS torque/current/thermal limits in every assist level. This includes
                direct Level 5 demand/resumption, repeated speed-cap crossings, low-speed taper and
                simultaneous clearance of electrical restrictions.
            */
        }
    }
    satisfy torqueProfileCalibrationLimits by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
