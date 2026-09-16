# WeAct STM32H723VGT6 Board Profile

This document records intrinsic hardware properties of the WeAct Studio
Owner-confirmed WeAct STM32H7xx V1.2 core board populated with an STM32H723VGT6
and fitted with its 0.96 inch 80x160 ST7735 LCD. See the
[connector reference](WeAct-STM32H723VGT6-connectors.md) for physical header
pinouts.
[Return to the board documentation index](README.md).

| Document attribute | Value |
| --- | --- |
| Document ID | `X2C-BRD-003` |
| Board | WeAct Studio STM32H7xx V1.2 / STM32H723VGT6 |
| MCU | STM32H723VGT6, LQFP100 |
| Lifecycle status | Active target configuration; V1.2 with fitted LCD confirmed by owner on 2026-09-13 |
| Intended owner | Hardware and MCU software integration |

The official WeAct schematic is titled `STM32H7XX Board`, revision V1.2, dated
2023-07-18. The repository README describes the board as a 40.64 mm x 66.88 mm
core board. This profile covers the confirmed H723VGT6 assembly only.

## Normative board constraints

| ID | Requirement | Verification | Current status and evidence |
| --- | --- | --- | --- |
| `BRD-GEN-003` | This target profile shall apply to a WeAct Studio STM32H7xx V1.2 board populated with an STM32H723VGT6 in LQFP100. | `I`, `T-HW` | Board identity and package shall be recorded for each test or release unit. |
| `BRD-CLK-003` | Firmware crystal mode shall use the fitted 25 MHz HSE on PH0/OSC_IN and PH1/OSC_OUT with bypass disabled. | `I`, `T-HW` | Confirmed by the official V1.2 schematic; startup on the actual unit remains to be measured. |
| `BRD-LSE-003` | PC14/OSC32_IN and PC15/OSC32_OUT shall be treated as the fitted 32.768 kHz LSE connections when RTC use is enabled. | `I`, `T-HW` | Confirmed by the official V1.2 schematic; crystal load and RTC accuracy remain to be measured. |
| `BRD-LED-003` | PE3 shall drive the blue user LED through the fitted NPN transistor. A high PE3 level illuminates the LED; a low level turns it off. | `I`, `T-HW` | Confirmed by schematic and WeAct example code. |
| `BRD-KEY-003` | K1 shall be read on PC13. Pressing K1 drives PC13 high; firmware may use a pulldown. | `I`, `T-HW` | Confirmed by schematic and WeAct example code. |
| `BRD-DBG-003` | P3 shall expose 3V3, SWDIO, SWCLK and GND. The four-pin header has no NRST connection; debugger reset shall use the core's system reset request or the separate NRST button. | `I`, `T-HW` | Confirmed by schematic and board resource; probe operation remains a hardware test. |
| `BRD-UAR-003` | PA9/USART1_TX and PA10/USART1_RX are available on P1 for an external USB-UART adapter. | `I`, `T-HW` | Confirmed by MCU alternate functions and header mapping. |
| `BRD-PWR-003` | Board input shall remain within the documented 3.3 V to 5.5 V range. The onboard converter is documented for up to 1 A output. | `I`, `T-HW` | Confirmed by WeAct README; current draw and thermal margin require measurement. |
| `BRD-MEM-003` | Firmware shall reserve the fixed SPI and OSPI flash nets while the fitted memories remain populated. | `I`, `A` | Confirmed by the official schematic; memory initialization is a separate software requirement. |

## Board resource summary

| Resource | Physical implementation |
| --- | --- |
| HSE | X1, 25 MHz crystal on PH0/PH1 |
| LSE | X2, 32.768 kHz crystal on PC14/PC15 |
| MCU reset | NRST button and MAX809TEUR+T reset supervisor; NRST also reaches P2 |
| Boot selection | BOOT0 button and 10 kOhm pulldown; BOOT0 is not shown on the V1.2 P1/P2 header net map |
| User button | K1 on PC13, active high when pressed |
| User LED | Blue E3 on PE3 through PDTC114ET NPN stage, active high |
| USB | USB-C USB1_DN/USB1_DP on PA11/PA12; 5 V VBUS input |
| microSD | 4-bit SDMMC1 on PC8, PC9, PC10, PC11, PC12 and PD2; card detect on PD4 through SB2 |
| SPI flash | W25Q64, 64 Mbit / 8 MiB, SPI1-style nets; CS passes SB3 |
| OSPI flash | W25Q64, 64 Mbit / 8 MiB, OCTOSPI1 port 1 |
| TFT | 0.96 inch 80x160 RGB ST7735 TFT on a 10-contact FPC; SPI4-style signals |
| Camera connector | 24-pin DCMI FPC; 8-bit DVP, I2C control and optional control jumpers; camera population not confirmed |

