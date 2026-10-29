package X2CitySpecification_Platform_SystemInterfaceAllocations {
    private import X2CityComponent_Platform::Platform;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-INP-002'> acquisitionRecordSeparation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/System_Interface_Allocations.md#req-sys-inp-002
            (line 15).
            Original target: LE-PLATFORM.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-inp-002"></a>`REQ-SYS-INP-002` **Draft successor allocation**
            Type / logical target: Abstract Software Requirement;
            [LE-PLATFORM](../../../X2CityMCU.md#le-platform)
            Original obligation column: Requirement
            Derived from: REQ-SYS-HSI-001, REQ-SYS-HSI-007, REQ-SYS-HSI-009,
            [REQ-SYS-TRQIO-001](../../../Specification/SystemHardwareSoftwareInterface.sysml);
            REQ-SYS-INP-001 is limited to temperature/supply qualification.
            Planned verification and remaining gate: `T-SW`, `A`, `T-FI`: completion/error/overwrite,
            acquisition-time preservation, cache attributes, reset/configuration rollover, partial scans,
            fast-event sequencing, caller-time timeout and consumer age. Stream selection, timing and
            electrical acceptance remain qualification work.
        */
        subject owner:Platform =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;
        require constraint {
            doc /*
                Vehicle acquisition responsibility shall maintain separate regular completed-record and
                direct fast-epoch stores. Each record shall carry source sequence, actual
                acquisition/completion time in the host-boot monotonic microsecond domain,
                producer/configuration/reset context and completion/error/overflow state. Partial,
                overwritten, cache-incoherent, DMA-error or foreign-context records are unavailable. Later
                delivery preserves, and does not retimestamp, an earlier scan. Regular records remain
                distinct from direct fast epochs; they share no mutable record and fast acquisition adds no
                scheduler or queue latency. Hall capture remains a separate source. The acquisition
                responsibility supports downstream semantic qualification while each logical consumer
                retains its own qualification duties. These obligations do not create a shared logical
                acquisition element or change fast-epoch ownership.
            */
        }
    }
    satisfy acquisitionRecordSeparation by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;

    requirement <'REQ-SYS-PLT-002'> platformDispatchAndFastAccess : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/System_Interface_Allocations.md#req-sys-plt-002
            (line 18).
            Original target: LE-PLATFORM.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-plt-002"></a>`REQ-SYS-PLT-002` **Draft**
            Type / logical target: Abstract Software Requirement; LE-PLATFORM
            Original obligation column: Requirement
            Derived from: REQ-SYS-HSI-007, REQ-SYS-HSI-009
            Planned verification and remaining gate: `A`, `T-SW`, `T-FI`, `T-HW`: live caller-time sampling,
            fixed references, no reuse, reset generation, no clock/planned-release substitution,
            elapsed/WCET margins, vector/priority routes, context invalidation, shared-resource lifetime,
            crash-path separation, masked duration/order, late-commit abort, route overflow, health
            classification and scheduling. Driver/OS implementation, resource, electrical and
            physical-protection evidence remain gates.
        */
        subject owner:Platform =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;
        require constraint {
            doc /*
                Platform responsibility shall configure the selected startup, resource, vector, priority and
                scheduler bindings and route enabled hardware events to their designated logical handling
                responsibilities. It shall provide `ExecutionTime { currentTimeMicroseconds: Integer }` at
                `executionTimeIn` to every dispatched project component and standalone operation, sampled
                live immediately before each invocation. The fixed common-domain reference is not reused
                across invocations; reset generation is preserved; planned release/stale task time and
                component clock reads are not substituted. Direct fast execution remains direct: its
                immediate caller supplies same-domain time without queueing or retimestamping the hardware
                event. Platform integration remains generic and shall not embed vehicle pins, protocol, FOC
                or RidingControl session fault policy in reusable layers. Static access to shared fast
                resources shall be checked; immediate fast inhibition and relevant health evidence shall
                remain effective and available to system-level fault classification. NMI and HardFault shall
                not access shared fast resources; any crash-only action shall use disjoint hardware/register
                ownership. A runtime/repair fast fault remains inhibited until applicable clean restart.
                Fast execution shall prevent unchecked shared access, complete required ordering before
                output commit, bound interrupt masking and abort a late commit after break/inhibit.
            */
        }
    }
    satisfy platformDispatchAndFastAccess by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;

    requirement <'REQ-SYS-PLT-001'> platformContextInvalidation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/System_Interface_Allocations.md#req-sys-plt-001
            (line 16).
            Original target: LE-PLATFORM.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: `REQ-SYS-PLT-001` **Draft successor**
            Type / logical target: Abstract Software Requirement; LE-PLATFORM
            Original obligation column: Requirement
            Derived from: REQ-SYS-HSI-007
            Planned verification and remaining gate: `A`, `T-SW`, `T-FI`, `T-SYS`: endpoint/rail reset and
            local-health context cases. Domains, integrity, scheduling and common-cause coverage remain
            gates.
        */
        subject owner:Platform =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;
        require constraint {
            doc /*
                Platform responsibility shall invalidate observations, commands and acknowledgements
                affected by power, reset or local-health context change until qualified in the current
                context, without deciding consumer session semantics.
            */
        }
    }
    satisfy platformContextInvalidation by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;

    requirement <'REQ-SYS-PLT-CAL-001'> compiledCalibrationValidation : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/System_Interface_Allocations.md#req-sys-plt-cal-001
            (line 17).
            Original target: LE-PLATFORM.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: `REQ-SYS-PLT-CAL-001` **Draft — retained identifier, compile-time parameter obligation**
            Type / logical target: Abstract Software Requirement; LE-PLATFORM (other parameter-owning
            logical responsibilities are dependencies)
            Original obligation column: Requirement
            Derived from: REQ-SYS-HSI-007, REQ-SYS-HSI-009
            Planned verification and remaining gate: `A`, `T-SW`, `T-FI`: startup validation and
            failed-output withholding; build/static-initialization correspondence; reset and failed-source
            invalidation; static binding mismatch; rebuild/deployment/restart change; and independent
            producer-context rollover.
        */
        subject owner:Platform =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;
        require constraint {
            doc /*
                Each logical responsibility shall use immutable compiled calibration/configuration
                parameters for its obligations and validate required parameters during startup self-test
                against firmware build identity/static initialization. Failed validation withholds the
                dependent output. Parameter changes require rebuild, deployment and restart. Calibration
                does not create runtime context rollover, bundle publication, disarmed activation,
                calibration-lifecycle service or partial live update. Interface-health failure does not
                itself define RidingControl fault/report policy or physical traction output. Static hardware
                binding remains a Platform responsibility.
            */
        }
    }
    satisfy compiledCalibrationValidation by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;

}
