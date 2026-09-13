# WeAct STM32H723VGT6 Connector Reference

This document is the physical connector reference for the WeAct Studio
STM32H7xx V1.2 board populated with STM32H723VGT6. See the [board profile](WeAct-STM32H723VGT6-board.md)
for fixed onboard resources.
[Return to the board documentation index](README.md).

| Document attribute | Value |
| --- | --- |
| Document ID | `X2C-BRD-004` |
| Board | WeAct Studio STM32H7xx V1.2 / STM32H723VGT6 |
| Lifecycle status | Active target configuration; V1.2 with fitted LCD confirmed by owner on 2026-09-13 |
| Intended owner | Hardware integration |

Signal names below use the MCU port notation (`PA0`, `PB13`, and so on).

## Orientation and numbering

With the board viewed from the **silkscreen side** (the side that prints the
header signal names) and USB-C and microSD at the bottom, P1 is the left 2x22
header and P2 is the right 2x22 header. P1's odd pins are its outside column
and P2's odd pins are its inside column; pins increase from the top down. On
the component side this is mirrored: P1 is on the right and P2 on the left.
P3 is the four-pin SWD header at the top edge. Use the board silkscreen and
the square pin-1 pad when fitting headers.

## P1 2x22 I/O header

| Pin | Board signal | Fixed board connection | Pin | Board signal | Fixed board connection |
| ---: | --- | --- | ---: | --- | --- |
| 1 | GND | Ground | 2 | 5V | Board 5 V input rail |
| 3 | PE1 | DCMI_D3 / camera | 4 | PE0 | DCMI_D2 / camera |
| 5 | PB9 | I2C1_SDA / camera | 6 | PB8 | I2C1_SCL / camera |
| 7 | PB7 | DCMI_VSYNC / camera | 8 | PB6 | OSPI_NCS |
| 9 | PB5 | None | 10 | PB4 | SPI flash MISO |
| 11 | PB3 | SPI flash SCK | 12 | PD7 | SPI flash MOSI |
| 13 | PD6 | SPI flash CS through SB3 | 14 | PD5 | None |
| 15 | PD4 | microSD card detect through SB2 | 16 | PD3 | DCMI_D5 / camera |
| 17 | PD2 | SDMMC1 CMD | 18 | PD1 | None |
| 19 | PD0 | None | 20 | PC12 | SDMMC1 CLK |
| 21 | PC11 | SDMMC1 DAT3 | 22 | PC10 | SDMMC1 DAT2 |
| 23 | PA15 | None | 24 | PA12 | USB D+ |
| 25 | PA11 | USB D- | 26 | PA10 | USART1 RX / UART |
| 27 | PA9 | USART1 TX / UART | 28 | PA8 | DCMI XCLK / MCO1 |
| 29 | PC9 | SDMMC1 DAT1 | 30 | PC8 | SDMMC1 DAT0 |
| 31 | PC7 | DCMI D1 / camera | 32 | PC6 | DCMI D0 / camera |
| 33 | PD15 | None | 34 | PD14 | None |
| 35 | PD13 | OSPI IO3 | 36 | PD12 | OSPI IO1 |
| 37 | PD11 | OSPI IO0 | 38 | PD10 | None |
| 39 | PD9 | None | 40 | PD8 | None |
| 41 | PB15 | None | 42 | PB14 | None |
| 43 | PB13 | None | 44 | PB12 | None |

## P2 2x22 I/O header

| Pin | Board signal | Fixed board connection | Pin | Board signal | Fixed board connection |
| ---: | --- | --- | ---: | --- | --- |
| 1 | GND | Ground | 2 | 3V3 | Board 3.3 V rail |
| 3 | PE2 | OSPI IO2 | 4 | PE3 | Blue user LED, active high |
| 5 | PE4 | DCMI D4 / camera | 6 | PE5 | DCMI D6 / camera |
| 7 | PE6 | DCMI D7 / camera | 8 | VBAT_Pin | VBAT input net |
| 9 | PC13 | K1 user button, active high | 10 | NRST | Reset net |
| 11 | PC0 | None | 12 | PC1 | None |
| 13 | PC2 | None | 14 | PC3 | None |
| 15 | GND | Ground | 16 | VREF+ | MCU analog reference |
| 17 | PA0 | None | 18 | PA1 | None |
| 19 | PA2 | None | 20 | PA3 | None |
| 21 | PA4 | DCMI_HSYNC / camera | 22 | PA5 | None |
| 23 | PA6 | DCMI_PIXCLK / camera | 24 | PA7 | DCMI power-down through SB1 |
| 25 | PC4 | None | 26 | PC5 | None |
| 27 | PB0 | None | 28 | PB1 | None |
| 29 | PB2 | OSPI CLK | 30 | PE7 | None |
| 31 | PE8 | None | 32 | PE9 | None |
| 33 | PE10 | TFT backlight gate, active low | 34 | PE11 | TFT CS |
| 35 | PE12 | TFT SCK / SPI4_SCK | 36 | PE13 | TFT D/C |
| 37 | PE14 | TFT MOSI / SPI4_MOSI | 38 | PE15 | None |
| 39 | PB10 | None | 40 | PB11 | None |
| 41 | 3V3 | Board 3.3 V rail | 42 | 5V | Board 5 V input rail |
| 43 | GND | Ground | 44 | GND | Ground |

## P3 SWD debug header

P3 is a 2.54 mm 1x4 header. The official schematic includes 22 ohm series
resistors in the SWDIO and SWCLK paths. NRST is not present on P3.

