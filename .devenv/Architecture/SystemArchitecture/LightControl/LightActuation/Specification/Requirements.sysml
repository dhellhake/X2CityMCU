package X2CitySpecification_LightActuation_Requirements {
    private import X2CityComponent_LightActuation::LightActuation;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-LGTHW-001'> physicalLampModeActuation : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightActuation/LightActuation.md#req-sys-lgthw-001
            (line 8).
            Original target: LE-LAMP-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgthw-001"></a>`REQ-SYS-LGTHW-001` **Draft**
            Original obligation column: Allocation
            Derived from: [LGT-001](../../Specification/LightingBehavior.sysml),
            [LGT-003](../../Specification/LightingBehavior.sysml),
            [LGT-010](../../Specification/LightingBehavior.sysml),
            [FSC-012](../../Specification/LightingBehavior.sysml)
            Planned verification / acceptance: `T-HW`, `T-SYS`: exercise every mode and distinguish physical
            Dim from Full.
        */
        subject owner:LightActuation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;
        require constraint {
            doc /*
                `LE-LAMP-HW` shall realize selected and available front On/Off and rear Off/Dim/Full logical
                modes as the corresponding physical illumination states, including the required rear
                Dim/Full distinction, subject to qualified lighting availability, supply and protection.
            */
        }
    }
    satisfy physicalLampModeActuation by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;

    requirement <'REQ-SYS-LGTHW-002'> startupLampFallback : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightActuation/LightActuation.md#req-sys-lgthw-002
            (line 9).
            Original target: LE-LAMP-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgthw-002"></a>`REQ-SYS-LGTHW-002` **Draft**
            Original obligation column: Allocation
            Derived from: [LGT-002](../../Specification/LightingBehavior.sysml),
            [LGT-005](../../Specification/LightingBehavior.sysml),
            [LGT-009](../../Specification/LightingBehavior.sysml),
            [FSC-012](../../Specification/LightingBehavior.sysml)
            Planned verification / acceptance: `T-HW`, `T-SYS`: start and reset before software execution;
            verify front Off and rear Full.
        */
        subject owner:LightActuation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;
        require constraint {
            doc /*
                While powered, where no current or retained qualified unavailable restriction exists and
                supply and protection permit, before software can establish usable qualified mode selection
                after power-on or reset, `LE-LAMP-HW` shall provide front Off and rear Full.
            */
        }
    }
    satisfy startupLampFallback by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;

    requirement <'REQ-SYS-LGTHW-003'> rearLampInterfaceCompatibility : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightActuation/LightActuation.md#req-sys-lgthw-003
            (line 10).
            Original target: LE-LAMP-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgthw-003"></a>`REQ-SYS-LGTHW-003` **Draft**
            Original obligation column: Allocation
            Derived from: [LGT-003](../../Specification/LightingBehavior.sysml),
            [FSC-012](../../Specification/LightingBehavior.sysml); `DEC-LGT-001`, `CON-009`.
            Planned verification / acceptance: `I`, `T-HW`: inspect and exercise the released interface
            through each rear mode.
        */
        subject owner:LightActuation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;
        require constraint {
            doc /*
                `LE-LAMP-HW` shall retain compatibility with the released VCC/GND two-terminal rear-lamp
                interface.
            */
        }
    }
    satisfy rearLampInterfaceCompatibility by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;

    requirement <'REQ-SYS-LGTHW-004'> lampContinuityDuringFaults : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightActuation/LightActuation.md#req-sys-lgthw-004
            (line 11).
            Original target: LE-LAMP-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgthw-004"></a>`REQ-SYS-LGTHW-004` **Draft**
            Original obligation column: Allocation
            Derived from: [AUX-001](../../../Specification/AuxiliaryContinuity.sysml),
            [LGT-010](../../Specification/LightingBehavior.sysml),
            [FSC-012](../../Specification/LightingBehavior.sysml)
            Planned verification / acceptance: `T-HW`, `T-SYS`: exercise powered faults, protection
            withdrawal, and restoration without claiming protection bypass.
        */
        subject owner:LightActuation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;
        require constraint {
            doc /*
                During powered faults, `LE-LAMP-HW` shall maintain requested illumination wherever lighting
                availability, supply, electrical protection, and affected lamp function permit.
            */
        }
    }
    satisfy lampContinuityDuringFaults by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;

    requirement <'REQ-SYS-LGTHW-005'> lightingSupplyAvailabilityRestriction : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/LightControl/LightActuation/LightActuation.md#req-sys-lgthw-005
            (line 12).
            Original target: LE-LAMP-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-lgthw-005"></a>`REQ-SYS-LGTHW-005` **Draft**
            Original obligation column: Allocation
            Derived from: [LGT-010](../../Specification/LightingBehavior.sysml),
            [AUX-001](../../../Specification/AuxiliaryContinuity.sysml)
            Planned verification / acceptance: `T-HW`, `T-SYS`: verify gate during startup and all modes,
            qualification loss after false, and restoration with supply and protection limits.
        */
        subject owner:LightActuation =
            X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;
        require constraint {
            doc /*
                `LE-LAMP-HW`, through its contained LightPower supply responsibility, shall withdraw
                lighting supply or actuation when lighting availability is qualified unavailable, overriding
                front and rear illumination including rear Full before usable software modes exist. In the
                live powered actuation context it shall retain that restriction through loss of
                qualification until a new qualified available indication, then permit the current modes
                subject to supply and protection.
            */
        }
    }
    satisfy lightingSupplyAvailabilityRestriction by X2CitySystemArchitecture::x2CityVehicle.epcs.lightControl.lightActuation;

}
