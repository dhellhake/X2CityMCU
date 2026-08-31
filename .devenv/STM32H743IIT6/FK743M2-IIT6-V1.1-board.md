# FK743M2-IIT6 V1.1 Board Profile

This document records intrinsic hardware properties of the FK743M2-IIT6 V1.1
board. It is a controlled companion to the
[hardware/software interface specification](../hsi/FK743M2-IIT6-V1.1-hardware-software-interface.md).
Connector geometry is maintained in the
[connector reference](FK743M2-IIT6-V1.1-connectors.md).
[Return to the board documentation index](README.md).

| Document attribute | Value |
| --- | --- |
| Document ID | `X2C-BRD-001` |
| Board | FK743M2-IIT6 V1.1 |
| MCU | STM32H743IIT6, LQFP176 |
| Lifecycle status | Draft; physical claims require confirmation against a controlled schematic and the production unit |
| Applicable HSI | [`X2C-HSI-001`](../hsi/FK743M2-IIT6-V1.1-hardware-software-interface.md) |
| Applicable safety-process baseline | Inherited from `X2C-HSI-001` |
| Item-level ASIL allocation | Inherited as `TBD` from `X2C-HSI-001` unless a requirement states otherwise |
| Parent technical/software safety requirements | Inherited as `TBD` from `X2C-HSI-001` unless a requirement states otherwise |
| Intended owner | Hardware and MCU software integration |

**Board connection** means that the PCB permanently connects an MCU pin to an
onboard device or board connector. It does not imply that firmware initializes
that device. Board silkscreen signal names omit the `P` prefix; for example,
`A3` denotes MCU pin `PA3`, and `I11` denotes `PI11`.

## Normative Board Constraints

Existing `HSI-*` identifiers retain their original traceability after being
moved from the HSI. `BRD-*` identifiers capture the physical half of requirements
whose MCU configuration remains in the HSI.

The requirement keywords, status terms and verification codes are defined by
`X2C-HSI-001`. Unless a row states otherwise, each requirement inherits that
document's `TBD` ASIL and parent-requirement allocations.

| ID | Requirement | Allocated element | Verification | Current status and evidence |
| --- | --- | --- | --- | --- |
| `BRD-GEN-001` | This target profile shall apply only to an FK743M2-IIT6 V1.1 board populated with an STM32H743IIT6 in the LQFP176 package. | System integration, board configuration | `I`, `T-HW` | Assumption; board identity must be recorded for each test or release unit. |
| `BRD-CLK-001` | The board shall provide the firmware-required 25 MHz HSE crystal on PH0/OSC_IN and PH1/OSC_OUT for crystal-mode operation with bypass disabled. | Board oscillator, system integration | `I`, `A`, `T-HW` | Board connection recorded; oscillator frequency requires controlled hardware evidence. |
| `BRD-UAR-001` | P1 RX shall connect to PA10/USART1_RX and P1 TX shall connect to PA9/USART1_TX at MCU-compatible logic levels. | Board P1, system integration | `I`, `T-HW` | Board route recorded; connector-level electrical verification remains external. |
| `BRD-LED-001` | PH7 shall connect to the user LED cathode through the onboard current-limiting network so that a low GPIO level illuminates the LED. | Board LED, GPIOH | `I`, `T-HW` | Board connection and polarity are recorded; controlled electrical evidence remains external. |
| `BRD-DBG-001` | P1 shall expose PA14/SWCLK, PA13/SWDIO, NRST, target reference and ground without requiring four-wire JTAG. | Board P1, debugger interface | `I`, `T-HW` | P1 mapping is recorded; controlled connector-level evidence remains external. |
| `HSI-PIN-001` | Configured MCU pins shall match this board profile and the connector reference. | MCU GPIO and board wiring | `I`, `T-HW` | Partial; software assignments are implemented, while controlled board-level continuity evidence is external. |
| `HSI-PIN-002` | FMC-connected SDRAM pins shall not be reassigned as application GPIO while the fitted W9825G6KH-6I is present unless the electrical effect is analyzed and approved. | Pin multiplexing, board SDRAM | `I`, `A` | Implemented as a prohibition; FMC is currently unconfigured. |
| `HSI-PIN-003` | PC8, PC9, PC10, PC11, PC12 and PD2 shall remain available to the fitted microSD interface. PC9 shall not output MCO2 while an SD transaction is active. | Pin multiplexing, SDMMC1, RCC | `I`, `T-HW` | Implemented as a prohibition; SDMMC1 and MCO2 are currently unconfigured. |
| `HSI-PIN-004` | PA11 and PA12 shall remain unconfigured until USB OTG FS, its electrical interface and a valid 48 MHz kernel clock are specified and verified. | GPIOA, RCC, USB OTG FS | `I`, `T-HW` | Implemented as a prohibition. |
| `HSI-PIN-005` | LCD1 RGB, timing, touch and backlight pins shall remain unconfigured until ownership, timing, electrical and startup requirements for the attached panel are specified and verified. | LTDC, GPIO, touch interface | `I`, `T-HW` | Implemented as a prohibition. |
| `HSI-PIN-006` | PC14/PC15, LSE, RTC and the backup domain shall remain unconfigured until their use and fault behavior are specified and verified. | RCC, RTC | `I` | Implemented as a prohibition. |

