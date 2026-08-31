# FK743M2-IIT6 V1.1 Connector Reference

This document is the physical connector reference for the FK743M2-IIT6 V1.1
board. See the [board profile](FK743M2-IIT6-V1.1-board.md) for fixed onboard
resources.
[Return to the board documentation index](README.md).

| Document attribute | Value |
| --- | --- |
| Document ID | `X2C-BRD-002` |
| Board | FK743M2-IIT6 V1.1 |
| Lifecycle status | Draft; informative connector reference |
| Configuration item | This Git-controlled Markdown file |
| Intended owner | Hardware integration |

`None` under board connection means that no additional fixed onboard load was
identified. It does not mean that the MCU pin lacks alternate functions; consult
the STM32H743II datasheet for the complete alternate-function matrix.

## Orientation And Numbering

For the two long headers, view the PCB from the underside with the P1 debug/UART
header on the left and the microSD socket on the right. Positions below run
left-to-right. `Row A` is the first printed silkscreen line and `Row B` is the
second printed line. These row names deliberately do not infer undocumented
odd/even connector numbering.

Board silkscreen signal names omit the `P` prefix. For example, `A3` denotes
MCU pin `PA3`, and `I11` denotes `PI11`.

## P1 Debug, UART And Power Header

P1 is electrically a 2x4 header even when only one 1x4 strip is fitted.

| P1 pin | Board signal | MCU/rail | Fixed board function |
| ---: | --- | --- | --- |
| 1 | CLK | PA14 | SWCLK |
| 2 | DIO | PA13 | SWDIO |
| 3 | GND | GND | Ground |
| 4 | 5V | 5 V rail | Board 5 V rail |
| 5 | RX | PA10 | USART1_RX |
| 6 | TX | PA9 | USART1_TX |
| 7 | RST | NRST through 1 kohm | Reset net and reset button |
| 8 | 3V3 | 3.3 V rail | Board 3.3 V rail/reference |

## Upper 2x26 Edge Header

| Pos. | Row A | MCU/rail | Board connection | Row B | MCU/rail | Board connection |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | 5V | 5 V rail | Board supply rail | 5V | 5 V rail | Board supply rail |
| 2 | RST | NRST | Reset button and P1-7 | BT0 | BOOT0 | Boot button/strap |
| 3 | A12 | PA12 | USB OTG FS D+ | A11 | PA11 | USB OTG FS D- |
| 4 | I0 | PI0 | LCD FPC G5 | I1 | PI1 | LCD FPC G6 |
| 5 | H14 | PH14 | LCD FPC G3 | H15 | PH15 | LCD FPC G4 |
| 6 | C6 | PC6 | None | H13 | PH13 | LCD FPC G2 |
| 7 | G6 | PG6 | LCD FPC R7 | C7 | PC7 | None |
| 8 | C8 | PC8 | microSD D0, 10 kohm pull-up | G7 | PG7 | LCD FPC pixel clock |
| 9 | A8 | PA8 | LCD FPC B3 | C9 | PC9 | microSD D1, 10 kohm pull-up |
| 10 | D2 | PD2 | microSD CMD, 10 kohm pull-up | C12 | PC12 | microSD clock |
| 11 | G12 | PG12 | LCD FPC B1 | D6 | PD6 | LCD FPC B2 |
| 12 | I2 | PI2 | LCD FPC G7 | G14 | PG14 | LCD FPC B0 |
| 13 | C10 | PC10 | microSD D2, 10 kohm pull-up | I3 | PI3 | None |
| 14 | C11 | PC11 | microSD D3, 10 kohm pull-up | A15 | PA15 | None |
| 15 | D4 | PD4 | None | D3 | PD3 | None |
| 16 | D7 | PD7 | None | D5 | PD5 | None |
| 17 | G10 | PG10 | None | G9 | PG9 | None |
| 18 | B3 | PB3 | None | G11 | PG11 | None |
| 19 | B5 | PB5 | None | B4 | PB4 | None |
| 20 | B8 | PB8 | None | B7 | PB7 | None |
| 21 | C13 | PC13 | None | B9 | PB9 | None |
| 22 | E6 | PE6 | LCD FPC G1 | E5 | PE5 | LCD FPC G0 |
| 23 | E4 | PE4 | None | E3 | PE3 | None |
| 24 | F10 | PF10 | LCD FPC data enable | G13 | PG13 | LCD FPC R0 |
| 25 | I9 | PI9 | LCD FPC VSYNC | I10 | PI10 | LCD FPC HSYNC |
| 26 | VBT | VBAT | MCU backup supply rail | H4 | PH4 | LCD FPC touch reset |

