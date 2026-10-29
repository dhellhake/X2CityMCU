package X2CitySpecification_LightModeSelection_Requirements {
    private import X2CityComponent_LightModeSelection::LightModeSelection;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-LGTPOL-001'> normalLightRequestRetention : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightModeSelection/LightModeSelection.md#req-sys-lgtpol-001
            (line 10).
            Original target: LE-LIGHT-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgtpol-001"></a>`REQ-SYS-LGTPOL-001` **Draft successor**
            Original obligation column: Allocation
            Derived from: [LGT-001](../../Specification/LightingBehavior.sysml),
            [LGT-002](../../Specification/LightingBehavior.sysml)
            Planned verification / acceptance: `T-SW`: test initial Off, valid On/Off, loss, recovery
            without command, and next session.
        */
        subject owner:LightModeSelection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightModeSelection;
        require constraint {
            doc /*
                `LE-LIGHT-POLICY` shall retain the current-session normal-light request from valid
                `runningLightStateIn`, initially Off, through communication loss.
            */
        }
    }
    satisfy normalLightRequestRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightModeSelection;

    requirement <'REQ-SYS-LGTPOL-002'> frontLightRequestSelection : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightModeSelection/LightModeSelection.md#req-sys-lgtpol-002
            (line 11).
            Original target: LE-LIGHT-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgtpol-002"></a>`REQ-SYS-LGTPOL-002` **Draft**
            Original obligation column: Allocation
            Derived from: [LGT-001](../../Specification/LightingBehavior.sysml),
            [LGT-005](../../Specification/LightingBehavior.sysml)
            Planned verification / acceptance: `T-SW`: vary rear Full triggers while retaining each front
            state.
        */
        subject owner:LightModeSelection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightModeSelection;
        require constraint {
            doc /*
                `LE-LIGHT-POLICY` shall produce Front On/Off from the retained normal-light request
                independently of rear brake priority.
            */
        }
    }
    satisfy frontLightRequestSelection by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightModeSelection;

    requirement <'REQ-SYS-LGTPOL-003'> rearFullBrakeSelection : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightModeSelection/LightModeSelection.md#req-sys-lgtpol-003
            (line 12).
            Original target: LE-LIGHT-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgtpol-003"></a>`REQ-SYS-LGTPOL-003` **Draft**
            Original obligation column: Allocation
            Derived from: [LGT-004](../../Specification/LightingBehavior.sysml),
            [LGT-005](../../Specification/LightingBehavior.sysml),
            [LGT-006](../../Specification/LightingBehavior.sysml),
            [LGT-009](../../Specification/LightingBehavior.sysml)
            Planned verification / acceptance: `T-SW`, `T-FI`: cover each trigger, startup unknowns, and
            command changes during Full.
        */
        subject owner:LightModeSelection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightModeSelection;
        require constraint {
            doc /*
                `LE-LIGHT-POLICY` shall select rear Full when either qualified lever is actuated,
                `electricalBrakingStateIn` is qualified active, or either required input is unqualified.
            */
        }
    }
    satisfy rearFullBrakeSelection by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightModeSelection;

    requirement <'REQ-SYS-LGTPOL-004'> rearNormalLightSelection : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightModeSelection/LightModeSelection.md#req-sys-lgtpol-004
            (line 13).
            Original target: LE-LIGHT-POLICY.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgtpol-004"></a>`REQ-SYS-LGTPOL-004` **Draft**
            Original obligation column: Allocation
            Derived from: [LGT-003](../../Specification/LightingBehavior.sysml),
            [LGT-007](../../Specification/LightingBehavior.sysml),
            [LGT-008](../../Specification/LightingBehavior.sysml),
            [LGT-009](../../Specification/LightingBehavior.sysml)
            Planned verification / acceptance: `T-SW`, `T-FI`: restore qualifying released/absent states in
            either order with a retained fault.
        */
        subject owner:LightModeSelection =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightModeSelection;
        require constraint {
            doc /*
                Only when both levers are qualified released and electrical braking is qualified absent,
                `LE-LIGHT-POLICY` shall select rear Dim for retained normal On and rear Off for retained
                normal Off, regardless of a retained related fault state.
            */
        }
    }
    satisfy rearNormalLightSelection by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightModeSelection;

}
