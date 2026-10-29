package X2CitySpecification_HmiInformationProcessing_Requirements {
    private import X2CityComponent_HmiInformationProcessing::HmiInformationProcessing;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-CTL-003'> outgoingHmiReportComposition : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HmiInformationProcessing/HmiInformationProcessing.md#req-sys-ctl-003
            (line 10).
            Original target: LE-HMI.
            Original type: Abstract Software Requirement.
            Status: Draft, Approved.
            ID: <a id="req-sys-ctl-003"></a>`REQ-SYS-CTL-003` **Approved body; Draft target**
            Original obligation column: Requirement
            Derived from / governing contract: [REQ-VEH-HMI-001](../../Specification/Requirements.sysml),
            [REQ-VEH-HMI-002](../../Specification/Requirements.sysml),
            [REQ-VEH-HMI-012](../../Specification/Requirements.sysml),
            [REQ-VEH-HMI-020](../../Specification/Requirements.sysml).
            Planned verification / remaining gate: `I`, `A`, `T-SYS`, `T-SW`: inspect protocol fields
            against the independent interface with boundary, invalid-data and retained-report cases.
            `IF-A-002/006`, `WS-OI-008/009/010`; no unsupported indication is added.
        */
        subject owner:HmiInformationProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiInformationProcessing;
        require constraint {
            doc /*
                For each outgoing VD18MT information update, the communication policy shall form protocol
                fields from the selected project report, usable-charge indication and unsigned
                battery-current magnitude/fallback according to their system parents, keeping internal input
                validity separate from transmitted fallback values.
            */
        }
    }
    satisfy outgoingHmiReportComposition by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiInformationProcessing;

    requirement <'REQ-SYS-HMIP-001'> hmiRequestQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HmiInformationProcessing/HmiInformationProcessing.md#req-sys-hmip-001
            (line 11).
            Original target: LE-HMI.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-hmip-001"></a>`REQ-SYS-HMIP-001` **Draft**
            Original obligation column: Requirement
            Derived from / governing contract: System parents:
            [REQ-SYS-HSI-002](../../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-VEH-LGT-001](../../../../LightControl/Specification/LightingBehavior.sysml).
            [REQ-SYS-LVL-001](../../../../RidingControl/RidingPolicy/Specification/SettingsAndControlPolicy.sysml)
            is a consuming cross-contract.
            Planned verification / remaining gate: `T-SW`, `T-SYS`, `T-FI`: distinguish valid request,
            initialization, loss, reset and invalid transport; no invalid record creates a setting or light
            command.
        */
        subject owner:HmiInformationProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiInformationProcessing;
        require constraint {
            doc /*
                `LE-HMI` shall publish qualified `ridingSettingsOut` and `runningLightStateOut` from a
                current-context VD18MT request, and shall publish invalidity for an absent, invalid, stale,
                or mismatched request.
            */
        }
    }
    satisfy hmiRequestQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiInformationProcessing;

    requirement <'REQ-SYS-HMIP-002'> qualifiedVehicleSpeedReporting : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HmiInformationProcessing/HmiInformationProcessing.md#req-sys-hmip-002
            (line 12).
            Original target: LE-HMI.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-hmip-002"></a>`REQ-SYS-HMIP-002` **Draft**
            Original obligation column: Requirement
            Derived from / governing contract: System parents:
            [REQ-SYS-HSI-002](../../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-SPD-009](../../../../Specification/RiderControl.sysml), `CON-012`,
            [DEC-SPD-002](../../../../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-002).
            [REQ-SYS-CTL-003](Requirements.sysml) is a sibling governing report-encoding contract.
            Planned verification / remaining gate: `T-SW`, `T-SYS`, `T-FI`: vary motion value and
            qualification. Selected-display speed representation, unavailable-motion treatment, precision
            and report period remain open; this row selects no speed fallback, accuracy, status bit or
            timing value.
        */
        subject owner:HmiInformationProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiInformationProcessing;
        require constraint {
            doc /*
                `LE-HMI` shall form the VD18MT speed report only from current qualified vehicle-motion
                speed, preserving the motion source's distinction from the fixed nominal 16-inch
                control-speed basis.
            */
        }
    }
    satisfy qualifiedVehicleSpeedReporting by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiInformationProcessing;

    requirement <'REQ-SYS-PLT-004'> powerLockOperationRequest : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HmiInformationProcessing/HmiInformationProcessing.md#req-sys-plt-004
            (line 13).
            Original target: LE-HMI.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-plt-004"></a>`REQ-SYS-PLT-004` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from / governing contract: [REQ-SYS-CMP-001](../../Specification/Requirements.sysml),
            [REQ-SYS-PWR-001](../../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-PWR-002](../../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-002](../../../../Specification/SystemHardwareSoftwareInterface.sysml); supporting
            input [REQ-SYS-CMPH-002](../../HmiElectricalInterface/Specification/Requirements.sysml);
            `HmiPowerLockObservation`, `VehicleOperationRequest`.
            Planned verification / remaining gate: `T-SW`, `T-FI`, `T-SYS`: verify On/Off mapping,
            preservation of Unknown/unavailable and invalid integrity, stale/source-context changes, and
            UART loss/recovery independence. Treat physical `Inactive` as qualified Off only after
            selected-unit compatibility and deassertion qualification; that gate remains open.
        */
        subject owner:HmiInformationProcessing =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiInformationProcessing;
        require constraint {
            doc /*
                `LE-HMI` shall derive and publish `VehicleOperationRequest` with request and qualification
                distinct from the current `HmiPowerLockObservation`: only supported qualified `Active` and
                `Inactive` may represent On and Off respectively; `Unknown`, unavailable, invalid-integrity
                or stale observations shall not represent Off. The same qualified composite shall reach
                RidingControl independently of UART availability or protocol state.
            */
        }
    }
    satisfy powerLockOperationRequest by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiInformationProcessing;

}