## Lower 2x24 Edge Header

| Pos. | Row A | MCU/rail | Board connection | Row B | MCU/rail | Board connection |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | D12 | PD12 | None | B6 | PB6 | None |
| 2 | E2 | PE2 | None | D13 | PD13 | None |
| 3 | D11 | PD11 | None | B2 | PB2 | None |
| 4 | F6 | PF6 | None | F7 | PF7 | None |
| 5 | F8 | PF8 | None | F9 | PF9 | None |
| 6 | C0 | PC0 | None | C1 | PC1 | None |
| 7 | C2 | PC2 | None | C3 | PC3 | None |
| 8 | B13 | PB13 | None | B15 | PB15 | None |
| 9 | B14 | PB14 | None | B12 | PB12 | None |
| 10 | H12 | PH12 | LCD FPC R6 | H8 | PH8 | LCD FPC R2 |
| 11 | H11 | PH11 | LCD FPC R5 | H10 | PH10 | LCD FPC R4 |
| 12 | H9 | PH9 | LCD FPC R3 | H7 | PH7 | Active-low user LED |
| 13 | B11 | PB11 | None | H6 | PH6 | LCD FPC backlight PWM |
| 14 | I4 | PI4 | LCD FPC B4 | B10 | PB10 | None |
| 15 | I5 | PI5 | LCD FPC B5 | I6 | PI6 | LCD FPC B6 |
| 16 | I7 | PI7 | LCD FPC B7 | B1 | PB1 | None |
| 17 | B0 | PB0 | None | C5 | PC5 | None |
| 18 | A7 | PA7 | None | C4 | PC4 | None |
| 19 | A4 | PA4 | None | A6 | PA6 | None |
| 20 | A3 | PA3 | None | A5 | PA5 | None |
| 21 | A1 | PA1 | None | A2 | PA2 | LCD FPC R1 |
| 22 | I8 | PI8 | LCD FPC touch SDA through 120 ohm | A0 | PA0 | None |
| 23 | I11 | PI11 | LCD FPC touch SCL through 120 ohm | G3 | PG3 | LCD FPC touch interrupt through 1 kohm |
| 24 | Vref | VREF+ | MCU analog reference | GND | GND | Ground |

## LCD1 40-Pin RGB And Touch FPC

LCD1 is a 40-pin, 0.5 mm-pitch, bottom-contact FPC. Its LED supply is 5 V.

| FPC pin | Net/function | MCU/rail | FPC pin | Net/function | MCU/rail |
| ---: | --- | --- | ---: | --- | --- |
| 1 | VLED | 5 V | 21 | LCD_G7 | PI2 |
| 2 | VLED | 5 V | 22 | LCD_G6 | PI1 |
| 3 | LCD_BL | PH6 | 23 | LCD_G5 | PI0 |
| 4 | GLED | GND | 24 | LCD_G0 | PE5 |
| 5 | GLED | GND | 25 | LCD_G4 | PH15 |
| 6 | VCC | 3.3 V | 26 | LCD_G3 | PH14 |
| 7 | VCC | 3.3 V | 27 | LCD_G2 | PH13 |
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

The online pinout evidence is identified in the
[board profile](FK743M2-IIT6-V1.1-board.md#sources-and-confidence). Before
production use, verify the V1.1 silkscreen, header orientation, continuity and
FPC pin 1 against controlled hardware documentation.
