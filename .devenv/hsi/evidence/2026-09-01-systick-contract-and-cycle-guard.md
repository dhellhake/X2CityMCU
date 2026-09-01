# SysTick Contract And Cycle-Guard Target Evidence — 2026-09-01

## Scope

This record covers the `TimerArmResult` contract, 24-bit SysTick boundary
behavior, elapsed-time wrap accounting, OS immediate-rescan integration and the
4096-processor-cycle reprogramming guard on the powered FK743M2-IIT6 V1.1
target. It is verification evidence for `HSI-TIM-002`, `HSI-TIM-004` and
`HSI-TIM-005`; it is not a formal WCET proof or a production safety-release
qualification.

The diagnostic image initialized the production 480 MHz clock tree but did not
initialize UART, WWDG, ADC, PWM, motor-control or gate-driver outputs. DWT
`CYCCNT` supplied independent cycle timestamps. Test-only DTCM telemetry and
PendSV markers were removed after the campaign.

## Configuration

| Item | Value |
| --- | --- |
| MCU/probe | STM32H743IIT6 Cortex-M7 r1p1; Atmel-ICE CMSIS-DAP over SWD |
| Core/SysTick clock | 480 MHz processor clock |
| Guard | 4096 cycles = 8.533 us |
| Build | `thumbv7em-none-eabihf`, release optimization, caches disabled |
| Rust compiler | `rustc 1.96.0-nightly (ec818fda3 2026-03-02)`, LLVM 22.1.0 |
| Repository HEAD | `1169bd1f7495094dd6bc9dd6202caba4dc0fbf7d` plus the uncommitted contract changes identified below |
| Driver base | `5d6f5b5be2be16ef094c18a22809a6695b34d929` |
| OS base | `67d11f71601c3df31884bd49f00cdc86cdd5b516` |
| Diagnostic ELF SHA-256 | `21726B4AFFA0CAC65721BDB4D8506F4EAC0BA95F324B63C7B4E085041D6EC630` |
| Production debug ELF SHA-256 | `B6F21097926484B6735D6C759849EC22895F93698B97A58A3B8335A95A0A9517` |
| Production release ELF SHA-256 | `05F4E059879FDD6EC9239ED796CF8F9DCA005EB59DDF15B0937BA8AF9809FD3A` |

Production-source hashes after removal of diagnostic instrumentation:

| File | SHA-256 |
| --- | --- |
| `src/drv/systick/mod.rs` | `FD465C3CE51114210C16A6981BDFAB3A5DD731EBE9DBDD2D3269429C3B18CD7D` |
| `src/os/mod.rs` | `6ECEB4F1C0A15E44EE44EB91E358DF641DF75BCCD5A77B2ED70FCE53677542E8` |
| `src/mcu/mod.rs` | `B3E47CF56F16C73FF6151B978942C6C0A9ECBEF27D150EC981470ED2F7C2F780` |

## Campaign

Six complete campaigns were executed from independent resets. Each campaign
included:

- exact public-path arm checks at 0, 1, 4095, 4096, 4097, 16777216,
  16777217 and `u64::MAX` ticks using a 1 MHz conversion scale;
- 480 MHz public API checks at 0, 1, 8, 9, 1000, 34952 and 34953 us and
  `u64::MAX`;
- configuration, pause/resume, CSR-shadow/COUNTFLAG preservation and nested
  PRIMASK restoration checks;
- 100000 rapid live captures plus a DWT phase sweep over the CVR/CSR/CVR zero
  crossing;
- a 100 ms absolute deadline requiring maximum-length intermediate chunks;
- 250000 samples for each direct/shared armed and immediate driver path;
- 100000 samples for each normal and immediate scheduler path;
- one stale-timestamp software-pended SysTick integration test;
- 100000 exact-4096-cycle arm-to-PendSV tests; and
- five seconds of natural 5 ms/10 ms task releases, producing 2495 measured
  PendSV and post-arm chains per campaign.

This totals 504 passed top-level checks, 600000 exact-boundary context switches,
14970 natural context switches, 686604 classified live capture windows and
millions of driver/scheduler timing samples. No top-level check failed.

## Results

### Functional contract