## Fixed onboard MCU connections

### Clocks, reset, boot, key and LED

| MCU pin/net | Board function |
| --- | --- |
| PH0/OSC_IN | 25 MHz HSE crystal X1 input |
| PH1/OSC_OUT | 25 MHz HSE crystal X1 output |
| PC14/OSC32_IN | 32.768 kHz LSE crystal X2 input |
| PC15/OSC32_OUT | 32.768 kHz LSE crystal X2 output |
| NRST | MAX809 reset supervisor and SW3 reset button |
| BOOT0 | SW1 boot button and 10 kOhm pulldown |
| PC13 | K1 user button; pressed state is high through 330 ohm series resistor |
| PE3 | Blue LED E3 transistor base; active high |

The four-pin P3 connector exposes only 3V3, SWDIO, SWCLK and GND. There is no
P3 NRST pin in the official schematic. The Atmel-ICE configuration therefore
uses SWD system reset request behavior; the separate board NRST button remains
available for manual reset.

### Connector-reserved peripherals

USB and microSD mappings are retained in the [connector reference](WeAct-STM32H723VGT6-connectors.md).

### SPI and OSPI flash

The official schematic calls both memory devices `W25Qxx` and documents the
default population as W25Q64, 64 Mbit / 8 MiB. Exact die marking is not
controlled by the board schematic and should be recorded during production
inspection.

| SPI flash net | MCU pin |
| --- | --- |
| SPIx_MISO | PB4 |
| SPIx_MOSI | PD7 |
| SPIx_CLK | PB3 |
| SPIx_CS | PD6 through SB3 |

| OSPI flash net | MCU pin / OCTOSPI function |
| --- | --- |
| QSPI_BK1_IO0 | PD11 / OCTOSPIM_P1_IO0 |
| QSPI_BK1_IO1 | PD12 / OCTOSPIM_P1_IO1 |
| QSPI_BK1_IO2 | PE2 / OCTOSPIM_P1_IO2 |
| QSPI_BK1_IO3 | PD13 / OCTOSPIM_P1_IO3 |
| QSPI_CLK | PB2 / OCTOSPIM_P1_CLK |
| QSPI_BK1_NCS | PB6 / OCTOSPIM_P1_NCS |

The board schematic includes 33 ohm series resistors on the flash data and
clock nets and a 100 kOhm SPI-CS pull-up on the V1.2 revision.

### Display and camera connectors

TFT and camera mappings are retained in the [connector reference](WeAct-STM32H723VGT6-connectors.md). No camera module population is confirmed; any future camera use must resolve its voltage, option-bridge and control requirements.

## Sources and confidence

The primary board source is the official WeAct repository at commit
`0a08d2808291a7ff38c8a4f89748693019257345` (master, 2026-02-07):

- [WeAct Studio MiniSTM32H723 README](https://github.com/WeActStudio/WeActStudio.MiniSTM32H723/blob/0a08d2808291a7ff38c8a4f89748693019257345/README.md)
- [Official V1.2 schematic PDF](https://github.com/WeActStudio/WeActStudio.MiniSTM32H723/blob/0a08d2808291a7ff38c8a4f89748693019257345/Hardware/STM32H7xx%20SchDoc%20V12.pdf)
- [Official hardware revision notes](https://github.com/WeActStudio/WeActStudio.MiniSTM32H723/blob/0a08d2808291a7ff38c8a4f89748693019257345/Hardware/README.md)

MCU capabilities, package identity and alternate functions are controlled by
ST's [STM32H723VG product page](https://www.st.com/en/microcontrollers-microprocessors/stm32h723vg.html),
[DS13313 datasheet, Rev. 5](https://www.st.com/resource/en/datasheet/stm32h723vg.pdf)
and [RM0468 reference manual](https://www.st.com/resource/en/reference_manual/dm00603761.pdf).

Board-level claims are based on the V1.2 schematic and the owner-confirmed
2026-09-13 V1.2 assembly with its LCD fitted. Camera population remains
unconfirmed; the camera connector's intrinsic nets and option links are
documented for electrical integration purposes.
