# FK743M2-IIT6 V1.1 Hardware/Software Interface Specification

This document specifies the hardware/software interface (HSI) and records the
MCU configuration performed by the current firmware on an FK743M2-IIT6 V1.1
board populated with an STM32H743IIT6 in the LQFP176 package.

Physical board information is maintained separately and is part of the
controlled configuration set:

- [FK743M2-IIT6 V1.1 board profile](../STM32H743IIT6/FK743M2-IIT6-V1.1-board.md)
- [FK743M2-IIT6 V1.1 connector reference](../STM32H743IIT6/FK743M2-IIT6-V1.1-connectors.md)

Those documents are the single source of truth for fitted parts, fixed PCB
nets and physical board connectors.

| Document attribute | Value |
| --- | --- |
| Document ID | `X2C-HSI-001` |
| Lifecycle status | Draft; not released for a safety-related production item |
| Configuration item | This Git-controlled Markdown file, its board-profile companions and referenced implementation files |
| Applicable safety-process baseline | ISO 26262:2018 Parts 4, 6 and 8 |
| Item-level ASIL allocation | `TBD` by the hazard analysis and risk assessment |
| Parent technical/software safety requirements | `TBD` by the technical safety concept and software safety requirements specification |
| Intended owner | MCU software integration |

The requirement structure is intended to support an ISO 26262 safety lifecycle,
but this document alone does not establish ISO 26262 compliance. Item definition,
HARA, ASIL allocation, parent-requirement traceability, confirmation measures,
tool confidence, independence arguments, production release and the safety case
remain outside this document until supplied by the applicable safety plan.

The requirement tables are normative. The later configuration and memory
sections are informative design description and implementation evidence. If the
two conflict, the conflict shall be resolved through change control before a
safety release; the requirement shall not silently be weakened to match the code.

The following terms are used throughout the document:

- **Configured** means that the current firmware writes the relevant MCU
  registers during startup.
- **Reset state** means that the firmware does not intentionally configure the
  pin after reset.

For normative statements, **shall** denotes a mandatory requirement, **should**
denotes a recommendation requiring justification if not followed, and **may**
denotes permission. Unless a row states otherwise, every requirement has the
ASIL and parent traceability shown as `TBD` in the document attributes. These
attributes shall be resolved before a safety release.

### Requirement Status

The status is informative and is not a verification verdict:

- **Implemented**: matching implementation was found by source inspection.
- **Partial**: part of the requirement is implemented, but an implementation or
  verification obligation remains open.
- **Open**: the required behavior or safety evidence was not found.
- **Assumption**: satisfaction depends on board, system or external-component
  evidence outside this repository.

Verification method codes are:

| Code | Verification method |
| --- | --- |
| `I` | Inspection of source, linker output, schematic, pin continuity or configuration records |
| `A` | Analysis or calculation against the controlled MCU/board specification |
| `T-SW` | Host/unit/software-integration test with recorded expected and actual results |
| `T-HW` | Test on the specified target board with recorded equipment and results |
| `T-FI` | Fault-injection test demonstrating the specified detection and reaction |

## Normative HSI Requirements

