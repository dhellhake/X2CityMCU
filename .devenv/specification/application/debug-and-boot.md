# Debug and boot

[Application index](README.md) · [SoM reset and debug signals](../som/fet1061-s.md#swdjtag-wiring-debugger-reset-and-vtref)

**Status:** Atmel-ICE SWD wiring, RAM debug, and QSPI image workflows are implemented. QSPI production programming and target behavior still require release-hardware verification.

## Application-connector SWD wiring

The debugger is an Atmel-ICE used through its CMSIS-DAP SWD interface.

| Atmel-ICE function | External contact | FET1061-S connection | Requirement |
|---|:---:|---|---|
| SWDCLK | `K1` | SoM pad 32, `JTAG_TCK/SWD_CLK` | Start with a conservative adapter clock during bring-up. |
| VTG / target voltage reference | `K2` | Sense-only carrier 3.3 V reference | This is an Atmel-ICE input used to detect the target logic level; it is not a target supply. |
| GND | `K3` | Carrier/SoM ground | Keep a short return and ensure the debugger does not bridge an intended isolation domain. |
| nSRST | `K4` | SoM pad 21, `POR_B` | Active-low MCU power-on reset. It is not `POR_BUTTON` or `JTAG_TRST_B`. |
| SWDIO | `J4` | SoM pad 33, `JTAG_TMS/SWD_DIO` | Bidirectional nominal 3.3 V logic. |

The Atmel-ICE target-voltage pin must never source the target. Verify 3.3 V at `K2` before attachment, and do not connect a probe target-power output to it. Official references: [Atmel-ICE SWD pinout](https://onlinedocs.microchip.com/oxy/GUID-DDB0017E-84E3-4E77-AAE9-7AC4290E5E8B-en-US-4/GUID-6A4D7A9A-C350-4FDF-BECA-198D23A19E44.html) and [Atmel-ICE user guide](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-ICE_UserGuide.pdf).

## Boot straps

`BOOT_MODE0` and `BOOT_MODE1` are left unconnected on the project board. The design relies on the documented 10 kΩ pull-ups fitted to the SoM. Because these levels are sampled during reset and the SoM schematic is unavailable, verify their actual voltage and resulting boot mode on every production-intent module revision.

The debugger reset output is connected to `POR_B`, so a reset can re-latch the boot straps and enter the i.MX RT Boot ROM. `POR_B` must not be confused with the module-level `POR_BUTTON` input.

## RAM debug workflow

The VS Code launch configuration **Debug i.MX RT1061 from RAM (Atmel-ICE SWD)**:

1. Builds and validates the RAM image.
2. Halts the target through OpenOCD.
3. Copies the binary to OCRAM at `0x2020_0000`.
4. Sets the vector-table base, stack, and program counter for the RAM image.

This workflow is for quick debug sessions and does not exercise the Boot ROM or QSPI startup path.

## QSPI boot and debug workflow

The QSPI image contains the Boot ROM configuration block and image vector table for the fitted 4 MiB W25Q32-family NOR. On reset, the Boot ROM consumes that metadata from QSPI and transfers control to the image startup code; startup then copies the intended executable sections to their linked RAM/TCM locations before calling `main()`.

The VS Code tasks provide:

- **Build QSPI image (debug)** and **Build QSPI image (release)**.
- **Program QSPI image (debug)** and **Program QSPI image (release)**.

The launch configurations provide programming plus debug for a debug image and attach-only configurations for debug and release images. Programming uses NXP's flash algorithm because the stock OpenOCD configuration has no i.MX RT FlexSPI flash-bank driver; Atmel-ICE remains the SWD transport.

Canonical workspace definitions are [tasks.json](../../../.vscode/tasks.json), [launch.json](../../../.vscode/launch.json), the [OpenOCD target configuration](../../openocd/atmel-ice-mimxrt1061.cfg), and the [QSPI boot metadata](../../../src/mcu/boot.rs).

## Release cautions

- A RAM-only debug success does not validate the QSPI Boot ROM path, reset straps, flash geometry, or copy table.
- The current boot metadata targets the documented 4 MiB W25Q32-family device. Revisit it for a 16 MiB SoM or a different flash ordering code.
- Confirm that programming failure leaves the target halted or reset and that watchdog state cannot resume an unsafe flash-loader context.
- Check debugger connections against the selected system ground/isolation architecture before attaching a grounded workstation.

## Related documents

- [External connector](external-connector.md)
- [Power domains and isolation](power-domains-and-isolation.md)
- [Verification](verification.md)
