package X2CitySpecification_X2CityMCU_EnergyAndProtection {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-ENE-001'> totalBatteryCurrentEnforcement : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Energy_and_Protection.md#req-sys-ene-001 (line 17).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-ene-001"></a>`REQ-SYS-ENE-001`
            Original obligation column: Obligation
            Verification / acceptance: `A`, `T-SYS`. Establish the complete load inventory and duty; measure
            or calculate demand, SOC/cell-voltage margins and temperature cases, including shutdown, storage
            and the lowest-group-voltage discharge-cutoff transition. Acceptance uses derived qualified
            limits and margins; no arbitrary indefinite duration is implied.
            Sources: `OBJ-005`, `OBJ-012`, `OBJ-014`, `CON-048`, `CON-050`,
            [PD §6.6](../../../../README.md#66-range-reserve-and-energy-sizing),
            [PD §8.2](../../../../README.md#82-ambient-parking-and-weather-exposure)
            Open dependencies / qualifications: `OI-045`, `OI-061`, `OI-063`, `WS-OI-017`, `WS-OI-018`:
            derive battery limits, auxiliary/residual load budget, self-discharge, uncertainty and
            DEC-STO-002 normal-full entry tolerance. The cutoff applies to total operating discharge;
            physical enforcement, startup, residual and storage consumption remain to be derived and
            verified.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The energy system shall keep total applicable electrical loads, including auxiliary,
                residual and self-discharge consumption, within qualified battery and storage limits
                throughout each defined duty and transition.
            */
        }
    }
    satisfy totalBatteryCurrentEnforcement by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-ENE-002'> abnormalConditionProtectiveResponse : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Energy_and_Protection.md#req-sys-ene-002 (line 18).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-ene-002"></a>`REQ-SYS-ENE-002`
            Original obligation column: Obligation
            Verification / acceptance: `I`, `A`, `T-SYS`, `T-FI`. For the derived fault envelope, inject or
            reproduce each detectable condition and verify the assigned response, affected energy paths and
            limits, including cases where torque is already zero and where reporting is unavailable.
            Sources: `OBJ-005`, `OBJ-003`, `CON-018`, `CON-019`, `CON-021`, `CON-050`,
            [PD §2](../../../../README.md#2-project-objectives),
            [PD §13](../../../../README.md#13-project-constraints)
            Open dependencies / qualifications: `OI-049`, `OI-061`, `WS-OI-010`, `WS-OI-018`, `WS-OI-019`:
            fault catalogue, detection coverage, recognition/withdrawal timing, response severity, energy
            isolation/discharge and component limits remain to be derived. This row does not promise
            protection against every fault or select a topology.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                For each derived abnormal electrical or thermal condition requiring protection, the system
                shall produce the assigned protective response including when zero motor torque is
                commanded.
            */
        }
    }
    satisfy abnormalConditionProtectiveResponse by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-ENE-003'> residualAndGeneratedEnergyControl : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Energy_and_Protection.md#req-sys-ene-003 (line 19).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-ene-003"></a>`REQ-SYS-ENE-003` **Draft successor; historical approval
            retained**
            Original obligation column: Obligation
            Verification / acceptance: `I`, `A`, `T-SYS`, `T-FI`. Exercise shutdown, zero-command wheel
            rotation, faulted inverter/control, voltage/temperature regeneration-ineligible states and
            service boundaries; observe voltage, current, dissipation, torque/drag effects and accessible
            contacts against derived limits.
            Sources: `OBJ-005`, `CON-019`, `CON-048`,
            [PD §9](../../../../README.md#9-vehicle-operating-states),
            [PD §10.2](../../../../README.md#102-installed-rear-hub-motor),
            [PD §11.8](../../../../README.md#118-battery-removal-and-service-interfaces),
            [DEC-001](../../DEC-001_Decisions_and_Open_Issues.md)
            Open dependencies / qualifications: `OI-045`, `OI-048`, `OI-049`, `WS-OI-018`: derive
            generated-energy envelope, regenerative charge acceptance, dissipation/isolation paths,
            accessible-interface limits and residual-energy timing. Preserve the distinction between zero
            command and electrical energy; no regenerative topology or instantaneous zero-energy claim is
            selected.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The energy system shall handle residual stored energy and externally wheel-generated energy
                in off, fault and regeneration-ineligible states within derived component and
                accessible-interface limits.
            */
        }
    }
    satisfy residualAndGeneratedEnergyControl by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-ENE-004'> offlineEssentialControlAvailability : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Energy_and_Protection.md#req-sys-ene-004 (line 20).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-ene-004"></a>`REQ-SYS-ENE-004`
            Original obligation column: Obligation
            Verification / acceptance: `I`, `T-SYS`, `T-FI`. Remove or deny each external connectivity path
            during startup, normal operation and representative fault handling; verify essential control,
            protection and recovery continue within their qualified limits.
            Sources: `CON-016`, `OBJ-003`, `OBJ-005`,
            [PD §13.2](../../../../README.md#13-project-constraints)
            Open dependencies / qualifications: `OI-049`, architecture allocation to `LE-EPCS` and
            [ARCH-001](../X2CityMCU.md): identify the essential function set, local interfaces, degraded
            behavior and timing/availability limits. No wireless, phone, cloud or internet implementation is
            selected.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Required essential control and fault-handling functions shall remain operable without a
                phone, cloud service, wireless link or internet connection.
            */
        }
    }
    satisfy offlineEssentialControlAvailability by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
