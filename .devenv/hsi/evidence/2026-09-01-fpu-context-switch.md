# Eager FPU Context-Switch Target Evidence — 2026-09-01

## Scope

This record covers compile-time Cortex-M context-port selection, eager
floating-point stacking, task-local `EXC_RETURN`, preservation of `s0-s31` and
`FPSCR`, and the effect of the larger context on the 4096-cycle SysTick guard.
It supplements the exact-boundary SysTick campaign; it does not repeat that
campaign's synchronized 4096-tick expiry test.

All diagnostic task and timing instrumentation was removed after measurement.
The ordinary debug and release images were rebuilt from production sources,
and the final release image was programmed and verified separately.

## Configuration

| Item | Value |
| --- | --- |
| MCU/probe | STM32H743IIT6 Cortex-M7 r1p1; Atmel-ICE CMSIS-DAP over SWD |
| Core clock | 480 MHz, caches disabled |
| Build | `thumbv7em-none-eabihf`, release optimization |
| Rust compiler | `rustc 1.96.0-nightly (ec818fda3 2026-03-02)`, LLVM 22.1.0 |
| FP policy | `FPCCR.ASPEN=1`, `FPCCR.LSPEN=0` |
| Guard | 4096 processor cycles = 8.533 us |

The diagnostic used a long-running FP task and a short 1 ms task. The long
task alternated two patterns in all 32 FP registers and `FPSCR`. On alternating
releases, the short task either remained integer-only or loaded a third FP
pattern. The long task snapshot and comparison after every resume therefore
exercised initial basic frames, extended-to-basic, basic-to-extended,
extended-to-extended, and finished-FP-task reset back to a basic frame.

## Build And Static Port Selection

The following complete application builds passed:

- debug and release `thumbv7em-none-eabihf` for Cortex-M7;
- release `thumbv7em-none-eabi` for Cortex-M7 with
  `target-feature=-fpregs`; and
- release `thumbv6m-none-eabi` for Cortex-M0.

Disassembly showed the hard-float PendSV testing `EXC_RETURN[4]` and containing
only the intended `vstmdb/vldmia {s16-s31}` context operations. The soft-EABI
Cortex-M7 and Cortex-M0 images contained no FP instructions. The ARMv6-M image
also established that the basic context port remains Thumb-1 compatible.

## FP Preservation Campaign

| Observation | Result |
| --- | ---: |
| Required verified resumes | 100000 |
| Integer short-task transitions by completion | 50000 |
| FP short-task transitions by completion | 50000 |
| Registers compared per resume | `s0-s31` plus `FPSCR` |
| Register/FPSCR mismatches | 0 |
| `FPCCR` at inspection | `0x80000000` |
| `CFSR`, `HFSR`, `SHCSR` | all zero |

The first retained 184-byte telemetry block was captured after the target had
continued beyond the acceptance count. It contains 100000 completed checks,
54901 integer and 54901 FP short-task executions, zero failures and `done=1`.

| Artifact | SHA-256 |
| --- | --- |
| `target/hw-test/fp-context-results.bin` | `5AB998C1C1508933F7C4F38A04CC0000F3D75A04B2F4B25B39836CA0AC716CA8` |
| FP stress ELF | `341F54FF80E2032569CE8379819E9D9C37EF694A5C713CFDAE7EDF8E9FB0BFA0` |
| FP stress task source | `D9891630B8ED5C2A3FA94C77B99CF0AD94828C963CFCE28D025A17DAD2C26582` |

## Cycle-Guard Measurements

The DWT cycle counter was sampled immediately before the final SysTick-enable
write and near the end of PendSV, before restoring `PRIMASK`. The reported
interval is conservative because it includes test-only transition
classification before the end sample. Counts and maxima are raw DWT deltas.

| Transition | Samples | Maximum cycles | Guard margin |
| --- | ---: | ---: | ---: |
| Basic to basic, production tasks/watchdog | 52367 | 784 | 3312 |
| Basic to basic, mixed-frame startup | 1 | 677 | 3419 |
| Basic to extended FP | 55388 | 809 | 3287 |
| Extended FP to basic | 110776 | 725 | 3371 |
| Extended FP to extended FP | 55388 | 801 | 3295 |

No measured transition equalled or exceeded 4096 cycles. The worst observed
path used 19.8% of the guard and left 3287 cycles, or approximately 6.85 us at
480 MHz. The mixed-frame run also repeated the 100000 FP comparisons with zero
failures and ended with `FPCCR=0x80000000` and clear fault registers.

| Artifact | SHA-256 |
| --- | --- |
| `target/hw-test/fp-cycle-guard-results.bin` | `1ED34DFC4408A2C09153C65271D9769FE68763009AC38CE656D6377158A9A87C` |
| `target/hw-test/basic-cycle-guard-results.bin` | `A1FAED245304C7C1904BBDAE084D0C7C115E11DDD17CFC314878FC814BF1591B` |
| Instrumented production ELF | `8544A91EAD0CB2FEBDBDC66CDB03319BF506C54974D659B5334463517195A63D` |
| Final uninstrumented release ELF | `E8C2DDE01521FA31C4A9A505C4DF740E2054E228E933B9C40AEA33A1B4B22B7F` |

## Final Production-Image Soak

The final uninstrumented release image was programmed and verified, then run
for 25 seconds with the normal tasks, program-flow monitor and WWDG1 enabled.
At the inspection halt:

- `FPCCR=0x80000000` and `CPACR=0x00F00000`;
- WWDG1 was active with `CFR=0x00001861`;
- SysTick control bits were `0b111` and SCB ICSR had no pending exception;
- `SHCSR`, `CFSR` and `HFSR` were zero; and
- execution was in Thread mode on PSP with `CONTROL=0x2` and `PRIMASK=0`.

The image was resumed after inspection and left running on the target.

## Limitations And Revalidation Triggers

- These measurements are empirical evidence, not a static WCET proof.
- The mixed-frame test intentionally disabled WWDG/PFM; the basic-frame
  production campaign restored both mechanisms.
- The exact 4096-tick synchronized-expiry campaign was not rerun. Its earlier
  600000-switch evidence remains recorded separately, while this campaign
  specifically bounds the changed context-switch paths.
- After measurement, direct background activation was corrected to start PSP
  at the stack top instead of the unused synthetic-frame base. This changes
  the initial PSP value but not the PendSV instruction stream, frame size,
  memory region or measured post-arm path. The rebuilt final image was checked
  by disassembly and by the production-image soak above.
- The raw result blocks are in the local ignored `target/hw-test` directory;
  their hashes make accidental changes detectable but do not replace a
  controlled release-evidence archive.
- Compiler, linker, optimization, clock/cache state, interrupt load, task
  count, stack policy, scheduler or context-assembly changes that can affect
  the measured post-arm path or frame timing require another measurement
  campaign.
