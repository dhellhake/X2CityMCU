package X2CitySpecification_ComputeHardware_Requirements {
    private import X2CityComponent_ComputeHardware::ComputeHardware;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-CMPH-001'> controllerPowerLockWakeInput : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Compute/ComputeHardware/ComputeHardware.md#req-sys-cmph-001
            (line 8).
            Original target: LE-COMPUTE-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-cmph-001"></a>`REQ-SYS-CMPH-001` **Draft**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-PWR-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-STA-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-002](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-HMIE-002](../../../DriverInteraction/HMIControl/HmiElectricalInterface/Specification/Requirements.sysml),
            [DEC-PWR-001](../../../../DEC-001_Decisions_and_Open_Issues.md#dec-pwr-001);
            `IF-EPCS-006`, `HW-I-001`; selected
            [HC-CONTROLLER](../../../../ARCH-002_Hardware_Architecture.md#hc-controller);
            [STM32H723 reference manual](https://www.st.com/resource/en/reference_manual/dm00603761.pdf)
            §§6.7.4–6.7.7, 8.5.7 and [datasheet](https://www.st.com/resource/en/datasheet/stm32h723vg.pdf).
            Planned verification / remaining gate: `T-HW`, `T-FI`, `T-SYS`: wake acceptance at the selected
            controller input from the selected deep-sleep state using the conditioned display signal.
            Derive/qualify mode, eligible wake input, voltage thresholds, loading, leakage, protection,
            clock/context restoration, wake acceptance and finite timing.
        */
        subject owner:ComputeHardware =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.computeHardware;
        require constraint {
            doc /*
                `LE-COMPUTE-HW` shall provide a compatible input for the conditioned VD18MT on/wake signal
                and enable the selected STM32H723VGT6 to wake from its selected deep-sleep mode without
                requiring UART traffic or application execution.
            */
        }
    }
    satisfy controllerPowerLockWakeInput by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.computeHardware;

    requirement <'REQ-SYS-CMPH-003'> controllerElectricalPowerInput : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Compute/ComputeHardware/ComputeHardware.md#req-sys-cmph-003
            (line 9).
            Original target: LE-COMPUTE-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-cmph-003"></a>`REQ-SYS-CMPH-003` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from / governing contract: [REQ-SYS-CMP-002](../../Specification/Requirements.sysml),
            `IfA010VehicleElectricalPower`, selected
            [HC-CONTROLLER](../../../../ARCH-002_Hardware_Architecture.md#hc-controller).
            Planned verification / remaining gate: `I`, `A`, `T-HW`, `T-FI`: inspect and characterize the
            selected controller supply connection, compatibility and powered/unpowered states. Rail
            selection, limits, protection, reset behavior and acceptance remain open.
        */
        subject owner:ComputeHardware =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.computeHardware;
        require constraint {
            doc /*
                `LE-COMPUTE-HW` shall accept electrical power supplied from the EPCS `EnergyPath` through
                Compute's `vehicleElectricalPowerIn` for operation of the selected controller.
            */
        }
    }
    satisfy controllerElectricalPowerInput by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.computeHardware;

    requirement <'REQ-SYS-CMPH-004'> qualifiedControllerSleepHandoff : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Compute/ComputeHardware/ComputeHardware.md#req-sys-cmph-004
            (line 10).
            Original target: LE-COMPUTE-HW.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-cmph-004"></a>`REQ-SYS-CMPH-004` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-PLT-005](../../Platform/Specification/Requirements.sysml),
            [REQ-SYS-PWR-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-STA-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-002](../../../Specification/SystemHardwareSoftwareInterface.sysml);
            `ComputeSleepRequest`, `HW-I-001`.
            Planned verification / remaining gate: `T-HW`, `T-FI`, `T-SYS`: verify true, false, absent,
            invalid, expired, context-mismatched, superseded and cancelled handoffs against actual sleep
            entry; verify rejection/clearing of stale pending handoff and conditioned wake acceptance. Mode,
            wake input, entry mechanism, electrical limits, lifetime value and timing remain derivation and
            qualification gates.
        */
        subject owner:ComputeHardware =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.computeHardware;
        require constraint {
            doc /*
                `LE-COMPUTE-HW` shall initiate its selected sleep behavior only for a current qualified
                Platform handoff preserving the latest Session `ComputeSleepRequest` qualification, source
                context and unexpired `expiry`. A false, absent, invalid, expired, context-mismatched,
                superseded or cancelled handoff shall not initiate sleep. The conditioned controller wake
                input shall remain available in the selected sleep state.
            */
        }
    }
    satisfy qualifiedControllerSleepHandoff by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.computeHardware;

}
