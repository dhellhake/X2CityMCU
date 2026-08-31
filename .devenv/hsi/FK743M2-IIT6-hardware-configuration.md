# FK743M2-IIT6 V1.1 Hardware/Software Interface Specification

This document specifies the hardware/software interface (HSI) and records the
hardware configuration performed by the current X2CityMCU firmware. The target
is the FK743M2-IIT6 V1.1 board with an STM32H743IIT6 in the LQFP176 package.

| Document attribute | Value |
| --- | --- |
| Document ID | `X2C-HSI-001` |
| Lifecycle status | Draft; not released for a safety-related production item |
| Configuration item | This Git-controlled Markdown file and its referenced implementation files |
| Applicable safety-process baseline | ISO 26262:2018 Parts 4, 6 and 8 |
| Item-level ASIL allocation | `TBD` by the hazard analysis and risk assessment |
| Parent technical/software safety requirements | `TBD` by the technical safety concept and software safety requirements specification |
| Intended owner | MCU software integration |

The requirement structure is intended to support an ISO 26262 safety lifecycle,
but this document alone does not establish ISO 26262 compliance. Item definition,
HARA, ASIL allocation, parent-requirement traceability, confirmation measures,
tool confidence, independence arguments, production release and the safety case
remain outside this document until supplied by the applicable safety plan.

The requirement tables are normative. The later configuration, memory and pinout
sections are informative design description and implementation evidence. If the
two conflict, the conflict shall be resolved through change control before a
safety release; the requirement shall not silently be weakened to match the code.

The following terms are used throughout the document:

- **Configured** means that the current firmware writes the relevant MCU
  registers during startup.
- **Board connection** means that the PCB permanently connects the MCU pin to
  an onboard device or another board connector. It does not imply that the
  firmware initializes that device.
- **Reset state** means that the firmware does not intentionally configure the
  pin after reset.
