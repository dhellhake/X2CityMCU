package X2CitySpecification_LightControl_LightingBehavior {
    private import X2CityComponent_LightControl::LightControl;
    private import RequirementTypes::*;

    requirement <'REQ-VEH-LGT-001'> normalLightingRequestFollowing : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-001 (line 43).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-001"></a>`REQ-VEH-LGT-001` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-HMI-003`, `OBJ-007`, `OI-032`, `OI-038`, `OI-039`;
            [AUX-001](../../Specification/AuxiliaryContinuity.sysml).
            Planned verification: `I`, `T-SYS`: normal On gives front On/rear Dim; normal Off gives both Off
            when rear has no brake priority.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                From power-on, front and rear normal illumination shall follow the same current valid or
                retained normal-light request, subject to rear brake priority.
            */
        }
    }
    satisfy normalLightingRequestFollowing by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-002'> initialNormalLightingOff : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-002 (line 44).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-002"></a>`REQ-VEH-LGT-002` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-HMI-003`, `DEC-FLT-001`.
            Planned verification: `I`, `T-SYS`: distinguish initial Off from later communication loss and
            retained request.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                Before the first valid normal-light request in a powered session, normal front/rear
                illumination shall remain Off, subject to rear brake priority.
            */
        }
    }
    satisfy initialNormalLightingOff by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-003'> rearNormalAndBrakeIntensity : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-003 (line 45).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-003"></a>`REQ-VEH-LGT-003` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-LGT-001`, `OI-039`; physical distinction:
            [FSC-012](LightingBehavior.sysml).
            Planned verification: `I`, `T-SYS`: distinguish physical Dim and Full.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                Rear normal On shall be Dim and rear brake indication Full.
            */
        }
    }
    satisfy rearNormalAndBrakeIntensity by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-004'> electricalBrakingRearLight : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-004 (line 46).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-004"></a>`REQ-VEH-LGT-004` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-LGT-001`; actual braking is supplied by Traction and
            includes rollback retardation and constant-speed descent motor braking.
            Planned verification: `I`, `T-SYS`: cover those braking cases; suppressed demand, torque sign,
            and battery-current direction alone do not establish braking.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                While powered, qualified active electrical braking shall require rear Full brake indication.
            */
        }
    }
    satisfy electricalBrakingRearLight by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-005'> rearBrakeLightPriority : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-005 (line 47).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-005"></a>`REQ-VEH-LGT-005` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-LGT-001`, `DEC-HMI-003`, `DEC-FLT-001`.
            Planned verification: `I`, `T-SYS`: cover normal On/Off, no first command, and communication
            loss.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                While powered, required rear brake indication shall override rear normal illumination,
                including normal Off and unavailable normal-light information; the front remains governed by
                its normal request.
            */
        }
    }
    satisfy rearBrakeLightPriority by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-006'> mechanicalBrakeRearLight : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-006 (line 48).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-006"></a>`REQ-VEH-LGT-006` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-LGT-001`; qualified mechanical lever state is supplied by
            MechanicalBrakeDetection.
            Planned verification: `I`, `T-SYS`: each/both levers at rest and in motion, including
            unavailable regeneration.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                While powered, either qualified actuated mechanical brake lever shall require rear Full
                brake indication regardless of motion or actual deceleration.
            */
        }
    }
    satisfy mechanicalBrakeRearLight by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-007'> passiveSlowingLightBehavior : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-007 (line 49).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-007"></a>`REQ-VEH-LGT-007` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-LGT-001`.
            Planned verification: `I`, `T-SYS`: coast, drag, and uphill travel, then add each qualifying
            trigger.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                Passive slowing alone shall not require rear brake indication when both levers are qualified
                released and active electrical braking is qualified absent.
            */
        }
    }
    satisfy passiveSlowingLightBehavior by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-008'> rearNormalLightRestoration : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-008 (line 50).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-008"></a>`REQ-VEH-LGT-008` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-LGT-001`, `DEC-FLT-002`, `DEC-FLT-003`.
            Planned verification: `T-FI`, `T-SYS`: restore qualified released/absent states with retained
            fault and torque state; Full shall not remain latched.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                While powered, the rear shall return to the current normal Dim/Off state when both levers
                are qualified released and actual electrical braking is qualified absent, even if related
                torque-inhibition or fault-report state remains latched.
            */
        }
    }
    satisfy rearNormalLightRestoration by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-009'> unknownBrakeStateRearLight : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-009 (line 51).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-009"></a>`REQ-VEH-LGT-009` **Draft successor**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: `DEC-LGT-002`, `DEC-FLT-011`, `REQ-SYS-INT-003`;
            [AUX-001](../../Specification/AuxiliaryContinuity.sysml).
            Planned verification: `T-FI`, `T-SYS`: withhold and stale each input independently and together,
            including startup.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                While powered, unqualified brake-lever state or unqualified actual electrical-braking state
                shall require rear Full brake indication, including startup.
            */
        }
    }
    satisfy unknownBrakeStateRearLight by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-LGT-010'> lightingAvailabilityRestriction : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-lgt-010 (line 52).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-lgt-010"></a>`REQ-VEH-LGT-010` **Draft**
            Original obligation column: Requirement
            Derived from: —
            Sources / governing contracts: Owner-approved lighting availability proposal, 2026-10-28;
            `IfA006LightingAvailability`; [AUX-001](../../Specification/AuxiliaryContinuity.sysml).
            Planned verification: `T-SYS`, `T-FI`: inhibit normal and rear Full including startup; lose
            qualification after false; restore true with retained request and current brake state; exercise
            initially unqualified and supply/protection limits.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                LightControl shall inhibit all front and rear illumination when lighting availability is
                qualified unavailable, including brake indication and the startup fallback. In the live
                powered lighting actuation context, a known qualified unavailable restriction shall persist
                through unqualified, invalid, lost, or expired availability until a new qualified available
                indication arrives. On qualified availability returning, the current selected modes shall
                automatically apply subject to supply and protection, without a new rider request. Where no
                known restriction exists, unqualified availability alone shall retain the existing startup
                and fault behavior wherever power and protection permit.
            */
        }
    }
    satisfy lightingAvailabilityRestriction by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

    requirement <'REQ-VEH-FSC-012'> physicalLightingVisibility : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightControl.md#req-veh-fsc-012 (line 53).
            Original target: LE-LIGHT-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-fsc-012"></a>`REQ-VEH-FSC-012` **Draft**
            Original obligation column: Requirement
            Derived from: [SG-007](../../../../Safety/SG-001_Safety_Goals.md#sg-007)
            Sources / governing contracts: `OI-032`, `OI-038`, `OI-039`, `OI-041`, `OI-045`, `OI-056`,
            `WS-OI-007`, `WS-OI-010`, `WS-OI-012`;
            [WS-OI-016 acceptance gate](../../../DEC-001_Decisions_and_Open_Issues.md#dec-lgt-002).
            Planned verification: `I`, `A`, `T-SYS`, `T-FI`: exercise all physical modes, triggers, unknown
            states, communication loss, and protection-limited transitions.
        */
        subject owner:LightControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;
        require constraint {
            doc /*
                Physical front illumination and rear Off/Dim/Full output shall meet the qualified visibility
                and rear normal/brake-mode distinction envelope for selected and available LightControl
                modes wherever power and protection permit, including startup, unqualified braking
                information, and protection-limited transitions. Rear Full for unknown braking state retains
                its precautionary meaning; no extra rider indication is required.
            */
        }
    }
    satisfy physicalLightingVisibility by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl;

}