### Scope And Configuration Control

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-GEN-001` | The software shall execute only on an FK743M2-IIT6 V1.1 board populated with an STM32H743IIT6 in the LQFP176 package unless a controlled HSI variant is released. | System integration | `I`, `T-HW` | Assumption; board identity must be recorded for each test or release unit. |
| `HSI-GEN-002` | The linker memory map, startup code and peripheral base addresses shall match the STM32H743IIT6 memory and peripheral map. | Linker, startup, generic drivers | `I`, `A` | Implemented in [`memory.x`](../../memory.x), [`src/drv/startup`](../../src/drv/startup) and the drivers. |
| `HSI-GEN-003` | All required MCU hardware initialization shall complete before the scheduler can execute an application task. | `main`, `McuManager` | `I`, `T-SW` | Implemented by the startup order in [`src/main.rs`](../../src/main.rs). |
| `HSI-GEN-004` | Project-specific board and use-case configuration shall reside in `src/mcu`; reusable register-level access shall reside in the `src/drv` submodule. | Software architecture | `I` | Implemented by [`src/mcu/peripherals`](../../src/mcu/peripherals) and [`src/drv`](../../src/drv). |
| `HSI-GEN-005` | A peripheral not explicitly identified as configured by this HSI shall not be enabled or used by application software. | MCU software | `I`, `T-SW` | Implemented by inspection; listed under [Intentionally Unconfigured Hardware](#intentionally-unconfigured-hardware). |
| `HSI-GEN-006` | Failure to establish a required hardware configuration shall prevent execution of safety-relevant application functions and shall cause the allocated safe reaction within the item FTTI. | Startup and system safety mechanism | `T-FI`, `T-HW` | Open; several pre-watchdog readiness waits and assertion paths can wait indefinitely. Safe reaction and FTTI are `TBD`. |
| `HSI-GEN-007` | A change to target part, FK743M2 board revision, clock, memory allocation, peripheral configuration or pin assignment shall update the owning controlled document, its parent traces and affected verification before release. | Configuration/change management | `I` | Partial; the documents are version controlled, but parent traces and release workflow are `TBD`. |
| `HSI-GEN-008` | Safety-relevant hardware configuration values shall be represented by named constants or typed values and shall not be modified during normal operation except by an approved safety mechanism. | MCU software | `I`, `T-SW` | Partial; typed driver values and project constants exist, but a formal write-protection and call-graph verification record is absent. |

### Reset, Core And Internal Memory

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-STA-001` | Reset startup shall mask configurable interrupts before modifying TCM state or runtime memory. | Reset handler | `I`, `T-HW` | Implemented by `cpsid i` in [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs). |
| `HSI-STA-002` | Startup shall enable the 64 KiB ITCM and 128 KiB DTCM and execute data/instruction synchronization barriers before either TCM is used. | Reset handler, Cortex-M7 core | `I`, `T-HW` | Implemented in [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs). |
| `HSI-STA-003` | Startup shall grant full access to floating-point coprocessors CP10 and CP11, followed by synchronization barriers, before any hard-float Rust code can execute. | Reset handler, Cortex-M7 core | `I`, `T-HW` | Implemented in [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs). |
| `HSI-STA-004` | Startup shall copy initialized ordinary data from its Flash load image to AXI SRAM and zero ordinary BSS before `main`. | Reset handler, linker | `I`, `T-HW` | Implemented by `.data` and `.bss` relocation. |
| `HSI-STA-005` | Startup shall copy selected initialized DTCM data, zero selected DTCM BSS and complete both operations before accessing the relocated objects. | Reset handler, linker | `I`, `T-HW` | Implemented by `.dtcm_data` and `.dtcm_bss` relocation. |
| `HSI-STA-006` | Startup shall copy `.itcm_text` from Flash to ITCM and execute synchronization barriers before calling relocated code. | Reset handler, linker | `I`, `T-HW` | Implemented in [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs). |
| `HSI-STA-007` | The linker shall reject an image whose `.itcm_text` exceeds the 64 KiB ITCM range. | Linker | `I`, `T-SW` | Implemented by the ITCM linker assertion in [`memory.x`](../../memory.x). |
| `HSI-STA-008` | The linker shall reject an image whose DTCM allocations overlap the reserved main stack or exceed the 128 KiB DTCM range. | Linker | `I`, `T-SW` | Implemented by the DTCM linker assertions in [`memory.x`](../../memory.x). |
| `HSI-STA-009` | The complete interrupt vector table shall be copied from Flash to a 1024-byte-aligned DTCM allocation, and `SCB.VTOR` shall reference that copy before interrupts are unmasked. | Reset handler, SCB, linker | `I`, `T-HW` | Implemented in [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs) and [`memory.x`](../../memory.x). |
| `HSI-STA-010` | Startup shall unmask interrupts only after all runtime memory relocation, zeroing and vector-table redirection are complete. | Reset handler | `I`, `T-HW` | Implemented by `cpsie i` immediately before `main`. |
| `HSI-STA-011` | The linker shall reserve a non-overlapping 4 KiB, 8-byte-aligned main stack at the top of DTCM and shall place its end in the initial vector-table stack entry. | Linker, reset vector | `I`, `T-SW` | Implemented in [`memory.x`](../../memory.x). |
| `HSI-STA-012` | Each configured OS task shall have a 1024-byte stack in DTCM, and the configured task count shall not exceed the statically allocated task array. | OS, linker | `I`, `T-SW` | Implemented for three tasks by `STACK_SIZE = 256` words and the DTCM OS object. Stack-depth evidence remains open. |
| `HSI-STA-013` | Thread mode shall use the process stack pointer in privileged mode before the background task is entered. | `main`, Cortex-M7 core | `I`, `T-HW` | Implemented by the `PSP` and `CONTROL=0x2` writes in [`src/main.rs`](../../src/main.rs). |
| `HSI-STA-014` | A processor exception or panic shall invoke the allocated safe reaction and shall not leave outputs in an unidentified state beyond the item FTTI. | Exception handlers, system safety mechanism | `T-FI`, `T-HW` | Partial; handlers stop in a loop and WWDG1 can reset only after it has started. Pre-watchdog reaction, output state and FTTI are `TBD`. |
| `HSI-MEM-001` | Ordinary initialized and zero-initialized objects not explicitly selected for DTCM shall be allocated in the 512 KiB AXI SRAM range `0x2400_0000..0x2408_0000`. | Linker | `I`, `T-SW` | Implemented by `.data` and `.bss` placement and an AXI SRAM bounds assertion. |
| `HSI-MEM-002` | D2 SRAM, D3 SRAM and backup SRAM shall remain unallocated until startup initialization, ownership and diagnostic requirements are defined for them. | Linker, MCU software | `I` | Implemented; only region symbols are currently exposed by [`memory.x`](../../memory.x). |
| `HSI-MEM-003` | External SDRAM shall not be linked, dereferenced or exposed to application software until FMC pin setup, SDRAM timing, JEDEC initialization and a startup memory test have completed successfully. | FMC configuration, linker, system integration | `I`, `T-HW`, `T-FI` | Implemented as a prohibition; SDRAM is absent from [`memory.x`](../../memory.x). FMC initialization and test are not implemented. |
| `HSI-MEM-004` | Instruction cache, data cache or MPU use shall require a controlled memory-attribute configuration and analysis of coherency, DMA and safety mechanisms before enablement. | Cortex-M7 core configuration | `I`, `A`, `T-HW` | Implemented as a prohibition; cache and MPU enablement is absent. Future configuration remains open. |
| `HSI-MEM-005` | The safety analysis shall define startup and runtime diagnostics for internal SRAM, ECC faults, stack overflow and memory corruption according to the allocated ASIL and FTTI. | Safety concept, MCU software | `A`, `T-FI` | Open; no complete RAM/ECC/stack diagnostic concept is implemented. |

