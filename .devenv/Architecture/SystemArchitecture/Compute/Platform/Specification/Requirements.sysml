package X2CitySpecification_Platform_Requirements {
    private import X2CityComponent_Platform::Platform;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-PLT-003'> runtimeInitializationQualification : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Compute/Platform/Platform.md#req-sys-plt-003 (line 10).
            Original target: LE-PLATFORM.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-plt-003"></a>`REQ-SYS-PLT-003` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-STA-001](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-STA-006](../../../Specification/PowerStartupAndFaults.sysml),
            [REQ-SYS-HSI-002](../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-PLT-002](SystemInterfaceAllocations.sysml).
            Planned verification / remaining gate: `T-SW`, `T-FI`, `T-SYS`: after each wake, verify
            `requiredRuntimeReady` is true only with current qualified evidence for each required runtime
            resource and monotonic timebase; distinguish qualified false from unavailable/invalid
            qualification. Verify caller-supplied execution-time references use that current timebase.
            Inject failed, incomplete and context-mismatched resources. Vehicle self-tests and the common
            Ready guard remain separately verified.
        */
        subject owner:Platform =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;
        require constraint {
            doc /*
                After each controller wake, Platform shall publish a current `ComputeRuntimeInitialization`
                record. It shall set `requiredRuntimeReady=true` only when the record qualifies
                current-context initialization and availability of the required runtime clocks, peripherals
                and runtime monotonic timebase; failed or incomplete initialization shall not be represented
                as ready. Calling tasks shall supply execution-time references sampled from that initialized
                timebase. This result shall not represent vehicle self-test completion, Ready, fault
                clearance or drive permission.
            */
        }
    }
    satisfy runtimeInitializationQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;

    requirement <'REQ-SYS-PLT-005'> sleepEntryGrantValidation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Compute/Platform/Platform.md#req-sys-plt-005 (line 11).
            Original target: LE-PLATFORM.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-plt-005"></a>`REQ-SYS-PLT-005` **Draft — 2026-10-05**
            Original obligation column: Requirement
            Derived from / governing contract:
            [REQ-SYS-CTL-006](../../../RidingControl/RidingPolicy/Specification/SettingsAndControlPolicy.sysml),
            [REQ-SYS-PWR-003](../../../Specification/PowerStartupAndFaults.sysml); `ComputeSleepRequest`.
            Planned verification / remaining gate: `T-SW`, `T-FI`, `T-SYS`: validate qualified latest
            grants; attempt entry for absent, invalid, expired, context-mismatched, false, cancelled and
            superseded requests; verify handoff preserves Session qualification, source context and expiry
            without renewal, and no invalidated grant can initiate sleep. Revoke/expiry during a pending
            handoff must be tested against actual entry. Numeric lifetime and finite race/order/transport
            behavior remain downstream derivation and qualification gates. Physical inhibition,
            residual/generated energy and component acceptance remain under `REQ-SYS-ENE-002/003`.
        */
        subject owner:Platform =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;
        require constraint {
            doc /*
                At actual sleep entry, Platform shall validate that the Session `ComputeSleepRequest` with
                `enterSleep=true` is the latest current qualified grant, its source context is valid for the
                current Session context, and its `expiry` has not elapsed. The true handoff shall preserve
                the grant's qualification, source context and `expiry` without renewal. An absent, invalid,
                expired, context-mismatched, false, cancelled or superseded request shall not initiate
                sleep; Platform shall clear any pending true handoff and keep the controller awake.
            */
        }
    }
    satisfy sleepEntryGrantValidation by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;

}
