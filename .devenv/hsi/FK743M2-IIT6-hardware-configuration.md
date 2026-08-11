# FK743M2-IIT6 V1.1 Hardware/Software Interface

This document records the hardware configuration performed by the current
X2CityMCU firmware and the connector pinout of the FK743M2-IIT6 V1.1 board.
The target microcontroller is the STM32H743IIT6 in the LQFP176 package.

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

## Configuration Summary

| Subsystem | Current software state | Principal source |
| --- | --- | --- |
| CPU supply/performance | Internal MCU LDO selected; voltage scale 0/overdrive selected | [`src/mcu/peripherals/pwr.rs`](../../src/mcu/peripherals/pwr.rs) |
| System clock | 25 MHz HSE crystal through PLL1 to 480 MHz CPU clock | [`src/mcu/peripherals/rcc.rs`](../../src/mcu/peripherals/rcc.rs) |
| Flash interface | 4 wait states | [`src/mcu/peripherals/flash.rs`](../../src/mcu/peripherals/flash.rs) |
| FPU | CP10 and CP11 full access enabled before Rust code executes | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs) |
| ITCM/DTCM | Enabled during reset; selected code/data relocated before `main` | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs), [`memory.x`](../../memory.x) |
| Vector table | Copied from Flash to DTCM and `VTOR` redirected to the RAM copy | [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs) |
| SWD | J-Link target connection on PA13, PA14 and NRST | [`.devenv/STM32H743IIT6/STM32H743IIT6.cfg`](../STM32H743IIT6/STM32H743IIT6.cfg) |
| USART1 | Debug/PC UART, 115200 8N1, PA9/PA10 | [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs) |
| USART2 | VD18MT/VT8MT display UART, 9600 8N1, PA3/PD5 | [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs) |
| USART3 | JDB BMS UART, 9600 8N1, PB10/PB11 | [`src/mcu/peripherals/usart.rs`](../../src/mcu/peripherals/usart.rs) |
| SysTick | Processor clock source at 480 MHz; interrupt-driven scheduler deadlines | [`src/drv/systick/mod.rs`](../../src/drv/systick/mod.rs) |
| WWDG1 | Window watchdog enabled for program-flow supervision | [`src/mcu/peripherals/wwdg.rs`](../../src/mcu/peripherals/wwdg.rs) |
| External SDRAM | Fitted and wired, but not initialized or mapped by this firmware | Not configured |
| microSD | Fitted and wired, but SDMMC1 is not initialized | Not configured |
| USB Type-C data | PA11/PA12 are wired, but USB OTG FS is not initialized | Not configured |
| RGB LCD/touch FPC | Fitted and wired, but LTDC/touch GPIO is not initialized | Not configured |
| User LED | PH7 is wired to the active-low LED, but is not initialized | Not configured |
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
11. Configure USART1, USART2 and USART3.
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
| J-Link EDU Mini V2 | DIO / J-Link TMS | PA13/SWDIO | Bidirectional | Active debug connection |
| J-Link EDU Mini V2 | CLK / J-Link TCLK | PA14/SWCLK | Input | Active debug connection |
| J-Link EDU Mini V2 | RST / J-Link RESET | NRST | Input to reset circuit | Active debug connection |
| J-Link EDU Mini V2 | 3.3V / J-Link VCC | 3.3V target reference | Power sense | Active debug connection |
| J-Link EDU Mini V2 | GND | GND | Reference | Active debug connection |
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
| 12 | H9 | PH9 | LCD FPC R3 | Reset state | H7 | PH7 | Active-low user LED | Reset state |
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
| PH7 | User LED cathode through onboard LED/resistor; active low | Not configured |
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
- PH7 user LED.
- CPU instruction/data caches and MPU.
- DMA and MDMA.
- UART interrupts and NVIC configuration for USART1/2/3.
- HSE clock-security system and MCO outputs.

## Sources And Traceability

Firmware configuration is derived directly from this repository, especially:

- [`src/drv/startup/mod.rs`](../../src/drv/startup/mod.rs)
- [`src/mcu/mod.rs`](../../src/mcu/mod.rs)
- [`src/mcu/peripherals`](../../src/mcu/peripherals)
- [`src/os`](../../src/os)
- [`memory.x`](../../memory.x)
- [`.cargo/config.toml`](../../.cargo/config.toml)

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