### Power, Flash And Clock Tree

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-CLK-001` | Startup shall select the internal LDO supply by setting `PWR_CR3.LDOEN=1`, `BYPASS=0` and `SCUEN=0`, and shall wait for the applicable supply-ready indication. | PWR | `I`, `T-HW` | Implemented by [`ConfigureLdoSupply`](../../src/mcu/peripherals/pwr.rs). |
| `HSI-CLK-002` | Before selecting a 480 MHz CPU clock, startup shall select voltage scale 1, wait for readiness, enable SYSCFG overdrive to voltage scale 0, and wait for voltage readiness. | PWR, SYSCFG | `I`, `T-HW` | Implemented by [`ConfigureVoltageScale0For480Mhz`](../../src/mcu/peripherals/pwr.rs). |
| `HSI-CLK-003` | The system clock source shall be the FK743M2-IIT6 V1.1 board's 25 MHz HSE crystal on PH0/PH1 in crystal mode with HSE bypass disabled. | Board oscillator, RCC | `I`, `A`, `T-HW` | Implemented by [`src/mcu/peripherals/rcc.rs`](../../src/mcu/peripherals/rcc.rs); the physical source is specified by the [board profile](../STM32H743IIT6/FK743M2-IIT6-V1.1-board.md). |
| `HSI-CLK-004` | PLL1 shall use HSE with `DIVM1=5`, `DIVN1=192`, `DIVP1=2`, wide VCO, 4-to-8-MHz input range and fractional mode disabled. PLL1P shall be enabled; PLL1Q and PLL1R shall remain disabled. | RCC PLL1 | `I`, `A`, `T-HW` | Implemented by [`ConfigurePll1Hse25MhzTo480Mhz`](../../src/mcu/peripherals/rcc.rs). |
| `HSI-CLK-005` | Startup shall wait for HSE and PLL1 readiness and shall confirm that the system-clock status selects PLL1 before continuing. | RCC | `I`, `T-FI`, `T-HW` | Implemented with blocking ready/status waits. The waits are not time bounded. |
| `HSI-CLK-006` | `D1CPRE` shall divide SYSCLK by 1, `HPRE` shall divide SYSCLK by 2, and each APB prescaler shall divide HCLK by 2. | RCC bus clocks | `I`, `A`, `T-HW` | Implemented by [`SetBusPrescalersFor480Mhz`](../../src/mcu/peripherals/rcc.rs). |
| `HSI-CLK-007` | The configured clock tree shall produce a 480 MHz CPU clock, 240 MHz HCLK/AXI clock and 120 MHz PCLK1, PCLK2, PCLK3 and PCLK4 from a 25 MHz HSE. | RCC | `A`, `T-HW` | Implemented; calculations are recorded under [Resulting Clock Domains](#resulting-clock-domains). |
| `HSI-CLK-008` | Before switching SYSCLK to PLL1, the Flash interface shall be configured for at least four wait states at the configured voltage and clock. | Flash, startup sequence | `I`, `A`, `T-HW` | Implemented by [`ConfigureFor480Mhz`](../../src/mcu/peripherals/flash.rs), called before the PLL1 switch. |
| `HSI-CLK-009` | Before switching SYSCLK to PLL1, `FLASH_ACR.WRHIGHFREQ` shall be set to the value required by the controlled STM32H743II datasheet/reference-manual revision for voltage scale 0 and a 240 MHz AXI clock. | Flash | `I`, `A`, `T-HW` | Open; the driver supports the field, but project configuration changes only `LATENCY`. |
| `HSI-CLK-010` | The software shall not claim or use a 48 MHz USB kernel clock while PLL1Q is disabled and no alternative 48 MHz source is configured. | RCC, USB software | `I` | Implemented; USB is intentionally unconfigured. |
| `HSI-CLK-011` | Loss or out-of-tolerance operation of a safety-relevant system clock shall be detected and shall cause the allocated safe reaction within the item FTTI. | RCC clock security or independent monitor | `T-FI`, `T-HW` | Open; HSE clock security and an independent runtime clock monitor are not enabled. |
| `HSI-CLK-012` | Safety-relevant clock, power and Flash configuration registers shall be read back or independently checked before supervised operation begins. | MCU initialization diagnostics | `I`, `T-FI`, `T-HW` | Partial; readiness/status bits are checked, but there is no complete expected-register readback. |

### Scheduler Timing, Program Flow And Watchdog

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-TIM-001` | SysTick shall use the processor clock and shall be configured with `SYSTICK_CLOCK_HZ = 480_000_000`. | SysTick, OS | `I`, `A`, `T-HW` | Implemented in [`src/main.rs`](../../src/main.rs) and [`src/drv/systick`](../../src/drv/systick). |
| `HSI-TIM-002` | Every programmed SysTick interval shall fit the 24-bit reload field; longer intervals shall be represented without truncating the requested deadline. | SysTick driver | `I`, `T-SW` | Implemented by bounded deadline arming in [`src/drv/systick`](../../src/drv/systick). |
| `HSI-TIM-003` | The first scheduler deadline shall be armed for 1000 us after the program-flow epoch. | MCU manager, SysTick | `I`, `T-HW` | Implemented by `INITIAL_SCHEDULER_WAKEUP_US`. |
| `HSI-TIM-004` | The scheduler and program-flow monitor shall use the same monotonic microsecond time base. | SysTick, OS, PFM | `I`, `T-SW` | Implemented through `Systick::GetElapsedMicroseconds`. Independent timing plausibility evidence is open. |
| `HSI-WDG-001` | WWDG1 shall be clocked from PCLK3 at 120 MHz and configured with divider 32768, reload counter `0x7F`, window counter `0x61` and early-wakeup interrupt disabled. | RCC, WWDG1 | `I`, `A`, `T-HW` | Implemented by [`src/mcu/peripherals/wwdg.rs`](../../src/mcu/peripherals/wwdg.rs). |
| `HSI-WDG-002` | The WWDG1 configuration shall provide an approximate hardware window opening at 8.2 ms and reset timeout at 17.5 ms after each reload. | WWDG1 | `A`, `T-HW` | Implemented by the values in `HSI-WDG-001`; tolerance analysis against PCLK3 accuracy is open. |
| `HSI-WDG-003` | WWDG1 start and the first SysTick deadline shall be performed in one interrupt-masked critical section using program-flow epoch 0. | MCU manager | `I`, `T-HW` | Implemented by [`ProgramFlowSupervision_Start`](../../src/mcu/mod.rs). |
| `HSI-WDG-004` | Exactly one 10 ms unsupervised PFM task shall be configured, and it shall execute after all supervised tasks released at the same deadline. | OS task configuration, PFM | `I`, `T-SW` | Implemented and checked by [`ProgramFlowMonitor::ConfigureFromTasks`](../../src/mcu/program_flow.rs). |
| `HSI-WDG-005` | Each task with role `Supervised` and a cyclic period shall report ordered start/end checkpoints for every release in the 10 ms supervision cycle. Background and unsupervised tasks shall not falsely contribute checkpoints. | OS, PFM | `I`, `T-SW`, `T-FI` | Implemented in [`src/os`](../../src/os) and [`src/mcu/program_flow.rs`](../../src/mcu/program_flow.rs). |
| `HSI-WDG-006` | Before each watchdog service, the PFM shall validate all expected checkpoints for omission, duplication, order, completion and configured timing limits. | PFM | `I`, `T-SW`, `T-FI` | Implemented by `ValidateAndServiceWatchdog`. |
| `HSI-WDG-007` | The PFM shall authorize and perform WWDG1 service only between 8500 us and 15500 us relative to the current supervision-cycle start. | PFM, WWDG1 | `I`, `A`, `T-HW` | Implemented by `WATCHDOG_SERVICE_MIN_US` and `WATCHDOG_SERVICE_MAX_US`. |
| `HSI-WDG-008` | No application task or periodic path other than the PFM validation path shall service WWDG1. | Software architecture | `I`, `T-SW` | Implemented; WWDG1 ownership is private to [`src/mcu/mod.rs`](../../src/mcu/mod.rs), and the only refresh call is in PFM. |
| `HSI-WDG-009` | Detection of invalid flow, invalid PFM state, missing checkpoints or a missed software service interval shall latch a diagnostic fault and inhibit all subsequent watchdog service until reset. | PFM | `I`, `T-FI`, `T-HW` | Implemented by the latched `Faulted` state. Formal fault-injection evidence is open. |
| `HSI-WDG-010` | WWDG1 shall be started only after required MCU, communication, OS, component and PFM initialization has completed successfully, and before any safety-relevant cyclic application task executes. | Startup, MCU manager | `I`, `T-HW` | Implemented by the order in [`src/main.rs`](../../src/main.rs). Completeness criteria for safety initialization are `TBD`. |
| `HSI-WDG-011` | After WWDG1 is started, normal software shall neither disable it nor alter its divider, reload, window or fault reaction. | WWDG1 ownership, MCU software | `I`, `T-SW` | Partial; no normal reconfiguration call exists and hardware cannot be stopped without reset, but formal freedom-from-interference evidence is absent. |
| `HSI-WDG-012` | The worst-case interval from a monitored fault to watchdog reset or other safe reaction shall not exceed the item FTTI under all specified oscillator, scheduling and execution-time tolerances. | System safety analysis | `A`, `T-FI`, `T-HW` | Open; the nominal watchdog timing is defined, but item FTTI and tolerance/WCET evidence are `TBD`. |
| `HSI-WDG-013` | Startup stalls occurring before WWDG1 activation shall be covered by an independent startup supervision mechanism or by starting an appropriate watchdog early enough to meet the item FTTI. | System safety mechanism | `A`, `T-FI`, `T-HW` | Open; no early startup watchdog or bounded startup timeout is implemented. |

