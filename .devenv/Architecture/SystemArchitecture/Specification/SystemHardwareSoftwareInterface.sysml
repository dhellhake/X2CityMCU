package X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-HSI-001'> qualifiedInputObservationBoundary : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-001
            (line 9).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-sys-hsi-001"></a>`REQ-SYS-HSI-001` **Approved body; Draft successor allocation**
            Original obligation column: Approved requirement
            Target / allocation direction: **Target: [LE-EPCS](../X2CityMCU.md#le-epcs).** Its endpoint
            contributors are [LE-ACCELERATOR](../X2CityMCU.md#le-accelerator);
            [LE-BRAKE-SIGNAL](../X2CityMCU.md#le-brake-signal) and
            [LE-BRAKE-STATE](../X2CityMCU.md#le-brake-state);
            [LE-TRACTION-CONTROL](../X2CityMCU.md#le-traction-control) for nonbattery-temperature and
            supply/rail physical evidence and qualification;
            [LE-MOTOR-SIGNAL](../X2CityMCU.md#le-motor-signal) for direct physical Hall/current/bridge
            evidence; and [LE-MOTOR-POSITION-PROC](../X2CityMCU.md#le-motor-position-proc) for semantic
            motor evidence/final position. The physical board may realize both TractionControl and
            MotorSignalMeasurement, while their logical ownership stays separate. Shared
            physical/acquisition realization remains subject to hardware and software qualification;
            implementation allocation is pending.
            Derived from / interfaces: [INT-001](InterfaceQualification.sysml),
            [INT-002](InterfaceQualification.sysml); IF-A-001, HW-I-001/003,
            Planned verification and open acceptance: `I`, `A`, `T-FI`, `T-SYS`: inject
            acquisition/transport loss, stale retained values and reset during each configuration; verify
            consumers reject unqualified data. Derive electrical ranges, sensor method, source age, skew,
            fault envelope and response bounds.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The input boundary shall provide the acquiring software with each required rider, motion and
                temperature observation together with source/configuration identity, current reset context,
                semantic state and independently represented qualification and freshness. Initial, absent,
                invalid, stale, implausible and context-mismatched observations shall not be represented as
                a qualified semantic state.
            */
        }
    }
    satisfy qualifiedInputObservationBoundary by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-HSI-002'> hmiEndpointCommunicationQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-002
            (line 10).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft, Approved.
            ID: <a id="req-sys-hsi-002"></a>`REQ-SYS-HSI-002` **Approved body; Draft target**
            Original obligation column: Approved requirement
            Target / allocation direction: **Target: [LE-EPCS](../X2CityMCU.md#le-epcs).** Contributions are
            made by [LE-HMI-CONTROL](../X2CityMCU.md#le-hmi-control) for qualified settings/report exchange,
            display-supply/UART compatibility, and the current qualified `VehicleOperationRequest`;
            [LE-HMI-ELECTRICAL](../X2CityMCU.md#le-hmi-electrical) conditions the asserted pin-5 on/wake
            signal for a compatible controller input and publishes the awake `HmiPowerLockObservation` with
            integrity; [LE-HMI](../X2CityMCU.md#le-hmi) derives Request plus Qualification independently of
            UART transport or protocol and publishes it to RidingControl.
            [LE-COMPUTE-HW](../X2CityMCU.md#le-compute-hw) provides the direct wake input;
            [LE-PLATFORM](../X2CityMCU.md#le-platform) initializes runtime clocks/peripherals/timebase after
            wake and validates and executes the current qualified Session sleep grant by checking
            qualification, source context, lifetime and cancellation. Platform does not consume or recheck
            HMI or traction eligibility evidence. RidingControl alone owns sleep eligibility and operation
            lifecycle, Ready and authority decisions under
            [REQ-SYS-CTL-005](../RidingControl/RidingPolicy/Specification/SettingsAndControlPolicy.sysml)–007.
            Draft requirement elaborations are
            [REQ-SYS-CMP-001](../DriverInteraction/HMIControl/Specification/Requirements.sysml),
            [REQ-SYS-CMPH-002](../DriverInteraction/HMIControl/HmiElectricalInterface/Specification/Requirements.sysml),
            [REQ-SYS-PLT-003](../Compute/Platform/Specification/Requirements.sysml),
            [REQ-SYS-PLT-005](../Compute/Platform/Specification/Requirements.sysml) and
            [REQ-SYS-PLT-004](../DriverInteraction/HMIControl/HmiInformationProcessing/Specification/Requirements.sysml).
            Wake does not grant drive permission; UART loss alone does not create Off.
            Derived from / interfaces:
            [REQ-SYS-LVL-001](../RidingControl/RidingPolicy/Specification/SettingsAndControlPolicy.sysml),
            [REQ-VEH-HMI-015](../DriverInteraction/HMIControl/Specification/Requirements.sysml);
            IF-A-002/006/010, HW-I-001,
            [VD18MT reference](../DriverInteraction/HMIControl/HMIControl.md#vd18mt-device-reference-vd18mt-tongsheng-uart-interface),
            [implementation evidence](../DriverInteraction/HMIControl/HMIControl.md),
            [STM32H723 reference manual](https://www.st.com/resource/en/reference_manual/dm00603761.pdf)
            §§6.7.4–6.7.7, 8.5.7, [datasheet](https://www.st.com/resource/en/datasheet/stm32h723vg.pdf).
            Planned verification and open acceptance: `I`, `A`, `T-FI`, `T-SYS`: correlate selected-unit
            electrical/transport behavior, UART loss independent of the power-state signal, reset and
            disconnect/reconnect cases with valid settings/report handling. Characterize actual levels,
            loading, power-off/backfeed, pin-5 asserted/deasserted behavior and qualification, timing,
            selected-unit behavior and display presentation; qualify the selected sleep mode, eligible wake
            input, powered sleep-state path, wake/runtime initialization, qualified sleep/cancellation
            handoff and full startup guard. When Standby is considered, review eligible wake-input sharing
            with existing pin assignments. The development implementation is evidence only.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The vehicle-side VD18MT endpoint shall preserve the confirmed five-pin, 5 V-class UART
                interface as an externally supplied endpoint and shall exchange only current-context
                qualified settings and outgoing report information. Loss, restart or unqualified receipt
                shall not create a received setting, drive authorization, or a claim that an outgoing report
                was received by the display.
            */
        }
    }
    satisfy hmiEndpointCommunicationQualification by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-HSI-003'> bmsEndpointObservationQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-003
            (line 11).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-hsi-003"></a>`REQ-SYS-HSI-003` **Draft successor; historical approval
            retained**
            Original obligation column: Approved requirement
            Target / allocation direction: [LE-EPCS](../X2CityMCU.md#le-epcs); Draft successor binding.
            [LE-BATTERY-SUPERVISION](../X2CityMCU.md#le-battery-supervision) contributes BMS observation
            interpretation and qualification; EPCS retains the protected physical vehicle/BMS UART endpoint.
            The revised body is a Draft successor; its historical approval provenance is retained.
            Derived from / interfaces:
            [REQ-SYS-BMS-003](../BatteryControl/Specification/BmsIntegration.sysml),
            [REQ-SYS-BMS-004](BatteryControl.sysml); IF-A-003/009, HW-I-006–008,
            [BAT-001](../BatteryControl/BatterySupervision/BatterySupervision.md#uart-information-contract).
            Planned verification and open acceptance: `I`, `A`, `T-FI`, `T-SYS`: exercise vehicle mating,
            endpoint contention, BMS sleep/wake and stale/invalid replies. Establish actual board/firmware,
            command support, references/logic levels, protection, unpowered behavior, freshness, scaling and
            configuration acceptance before integration.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                In the fitted-pack vehicle configuration, the selected BMS UART boundary shall expose at
                most one active protected vehicle endpoint and shall deliver BMS observations with producer,
                configuration, current vehicle-controller context, semantic interpretation, validity and
                freshness separate from packet receipt. A BMS wake, returned packet or status bit shall not
                by itself restore riding authority or retained vehicle operating state.
            */
        }
    }
    satisfy bmsEndpointObservationQualification by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-HSI-008'> maintainerBoundaryInspection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-008
            (line 15).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-hsi-008"></a>`REQ-SYS-HSI-008` **Draft successor — debugger inspection**
            Original obligation column: Approved requirement
            Target / allocation direction: [LE-EPCS](../../REQ-001_Requirements.md#le-epcs);
            allocated to producer-owned diagnostic state and the debugger/tooling access realization.
            Derived from / interfaces: [REQ-SYS-SVC-001](ServiceAndDurability.sysml); HW-I-005/011/013.
            Planned verification and open acceptance: `I`, `A`, `T-FI`, `T-SYS`: inspect stale/mixed-context
            and unavailable producer state, access with each physical vehicle configuration, and return to
            riding. Derive debugger access, isolation/tooling and any permitted write authority separately.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The vehicle shall make current producer-owned identity, configuration, qualification,
                reset-context, inhibition and actual-output/status information available to a competent
                maintainer for debugger inspection. Inspection shall not grant riding authority, energize an
                endpoint, clear a latch or enable BMS configuration writes.
            */
        }
    }
    satisfy maintainerBoundaryInspection by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-HSI-009'> tractionPhysicalSoftwareBoundary : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-009
            (line 16).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-hsi-009"></a>`REQ-SYS-HSI-009` **Draft**
            Original obligation column: Approved requirement
            Target / allocation direction: **Target: [LE-EPCS](../X2CityMCU.md#le-epcs).** Its contributing
            logical responsibilities are [LE-TRACTION-HW](../X2CityMCU.md#le-traction-hw) for the physical
            boundary, [LE-MOTOR-SIGNAL](../X2CityMCU.md#le-motor-signal) for Hall/current/bridge measurement
            evidence, and [LE-MOTOR-POSITION-PROC](../X2CityMCU.md#le-motor-position-proc) for semantic
            Hall/current conversion, final position and observer-voltage qualification. Physical realization
            includes HC-TRACTION-POWER/HC-CONTROLLER/HC-INPUT-FE; software realization remains pending.
            Derived from / interfaces: REQ-SYS-HSI-001, REQ-SYS-HSI-004, REQ-SYS-HSI-007; HW-I-003;
            [allocated traction HSI](../Traction/TractionControl/TractionHardware/TractionHardware.md#drv8300drge-evm--weact-stm32h723vgt6-traction-hsi),
            software realization remains pending under DEC-ARCH-004.
            Planned verification and open acceptance: `I`, `A`, `T-FI`, `T-SYS`: continuity and unpowered
            states, reset/permit/BKIN behavior, ADC/DMA/timer loss, actual edge/acquisition-time and
            epoch-identity preservation through direct delivery, epoch skew/late samples, Hall/current
            polarity, generated-energy and physical-output observation. Numerical limits, bounded fast
            invocation/WCET, hardware coverage and vehicle acceptance remain gates.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The vehicle traction physical/software boundary shall convey complementary PWM, independent
                gate-inhibit state, Hall state/edge time, phase-current and local DC-link observations as
                one identified configuration. It shall preserve each acquisition epoch identity and actual
                Hall-edge and acquisition/measurement times in the common host-boot monotonic microsecond
                domain, with reset generation, aperture/skew and range/window evidence; delivery shall not
                retimestamp an earlier event or acquisition. It shall make reset, DMA, timer, ADC or
                protection-state loss unavailable before it can be used for torque. The acquisition boundary
                shall preserve separate regular records and direct fast epochs without shared mutable
                fast/slow records. Logical responsibilities shall provide qualified fast local Vdc,
                phase-current feedback, current-context Hall state and edge-time evidence, and final
                electrical position. The bounded control responsibility shall coordinate FOC and
                sampling-plan selection and retain sole ownership of final output update. The fast chain
                shall not depend on cyclic task release, queued transport or a masked global-access
                interval. Its immediate caller supplies the live same-domain execution-time reference; this
                does not queue or change the hardware event time. Its short stage/commit access shall use
                the checked scoped-token discipline and abort protocol, leaving independent inhibit and
                higher-priority fault withdrawal effective. The boundary shall preserve independent hardware
                inhibit and physical-output/energy-path observation separate from MCU command.
            */
        }
    }
    satisfy tractionPhysicalSoftwareBoundary by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-TRQIO-001'> atomicFastAcquisitionEpoch : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-trqio-001
            (line 17).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqio-001"></a>`REQ-SYS-TRQIO-001` **Draft**
            Original obligation column: Approved requirement
            Target / allocation direction: **Target: [LE-EPCS](../X2CityMCU.md#le-epcs).** Contributors are
            [LE-PLATFORM](../X2CityMCU.md#le-platform) for completed raw fast epochs,
            [LE-MOTOR-POSITION-PROC](../X2CityMCU.md#le-motor-position-proc) for qualified phase-current
            conversion, and [LE-MOTOR-CTRL](../X2CityMCU.md#le-motor-ctrl) for qualified fast Vdc
            conversion.
            Derived from / interfaces: [REQ-SYS-HSI-009](SystemHardwareSoftwareInterface.sysml)
            Planned verification and open acceptance: `T-SW`, `A`, `T-FI`: producer restart, JEOS/DMA/ADC
            error, cache coherency, trigger sequence, incomplete first samples, commanded-vector context
            rollover, conversion ownership and errata rearm sequence.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The direct fast-acquisition responsibility shall atomically publish only completed
                timer-triggered raw ADC epochs, with configuration/reset and commanded-vector/ADC-context
                identity, channel provenance, aperture/skew and acquisition error state. Qualified
                phase-current feedback and fast local Vdc shall derive from the same identified epoch. Each
                consumer rejects unavailable, stale, partial or old-context evidence; regular diagnostic
                records remain a distinct slower source.
            */
        }
    }
    satisfy atomicFastAcquisitionEpoch by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