| P3 pin | Board signal | MCU/rail | Fixed board function |
| ---: | --- | --- | --- |
| 1 | 3V3 | Target reference / 3.3 V | Atmel-ICE VTref |
| 2 | SWDIO | PA13 through 22 ohm | SWD data |
| 3 | SWCLK | PA14 through 22 ohm | SWD clock |
| 4 | GND | Ground | Debug ground |

## USB-C connector

The USB-C receptacle is USB1 on the official schematic. USB1_DN is PA11 and
USB1_DP is PA12, using the STM32 integrated full-speed PHY. VBUS is the 5 V
board input; CC1 and CC2 use 5.1 kOhm pulldowns. The receptacle also includes
ESD protection.

## microSD socket

The push-push microSD socket is wired for a four-bit SDMMC1 interface. Its
card-detect switch is routed separately through solder bridge SB2.

| Socket pin | Socket signal | MCU/rail | Board detail |
| ---: | --- | --- | --- |
| 1 | DAT2 | PC10 | SDMMC1_D2, 22 ohm series resistor |
| 2 | CD/DAT3 | PC11 | SDMMC1_D3, 22 ohm series resistor |
| 3 | CMD | PD2 | SDMMC1_CMD, 22 ohm series resistor |
| 4 | VDD | 3.3 V | Board rail |
| 5 | CLK | PC12 | SDMMC1_CK, 22 ohm series resistor |
| 6 | VSS | GND | Board ground |
| 7 | DAT0 | PC8 | SDMMC1_D0, 22 ohm series resistor |
| 8 | DAT1 | PC9 | SDMMC1_D1, 22 ohm series resistor |
| 9–12 | Shield/mounting | GND | Socket shield/mounting contacts |
| switch | MicroSD_SW | PD4 through SB2 | Card detect |

The official schematic shows 47 kOhm pull-ups and ESD protection around the
socket.

## TFT LCD FPC

LCD1 is a 10-contact, 0.5 mm-pitch FPC for the 0.96 inch 80x160 TFT. The FPC pin
numbers below are those shown in the official schematic.

| FPC pin | Signal | MCU/rail |
| ---: | --- | --- |
| 1 | LCD_LEDA | 3.3 V through PE10-controlled P-channel stage |
| 2 | LCD_GND | GND |
| 3 | LCD_RESET | SYS_RESET / NRST |
| 4 | LCD_WR_RS | PE13 |
| 5 | LCD_SDA | PE14 / SPI4_MOSI |
| 6 | LCD_SCL | PE12 / SPI4_SCK |
| 7 | LCD_VCC | 3.3 V |
| 8 | LCD_CS | PE11 |
| 9 | LCD_GND | GND |
| 10 | LCD_GND | GND |

The schematic symbol text says `FPC0.5-SMT-8P` but displays ten contacts and
connects both contacts 9 and 10 to ground. Verify the installed FPC footprint
and contact numbering against the actual board before mating a display.

## Camera DCMI FPC

CAMERA is a 24-pin, 0.5 mm-pitch FPC. No camera module population is confirmed
on the target assembly.

| FPC pin | Signal | MCU/rail |
| ---: | --- | --- |
| 1 | OV_STROBE | Test/optional strobe net |
| 2 | DVP_SDA | PB9 / I2C1_SDA |
| 3 | GND | Analog ground |
| 4 | DVP_SCL | PB8 / I2C1_SCL |
| 5 | AVDD-2V8 | Camera analog supply |
| 6 | DVP_RST | SYS_RESET / NRST |
| 7 | DVP_VSYNC | PB7 / DCMI_VSYNC |
| 8 | DVP_PWDN | PA7 through SB1; pulldown fitted |
| 9 | DVP_HSYNC | PA4 / DCMI_HSYNC |
| 10 | DVDD-1V5 | Camera digital supply |
| 11 | 2V8 | Camera supply |
| 12 | DVP_D7 | PE6 / DCMI_D7 |
| 13 | DVP_XCLK | PA8 / MCO1 through 33 ohm resistor |
| 14 | DVP_D6 | PE5 / DCMI_D6 |
| 15 | GND | Ground |
| 16 | DVP_D5 | PD3 / DCMI_D5 |
| 17 | DVP_PCLK | PA6 / DCMI_PIXCLK |
| 18 | DVP_D4 | PE4 / DCMI_D4 |
| 19 | DVP_D0 | PC6 / DCMI_D0 |
| 20 | DVP_D3 | PE1 / DCMI_D3 |
| 21 | DVP_D1 | PC7 / DCMI_D1 |
| 22 | DVP_D2 | PE0 / DCMI_D2 |
| 23 | AF-2V8 option | SB4 to AF-2V8 |
| 24 | GND option | SB5 to GND |

The camera connector is present, but no camera module population is confirmed.
SB1, SB4 and SB5 are intrinsic board option paths; observe the connector's
voltage and control constraints if camera support is implemented.

## Sources

- [Official V1.2 schematic PDF at the pinned WeAct repository revision](https://github.com/WeActStudio/WeActStudio.MiniSTM32H723/blob/0a08d2808291a7ff38c8a4f89748693019257345/Hardware/STM32H7xx%20SchDoc%20V12.pdf)
- [Official WeAct board README](https://github.com/WeActStudio/WeActStudio.MiniSTM32H723/blob/0a08d2808291a7ff38c8a4f89748693019257345/README.md)
- [ST STM32H723VG DS13313 Rev. 5](https://www.st.com/resource/en/datasheet/stm32h723vg.pdf)

The header and onboard connector mappings are transcribed from the V1.2
schematic dated 2023-07-18. The target assembly is the owner-confirmed V1.2
board with the 0.96 inch 80x160 ST7735 LCD fitted (confirmation date:
2026-09-13). No camera module population is confirmed.