### UART, GPIO And External Electrical Interfaces

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-UAR-001` | USART1 shall use asynchronous 8N1, LSB-first, non-inverted signaling, oversampling by 16, prescaler 1, enabled transmit/receive and enabled FIFO mode. | USART1 | `I`, `T-HW` | Implemented by [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs). |
| `HSI-UAR-002` | USART1 shall use a 120 MHz PCLK2 kernel clock, 115200 baud, PA9/AF7 as push-pull TX and PA10/AF7 with pull-up as RX. | RCC, GPIOA, USART1 | `I`, `A`, `T-HW` | Implemented; PA9 and PA10 are routed to P1 as defined by the [connector reference](../STM32H743IIT6/FK743M2-IIT6-V1.1-connectors.md#p1-debug-uart-and-power-header). |
| `HSI-UAR-005` | UART initialization shall enable only the required GPIOA and USART1 peripheral clocks. | RCC | `I` | Implemented by [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs). |
| `HSI-UAR-006` | USART1 communication shall remain polled with DMA, hardware flow control and USART interrupts disabled until an approved HSI change allocates and verifies those resources. | USART1, NVIC, DMA | `I` | Implemented as the current configuration. |
| `HSI-UAR-007` | A communication channel allocated a safety requirement shall detect UART framing, noise, overrun and parity indications, clear them deterministically and communicate invalidity to its consumer. | USART driver, component | `I`, `T-SW`, `T-FI` | Open; USART1 has no allocated safety requirement and its project wrapper does not expose error status. |
| `HSI-UAR-009` | Equipment connected to GPIO through an FK743M2-IIT6 V1.1 board header shall satisfy STM32H743II input/output voltage limits, share a defined ground reference and shall not back-power an unpowered participant. | FK743M2 board-header integration | `I`, `A`, `T-HW` | Assumption; equipment attached to the board headers is not controlled by firmware. |
| `HSI-LED-001` | PH7 shall be configured as an active-low, low-speed push-pull GPIO output without an internal pull. Its output latch shall be set high before output mode is selected. | RCC, GPIOH, heartbeat output | `I`, `T-HW` | Implemented by [`src/mcu/boardled/mod.rs`](../../src/mcu/boardled/mod.rs); the [board profile](../STM32H743IIT6/FK743M2-IIT6-V1.1-board.md) maps PH7 to the user LED. |
| `HSI-LED-002` | The supervised 5 ms task shall drive a one-second heartbeat consisting of 100 ms on, 100 ms off, 100 ms on and 700 ms off using its scheduled timestamp. | Scheduler, 5 ms task, heartbeat output | `I`, `T-SW`, `T-HW` | Implemented by [`src/mcu/boardled/mod.rs`](../../src/mcu/boardled/mod.rs) and [`src/mcu/deployment/mod.rs`](../../src/mcu/deployment/mod.rs); task-aligned edge assertions are evaluated at compile time. |
| `HSI-LED-003` | The heartbeat shall be treated as a scheduler-activity indication only and shall not replace program-flow monitoring or the hardware watchdog. | System diagnostics | `I`, `A` | Implemented architecturally; WWDG1 remains the independent scheduler supervision reaction. |
| `HSI-DBG-001` | Development debug shall use the MCU SWD interface on PA13/SWDIO, PA14/SWCLK and NRST through board header P1; four-wire JTAG operation shall not be assumed. | Board P1, MCU debug interface, debugger configuration | `I`, `T-HW` | Implemented; target reference, ground and SWD routing are defined by the [connector reference](../STM32H743IIT6/FK743M2-IIT6-V1.1-connectors.md#p1-debug-uart-and-power-header). |
| `HSI-DBG-002` | Safety-relevant operation on the FK743M2-IIT6 V1.1 board shall not depend on an attached debugger, and production debug access shall follow the item safety and security concept. | Board and system integration | `I`, `T-HW` | Partial; standalone execution works, but the production debug-access policy is `TBD`. |

### Pin Ownership

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-PIN-007` | Pins without an allocated software function shall remain in their documented reset state unless an approved pin-safety analysis specifies a deterministic alternative. | GPIO | `I`, `A`, `T-HW` | Implemented by absence of writes; pin-level safety analysis is open. |
| `HSI-PIN-008` | Shared or multiply connected board pins shall have one declared owner at a time, and software shall prevent conflicting peripheral functions from being enabled concurrently. | MCU software architecture | `I`, `T-SW` | Partial; current configuration has no active conflict, but no generic ownership enforcement exists. |

