# Vehicle runtime integration contract

**Draft 0.2 — 2026-09-16.** This is the implementation-facing design contract for the selected vehicle sensor and traction realization. It refines ARCH-003, DD-001–004 and the [traction HSI](../DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md). It is not firmware evidence or an allocation of the independent hardware inhibit.

## Boundary and current implementation status

A binding is project-owned code that selects a resource, static rank/trigger setup, vector and data route. A generic driver operation is project-independent register access. Current Rust sources do not implement the selected ADC, TIM/PWM, DMA, EXTI or NVIC bindings, nor a safe DMA storage abstraction. The planned bindings therefore do not describe delivered driver capability. The current cyclic OS has 1/5/10/20/50/100-ms releases; vehicle deployment uses 5 and 10 ms, and has no DMA-to-task wakeup API. A 10-ms cyclic qualifier is the nominal interface period, while its WCET, capacity and freshness limits remain qualification values. The regular 1-kHz rate is a planned target only; its timer/trigger, jitter and ADC1/ADC2 rank identities are preimplementation derivation and readback gates.

## Ownership and direct fast chain

| Owner | Binding or direct operation | Output / rule |
|---|---|---|
| `U-PLATFORM-CONTEXT` / `U-PLATFORM-BINDING` | `B-PLATFORM-BOOT`, `B-PLATFORM-IRQ-DISPATCH` | Static clocks, ADC ranks/triggers, DMA/D2 non-cacheable attributes, vectors, priorities and resource ownership under the active calibration context. It dispatches only. |
| `U-PLATFORM-CALIBRATION` / SC-PLATFORM | direct platform lifecycle call while disarmed | Solely validates an immutable calibration bundle, rolls context, invalidates dependent records and activates the bundle. It does not configure peripheral registers or convert signals. |
| `U-ANALOG-ACQ-FAST` / SC-ANALOG-ACQ | `B-FAST-ANALOG-JEOS` | Bounded ADC1/ADC2 JEOS/JDR1/JDR2 snapshot into raw `InjectedEpoch`. No DMA, task wakeup, queue, allocation, logging or unbounded lock. |
| `U-MOTOR-PHASE-FAST` / SC-MOTOR-PHASE-IF | direct fast call | Calibrates/scales current codes, checks aperture/window/range, reconstructs only from the admissible same-epoch pair and publishes immutable phase feedback. |
| `U-SUPPLY-FAST` / SC-SUPPLY-IF | direct fast call | Calibrates rank-2 `SEN_PVDD` into `FastDcLinkVoltageRecord`; it carries its actual rank-2 timestamp/skew and is not asserted simultaneous with the current pair. |
| `U-HALL-POSITION` / SC-HALL-IF | direct nonqueued accessor | Returns current complete `HallElectricalPositionRecord` (map/alignment, transition, direction, timestamp) or unavailable. |
| `U-TRACTION-CONTROL` / SC-TRACTION-CTRL | direct fast call | Accepts authority/command and the qualified phase, fast-Vdc and electrical-position inputs; executes FOC and produces next `CCR1..3`, `CCR4` and ADC context. |
| `U-TRACTION-OUTPUT` / SC-TRACTION-CTRL | direct fast call | Sole literal writer of `CCR1..4` and JSQR; performs the HSI guarded stage/commit transaction. |

The chain is `JEOS → raw injected epoch → phase feedback + fast Vdc + electrical position → FOC → output`. It runs in the fast interrupt context and is outside scheduler and intercom. `U-TRACTION-CONTROL` orchestrates it but has no sensor-calibration, DMA, Hall-capture or direct compare ownership. `U-TRACTION-OUTPUT` alone dynamically writes `CCR1..4` and JSQR. Static peripheral/rank/trigger configuration belongs to `U-PLATFORM-BINDING`.

## Fast access, safety and calibration context

All active JEOS, output and software-fault access uses the same selected non-nested checked-token discipline. No raw/unchecked alias, nested token, token escape, NMI or HardFault use is permitted for these shared resources. The code must provide a compiler plus hardware completion barrier appropriate to the target; a recheck sequence around unsynchronised shared data is not a safe-Rust publication protocol and cannot replace ownership, atomic acquire/release or a critical section. TIM8 break and the independent hardware inhibit can withdraw permit without OS service, including while configurable IRQs are masked.

`StartupUnqualified` is not a recognised fault. A recognised runtime/recovery fault latches both torque signs inhibited for the operation generation; each direct `SensorHealthCondition` reaches the existing Session first-recognized-fault/report path without replacement by platform fast-safety state, while the independent Platform health/readiness path also remains an input to Session. Only a clean restart creating a fresh operation generation can clear it. Ordinary battery/SOC/temperature restrictions are constraints, not failures. On a fresh canonical immutable `CalibrationBundle`, `U-PLATFORM-CALIBRATION` keeps permit/MOE low, validates the applicable raw-acquisition/rank-trigger, current/phase, supply, Hall, accelerator, brake and temperature parameter families, rolls context, invalidates dependent records and atomically activates the bundle. Bundle ID/revision/context bind the parameters; they are not the parameter payload. `U-PLATFORM-BINDING` then applies static configuration under that active bundle. Acquisition restarts and consumers require new qualified records. A partial or live update is rejected.

## Deferred records and DMA lifetime

| Route | Owner and record | Stable delivery / failure rule |
|---|---|---|
| Regular ADC1 | `U-ANALOG-ACQ-REGULAR` → accelerator, brake, temperature, supply-regular and motor-phase-diagnostic interfaces | Each circular completed half has its own generation, completion timestamp and DMA status. ADC1 data are never paired by array position with ADC2. |
| Regular ADC2 | same | Independent sequence and timestamp; a consumer may use a named scan only after its own stability test. |
| Hall captures | `U-HALL-CAPTURE` → `U-HALL-POSITION` | Per-channel completed capture storage, sampled Hall-state association, extended timestamp and overflow/ambiguity status; position owns legal transition/map/direction/alignment acceptance. |

DMA can overwrite memory despite CPU interrupt masking. DMA interrupts perform bounded completion/error bookkeeping only. A consumer selects a completed half only after an `NDTR`/write-window snapshot proves the DMA writer is in the other half; it makes a bounded volatile/raw copy to CPU-owned storage, then verifies that the writer did not enter that half and that status remains clear. The required maximum IRQ/task blocking plus copy time is less than one half recurrence, preventing an undetectable whole-cycle overwrite; otherwise the sample is unavailable. Missed completion, window ambiguity, error, overrun or exhausted consumer capacity also invalidate it. An atomic index alone is insufficient. The active non-cacheable DMA region has no normal Rust mutable reference; its external writes and raw/volatile reads are encapsulated in the binding. A separately CPU-owned snapshot uses correctly synchronised atomic state/acquire-release publication (or a proved lock), never sequence rechecks on ordinary racing fields. There is no assumed current OS intercom endpoint, dynamic registration or DMA task wakeup.

## Required engineering evidence

Before implementation/energisation, measure and validate exact vector/priority ordering, cache/MPU and DMA half ownership, all rank/channel/trigger readback, ADC1/ADC2 regular timestamps, writer-window overwrite/error handling, Hall capture association and complete electrical-position behaviour, calibration activation invalidation, fast JEOS-to-latch WCET and independent inhibit response. The planned nominal regular scan target is 1 kHz; acceptance requires a selected/read-back trigger source, rate/jitter and rank mapping, stated buffer depth, maximum IRQ/task blocking and copy bound, freshness budget, and end-to-end accelerator/brake latency evidence. The separate nominal 10-ms consumer period is likewise not proof. Exact thresholds and every deadline margin remain values to establish.
