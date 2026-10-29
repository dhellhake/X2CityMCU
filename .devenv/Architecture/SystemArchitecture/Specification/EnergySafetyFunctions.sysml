package X2CitySpecification_X2CityMCU_EnergySafetyFunctions {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-FSC-005'> chargePathLossEnergyCoordination : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Energy_Safety_Functions.md#req-sys-fsc-005 (line 9).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID / role / target: <a id="req-sys-fsc-005"></a>`REQ-SYS-FSC-005` · functional safety ·
            **Target: LE-EPCS**
            Original obligation column: Draft safety requirement
            Derived from: [SG-002](../../../Safety/SG-001_Safety_Goals.md#sg-002),
            [SG-004](../../../Safety/SG-001_Safety_Goals.md#sg-004),
            [SG-008](../../../Safety/SG-001_Safety_Goals.md#sg-008),
            [SG-010](../../../Safety/SG-001_Safety_Goals.md#sg-010)
            Supporting constraints: [REQ-SYS-ENE-002](EnergyAndProtection.sysml),
            [REQ-SYS-ENE-003](EnergyAndProtection.sysml), [REQ-SYS-BMS-005](BatteryControl.sysml),
            [REQ-SYS-BMS-009](BatteryControl.sysml),
            [REQ-SYS-BMS-008](../BatteryControl/Specification/OperatingPolicy.sysml)
            Planned verification and measurable outcome: Define the credible generated-energy and
            charge-path-loss cases, including controller/power/link absence and charging-ineligible states.
            Analyze and test representative bounded cases with wheel rotation: observe wheel torque/drag,
            energy destination, voltages/currents, accessible-interface state, and recovery. Show that the
            assigned safe transition and electrical energy limits are met without crediting an unavailable
            command or charge path.
            Open issue / acceptance gate: `OI-041/045/048/049/061`; derive the generated-energy envelope,
            permitted motor-induced torque/drag and electrical component/interface limits, physical response
            coverage, and common dependencies before allocation acceptance.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Draft:** For every credible loss, inhibition, erroneous availability, or withdrawal of a
                battery charge path while wheel-generated energy can reach the propulsion electrical system,
                the EPCS shall coordinate the electrical energy-path response so that neither hazardous
                electrical-energy escalation nor hazardous motor-induced wheel restraint results. This
                applies with normal propulsion control off, faulted, or unable to command the response, and
                when the battery is charging-ineligible. Availability and adequacy of supplied mechanical
                braking remain external platform assumptions. The assigned treatment shall not depend on
                continued battery charge acceptance or on a zero-torque command being physically sufficient.
            */
        }
    }
    satisfy chargePathLossEnergyCoordination by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FSC-006'> accessibleElectricalEnergyProtection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Energy_Safety_Functions.md#req-sys-fsc-006 (line 10).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID / role / target: <a id="req-sys-fsc-006"></a>`REQ-SYS-FSC-006` · broader functional safety ·
            **Target: LE-EPCS**
            Original obligation column: Draft safety requirement
            Derived from: [SG-008](../../../Safety/SG-001_Safety_Goals.md#sg-008),
            [SG-010](../../../Safety/SG-001_Safety_Goals.md#sg-010)
            Supporting constraints: [REQ-SYS-BAT-003](BatteryHandling.sysml),
            [REQ-SYS-BMS-004](BatteryControl.sysml), [REQ-SYS-BMS-009](BatteryControl.sysml),
            [REQ-SYS-ENE-003](EnergyAndProtection.sysml)
            Planned verification and measurable outcome: Establish each accessible interface and
            electrical-reference configuration, then inspect, analyze, and test normal intermediates plus
            representative credible faults. Measure or otherwise demonstrate that accessible voltage,
            current, arc/energy and residual-energy outcomes meet derived person-exposure acceptance,
            including when the ordinary control or communication path is absent.
            Open issue / acceptance gate: `OI-041/045/046/049/062`; derive accessible-interface limits,
            reference/power-state model, residual/generated-energy behavior, handling/service recovery
            criteria, and the qualified UART electrical arrangement.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Draft:** Across normal removal/refitting, connected-but-unseated handling, empty-bay
                exposure, shutdown, storage and service/BMS-disconnect configurations, the EPCS shall
                prevent hazardous human exposure to supplied, residual or wheel-generated electrical energy
                at accessible pack, vehicle and communication interfaces. The outcome shall remain valid
                across the applicable pack-potential, switched-reference, non-isolated-UART, powered and
                unpowered-host states and credible misconnection/fault states; a reported disabled path or
                zero commanded torque is not evidence of the required outcome.
            */
        }
    }
    satisfy accessibleElectricalEnergyProtection by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FSC-007'> cumulativeRestartEnergyLimitation : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Energy_Safety_Functions.md#req-sys-fsc-007 (line 11).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID / role / target: <a id="req-sys-fsc-007"></a>`REQ-SYS-FSC-007` · functional safety ·
            **Target: LE-EPCS**
            Original obligation column: Draft safety requirement
            Derived from: [SG-008](../../../Safety/SG-001_Safety_Goals.md#sg-008)
            Supporting constraints: [REQ-SYS-BMS-005](BatteryControl.sysml),
            [REQ-SYS-BMS-006](../BatteryControl/Specification/StartupAndClassification.sysml),
            [REQ-SYS-ENE-001](EnergyAndProtection.sysml)
            Planned verification and measurable outcome: Define repeated vehicle-event sequences, including
            reset during riding transfer, fault clearance, battery handling and unavailable telemetry.
            Verify accumulated regenerative charge, discharge, heat, residual transfer and
            renewed-permission guards against derived cumulative bounds; show that an old fault record is
            neither incorrectly retained nor required current qualification omitted.
            Open issue / acceptance gate: `OI-041/045/049/061/063`; derive reset-event identity,
            retained-state integrity, required fresh checks, per-event residual transfer, accumulation
            window, thermal/load margins and protective response before reset/recovery acceptance.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Draft:** The vehicle energy system shall bound cumulative electrical transfer and heat
                caused by repeated reset, restart, recovery or battery-connection events so that successive
                individually permissible transitions cannot together create a hazardous battery, conductor
                or accessible-interface condition. Before each restored transfer, current conditions and
                required protection readiness shall be qualified. A riding restart does not retain
                past-failure history, but that rule does not permit a reset to bypass a current unsafe
                condition or accumulate unbounded reset-pulse energy.
            */
        }
    }
    satisfy cumulativeRestartEnergyLimitation by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-FSC-008'> packLocalFaultEnergyContainment : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Energy_Safety_Functions.md#req-sys-fsc-008 (line 12).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID / role / target: <a id="req-sys-fsc-008"></a>`REQ-SYS-FSC-008` · broader functional safety ·
            **Target: LE-EPCS**
            Original obligation column: Draft safety requirement
            Derived from: [SG-008](../../../Safety/SG-001_Safety_Goals.md#sg-008)
            Supporting constraints: [REQ-SYS-BMS-003](../BatteryControl/Specification/BmsIntegration.sysml),
            [REQ-SYS-BMS-006](../BatteryControl/Specification/StartupAndClassification.sysml),
            [REQ-SYS-BMS-009](BatteryControl.sysml), [REQ-SYS-ENE-002](EnergyAndProtection.sysml),
            [REQ-SYS-ENE-003](EnergyAndProtection.sysml)
            Planned verification and measurable outcome: Define the credible unobserved pack-local fault
            envelope and its possible escalation paths. By analysis, inspection and suitably bounded tests
            or representative evidence, show the assigned prevention, limitation, containment, isolation,
            inspection and recovery treatment keeps person-accessible energy, temperature and
            material-release outcomes within derived acceptance. Document residual unobservable conditions
            and their treatment rather than representing them as detected.
            Open issue / acceptance gate: `OI-040/041/045/049/061/062/063`; establish physical pack
            condition/propagation evidence, observable versus unobservable coverage, accessible-location
            consequences, storage/regeneration/load cases, post-damage inspection/recovery rules and
            residual-risk disposition before safety-concept allocation acceptance.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Draft:** For credible pack-local electrical, thermal or electrochemical fault conditions
                that are not reliably observable through the supplied BMS information, the vehicle energy
                system shall provide assigned treatment that bounds hazardous energy release, heat
                escalation and battery-material release at person-accessible locations during riding,
                storage, handling and service. The treatment shall not rely solely on a valid UART reply,
                fourteen group-voltage observations or the available temperature probes, and it shall
                address propagation and post-damage recovery within the declared credible fault envelope.
            */
        }
    }
    satisfy packLocalFaultEnergyContainment by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
