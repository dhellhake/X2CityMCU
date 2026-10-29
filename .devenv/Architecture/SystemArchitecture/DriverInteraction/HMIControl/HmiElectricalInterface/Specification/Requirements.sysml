package X2CitySpecification_HmiElectricalInterface_Requirements {
    private import X2CityComponent_HmiElectricalInterface::HmiElectricalInterface;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-HMIE-001'> hmiElectricalInterface : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HmiElectricalInterface/HmiElectricalInterface.md#req-sys-hmie-001
            (line 10).
            Original target: LE-HMI-ELECTRICAL.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-hmie-001"></a>`REQ-SYS-HMIE-001` **Draft**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-HSI-002](../../../../Specification/SystemHardwareSoftwareInterface.sysml); `CON-012`,
            `IF-EPCS-006`; [VD18MT reference](../../HMIControl.md#vd18mt-device-reference-vd18mt-tongsheng-uart-interface).
            Planned verification / remaining gate: `I`, `T-HW`, `T-FI`: correlate selected-unit
            connector/pin identity and both UART directions; characterize levels, loading, continuity,
            mating, sealing and unpowered behavior.
        */
        subject owner:HmiElectricalInterface =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiElectricalInterface;
        require constraint {
            doc /*
                `LE-HMI-ELECTRICAL` shall provide the VD18MT display-supply and UART receive/transmit
                boundary compatible with the confirmed externally supplied five-pin interface, including its
                applicable 5 V-class UART signals.
            */
        }
    }
    satisfy hmiElectricalInterface by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiElectricalInterface;

    requirement <'REQ-SYS-HMIE-002'> hmiPowerLockWakeConditioning : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HmiElectricalInterface/HmiElectricalInterface.md#req-sys-hmie-002
            (line 11).
            Original target: LE-HMI-ELECTRICAL.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-hmie-002"></a>`REQ-SYS-HMIE-002` **Draft**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-PWR-001](../../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-002](../../../../Specification/SystemHardwareSoftwareInterface.sysml); governing
            sibling interface
            [REQ-SYS-CMPH-001](../../../../Compute/ComputeHardware/Specification/Requirements.sysml);
            `CON-012`, `IF-EPCS-006`, `HW-I-001`;
            [VD18MT reference](../../HMIControl.md#vd18mt-device-reference-vd18mt-tongsheng-uart-interface).
            Planned verification / remaining gate: `T-HW`, `T-FI`, `T-SYS`: exercise the on action from
            selected deep sleep with UART/application unavailable; characterize asserted/deasserted path and
            verify wake acceptance. Qualify deassertion behavior on the selected unit before accepting it as
            Off. Derive sleep mode, eligible wake input, thresholds, loading, protection, leakage, unpowered
            behavior and finite wake/restore bounds. When Standby is considered, review eligible wake-input
            sharing with existing pin assignments. Verify system integration retains the common startup and
            Ready guards [REQ-SYS-STA-001](../../../../Specification/PowerStartupAndFaults.sysml)–007.
        */
        subject owner:HmiElectricalInterface =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiElectricalInterface;
        require constraint {
            doc /*
                `LE-HMI-ELECTRICAL` shall condition the VD18MT pin-5 switched voltage and deliver the
                resulting asserted/deasserted signal to `LE-COMPUTE-HW` at a level compatible with the
                selected controller input, enabling wake from the selected deep-sleep mode on the display's
                on action without UART traffic, decoded settings, or application execution. Deassertion
                supports Off recognition only after selected-unit compatibility and qualification; it shall
                not be presumed from raw pin behavior.
            */
        }
    }
    satisfy hmiPowerLockWakeConditioning by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiElectricalInterface;

    requirement <'REQ-SYS-HMIE-003'> hmiEndpointAvailabilityEvidence : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HmiElectricalInterface/HmiElectricalInterface.md#req-sys-hmie-003
            (line 12).
            Original target: LE-HMI-ELECTRICAL.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-hmie-003"></a>`REQ-SYS-HMIE-003` **Draft**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-HSI-002](../../../../Specification/SystemHardwareSoftwareInterface.sysml).
            Planned verification / remaining gate: `T-FI`, `T-SYS`: disconnect, brown out, reset and
            reconnect the endpoint; verify published invalidity and that settings receipt remains absent
            until a qualified current-context request.
        */
        subject owner:HmiElectricalInterface =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiElectricalInterface;
        require constraint {
            doc /*
                `LE-HMI-ELECTRICAL` shall expose endpoint electrical availability or invalidity to
                HmiInformationProcessing without converting availability, initialization, or link activity
                into a qualified received setting.
            */
        }
    }
    satisfy hmiEndpointAvailabilityEvidence by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiElectricalInterface;

    requirement <'REQ-SYS-CMPH-002'> hmiPowerLockObservation : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HmiElectricalInterface/HmiElectricalInterface.md#req-sys-cmph-002
            (line 13).
            Original target: LE-HMI-ELECTRICAL.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-cmph-002"></a>`REQ-SYS-CMPH-002` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from / governing contract: [REQ-SYS-CMP-001](../../Specification/Requirements.sysml),
            [REQ-SYS-PWR-001](../../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-002](../../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-HMIE-002](Requirements.sysml); `HmiPowerLockObservation`, `HW-I-001`.
            Planned verification / remaining gate: `I`, `T-HW`, `T-FI`, `T-SYS`: verify state and integrity
            while awake for asserted, deasserted, absent, invalid and context-changed input; establish
            selected-unit compatibility and qualification before Inactive can support Off. Electrical limits
            and acceptance criteria remain open.
        */
        subject owner:HmiElectricalInterface =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiElectricalInterface;
        require constraint {
            doc /*
                While awake, `LE-HMI-ELECTRICAL` shall publish `HmiPowerLockObservation` from the
                conditioned VD18MT power-lock signal, with `Active`, `Inactive` or `Unknown` state and
                separate integrity qualification. Unavailable or unqualified input shall be represented as
                `Unknown`; physical Inactive-to-Off interpretation remains subject to selected-unit
                compatibility and qualification.
            */
        }
    }
    satisfy hmiPowerLockObservation by X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl.hmiElectricalInterface;

}
