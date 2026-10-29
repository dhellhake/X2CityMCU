package X2CitySpecification_X2CityMCU_InterfaceQualification {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-INT-001'> informationValueAndQualificationSeparation : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Interface_Qualification.md#req-sys-int-001 (line 11).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-int-001"></a>`REQ-SYS-INT-001` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-STA-003](PowerStartupAndFaults.sysml),
            [REQ-SYS-STA-005](PowerStartupAndFaults.sysml), [REQ-SYS-STA-007](PowerStartupAndFaults.sysml),
            [REQ-SYS-BRK-008](../DriverInteraction/MechanicalBrakeDetection/Specification/Requirements.sysml)
            Planned verification / acceptance: I, A, T-SYS, T-FI: independently vary value and
            qualification, withhold initial data and age previously valid data; verify prerequisite
            rejection and the applicable recognized-fault response. Exercise SOC/current display fallbacks
            without accepting them as control evidence; SOC-only loss has no Ready or current-capability
            effect.
            Sources and open dependencies: DEC-STA-001, DEC-FLT-004/005, DEC-TMP-002;
            WS-OI-001/002/010/012/018/019. Define references, validity/freshness/uncertainty and recognition
            bounds before input/control baseline. Telemetry-only battery current is not a new Ready
            prerequisite. Expressly retained VD18MT settings retain their communication-loss policy.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The EPCS shall distinguish the semantic value of required accelerator, brake, motion and
                temperature information, and SOC reporting information from its qualification and freshness,
                so that an unknown, invalid or stale value cannot satisfy a prerequisite requiring valid
                information.
            */
        }
    }
    satisfy informationValueAndQualificationSeparation by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-INT-002'> currentStartupPrerequisiteQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Interface_Qualification.md#req-sys-int-002 (line 12).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-int-002"></a>`REQ-SYS-INT-002`
            Original obligation column: Requirement
            Derived from: [REQ-SYS-STA-001](PowerStartupAndFaults.sysml),
            [REQ-SYS-STA-006](PowerStartupAndFaults.sysml), [REQ-SYS-FLT-010](PowerStartupAndFaults.sysml)
            Planned verification / acceptance: I, A, T-SYS, T-FI: restart with old values available, qualify
            prerequisites in different orders and cross each derived initialization deadline. Old data alone
            grants no Ready; late qualification does not release recognized session inhibition.
            Sources and open dependencies: DEC-STA-001, DEC-FLT-007; WS-OI-007/010/018/019. Derive per-input
            initialization, self-test coverage and timing; no common arbitrary timeout or newly detectable
            fault is selected.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Each startup prerequisite shall be established from information and self-test results
                qualified for the current startup; an initial unqualified condition shall remain distinct
                from a recognized failure under its specified qualification and fault-recognition criteria.
            */
        }
    }
    satisfy currentStartupPrerequisiteQualification by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
