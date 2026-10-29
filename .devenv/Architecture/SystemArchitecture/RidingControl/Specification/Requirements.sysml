package X2CitySpecification_RidingControl_Requirements {
    private import X2CityComponent_RidingControl::RidingControl;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-SOC-008'> propulsionCapabilityRecoveryRamp : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/RidingControl/RidingControl.md#req-sys-soc-008 (line
            23).
            Original target: LE-RIDING.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-soc-008"></a>`REQ-SYS-SOC-008` **Draft successor**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. E: assess recovery across levels,
            including pack capability recovery while the reserve leaves the traction budget zero, and
            overlapping brake/speed/fault constraints; verify the ramp is not consumed before resumption is
            permitted; warning clearance is independent of ramp completion.
            Sources:
            [DEC-SOC-001](../../../DEC-001_Decisions_and_Open_Issues.md#dec-soc-001),
            [DEC-BRK-002](../../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-002)
            Open dependencies / qualifications: `WS-OI-003`, `WS-OI-005`, `WS-OI-007`, `WS-OI-010`,
            `WS-OI-013`, `WS-OI-017`: Level 0 uses Level 1's ramp while keeping its static mapping; Level 5
            adds none.
        */
        subject owner:RidingControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require constraint {
            doc /*
                After propulsion stop, when the communicated qualified traction discharge budget and the
                other applicable guards permit positive propulsion resumption, that resumption shall use
                [REQ-SYS-BRK-005](../../Specification/BrakeInterfaceAndPriority.sysml) resumption ramps.
            */
        }
    }
    satisfy propulsionCapabilityRecoveryRamp by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;

}
