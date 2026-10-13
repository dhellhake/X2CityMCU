# Compute

`LE-COMPUTE` is the vehicle execution infrastructure composite. It contains only `LE-COMPUTE-HW` and `LE-PLATFORM`; system-function ownership remains with the owning logical components. The selected WeAct STM32H723VGT6 V1.2 board hosts vehicle execution. EnergyPath supplies distributed vehicle electrical power to Compute.

The conditioned HMI hardware wake is a direct path from HMIControl through Compute to ComputeHardware and remains available while the processor sleeps. After hardware wake, Platform initializes runtime independently of HMI request qualification. HMIControl publishes its qualified `VehicleOperationRequest` to RidingControl only; RidingControl evaluates sleep eligibility from qualified explicit Off and qualified traction `computeSleepPermitted` evidence, then grants or revokes the sleep request. Platform validates the RidingControl request at sleep entry and executes it; it does not re-evaluate HMI or traction eligibility or renew permission while forwarding. Platform does not observe or emit the awake power-lock signal.

Platform publishes `ComputeRuntimeInitialization` readiness for required clocks, peripherals and the runtime monotonic timebase used by caller-supplied time references. This is a runtime prerequisite and does not establish vehicle Ready. RidingControl owns On/Off lifecycle, vehicle Ready and fault-latch authority. A qualified explicit Off immediately closes the current operation session regardless of motion. A later qualified On requires fresh session qualification; it never resumes prior Ready or authority.

RidingControl requests sleep only after the required traction output handoff. Each true request is a current qualified grant with an expiry; false cancels it. Platform accepts only the latest current-context, valid, unexpired true request at actual entry, preserving its qualification, source context and expiry without renewing it. Revoked, invalid, missing, expired or superseded grants cannot initiate sleep, and a pending true handoff clears when no longer current. The traction `computeSleepPermitted` value is capability evidence used by RidingControl, not final permission. No physical disconnect/isolation behavior is implied.

## Decomposition

| Logical part | Role | Model and requirement navigation |
|---|---|---|
| `LE-COMPUTE` | System compute infrastructure composite and EnergyPath load | [Compute model](Compute.sysml), [requirements](Compute_Requirements.md) |
| `LE-COMPUTE-HW` | Selected controller board, energy input, reset/I/O and direct hardware wake | [ComputeHardware model](Decomposition/ComputeHardware.sysml), [requirements](Decomposition/ComputeHardware_Requirements.md) |
| `LE-PLATFORM` | Runtime initialization readiness and guarded sleep execution | [Platform model](Decomposition/Platform.sysml), [requirements](Decomposition/Platform_Requirements.md) |

## Composition and exchanges

The first view means **composed of**. The second shows distinct energy, hardware wake, operation-record, runtime-readiness and lifecycle exchanges.

```mermaid
flowchart TB
    EPCS[LE-EPCS] -->|contains| Compute[LE-COMPUTE]
    Compute -->|contains| HW[LE-COMPUTE-HW]
    Compute -->|contains| Platform[LE-PLATFORM]
```

```mermaid
flowchart LR
    HMI[HMIControl] -->|conditioned hardware wake; works while MCU sleeps| Compute[LE-COMPUTE]
    Compute -->|direct hardware wake delegation| HW[LE-COMPUTE-HW]
    HMI -->|vehicleOperationRequestOut| RidingControl[RidingControl]
    EnergyPath[LE-ENERGY-PATH] -->|IF-A-010 vehicle electrical power| Compute
    Compute -->|delegated EnergyPath supply| HW
    Platform -->|ComputeRuntimeInitialization readiness| RidingControl
    RidingControl -->|ComputeSleepRequest after traction handoff| Compute
    Compute -->|delegated sleep request| Platform
    Traction[TractionControl capability evidence] -->|TractionConditionEvidence.computeSleepPermitted| RidingControl
    Platform -->|guarded sleep handoff| HW
```

This Compute refinement and its allocations are Draft. The selected sleep mechanism, eligible wake mode/input, pin-5 electrical/Off mapping, timing and sleep-persistence behavior remain downstream derivation and qualification gates. See [system architecture](../../ARCH-001_System_Architecture.md#le-compute), [SystemArchitecture navigation](../../README.md), and [ARCH-002 hardware architecture](../../../ARCH-002_Hardware_Architecture.md#hc-controller).