| Observation | Result |
| --- | ---: |
| Zero reload values observed | 0 |
| Exact/public boundary mismatches | 0 |
| Immediate-rescan integration failures | 0 |
| Non-monotonic elapsed captures | 0 |
| Post-CSR wrap clear/double-count failures | 0 |
| Exact 4096-cycle expiries before interrupt readiness | 0 / 600000 |
| Long-deadline chunk/release failures | 0 |

Each campaign classified 8397 wraps already visible through COUNTFLAG, 149
wraps occurring after the first CSR sample and 105888 no-wrap captures. The
post-CSR cases exercised the second CSR read that prevents the same wrap from
being counted by the following capture.

### Cycle measurements

All values below are raw DWT deltas; the back-to-back timestamp overhead was
not subtracted. Its observed maximum was 14 cycles.

| Path | Observed maximum cycles |
| --- | ---: |
| Direct `SetTimerAt`, long/armed | 1952 |
| Direct `SetTimerAt`, immediate | 578 |
| `Shared<Systick>` long/armed | 1968 |
| `Shared<Systick>` immediate | 599 |
| Scheduler normal arm | 1643 |
| Scheduler immediate-rescan arm | 1650 |
| Stale-time scan through software-pended handler return | 1760 |
| PendSV masked window, synchronized exact-boundary campaign | 638 |
| PendSV masked window, natural scheduling | 646 |
| Final SysTick-enable point through PendSV interrupt readiness | **794** |

The acceptance path is the final row: the guard is evaluated when
`SetTimerAt` takes its fresh timer snapshot, so work before the final enable
operation does not consume the newly armed interval. The broad handler-entry
through PendSV chain reached 4684 cycles, of which 3890 occurred before that
post-arm interval. The 794-cycle maximum uses 19.4% of the 4096-cycle guard and
leaves 3302 cycles, or 6.879 us at 480 MHz. At the exact boundary, the minimum
CVR observed at interrupt readiness was 3425 ticks.

Five retained result blocks are in the local ignored `target/hw-test`
directory. Their SHA-256 values are:

| Result | SHA-256 |
| --- | --- |
| `run2-results.bin` | `E5B915D6A978663F2BDC922D605F6E09D2217A988219B928A34050D7A7E1453F` |
| `run3-results.bin` | `03E984DC7A432AA0AEB0CF14E304B68DDC40B18E095E453B565089F9B7238718` |
| `run4-results.bin` | `E5B915D6A978663F2BDC922D605F6E09D2217A988219B928A34050D7A7E1453F` |
| `run5-results.bin` | `E5B915D6A978663F2BDC922D605F6E09D2217A988219B928A34050D7A7E1453F` |
| `run6-results.bin` | `4CC7A30C617B8D1E9D87908BF1BB12FA7941E5EDC5C27E40EE4EF7EC0F253175` |

## Production-Image Soak

After removing all diagnostic instrumentation, both ordinary images were
programmed and verified through OpenOCD. The debug image ran for five seconds
and the release image for 30 seconds with the production scheduler and WWDG1
enabled. In both cases:

- `RCC_RSR.WWDG1RSTF` and `RCC_RSR.SFTRSTF` remained clear;
- execution was in thread mode on PSP with `PRIMASK = 0`;
- WWDG1 remained enabled with configuration register `0x00001861`;
- SysTick CSR control bits remained `0b111`; and
- SCB ICSR showed no pending SysTick or PendSV at the inspection halt.

The final release image was resumed after inspection and left running on the
target.

## Limitations And Revalidation Triggers

- The current application configures no higher-priority external interrupt
  load. Future PWM, ADC, communication or motor-control ISRs require response-
  time analysis and a repeat campaign under their maximum intended load.
- Measured maxima are evidence, not a static WCET bound. Compiler, linker,
  optimization, memory placement, cache/predictor, clock, task count, stack
  checks, scheduler control flow and exception-priority changes invalidate the
  numeric margin until reverified.
- The measurement image included test-only DTCM stores and branches. The
  post-arm timestamp was placed before those stores, so the reported bound is
  conservative for the tested production path, but instrumentation can still
  perturb Flash layout and pipeline state.
- SysTick intentionally pauses during reprogramming. This campaign establishes
  monotonic accounting and the guard margin; it does not close the independent
  wall-clock drift/plausibility item in `HSI-TIM-004`.
