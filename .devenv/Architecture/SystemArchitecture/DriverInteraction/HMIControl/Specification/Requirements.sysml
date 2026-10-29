package X2CitySpecification_HMIControl_Requirements {
    private import X2CityComponent_HmiControl::HMIControl;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-HMIC-001'> qualifiedHmiExchange : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-sys-hmic-001
            (line 51).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-hmic-001"></a>`REQ-SYS-HMIC-001` **Draft**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-HSI-002](../../../Specification/SystemHardwareSoftwareInterface.sysml);
            [F-015](../../../../FC-001_Functional_Concept.md#f-015).
            Planned verification / remaining gate: `I`, `T-SYS`: trace the electrical and information leaves
            through the selected display; verify loss, reset, invalidity and restart do not manufacture
            receipt or acknowledgement.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                `LE-HMI-CONTROL` shall provide the complete qualified VD18MT settings/report exchange by
                composing [HmiElectricalInterface](../HmiElectricalInterface/HmiElectricalInterface.md) and
                [HmiInformationProcessing](../HmiInformationProcessing/HmiInformationProcessing.md).
            */
        }
    }
    satisfy qualifiedHmiExchange by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-SYS-CMP-001'> qualifiedVehicleOperationRequest : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-sys-cmp-001
            (line 52).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-cmp-001"></a>`REQ-SYS-CMP-001` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-PWR-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-PWR-002](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-FLT-002](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-002](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [DEC-PWR-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-pwr-001);
            allocated to [REQ-SYS-CMPH-002](../HmiElectricalInterface/Specification/Requirements.sysml) and
            [REQ-SYS-PLT-004](../HmiInformationProcessing/Specification/Requirements.sysml); `IF-EPCS-006`.
            Planned verification / remaining gate: `A`, `T-SW`, `T-FI`, `T-SYS`: exercise qualified On/Off,
            unknown/unavailable/integrity-invalid/stale observations, UART loss/recovery independent of the
            power-state path, and source/context changes. Raw physical Inactive-to-Off interpretation
            remains a selected-unit qualification gate and is not a measured pin-5 fact.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                `LE-HMI-CONTROL` shall provide RidingControl with the current `VehicleOperationRequest`
                derived from the awake HMI power-lock observation, with request and qualification distinct.
                Only supported qualified On or Off may be represented; Unknown, unavailable,
                invalid-integrity or stale evidence shall remain unqualified and shall not represent Off.
                VD18MT UART availability or loss shall not alter this request.
            */
        }
    }
    satisfy qualifiedVehicleOperationRequest by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-001'> regenerationIndicationAbsence : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-001
            (line 60).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-001"></a>`REQ-VEH-HMI-001` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-HMI-001`, `DEC-HMI-006`; `0x01` MOS warning is status
            reporting, not a blanket regeneration-availability indication. `I`, `T-SYS`: exercise ordinary
            full/partial restrictions and clearance, and verify fault indication without regenerative
            demand. `WS-OI-008/009/010/019`.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                The HMI shall provide no dedicated reduced/unavailable-regeneration indication; underlying
                fault reporting shall remain effective.
            */
        }
    }
    satisfy regenerationIndicationAbsence by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-002'> usableBatteryChargeIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-002
            (line 61).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-hmi-002"></a>`REQ-VEH-HMI-002` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-HMI-002`, `DEC-SOC-001`; `I`, `A`, `T-SYS`: 27.5/45/62.5%
            actual → 25/50/75% usable before quantization. `WS-OI-005/008/009/013/017/018`; scale is 100 ×
            (actual SOC − 10)/70 and display capability/accuracy remain open.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                Normal battery indication, including any visible percentage, shall linearly represent usable
                charge from 0% at 10% actual SOC to 100% at 80%, hiding actual-SOC limits from normal charge
                presentation.
            */
        }
    }
    satisfy usableBatteryChargeIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-003'> batteryChargeIndicationClamping : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-003
            (line 62).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-hmi-003"></a>`REQ-VEH-HMI-003` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-HMI-002`, `DEC-REG-001`; `I`, `T-SYS`: 0/10/80/90% →
            empty/empty/full/full. `WS-OI-005/008/009/013/017/018`; display clamping does not determine
            charge acceptance.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                Battery indication shall clamp to empty/0% at/below 10% actual SOC and full/100% at/above
                80%.
            */
        }
    }
    satisfy batteryChargeIndicationClamping by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-004'> acceleratorFaultIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-004
            (line 63).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-004"></a>`REQ-VEH-HMI-004` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-FLT-003`; `I`, `T-SYS`, `T-FI`: defined invalid accelerator
            cases and valid-input exclusion. `OI-026`, `WS-OI-008/009/010`.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                A selected accelerator-input fault shall report VD18MT error-field `0x0A`, retained under
                [REQ-VEH-HMI-006](../../../RidingControl/Specification/SessionReportPolicy.sysml).
            */
        }
    }
    satisfy acceleratorFaultIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-005'> brakeFaultIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-005
            (line 64).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-005"></a>`REQ-VEH-HMI-005` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-FLT-003`, `DEC-REF-002`; `I`, `T-SYS`, `T-FI`: detectable
            brake-invalidity and valid finite states. `WS-OI-008/009/010/012`; no handle identity or
            universal alias claim.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                A selected shared-loop brake-input fault shall report VD18MT error-field `0x0D`, retained
                under [REQ-VEH-HMI-006](../../../RidingControl/Specification/SessionReportPolicy.sysml).
            */
        }
    }
    satisfy brakeFaultIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-008'> speedFaultIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-008
            (line 65).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-008"></a>`REQ-VEH-HMI-008` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-FLT-004`, `DEC-FLT-003`; `I`, `T-SYS`, `T-FI`: defined
            unreliable-speed cases, excluding wheel-setting display mismatch. `WS-OI-001/008/009/010/015`.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                A selected vehicle-speed-input fault shall report VD18MT error-field `0x03`, retained under
                [REQ-VEH-HMI-006](../../../RidingControl/Specification/SessionReportPolicy.sysml).
            */
        }
    }
    satisfy speedFaultIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-011'> batteryFaultIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-011
            (line 66).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-hmi-011"></a>`REQ-VEH-HMI-011` **Draft successor — 2026-10-26**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-FLT-006`, `DEC-TMP-001`, `DEC-FLT-007`; `I`, `T-SYS`,
            `T-FI`: BMS battery/thermal fault, SOC-only loss/init without a fault report, and independently
            recognized temperature fault/overlap cases. `WS-OI-008/009/010/018`.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                Selected actual battery faults shall report `0x07`, including BMS-reported thermal faults.
                SOC field loss or failed SOC initialization alone shall not generate `0x07`. Independently
                recognized temperature-limit faults use `0x06` under HMI-013.
            */
        }
    }
    satisfy batteryFaultIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-012'> unavailableSocDisplayFallback : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-012
            (line 67).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-012"></a>`REQ-VEH-HMI-012` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-HMI-005`, `DEC-HMI-002`, `DEC-FLT-005`; `I`, `A`, `T-SYS`,
            `T-FI`: recover valid mapping without restart while preserving independently retained fault
            effects. `WS-OI-005/007/008/009/010/018`.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                Unavailable trustworthy SOC, including initial startup, shall display empty/0% without using
                that fallback as control SOC, qualification evidence or a charge-threshold decision.
            */
        }
    }
    satisfy unavailableSocDisplayFallback by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-013'> temperatureFaultIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-013
            (line 68).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-hmi-013"></a>`REQ-VEH-HMI-013` **Draft successor — 2026-10-26**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-TMP-001`, `DEC-HMI-006`; `I`, `T-SYS`, `T-FI`: independently
            recognized non-battery hot/cold limits, all demand states, startup and riding; BMS-reported
            battery thermal faults use HMI-011. `OI-026`, `WS-OI-008/009/019`.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                Independently recognized upper/lower temperature-limit faults outside the supplied-BMS
                battery fault path shall report `0x06` whenever selected/communicable, independently of
                current demand or observable torque reaction. A temperature fault reported by the BMS
                remains an actual battery fault reported as `0x07` under HMI-011.
            */
        }
    }
    satisfy temperatureFaultIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-015'> selectedFaultCommunication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-015
            (line 69).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-015"></a>`REQ-VEH-HMI-015` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-HMI-006`; `I`, `T-SYS`, `T-FI`: each fault with and without
            demand. `WS-OI-008/009/010/019`; no simultaneous competing-fault display is implied.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                A selected recognized fault shall be indicated whenever VD18MT communication is available,
                independently of affected functions or functional reaction.
            */
        }
    }
    satisfy selectedFaultCommunication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-016'> unassignedFaultCodeIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-016
            (line 70).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-016"></a>`REQ-VEH-HMI-016` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-FLT-008`; `I`, `T-SYS`, `T-FI`: generic versus assigned
            categories. `WS-OI-008/009/010/019`; invalid temperature data alone does not justify `0x06`.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                A selected recognized fault without a specifically assigned project code shall report
                `0x05`.
            */
        }
    }
    satisfy unassignedFaultCodeIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-017'> blockedMotorFaultIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-017
            (line 71).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-017"></a>`REQ-VEH-HMI-017` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-FLT-008`; `I`, `T-SYS`, `T-FI`: derived blockage cases and
            restart assessment. `WS-OI-008/009/010`; standstill, brake actuation or absent motion alone is
            not blockage.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                A selected recognized blocked-motor fault shall report `0x04`.
            */
        }
    }
    satisfy blockedMotorFaultIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

    requirement <'REQ-VEH-HMI-020'> batteryCurrentMagnitudeIndication : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-020
            (line 73).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-veh-hmi-020"></a>`REQ-VEH-HMI-020` **Approved body; Draft target**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-HMI-008`; `I`, `T-SYS`: +12.4 A and −12.4 A encode 62, 0
            encodes 0, at/above 51 A encodes 255; invalid information encodes 0. `WS-OI-008/009`; rounding,
            accuracy and period remain open.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                The vehicle shall continuously provide the magnitude of battery current to the VD18MT,
                representing both discharge and regenerative charging as positive values clamped to 51 A;
                unavailable or invalid battery-current information shall be reported as 0 A.
            */
        }
    }
    satisfy batteryCurrentMagnitudeIndication by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;

}