## Board Resource Summary

| Resource | Physical implementation |
| --- | --- |
| HSE | 25 MHz crystal on PH0/PH1 |
| LSE | 32.768 kHz crystal on PC14/PC15 |
| User LED | PH7, active low |
| USB Type-C data | PA11/PA12 |
| microSD | PC8..PC12 and PD2 |
| RGB LCD/touch FPC | LTDC and touch-capable GPIO listed in the connector reference |
| SDRAM | W9825G6KH-6I, 32 MiB, 16-bit FMC interface |

The HSI is the single source of truth for the current software configuration of
these resources.

## Fixed Onboard MCU Connections

### Oscillators, Indicator And USB

| MCU pin | Board function |
| --- | --- |
| PH0/OSC_IN | 25 MHz HSE crystal input |
| PH1/OSC_OUT | 25 MHz HSE crystal output |
| PC14/OSC32_IN | 32.768 kHz LSE crystal input |
| PC15/OSC32_OUT | 32.768 kHz LSE crystal output |
| PH7 | User LED cathode through onboard LED/resistor; active low |
| PA11 | USB OTG FS D- to Type-C connector and upper header |
| PA12 | USB OTG FS D+ to Type-C connector and upper header |

### microSD Socket

| microSD signal | MCU pin | Additional board connection |
| --- | --- | --- |
| DAT0 | PC8 | Upper header C8, 10 kohm pull-up |
| DAT1 | PC9 | Upper header C9, 10 kohm pull-up |
| DAT2 | PC10 | Upper header C10, 10 kohm pull-up |
| DAT3 | PC11 | Upper header C11, 10 kohm pull-up |
| CMD | PD2 | Upper header D2, 10 kohm pull-up |
| CLK | PC12 | Upper header C12 |
| VDD | 3.3 V | Board rail |
| VSS/shield | GND | Board ground |

### W9825G6KH-6I SDRAM

The board carries a 256-Mbit, 16-bit-wide SDR SDRAM, equivalent to 32 MiB. These
nets are permanently wired to FMC-capable MCU pins.

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

Accesses to the external SDRAM address range are invalid until FMC clocks, all
FMC GPIO alternate functions, timing registers, the JEDEC initialization
sequence and the required startup diagnostics have been implemented.

## Historical Board Verification

A previous clock-tree smoke test configured MCO2 on PC9 and measured a 32 MHz
output, confirming the derived clock at that time. The test implementation was
removed, no controlled verification report was retained, and PC9 is currently
unconfigured. PC9 is also connected to microSD DAT1, so any future reuse as
MCO2 requires the ownership constraint in `HSI-PIN-003` to be observed.

## Sources And Confidence

Board-level pin and fixed-net information was cross-checked against:

- [FK743M2-IIT6 V1.1 underside/pin-label photograph](https://images.prom.ua/6492762220_w700_h500_otladochnaya-plata-stm32h743iit6.jpg)
- [FK743M2-IIT6 mechanical drawing](https://shuaiwen-cui.github.io/Warehouse/DEV/FK-STM32H743/FK743-MECHANICAL-DESIGN.pdf)
- [P1 SWD/USART1 circuit](https://github.com/Shuaiwen-Cui/MCU_NODE_STM32/blob/main/MCU_DOC/docs/MAIN-CONTROL/USART/usart_circuit.png)
- [SDRAM circuit](https://github.com/Shuaiwen-Cui/MCU_NODE_STM32/blob/main/MCU_DOC/docs/MAIN-CONTROL/SDRAM/sdram_circuit.png)
- [microSD circuit](https://github.com/Shuaiwen-Cui/MCU_NODE_STM32/blob/main/MCU_DOC/docs/MAIN-CONTROL/SDCARD/sdcard_circuit.png)
- [FK743 RGB LCD/touch interface circuit](https://www.cnblogs.com/Skyrim-sssuuu/p/19187288)

These online board sources are vendor/community-hosted rather than controlled
artifacts in this repository. Production wiring requires confirmation against a
controlled schematic and continuity checks on the actual V1.1 board.