Board-connected pin constraints are normative in the
[board profile](../STM32H743IIT6/FK743M2-IIT6-V1.1-board.md), with physical
routes recorded in the
[connector reference](../STM32H743IIT6/FK743M2-IIT6-V1.1-connectors.md).

### Verification And Safety Release

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-VER-001` | A release build shall fail when Flash, ITCM, DTCM, AXI SRAM or reserved-stack bounds in `memory.x` are exceeded. | Linker/build system | `T-SW` | Implemented for ITCM, DTCM, AXI SRAM and main-stack relations; Flash overflow is enforced by linker region size. |
| `HSI-VER-002` | Each safety release shall archive a linker map demonstrating the address and size of the vector table, `.itcm_text`, DTCM objects, each task stack, main stack, `.data` and `.bss`. | Build/configuration management | `I` | Open; linker placement is inspectable, but no release evidence archive is defined. |
| `HSI-VER-003` | Target verification shall demonstrate 480 MHz CPU timing and the derived bus clocks using an independent measurement or a traceable timing test. | Verification | `A`, `T-HW` | Partial; a prior manual measurement confirmed the derived clock, but the test code and formal record are not retained. The historical setup is recorded in the [board profile](../STM32H743IIT6/FK743M2-IIT6-V1.1-board.md#historical-board-verification). |
| `HSI-VER-004` | Target verification shall demonstrate execution inside and outside ITCM, valid DTCM data/stack use, vector-table relocation and correct interrupt dispatch after relocation. | Verification | `T-HW` | Partial; development smoke tests were performed, but a controlled verification report is absent. |
| `HSI-VER-005` | Target verification shall exercise nominal, early, late, missing, duplicate, out-of-sequence and internally corrupted PFM/watchdog cases and record the resulting diagnostic and reset timing. | Verification | `T-FI`, `T-HW` | Open; implementation exists, but complete recorded fault-injection evidence is absent. |
| `HSI-VER-006` | Target verification shall measure baud rate and validate transmit, receive and error behavior for all configured UARTs at the connector/device boundary. | Verification | `T-HW`, `T-FI` | Partial; nominal communication has been manually observed, but controlled error/tolerance records are absent. |
| `HSI-VER-007` | Before safety release, every normative requirement in this HSI and its controlled board-profile companions shall have an allocated ASIL, parent safety-requirement trace, responsible owner, verification result and controlled evidence reference, or an approved rationale for non-applicability. | Safety/configuration management | `I` | Open; these drafts intentionally expose the missing allocations and evidence. |
| `HSI-VER-008` | Tool confidence, compiler/linker assumptions and verification-tool suitability shall be assessed according to the project safety plan before their outputs are used as sole safety evidence. | Safety management | `I`, `A` | Open; no tool-confidence assessment is present in this repository. |

## Configuration Summary

| Subsystem | Current software state | Principal source |
| --- | --- | --- |
| CPU supply/performance | Internal MCU LDO selected; voltage scale 0/overdrive selected | [`src/mcu/peripherals/pwr.rs`](../../src/mcu/peripherals/pwr.rs) |
| System clock | 25 MHz HSE input through PLL1 to 480 MHz CPU clock | [`src/mcu/peripherals/rcc.rs`](../../src/mcu/peripherals/rcc.rs) |
| Flash interface | 4 wait states | [`src/mcu/peripherals/flash.rs`](../../src/mcu/peripherals/flash.rs) |
| FPU | CP10 and CP11 full access enabled before Rust code executes | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs) |
| ITCM/DTCM | Enabled during reset; selected code/data relocated before `main` | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs), [`memory.x`](../../memory.x) |
| Vector table | Copied from Flash to DTCM and `VTOR` redirected to the RAM copy | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs) |
| SWD | MCU SWD interface on PA13, PA14 and NRST | [`.devenv/STM32H743IIT6/STM32H743IIT6.cfg`](../STM32H743IIT6/STM32H743IIT6.cfg) |
| USART1 | 115200 8N1, PA9/PA10, polled I/O | [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs) |
| SysTick | Processor clock source at 480 MHz; interrupt-driven scheduler deadlines | [`src/drv/systick/mod.rs`](../../src/drv/systick/mod.rs) |
| WWDG1 | Window watchdog enabled for program-flow supervision | [`src/mcu/peripherals/wwdg.rs`](../../src/mcu/peripherals/wwdg.rs) |
| Heartbeat output | PH7 active-low output, updated by the supervised 5 ms task | [`src/mcu/boardled/mod.rs`](../../src/mcu/boardled/mod.rs) |
| Physical target | FK743M2-IIT6 V1.1 resources and connectors | [Board documentation](../STM32H743IIT6/README.md) |

## Startup Configuration

The reset and startup sequence is:

1. Mask interrupts with `PRIMASK`.
2. Enable ITCM and DTCM through the Cortex-M7 TCM control registers.
3. Enable the double-precision FPU by granting full access to CP10 and CP11.
4. Copy ordinary initialized data from Flash to AXI SRAM.
5. Copy selected DTCM data from Flash to DTCM and zero selected DTCM BSS.
6. Copy `.itcm_text` from Flash to ITCM.
7. Zero ordinary BSS in AXI SRAM.
8. Copy the complete vector table to a 1024-byte-aligned DTCM allocation and
   write its address to `SCB.VTOR`.
9. Unmask interrupts and enter `main()`.
10. Configure power, Flash latency and the 480 MHz clock tree.
11. Configure the PH7 heartbeat output and USART1.
12. Create the OS tasks.
13. Configure the program-flow monitor, start WWDG1 and arm the first SysTick
    deadline from the same time origin.
14. Select PSP for privileged thread mode and start the background task.

No MCU I-cache, D-cache, MPU, DMA or MDMA configuration is currently made.
SVCall, SysTick and PendSV are explicitly programmed to `0xD0`, `0xE0` and
`0xF0` respectively. The numerically lower SVCall and SysTick priorities allow
scheduler bookkeeping to complete before PendSV context switching.

## Clock And Power Tree

### Power And Flash

| Item | Register-level configuration |
| --- | --- |
| MCU core supply | `PWR_CR3`: `LDOEN=1`, `BYPASS=0`, `SCUEN=0` |
| Initial voltage scaling | `PWR_D3CR.VOS = Scale 1` |
| 480 MHz performance mode | SYSCFG overdrive enabled, resulting in voltage scale 0 operation |
| Flash | `FLASH_ACR.LATENCY = 4` wait states |

Only Flash latency is explicitly changed. Flash write-frequency selection and
CPU cache enablement are not explicitly configured by the current software.

### PLL1

| Parameter | Value |
| --- | --- |
| Clock source | External HSE, 25 MHz, crystal mode (`HSEBYP=0`) |
| HSE pins | PH0/OSC_IN and PH1/OSC_OUT |
| `DIVM1` | 5 |
| PLL1 input | 25 MHz / 5 = 5 MHz |
| Input range | 4 to 8 MHz |
| VCO mode | Wide VCO |
| `DIVN1` | 192 |
| PLL1 VCO | 5 MHz x 192 = 960 MHz |
| `DIVP1` | 2, output enabled |
| PLL1P / SYSCLK | 960 MHz / 2 = 480 MHz |
| `DIVQ1`, `DIVR1` | Both set to 2, but both outputs disabled |
| Fractional mode | Disabled, `FRACN1=0` |

The HSI does not claim a usable 48 MHz USB clock. PLL1Q is disabled and no
other 48 MHz source is configured.

### Resulting Clock Domains

| Clock | Divider/source | Frequency |
| --- | --- | ---: |
| CPU clock / `D1CPRE` | SYSCLK / 1 | 480 MHz |
| HCLK / AXI / AHB | SYSCLK / 2 | 240 MHz |
| PCLK3 / APB3 | HCLK / 2 | 120 MHz |
| PCLK1 / APB1 | HCLK / 2 | 120 MHz |
| PCLK2 / APB2 | HCLK / 2 | 120 MHz |
| PCLK4 / APB4 | HCLK / 2 | 120 MHz |
| USART1 kernel | PCLK2 | 120 MHz |
| SysTick | Processor clock | 480 MHz |
| WWDG1 | PCLK3 before watchdog divider | 120 MHz |

With the APB prescalers set to `/2` and the timer clock selection left at its
reset behavior, applicable APB timer kernels run at 240 MHz. No timer is
otherwise initialized by this firmware.

## Memory And Core Placement

| Region | Address | Size | Current use |
| --- | ---: | ---: | --- |
| ITCM | `0x0000_0000` | 64 KiB | `.itcm_text`; the two task deployment wrappers |
| Internal Flash | `0x0800_0000` | 2 MiB | Vector load image, ordinary code/const data, RAM load images |
| DTCM | `0x2000_0000` | 128 KiB | RAM vector table, OS/task stacks, SysTick/WWDG/PFM state, 4 KiB MSP stack |
| AXI SRAM | `0x2400_0000` | 512 KiB | Ordinary `.data` and `.bss`, including peripheral handles |
| D2 SRAM | `0x3000_0000` | 288 KiB | Exposed by linker symbols, no section allocated currently |
| D3 SRAM | `0x3800_0000` | 64 KiB | Exposed by linker symbols, no section allocated currently |
| Backup SRAM | `0x3880_0000` | 4 KiB | Exposed by linker symbols, no section allocated currently |

The linker asserts that ITCM content fits in 64 KiB and that DTCM allocations
cannot overlap the reserved MSP stack. Ordinary AXI SRAM allocations are also
bounds-checked.

`STACK_SIZE` is 256 `u32` words per OS task, or 1024 bytes per task. The OS
object contains all three task stacks and is explicitly placed in DTCM. The
deployment functions `tsk_1_5ms` and `tsk_pfm_10ms` execute from
ITCM. Functions called by those wrappers remain in Flash unless they have their
own ITCM section attribute.

No external-memory region is present in `memory.x`; external memory cannot be
used as normal linked memory until its controller, GPIO, timing, initialization
and startup diagnostics are defined.

## Scheduler And Watchdog Hardware

### SysTick

- Clock source: processor clock, 480 MHz.
- Counter width: 24 bits.
- Interrupt: enabled whenever a scheduler deadline is armed.
- Initial deadline: 1000 us after the common program-flow epoch.
- Later deadlines: dynamically armed to the next cyclic task release.
- The vector table entry is the shared OS symbol `SysTick_Isr`.

### WWDG1

| Parameter | Value |
| --- | ---: |
| Peripheral clock | PCLK3 = 120 MHz |
| Watchdog divider | 32768 |
| Reload counter | `0x7F` |
| Window counter | `0x61` |
| Early wakeup interrupt | Disabled |
| Approximate window opening | 8.2 ms after reload |
| Approximate reset timeout | 17.5 ms after reload |
| Software-authorized service interval | 8.5 to 15.5 ms |

WWDG1 and the first SysTick deadline are started in one outer critical section
with time origin 0. The unsupervised 10 ms PFM task is the only software path
that calls `Wwdg::Refresh`. It services WWDG1 only after all expected supervised
task checkpoints have been validated. A PFM fault inhibits all later refreshes
and leaves the hardware watchdog to reset the MCU.

## Configured UART Interface

USART1 uses asynchronous transmit and receive, 8 data bits, no parity,
one stop bit, oversampling by 16, prescaler `/1`, non-inverted signaling, LSB
first and enabled FIFOs. Hardware flow control, DMA and USART interrupts are
not enabled; communication is polled.

| Interface | MCU TX | MCU RX | AF | Baud | GPIO electrical setup |
| --- | --- | --- | ---: | ---: | --- |
| USART1 | PA9 | PA10 | 7 | 115200 | TX very-high speed/no pull; RX very-high speed/pull-up; push-pull |

The GPIOA AHB4 clock is enabled as a consequence of this UART configuration.

## Intentionally Unconfigured Hardware

The following MCU facilities are not enabled by the current software. The
board profile separately identifies which related components are physically
fitted:

- External-memory controllers and external-memory address ranges.
- SDMMC1.
- USB OTG FS and a valid USB 48 MHz kernel clock.
- LTDC, touch-interface GPIO and display backlight PWM.
- LSE, RTC and backup SRAM use.
- USART2 and USART3, including PA3, PD5, PB10 and PB11.
- CPU instruction/data caches and MPU.
- DMA and MDMA.
- UART interrupts and NVIC configuration for USART1.
- HSE clock-security system and MCO outputs.

## Sources And Traceability

The HSI work-product structure and requirement-management fields are aligned to
the currently published second edition of the following standards. Access to
the full controlled standards is required for a safety release:

- [ISO 26262-4:2018, product development at the system level](https://www.iso.org/standard/68386.html)
- [ISO 26262-6:2018, product development at the software level](https://www.iso.org/standard/68388.html)
- [ISO 26262-8:2018, supporting processes](https://www.iso.org/standard/68390.html)

Firmware configuration is derived directly from this repository, especially:

- [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs)
- [`src/mcu/mod.rs`](../../src/mcu/mod.rs)
- [`src/mcu/peripherals`](../../src/mcu/peripherals)
- [`src/os`](../../src/os)
- [`memory.x`](../../memory.x)
- [`.cargo/config.toml`](../../.cargo/config.toml)

MCU reference sources are:

- [STM32H743II product and datasheet page](https://www.st.com/en/microcontrollers-microprocessors/stm32h743ii.html)
- [STM32H743 reference manual RM0433](https://www.st.com/resource/en/reference_manual/rm0433-stm32h743-753-and-stm32h750-value-line-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf)

Physical-board sources are recorded with the corresponding
[board documentation](../STM32H743IIT6/README.md).
