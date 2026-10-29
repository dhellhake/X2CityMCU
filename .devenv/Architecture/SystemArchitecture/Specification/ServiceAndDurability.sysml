package X2CitySpecification_X2CityMCU_ServiceAndDurability {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-VEH-DUR-001'> electricalEquipmentServiceLife : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Service_and_Durability.md#req-veh-dur-001 (line 15).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-dur-001"></a>`REQ-VEH-DUR-001`
            Original obligation column: Obligation
            Verification / acceptance: `I`, `A`, `T-SYS`. Define the electrical duty accumulation,
            inspections, permitted battery and applicable normal electrical wear-part replacements and end
            criteria; assess project equipment function and condition at intervals and at the first reached
            target.
            Sources: `OBJ-009`, `OBJ-010`,
            [PD §6.6](../../../../README.md#66-range-reserve-and-energy-sizing), DUR-001
            Open dependencies / qualifications: `OI-050`, `OI-054`, `OI-061`: define project electrical
            durability acceptance, duty accumulation, replacement records, inspection intervals and age/time
            accounting. The supplied platform age/wear is an external assumption; this row does not
            guarantee aged-battery range or an aged 70 km qualification.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Project electrical/electronic equipment, including the installed battery/BMS, propulsion
                control, wiring, HMI and lighting, shall retain its required electrical functions through
                **50,000 km of supplied vehicle duty or 5 years, whichever is reached first**, measured from
                commissioning of the modified electrical retrofit. Battery and applicable normal electrical
                wear parts may be replaced under the controlled maintenance basis. This target does not
                qualify BMW mechanical-platform service life.
            */
        }
    }
    satisfy electricalEquipmentServiceLife by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-SVC-001'> safeElectricalServiceProcedures : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Service_and_Durability.md#req-veh-svc-001 (line 16).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-svc-001"></a>`REQ-VEH-SVC-001`
            Original obligation column: Obligation
            Verification / acceptance: `I`, `A`, `T-SYS`, `T-FI`. Inspect procedures and access points;
            execute representative service tasks with installed and removed battery configurations,
            wheel-generated energy and residual energy present; acceptance requires the documented controls
            to achieve derived accessible-interface limits.
            Sources: `OBJ-009`, `CON-027`,
            [PD §11.8](../../../../README.md#118-battery-removal-and-service-interfaces),
            [PD §13](../../../../README.md#13-project-constraints)
            Open dependencies / qualifications: `OI-045`, `OI-047`, `OI-048`, `OI-049`: derive isolation
            states, access boundaries, discharge/verification steps, generated-energy controls and service
            preparation. No specific switch, connector, discharge mechanism or service topology is selected.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The vehicle shall provide documented inspection, maintenance and access procedures,
                including physical source isolation/removal and residual/generated-energy controls for tasks
                requiring isolation; any deliberately energized diagnostic task shall have its own
                controlled preparation and operating conditions.
            */
        }
    }
    satisfy safeElectricalServiceProcedures by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-SVC-001'> maintainerDiagnosticInspection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Service_and_Durability.md#req-sys-svc-001 (line 17).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-svc-001"></a>`REQ-SYS-SVC-001`
            Original obligation column: Obligation
            Verification / acceptance: `I`, `T-SYS`, `T-FI`. Inspect producer-owned debugger
            variables/register views and identity during startup, operation and representative faults;
            restart after cleared and persistent conditions and verify no old failure history remains.
            Sources: `OBJ-009`, [PD §2](../../../../README.md#2-project-objectives),
            [PD §11.8](../../../../README.md#118-battery-removal-and-service-interfaces), `OI-047`,
            `OI-049`, [REQ-SYS-FLT-006](PowerStartupAndFaults.sysml),
            [REQ-SYS-FLT-011](PowerStartupAndFaults.sysml)
            Open dependencies / qualifications: `OI-047`, `OI-049`, `OI-050`: define debugger access,
            diagnostic scope, self-test observability, configuration/calibration identity and
            coverage/completion. Current-session observations may be retained as already defined; no
            persistent past-failure record is required.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The EPCS shall make current diagnostic and self-test observations, plus configuration and
                calibration identity, available for competent-maintainer debugger inspection. It shall not
                retain past-failure history across a normal or unexpected restart.
            */
        }
    }
    satisfy maintainerDiagnosticInspection by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-SVC-002'> postServiceStartupQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Service_and_Durability.md#req-sys-svc-002 (line 18).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-svc-002"></a>`REQ-SYS-SVC-002`
            Original obligation column: Obligation
            Verification / acceptance: `I`, `T-SYS`, `T-FI`. Perform representative isolation, replacement,
            configuration and access tasks in fitted and removed-battery service configurations; attempt
            operation with incomplete, failed and passing qualification. Verify service completion cannot
            bypass current-information checks, fault recovery or riding Ready.
            Sources: `OBJ-009`, `OBJ-010`, [PD §9](../../../../README.md#9-vehicle-operating-states),
            [REQ-SYS-STA-006](PowerStartupAndFaults.sysml), [REQ-SYS-FLT-005](PowerStartupAndFaults.sysml)
            Open dependencies / qualifications: `OI-047`, `OI-049`: define service completion conditions,
            restart/qualification observations and any configuration-change controls. No service bypass or
            special fault-clearing event is selected.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Following controlled service, riding shall become eligible only through fresh normal startup
                qualification and all applicable Ready permissives. Service completion alone shall bypass
                neither vehicle qualification guards nor fault recovery.
            */
        }
    }
    satisfy postServiceStartupQualification by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
