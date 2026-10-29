# Platform
## Platform requirements

**Type:** Abstract Software Requirement. **Target:** `LE-PLATFORM`. **Status:** Draft.

These obligations allocate compute runtime initialization and validation/execution of RidingControl's sleep handoff to Platform. RidingControl alone determines sleep eligibility from current qualified Off and traction sleep-permission evidence. Platform does not consume or recheck those source records; it validates the current request's qualification, source context, lifetime and cancellation before execution. RidingControl also owns operation lifecycle, Ready, fault lifetime and riding authority.


This file contains only the new lifecycle-adjacent Platform allocation. Unrelated Platform acquisition and static binding records remain in [System Interface Allocations](Platform.md), including `REQ-SYS-INP-002` and existing `REQ-SYS-PLT-001/002`.

<a id="context-system-interface-allocations-specification"></a>
## Specification

- [Requirements](Specification/Requirements.sysml)
- [SystemHardwareSoftwareInterface](Specification/SystemHardwareSoftwareInterface.sysml)
- [SystemInterfaceAllocations](Specification/SystemInterfaceAllocations.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)

<a id="context-system-interface-allocations-system-interface-allocations"></a>
## System interface allocations

**Draft successor — 2026-10-28; retains REQ-001-R2.0.** This page retains the System-level Abstract Software obligations for acquisition, context, compiled parameters, caller-supplied time and fast-epoch execution. Their logical targets and parent links remain active; software realization and Unit Requirements are pending under [DEC-ARCH-004](../../../DEC-001_Decisions_and_Open_Issues.md#dec-arch-004).

The cross-leaf fast-epoch interface [REQ-SYS-TRQIO-001](../../Specification/SystemHardwareSoftwareInterface.sysml) remains canonical in the System HSI table. Its obligations retain separate acquisition, phase-current, supply and motor-control responsibilities through their logical targets.

<a id="context-system-interface-allocations-caller-supplied-execution-time-and-private-validity"></a>
### Caller-supplied execution time and private validity

`REQ-SYS-PLT-002` retains the common `ExecutionTime { currentTimeMicroseconds: Integer }` obligation. Every dispatched project component and standalone project operation receives a live value sampled from the common host-boot monotonic microsecond domain immediately before that invocation. The value is fixed for that bounded invocation; it is not a planned release time, stale task-start snapshot or component clock read. A nested operation uses its enclosing invocation's fixed reference and does not resample. Reset establishes a new context generation.

The receiving logical responsibility owns each private per-input validity/timeout rule and evaluates it against the supplied time. Guards account conservatively for elapsed time through relevant use/effect, including remaining bounded execution. Initial, invalid, unavailable or expired evidence is unavailable. A newly acquired valid measurement refreshes only its own timer, even if unchanged; health-only/composite republication and dequeuing an old record do not make evidence current. Parent-defined lifetimes for retained settings, light requests, compiled parameters and context remain in force. Transport delay, consumer period, bounded execution time and timeout must satisfy the end-to-end bound. No generic transmitted freshness field is imposed; meaningful measurement, acquisition, event, decision and expiry times remain explicit where age or ordering matters.


The Unit Requirements and detailed-design decomposition are pending. Their prior approved and Draft content remains in Git history; this page preserves only active System-level obligations and does not reinstate a unit allocation.