- Board silkscreen names omit the `P` prefix. For example, `A3` is MCU pin
  `PA3`, and `I11` is MCU pin `PI11`.

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
| `HSI-GEN-001` | The software shall execute only on an FK743M2-IIT6 V1.1 board populated with an STM32H743IIT6 in the LQFP176 package unless a controlled HSI variant is released. | System integration | `I`, `T-HW` | Assumption; board identity must be recorded for each test/release unit. |
| `HSI-GEN-002` | The linker memory map, startup code and peripheral base addresses shall match the STM32H743IIT6 memory and peripheral map. | Linker, startup, generic drivers | `I`, `A` | Implemented in [`memory.x`](../../memory.x), [`src/drv/startup`](../../src/drv/startup) and the drivers. |
| `HSI-GEN-003` | All required MCU hardware initialization shall complete before the scheduler can execute an application task. | `main`, `McuManager` | `I`, `T-SW` | Implemented by the startup order in [`src/main.rs`](../../src/main.rs). |
| `HSI-GEN-004` | Project-specific board and use-case configuration shall reside in `src/mcu`; reusable register-level access shall reside in the `src/drv` submodule. | Software architecture | `I` | Implemented by [`src/mcu/peripherals`](../../src/mcu/peripherals) and [`src/drv`](../../src/drv). |
| `HSI-GEN-005` | A peripheral not explicitly identified as configured by this HSI shall not be enabled or used by application software. | MCU software | `I`, `T-SW` | Implemented by inspection; listed under [Intentionally Unconfigured Hardware](#intentionally-unconfigured-hardware). |
| `HSI-GEN-006` | Failure to establish a required hardware configuration shall prevent execution of safety-relevant application functions and shall cause the allocated safe reaction within the item FTTI. | Startup and system safety mechanism | `T-FI`, `T-HW` | Open; several pre-watchdog readiness waits and assertion paths can wait indefinitely. Safe reaction and FTTI are `TBD`. |
| `HSI-GEN-007` | A change to target part, board revision, clock, memory allocation, peripheral configuration or pin assignment shall update this HSI, its parent traces and affected verification before release. | Configuration/change management | `I` | Partial; this file is version controlled, but parent traces and release workflow are `TBD`. |
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
| `HSI-STA-012` | Each configured OS task shall have a 1024-byte stack in DTCM, and the configured task count shall not exceed the statically allocated task array. | OS, linker | `I`, `T-SW` | Implemented for four tasks by `STACK_SIZE = 256` words and the DTCM OS object. Stack-depth evidence remains open. |
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
| `HSI-CLK-003` | The system clock source shall be the fitted 25 MHz HSE crystal on PH0/PH1 in crystal mode with HSE bypass disabled. | Board oscillator, RCC | `I`, `A`, `T-HW` | Implemented by [`src/mcu/peripherals/rcc.rs`](../../src/mcu/peripherals/rcc.rs); crystal frequency is a board assumption. |
| `HSI-CLK-004` | PLL1 shall use HSE with `DIVM1=5`, `DIVN1=192`, `DIVP1=2`, wide VCO, 4-to-8-MHz input range and fractional mode disabled. PLL1P shall be enabled; PLL1Q and PLL1R shall remain disabled. | RCC PLL1 | `I`, `A`, `T-HW` | Implemented by [`ConfigurePll1Hse25MhzTo480Mhz`](../../src/mcu/peripherals/rcc.rs). |
| `HSI-CLK-005` | Startup shall wait for HSE and PLL1 readiness and shall confirm that the system-clock status selects PLL1 before continuing. | RCC | `I`, `T-FI`, `T-HW` | Implemented with blocking ready/status waits. The waits are not time bounded. |
| `HSI-CLK-006` | `D1CPRE` shall divide SYSCLK by 1, `HPRE` shall divide SYSCLK by 2, and each APB prescaler shall divide HCLK by 2. | RCC bus clocks | `I`, `A`, `T-HW` | Implemented by [`SetBusPrescalersFor480Mhz`](../../src/mcu/peripherals/rcc.rs). |
| `HSI-CLK-007` | The configured clock tree shall produce a 480 MHz CPU clock, 240 MHz HCLK/AXI clock and 120 MHz PCLK1, PCLK2, PCLK3 and PCLK4 from a 25 MHz HSE. | RCC, board oscillator | `A`, `T-HW` | Implemented; calculations are recorded under [Resulting Clock Domains](#resulting-clock-domains). |
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
| `HSI-UAR-001` | USART1, USART2 and USART3 shall use asynchronous 8N1, LSB-first, non-inverted signaling, oversampling by 16, prescaler 1, enabled transmit/receive and enabled FIFO mode. | USART1/2/3 | `I`, `T-HW` | Implemented by [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs). |
| `HSI-UAR-002` | USART1 shall use a 120 MHz PCLK2 kernel clock, 115200 baud, PA9/AF7 as push-pull TX and PA10/AF7 with pull-up as RX. | RCC, GPIOA, USART1 | `I`, `A`, `T-HW` | Implemented for the P1 CH343/debug UART. |
| `HSI-UAR-003` | USART2 shall use a 120 MHz PCLK1 kernel clock, 9600 baud, PD5/AF7 as push-pull TX and PA3/AF7 with pull-up as RX. | RCC, GPIOA/GPIOD, USART2 | `I`, `A`, `T-HW` | Implemented for the VD18MT/VT8MT interface. |
| `HSI-UAR-004` | USART3 shall use a 120 MHz PCLK1 kernel clock, 9600 baud, PB10/AF7 as push-pull TX and PB11/AF7 with pull-up as RX. | RCC, GPIOB, USART3 | `I`, `A`, `T-HW` | Implemented for the JDB BMS interface. |
| `HSI-UAR-005` | UART initialization shall enable only the required GPIOA, GPIOB, GPIOD and USART1/2/3 peripheral clocks for these interfaces. | RCC | `I` | Implemented by [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs). |
| `HSI-UAR-006` | USART1/2/3 communication shall remain polled with DMA, hardware flow control and USART interrupts disabled until an approved HSI change allocates and verifies those resources. | USART1/2/3, NVIC, DMA | `I` | Implemented as the current configuration. |
| `HSI-UAR-007` | A communication channel allocated a safety requirement shall detect UART framing, noise, overrun and parity indications, clear them deterministically and communicate invalidity to its consumer. | USART driver, component | `I`, `T-SW`, `T-FI` | Partial; the BMS path exposes and handles USART errors. USART1/USART2 safety allocation and error handling are `TBD`. |
| `HSI-UAR-008` | A safety-relevant UART protocol shall provide and verify message framing, length, checksum, value range, sequence/freshness or timeout as required by its allocated safety requirement. | BMS/display component | `I`, `T-SW`, `T-FI` | Partial; component parsers validate framing/checksums, but channel safety allocation and end-to-end safety metrics are `TBD`. |
| `HSI-UAR-009` | External devices connected to MCU GPIO shall satisfy STM32H743II input/output voltage limits, share a defined ground reference and shall not back-power an unpowered participant. | Board/system integration | `I`, `A`, `T-HW` | Assumption; external wiring is not controlled by firmware. |
| `HSI-UAR-010` | The 5 V VT8MT UART side shall connect to PA3/PD5 only through a level interface demonstrated to provide valid 3.3 V MCU levels across voltage, load, baud rate and temperature. | External level shifter, system integration | `A`, `T-HW` | Assumption; the installed bidirectional level-shifter behavior requires electrical validation. |
| `HSI-LED-001` | PH7 shall drive the onboard active-low user LED as a low-speed push-pull GPIO output without an internal pull. Its output latch shall be set high before output mode is selected. | RCC, GPIOH, board LED | `I`, `T-HW` | Implemented by [`src/mcu/boardled/mod.rs`](../../src/mcu/boardled/mod.rs); the initialization sequence prevents an unintended startup pulse. |
| `HSI-LED-002` | The supervised 5 ms task shall drive a one-second heartbeat consisting of 100 ms on, 100 ms off, 100 ms on and 700 ms off using its scheduled timestamp. | Scheduler, 5 ms task, board LED | `I`, `T-SW`, `T-HW` | Implemented by [`src/mcu/boardled/mod.rs`](../../src/mcu/boardled/mod.rs) and [`src/mcu/deployment/mod.rs`](../../src/mcu/deployment/mod.rs); task-aligned edge assertions are evaluated at compile time. |
| `HSI-LED-003` | The heartbeat shall be treated as a scheduler-activity indication only and shall not replace program-flow monitoring or the hardware watchdog. | System diagnostics | `I`, `A` | Implemented architecturally; WWDG1 remains the independent scheduler supervision reaction. |
| `HSI-DBG-001` | SWD shall use PA13/SWDIO, PA14/SWCLK, NRST, target 3.3 V reference and common ground as listed for P1; four-wire JTAG operation shall not be assumed from J-Link signal labels. | Board P1, debugger configuration | `I`, `T-HW` | Implemented for development/debug connection. |
| `HSI-DBG-002` | Safety-relevant operation shall not depend on an attached debugger, and production debug access shall follow the item safety and security concept. | System integration | `I`, `T-HW` | Partial; standalone execution works, but the production debug-access policy is `TBD`. |
| `HSI-DBG-003` | The enclosure debug interface shall route J4 to PA13/SWDIO, K1 to PA14/SWCLK, K2 to the target 3.3 V reference, K3 to GND and K4 to NRST. J-Link TMS shall connect to J4/DIO, TCLK to K1/CLK, VCC/VTref to K2/3V3, GND to K3 and RESET to K4/RST. | Enclosure connector, internal harness and board P1 | `I`, `T-HW` | Assumption; the assignment is recorded and requires end-to-end continuity and isolation testing. |

### Board Resources And Pin Ownership

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-PIN-001` | Configured MCU pins and externally connected signals shall match the assignments in [Current External Assignments](#current-external-assignments), [Enclosure 48-Pin Molex Connector](#enclosure-48-pin-molex-connector) and [Board Connector Pinout](#board-connector-pinout). | MCU GPIO, board/system wiring | `I`, `T-HW` | Partial; software assignments are implemented, while production wiring continuity evidence is external. |
| `HSI-PIN-002` | FMC-connected SDRAM pins shall not be reassigned as application GPIO while the fitted W9825G6KH-6I is present, unless the electrical effect is analyzed and approved. | Pin multiplexing, board SDRAM | `I`, `A` | Implemented as a prohibition; FMC is currently unconfigured. |
| `HSI-PIN-003` | PC8, PC9, PC10, PC11, PC12 and PD2 shall remain available to the fitted microSD interface. PC9 shall not output MCO2 while an SD transaction is active. | Pin multiplexing, SDMMC1, RCC | `I`, `T-HW` | Implemented as a prohibition; SDMMC1 and MCO2 are currently unconfigured. |
| `HSI-PIN-004` | PA11 and PA12 shall remain unconfigured until USB OTG FS, its electrical interface and a valid 48 MHz kernel clock are specified and verified. | GPIOA, RCC, USB OTG FS | `I`, `T-HW` | Implemented as a prohibition. |
| `HSI-PIN-005` | LCD1 RGB, timing, touch and backlight pins shall remain unconfigured until ownership, timing, electrical and startup requirements for the attached panel are specified and verified. | LTDC, GPIO, touch interface | `I`, `T-HW` | Implemented as a prohibition. |
| `HSI-PIN-006` | PC14/PC15, LSE, RTC and the backup domain shall remain unconfigured until their use and fault behavior are added to this HSI. | RCC, RTC | `I` | Implemented as a prohibition. |
| `HSI-PIN-007` | Pins without an allocated software function shall remain in their documented reset state unless an approved pin-safety analysis specifies a deterministic alternative. | GPIO | `I`, `A`, `T-HW` | Implemented by absence of writes; pin-level safety analysis is open. |
| `HSI-PIN-008` | Shared or multiply connected board pins shall have one declared owner at a time, and software shall prevent conflicting peripheral functions from being enabled concurrently. | MCU software architecture | `I`, `T-SW` | Partial; current configuration has no active conflict, but no generic ownership enforcement exists. |
| `HSI-PIN-009` | Enclosure connector cavities M1 and M2 shall be assigned to the nominal 12 V supply, and cavities M3 and M4 shall be assigned to GND. The four power cavities shall not be assigned a signal function. | Enclosure connector and harness | `I`, `T-HW` | Assumption; assignment is based on the current physical integration and requires continuity and polarity verification. |
| `HSI-PIN-010` | An enclosure-connector cavity marked `TBD` in this HSI shall remain electrically unassigned until its function, direction, electrical limits, internal destination and verification are approved. | System integration | `I`, `T-HW` | Implemented as an interface prohibition; 39 cavities are currently unassigned. |
| `HSI-PIN-011` | Before a safety release, the exact Molex part number, keying orientation, mating-face reference view and cavity-label sequence shall be recorded and verified against the physical enclosure connector. | System integration and configuration management | `I`, `T-HW` | Open; the 48-cavity count implies that one letter between A and M is omitted, provisionally documented as column I. |

### Verification And Safety Release

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `HSI-VER-001` | A release build shall fail when Flash, ITCM, DTCM, AXI SRAM or reserved-stack bounds in `memory.x` are exceeded. | Linker/build system | `T-SW` | Implemented for ITCM, DTCM, AXI SRAM and main-stack relations; Flash overflow is enforced by linker region size. |
| `HSI-VER-002` | Each safety release shall archive a linker map demonstrating the address and size of the vector table, `.itcm_text`, DTCM objects, each task stack, main stack, `.data` and `.bss`. | Build/configuration management | `I` | Open; linker placement is inspectable, but no release evidence archive is defined. |
| `HSI-VER-003` | Target verification shall demonstrate 480 MHz CPU timing and the derived bus clocks using an independent measurement or a traceable timing test. | Verification | `A`, `T-HW` | Partial; a 32 MHz MCO2 test on PC9 previously confirmed the derived clock, but the test code and formal record are not retained. |
| `HSI-VER-004` | Target verification shall demonstrate execution inside and outside ITCM, valid DTCM data/stack use, vector-table relocation and correct interrupt dispatch after relocation. | Verification | `T-HW` | Partial; development smoke tests were performed, but a controlled verification report is absent. |
| `HSI-VER-005` | Target verification shall exercise nominal, early, late, missing, duplicate, out-of-sequence and internally corrupted PFM/watchdog cases and record the resulting diagnostic and reset timing. | Verification | `T-FI`, `T-HW` | Open; implementation exists, but complete recorded fault-injection evidence is absent. |
| `HSI-VER-006` | Target verification shall measure baud rate and validate transmit, receive and error behavior for all configured UARTs at the connector/device boundary. | Verification | `T-HW`, `T-FI` | Partial; nominal communication has been manually observed, but controlled error/tolerance records are absent. |
| `HSI-VER-007` | Before safety release, every HSI requirement shall have an allocated ASIL, parent safety-requirement trace, responsible owner, verification result and controlled evidence reference, or an approved rationale for non-applicability. | Safety/configuration management | `I` | Open; this draft intentionally exposes the missing allocations and evidence. |
| `HSI-VER-008` | Tool confidence, compiler/linker assumptions and verification-tool suitability shall be assessed according to the project safety plan before their outputs are used as sole safety evidence. | Safety management | `I`, `A` | Open; no tool-confidence assessment is present in this repository. |

## Configuration Summary

| Subsystem | Current software state | Principal source |
| --- | --- | --- |
| CPU supply/performance | Internal MCU LDO selected; voltage scale 0/overdrive selected | [`src/mcu/peripherals/pwr.rs`](../../src/mcu/peripherals/pwr.rs) |
| System clock | 25 MHz HSE crystal through PLL1 to 480 MHz CPU clock | [`src/mcu/peripherals/rcc.rs`](../../src/mcu/peripherals/rcc.rs) |
| Flash interface | 4 wait states | [`src/mcu/peripherals/flash.rs`](../../src/mcu/peripherals/flash.rs) |
| FPU | CP10 and CP11 full access enabled before Rust code executes | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs) |
| ITCM/DTCM | Enabled during reset; selected code/data relocated before `main` | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs), [`memory.x`](../../memory.x) |
| Vector table | Copied from Flash to DTCM and `VTOR` redirected to the RAM copy | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs) |
| SWD | J-Link target connection on PA13, PA14 and NRST through enclosure cavities J4, K1 and K4; K2/K3 provide reference and ground | [`.devenv/STM32H743IIT6/STM32H743IIT6.cfg`](../STM32H743IIT6/STM32H743IIT6.cfg) |
| Enclosure connector | 48-pin Molex matrix; M1/M2 = nominal 12 V, M3/M4 = GND, J4/K1/K2/K3/K4 = debugger interface, all other cavities TBD | Physical integration record |
| USART1 | Debug/PC UART, 115200 8N1, PA9/PA10 | [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs) |
| USART2 | VD18MT/VT8MT display UART, 9600 8N1, PA3/PD5 | [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs) |
| USART3 | JDB BMS UART, 9600 8N1, PB10/PB11 | [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs) |
| SysTick | Processor clock source at 480 MHz; interrupt-driven scheduler deadlines | [`src/drv/systick/mod.rs`](../../src/drv/systick/mod.rs) |
| WWDG1 | Window watchdog enabled for program-flow supervision | [`src/mcu/peripherals/wwdg.rs`](../../src/mcu/peripherals/wwdg.rs) |
| External SDRAM | Fitted and wired, but not initialized or mapped by this firmware | Not configured |
| microSD | Fitted and wired, but SDMMC1 is not initialized | Not configured |
| USB Type-C data | PA11/PA12 are wired, but USB OTG FS is not initialized | Not configured |
| RGB LCD/touch FPC | Fitted and wired, but LTDC/touch GPIO is not initialized | Not configured |
| User LED | PH7 active-low heartbeat, updated by the supervised 5 ms task | [`src/mcu/boardled/mod.rs`](../../src/mcu/boardled/mod.rs) |
| LSE/RTC | 32.768 kHz crystal is fitted, but LSE and RTC are not initialized | Not configured |
| PC9 clock test | Previously used as a 32 MHz MCO2 verification output; code was removed | Historical only |

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
11. Configure the PH7 heartbeat LED and USART1, USART2 and USART3.
12. Create the OS tasks and component instances.
13. Configure the program-flow monitor, start WWDG1 and arm the first SysTick
    deadline from the same time origin.
14. Select PSP for privileged thread mode and start the background task.

No MCU I-cache, D-cache, MPU, DMA or MDMA configuration is currently made.
No explicit SysTick, PendSV or SVCall priority is programmed, so their reset
priority values remain in effect.

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
| Clock source | Board HSE crystal, 25 MHz, crystal mode (`HSEBYP=0`) |
| HSE pins | PH0/OSC_IN and PH1/OSC_OUT, dedicated onboard connection |
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
| USART2/USART3 kernel | PCLK1 | 120 MHz |
| SysTick | Processor clock | 480 MHz |
| WWDG1 | PCLK3 before watchdog divider | 120 MHz |

With the APB prescalers set to `/2` and the timer clock selection left at its
reset behavior, applicable APB timer kernels run at 240 MHz. No timer is
otherwise initialized by this firmware.

## Memory And Core Placement

| Region | Address | Size | Current use |
| --- | ---: | ---: | --- |
| ITCM | `0x0000_0000` | 64 KiB | `.itcm_text`; the three task deployment wrappers |
| Internal Flash | `0x0800_0000` | 2 MiB | Vector load image, ordinary code/const data, RAM load images |
| DTCM | `0x2000_0000` | 128 KiB | RAM vector table, OS/task stacks, SysTick/WWDG/PFM state, 4 KiB MSP stack |
| AXI SRAM | `0x2400_0000` | 512 KiB | Ordinary `.data` and `.bss`, including component instances |
| D2 SRAM | `0x3000_0000` | 288 KiB | Exposed by linker symbols, no section allocated currently |
| D3 SRAM | `0x3800_0000` | 64 KiB | Exposed by linker symbols, no section allocated currently |
| Backup SRAM | `0x3880_0000` | 4 KiB | Exposed by linker symbols, no section allocated currently |

The linker asserts that ITCM content fits in 64 KiB and that DTCM allocations
cannot overlap the reserved MSP stack. Ordinary AXI SRAM allocations are also
bounds-checked.

`STACK_SIZE` is 256 `u32` words per OS task, or 1024 bytes per task. The OS
object contains all four task stacks and is explicitly placed in DTCM. The
deployment functions `tsk_1_5ms`, `tsk_2_10ms` and `tsk_pfm_10ms` execute from
ITCM. Functions called by those wrappers remain in Flash unless they have their
own ITCM section attribute.

The fitted W9825G6KH-6I SDRAM is not present in `memory.x`; it cannot be used as
normal linked memory until FMC GPIO, timing and SDRAM initialization are added.

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

## Configured UART Interfaces

All three USARTs use asynchronous transmit and receive, 8 data bits, no parity,
one stop bit, oversampling by 16, prescaler `/1`, non-inverted signaling, LSB
first and enabled FIFOs. Hardware flow control, DMA and USART interrupts are
not enabled; communication is polled.

| Use | MCU TX | MCU RX | AF | Baud | GPIO electrical setup | External connection |
| --- | --- | --- | ---: | ---: | --- | --- |
| PC/debug UART, USART1 | PA9 | PA10 | 7 | 115200 | TX very-high speed/no pull; RX very-high speed/pull-up; push-pull | P1 TX -> CH343 RX, P1 RX <- CH343 TX |
| VD18MT/VT8MT display, USART2 | PD5 | PA3 | 7 | 9600 | TX low speed/no pull; RX low speed/pull-up; push-pull | PD5 -> display RX, PA3 <- display TX |
| JDB BMS, USART3 | PB10 | PB11 | 7 | 9600 | TX low speed/no pull; RX low speed/pull-up; push-pull | PB10 -> BMS RX, PB11 <- BMS TX |

GPIOA, GPIOB and GPIOD AHB4 clocks are enabled as a consequence of these UART
configurations. The UART-connected VT8MT display is independent of the unused
40-pin RGB LCD connector. The CH343 is currently enumerated by the PC as COM5.
The VT8MT wiring includes an external bidirectional 3.3 V/5 V level-shifter
module; its electrical behavior is outside the firmware configuration.

## Current External Assignments

| External device | Board signal | MCU pin | Direction relative to MCU | Status |
| --- | --- | --- | --- | --- |
| J-Link EDU Mini V2 via enclosure | J4 DIO / J-Link TMS | PA13/SWDIO | Bidirectional | Active enclosure debug route |
| J-Link EDU Mini V2 via enclosure | K1 CLK / J-Link TCLK | PA14/SWCLK | Input | Active enclosure debug route |
| J-Link EDU Mini V2 via enclosure | K4 RST / J-Link RESET | NRST | Input to reset circuit | Active enclosure debug route |
| J-Link EDU Mini V2 via enclosure | K2 3V3 / J-Link VCC | 3.3V target reference | Power sense | Active enclosure debug route |
| J-Link EDU Mini V2 via enclosure | K3 GND | GND | Reference | Active enclosure debug route |
| CH343 USB/UART | TX | PA10/USART1_RX | Input | Active |
| CH343 USB/UART | RX | PA9/USART1_TX | Output | Active |
| CH343 USB/UART | GND | GND | Reference | Active |
| VD18MT/VT8MT | TX | PA3/USART2_RX | Input | Active |
| VD18MT/VT8MT | RX | PD5/USART2_TX | Output | Active |
| VD18MT/VT8MT | GND | GND | Reference | Active |
| JDB BMS | TX | PB11/USART3_RX | Input | Active |
| JDB BMS | RX | PB10/USART3_TX | Output | Active |
| JDB BMS | GND | GND | Reference | Active |
| Oscilloscope clock test | MCO2 | PC9 | Output | Removed; PC9 is now unconfigured |

The J-Link connector names TMS and TCLK carry SWDIO and SWCLK respectively
because the debug transport is configured for SWD, not four-wire JTAG.

## Enclosure 48-Pin Molex Connector

This is the external connector fitted to the enclosure around the board. The
view below is the mating-face view looking into the male connector, using the
cavity labels molded into the connector. A wire-side view is mirrored and shall
not be inferred from this table.

The connector is described as having 48 cavities in four numbered rows. Four
rows and labels A through M would yield 52 positions if every letter were used.
This draft therefore interprets the cavity sequence as `A` through `H`, followed
by `J` through `M`, with `I` omitted. The exact part number and molded labels
shall be checked before this overview is used to manufacture or test a harness.

`TBD` means that no electrical function has yet been assigned to the cavity.

| Row | A | B | C | D | E | F | G | H | J | K | L | M |
| ---: | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | SWD CLK | TBD | 12 V supply |
| 2 | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | 3.3 V target reference | TBD | 12 V supply |
| 3 | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | GND | TBD | GND |
| 4 | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | SWD DIO | RST | TBD | GND |

| Cavity | Assigned function | Direction at enclosure | Internal destination | Verification state |
| --- | --- | --- | --- | --- |
| J4 | SWD DIO / J-Link TMS | Bidirectional | PA13/SWDIO through board P1 DIO | Assignment recorded; end-to-end continuity test pending |
| K1 | SWD CLK / J-Link TCLK | Input to enclosure | PA14/SWCLK through board P1 CLK | Assignment recorded; end-to-end continuity test pending |
| K2 | 3.3 V target reference / J-Link VCC | Output reference from enclosure | Board 3.3 V rail through P1 3V3 | Assignment recorded; voltage and isolation test pending |
| K3 | Debug ground | Reference | Board GND through P1 GND | Assignment recorded; end-to-end continuity test pending |
| K4 | Debug reset / J-Link RESET | Input to enclosure | NRST through board P1 RST | Assignment recorded; end-to-end continuity test pending |
| M1 | Nominal 12 V supply | Power into enclosure | TBD | Assignment recorded; polarity/continuity test pending |
| M2 | Nominal 12 V supply | Power into enclosure | TBD | Assignment recorded; polarity/continuity test pending |
| M3 | GND / supply return | Power return | TBD | Assignment recorded; continuity test pending |
| M4 | GND / supply return | Power return | TBD | Assignment recorded; continuity test pending |

The permitted supply range, current allocation between M1/M2 and M3/M4,
contact derating, wire gauge, fusing, reverse-polarity protection and internal
power destination remain `TBD` system-level interface properties. The nominal
12 V assignment shall not be interpreted as permission to connect 12 V directly
to an STM32H743II supply or GPIO pin.

K2 is a target-voltage reference for the debugger. It shall not be used to power
the enclosure from the debugger unless a separately reviewed hardware design
explicitly permits that operating mode.

## Board Connector Pinout

### Orientation And Numbering

For the two long headers, view the PCB from the underside with the P1 debug/UART
header on the left and the microSD socket on the right. Positions below run
left-to-right. `Row A` is the first printed silkscreen line and `Row B` is the
second printed line. These row names deliberately do not infer undocumented
odd/even connector numbering.

`None` under board connection means that no additional fixed onboard load was
identified. It does not mean that the MCU pin lacks alternate functions; consult
the STM32H743II datasheet for the complete alternate-function matrix.

### P1 Debug, UART And Power Header

P1 is electrically a 2x4 header even when only one 1x4 strip is fitted.

| P1 pin | Board signal | MCU/rail | Board function | Current use |
| ---: | --- | --- | --- | --- |
| 1 | CLK | PA14 | SWCLK | J-Link TCLK |
| 2 | DIO | PA13 | SWDIO | J-Link TMS |
| 3 | GND | GND | Ground | J-Link/CH343 ground |
| 4 | 5V | 5V rail | Board 5 V rail | Not used by debugger |
| 5 | RX | PA10 | USART1_RX | CH343 TX -> board RX |
| 6 | TX | PA9 | USART1_TX | Board TX -> CH343 RX |
| 7 | RST | NRST through 1 kohm | Reset net and reset button | J-Link RESET |
| 8 | 3V3 | 3.3V rail | Board 3.3 V rail/reference | J-Link VCC sense |

### Upper 2x26 Edge Header

| Pos. | Row A | MCU/rail | Board connection | Current firmware | Row B | MCU/rail | Board connection | Current firmware |
| ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 5V | 5V rail | Board supply rail | None | 5V | 5V rail | Board supply rail | None |
| 2 | RST | NRST | Reset button and P1-7 | J-Link reset | BT0 | BOOT0 | Boot button/strap | None |
| 3 | A12 | PA12 | USB OTG FS D+ | Reset state | A11 | PA11 | USB OTG FS D- | Reset state |
| 4 | I0 | PI0 | LCD FPC G5 | Reset state | I1 | PI1 | LCD FPC G6 | Reset state |
| 5 | H14 | PH14 | LCD FPC G3 | Reset state | H15 | PH15 | LCD FPC G4 | Reset state |
| 6 | C6 | PC6 | None | Reset state | H13 | PH13 | LCD FPC G2 | Reset state |
| 7 | G6 | PG6 | LCD FPC R7 | Reset state | C7 | PC7 | None | Reset state |
| 8 | C8 | PC8 | microSD D0, 10 kohm pull-up | Reset state | G7 | PG7 | LCD FPC pixel clock | Reset state |
| 9 | A8 | PA8 | LCD FPC B3 | Reset state | C9 | PC9 | microSD D1, 10 kohm pull-up | Reset state; former MCO2 test |
| 10 | D2 | PD2 | microSD CMD, 10 kohm pull-up | Reset state | C12 | PC12 | microSD clock | Reset state |
| 11 | G12 | PG12 | LCD FPC B1 | Reset state | D6 | PD6 | LCD FPC B2 | Reset state |
| 12 | I2 | PI2 | LCD FPC G7 | Reset state | G14 | PG14 | LCD FPC B0 | Reset state |
| 13 | C10 | PC10 | microSD D2, 10 kohm pull-up | Reset state | I3 | PI3 | None | Reset state |
| 14 | C11 | PC11 | microSD D3, 10 kohm pull-up | Reset state | A15 | PA15 | None | Reset state |
| 15 | D4 | PD4 | None | Reset state | D3 | PD3 | None | Reset state |
| 16 | D7 | PD7 | None | Reset state | D5 | PD5 | None | USART2_TX to VT8MT |
| 17 | G10 | PG10 | None | Reset state | G9 | PG9 | None | Reset state |
| 18 | B3 | PB3 | None | Reset state | G11 | PG11 | None | Reset state |
| 19 | B5 | PB5 | None | Reset state | B4 | PB4 | None | Reset state |
| 20 | B8 | PB8 | None | Reset state | B7 | PB7 | None | Reset state |
| 21 | C13 | PC13 | None | Reset state | B9 | PB9 | None | Reset state |
| 22 | E6 | PE6 | LCD FPC G1 | Reset state | E5 | PE5 | LCD FPC G0 | Reset state |
| 23 | E4 | PE4 | None | Reset state | E3 | PE3 | None | Reset state |
| 24 | F10 | PF10 | LCD FPC data enable | Reset state | G13 | PG13 | LCD FPC R0 | Reset state |
| 25 | I9 | PI9 | LCD FPC VSYNC | Reset state | I10 | PI10 | LCD FPC HSYNC | Reset state |
| 26 | VBT | VBAT | MCU backup supply rail | None | H4 | PH4 | LCD FPC touch reset | Reset state |

### Lower 2x24 Edge Header

| Pos. | Row A | MCU/rail | Board connection | Current firmware | Row B | MCU/rail | Board connection | Current firmware |
| ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | D12 | PD12 | None | Reset state | B6 | PB6 | None | Reset state |
| 2 | E2 | PE2 | None | Reset state | D13 | PD13 | None | Reset state |
| 3 | D11 | PD11 | None | Reset state | B2 | PB2 | None | Reset state |
| 4 | F6 | PF6 | None | Reset state | F7 | PF7 | None | Reset state |
| 5 | F8 | PF8 | None | Reset state | F9 | PF9 | None | Reset state |
| 6 | C0 | PC0 | None | Reset state | C1 | PC1 | None | Reset state |
| 7 | C2 | PC2 | None | Reset state | C3 | PC3 | None | Reset state |
| 8 | B13 | PB13 | None | Reset state | B15 | PB15 | None | Reset state |
| 9 | B14 | PB14 | None | Reset state | B12 | PB12 | None | Reset state |
| 10 | H12 | PH12 | LCD FPC R6 | Reset state | H8 | PH8 | LCD FPC R2 | Reset state |
| 11 | H11 | PH11 | LCD FPC R5 | Reset state | H10 | PH10 | LCD FPC R4 | Reset state |
| 12 | H9 | PH9 | LCD FPC R3 | Reset state | H7 | PH7 | Active-low user LED | GPIO output; heartbeat |
| 13 | B11 | PB11 | None | USART3_RX from BMS | H6 | PH6 | LCD FPC backlight PWM | Reset state |
| 14 | I4 | PI4 | LCD FPC B4 | Reset state | B10 | PB10 | None | USART3_TX to BMS |
| 15 | I5 | PI5 | LCD FPC B5 | Reset state | I6 | PI6 | LCD FPC B6 | Reset state |
| 16 | I7 | PI7 | LCD FPC B7 | Reset state | B1 | PB1 | None | Reset state |
| 17 | B0 | PB0 | None | Reset state | C5 | PC5 | None | Reset state |
| 18 | A7 | PA7 | None | Reset state | C4 | PC4 | None | Reset state |
| 19 | A4 | PA4 | None | Reset state | A6 | PA6 | None | Reset state |
| 20 | A3 | PA3 | None | USART2_RX from VT8MT | A5 | PA5 | None | Reset state |
| 21 | A1 | PA1 | None | Reset state | A2 | PA2 | LCD FPC R1 | Reset state |
| 22 | I8 | PI8 | LCD FPC touch SDA through 120 ohm | Reset state | A0 | PA0 | None | Reset state |
| 23 | I11 | PI11 | LCD FPC touch SCL through 120 ohm | Reset state | G3 | PG3 | LCD FPC touch interrupt through 1 kohm | Reset state |
| 24 | Vref | VREF+ | MCU analog reference | None | GND | GND | Ground | External common ground |

### LCD1 40-Pin RGB And Touch FPC

The connector is a 40-pin, 0.5 mm-pitch, bottom-contact FPC. The current
firmware does not configure any LTDC or touch function on this connector. Its
5 V LED supply requirement is a board-interface property and is unrelated to
the UART-connected VT8MT display.

| FPC pin | Net/function | MCU/rail | FPC pin | Net/function | MCU/rail |
| ---: | --- | --- | ---: | --- | --- |
| 1 | VLED | 5V | 21 | LCD_G7 | PI2 |
| 2 | VLED | 5V | 22 | LCD_G6 | PI1 |
| 3 | LCD_BL | PH6 | 23 | LCD_G5 | PI0 |
| 4 | GLED | GND | 24 | LCD_G0 | PE5 |
| 5 | GLED | GND | 25 | LCD_G4 | PH15 |
| 6 | VCC | 3.3V | 26 | LCD_G3 | PH14 |
| 7 | VCC | 3.3V | 27 | LCD_G2 | PH13 |
| 8 | TOUCH_RST | PH4 | 28 | LCD_R0 | PG13 |
| 9 | LCD_DE | PF10 | 29 | LCD_R7 | PG6 |
| 10 | LCD_VS | PI9 | 30 | LCD_R6 | PH12 |
| 11 | LCD_HS | PI10 | 31 | LCD_R5 | PH11 |
| 12 | LCD_B0 | PG14 | 32 | LCD_R1 | PA2 |
| 13 | LCD_B7 | PI7 | 33 | LCD_R4 | PH10 |
| 14 | LCD_B6 | PI6 | 34 | LCD_R3 | PH9 |
| 15 | LCD_B5 | PI5 | 35 | LCD_R2 | PH8 |
| 16 | LCD_B1 | PG12 | 36 | GND | GND |
| 17 | LCD_B4 | PI4 | 37 | LCD_CLK | PG7 |
| 18 | LCD_B3 | PA8 | 38 | TOUCH_INT through 1 kohm | PG3 |
| 19 | LCD_B2 | PD6 | 39 | TOUCH_SCLK through 120 ohm | PI11 |
| 20 | LCD_G1 | PE6 | 40 | TOUCH_SDA through 120 ohm | PI8 |

## Fixed Onboard MCU Connections

### Oscillators And Indicators

| MCU pin | Board function | Current firmware state |
| --- | --- | --- |
| PH0/OSC_IN | 25 MHz HSE crystal input | Enabled as PLL1 source |
| PH1/OSC_OUT | 25 MHz HSE crystal output | Enabled as PLL1 source |
| PC14/OSC32_IN | 32.768 kHz LSE crystal input | Not enabled |
| PC15/OSC32_OUT | 32.768 kHz LSE crystal output | Not enabled |
| PH7 | User LED cathode through onboard LED/resistor; active low | GPIO output; 60 BPM heartbeat |
| PA11 | USB OTG FS D- to Type-C connector and upper header | Not configured |
| PA12 | USB OTG FS D+ to Type-C connector and upper header | Not configured |

### microSD Socket

| microSD signal | MCU pin | Additional board connection | Current firmware state |
| --- | --- | --- | --- |
| DAT0 | PC8 | Upper header C8, 10 kohm pull-up | Not configured |
| DAT1 | PC9 | Upper header C9, 10 kohm pull-up | Not configured; former MCO2 test |
| DAT2 | PC10 | Upper header C10, 10 kohm pull-up | Not configured |
| DAT3 | PC11 | Upper header C11, 10 kohm pull-up | Not configured |
| CMD | PD2 | Upper header D2, 10 kohm pull-up | Not configured |
| CLK | PC12 | Upper header C12 | Not configured |
| VDD | 3.3V | Board rail | Always physically supplied with board 3.3 V |
| VSS/shield | GND | Board ground | Ground |

PC9 must not be used as MCO2 while an SD card transaction is active. The old
32 MHz verification implementation was intentionally removed.

### W9825G6KH-6I SDRAM

The board carries a 256-Mbit, 16-bit-wide SDR SDRAM, equivalent to 32 MiB. The
following nets are permanently wired to FMC-capable MCU pins but are not
initialized by the current software.

| SDRAM signals | MCU pins | FMC function |
| --- | --- | --- |
| A0..A5 | PF0..PF5 | FMC_A0..FMC_A5 |
| A6..A9 | PF12..PF15 | FMC_A6..FMC_A9 |
| A10..A12 | PG0..PG2 | FMC_A10..FMC_A12 |
| BA0, BA1 | PG4, PG5 | FMC_BA0, FMC_BA1 |
| D0..D3 | PD14, PD15, PD0, PD1 | FMC_D0..FMC_D3 |
| D4..D12 | PE7..PE15 | FMC_D4..FMC_D12 |
| D13..D15 | PD8..PD10 | FMC_D13..FMC_D15 |
| LDQM, UDQM | PE0, PE1 | FMC_NBL0, FMC_NBL1 |
| SDCLK | PG8 | FMC_SDCLK |
| CKE | PH2 | FMC_SDCKE0 |
| CS | PH3 | FMC_SDNE0 |
| RAS | PF11 | FMC_SDNRAS |
| CAS | PG15 | FMC_SDNCAS |
| WE | PH5 | FMC_SDNWE |

Until FMC clocks, all FMC GPIO alternate functions, timing registers and the
JEDEC SDRAM command sequence are implemented, accesses to the external SDRAM
address range are invalid.

## Intentionally Unconfigured Hardware

The following board or MCU facilities are present but are not enabled by the
current software:

- W9825G6KH-6I external SDRAM and FMC.
- microSD socket and SDMMC1.
- USB OTG FS and a valid USB 48 MHz kernel clock.
- RGB LCD LTDC signals, touch interface and LCD backlight PWM.
- LSE, RTC and backup SRAM use.
- CPU instruction/data caches and MPU.
- DMA and MDMA.
- UART interrupts and NVIC configuration for USART1/2/3.
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

The enclosure connector assignments are based on the integrator's physical
wiring record: M1/M2 are nominal 12 V; M3/M4 are GND; J4 is SWD DIO; and
K1/K2/K3/K4 are SWD CLK, 3.3 V target reference, GND and RST respectively. No
controlled Molex part drawing, harness drawing or internal power schematic has
yet been supplied.

Board-level pin and fixed-net information was cross-checked against:

- [FK743M2-IIT6 V1.1 underside/pin-label photograph](https://images.prom.ua/6492762220_w700_h500_otladochnaya-plata-stm32h743iit6.jpg)
- [FK743M2-IIT6 mechanical drawing](https://shuaiwen-cui.github.io/Warehouse/DEV/FK-STM32H743/FK743-MECHANICAL-DESIGN.pdf)
- [P1 SWD/USART1 circuit](https://github.com/Shuaiwen-Cui/MCU_NODE_STM32/blob/main/MCU_DOC/docs/MAIN-CONTROL/USART/usart_circuit.png)
- [SDRAM circuit](https://github.com/Shuaiwen-Cui/MCU_NODE_STM32/blob/main/MCU_DOC/docs/MAIN-CONTROL/SDRAM/sdram_circuit.png)
- [microSD circuit](https://github.com/Shuaiwen-Cui/MCU_NODE_STM32/blob/main/MCU_DOC/docs/MAIN-CONTROL/SDCARD/sdcard_circuit.png)
- [FK743 RGB LCD/touch interface circuit](https://www.cnblogs.com/Skyrim-sssuuu/p/19187288)
- [STM32H743II product and datasheet page](https://www.st.com/en/microcontrollers-microprocessors/stm32h743ii.html)
- [STM32H743 reference manual RM0433](https://www.st.com/resource/en/reference_manual/rm0433-stm32h743-753-and-stm32h750-value-line-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf)

The board documents available online are vendor/community-hosted rather than a
version-controlled artifact in this repository. For any production wiring,
verify the V1.1 silkscreen and continuity on the actual board, especially the
orientation of headers and FPC pin 1.
