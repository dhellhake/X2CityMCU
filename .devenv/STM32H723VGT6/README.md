# WeAct STM32H723VGT6 Board Documentation

This directory documents the owner-confirmed WeAct Studio STM32H7xx V1.2 core
board fitted with an STM32H723VGT6 in the LQFP100 package and its onboard
0.96 inch 80x160 ST7735 LCD. The board and fitted LCD combination was confirmed
on 2026-09-13.

The board is selected as the vehicle `HC-CONTROLLER`; its controlled vehicle
integration boundary is recorded in the [allocated traction HSI](../Architecture/DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md).

## Documents

- [WeAct STM32H723VGT6 board profile](WeAct-STM32H723VGT6-board.md) records
  the MCU, power, clocks, fixed onboard resources and board constraints.
- [WeAct STM32H723VGT6 connector reference](WeAct-STM32H723VGT6-connectors.md)
  records the P1/P2 2x22 I/O headers, P3 SWD header and onboard connector
  pinouts.
- [Vehicle-controller integration](../Architecture/DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md)
  records this selection, EVM resource boundary and charger-host open decision.

## Tooling resources

- [`STM32H723VGT6.cfg`](STM32H723VGT6.cfg) configures OpenOCD for the attached
  Atmel-ICE CMSIS-DAP probe and STM32H723VGT6 target.
- [`STM32H723.svd`](STM32H723.svd) is the CMSIS SVD register description used
  by debugger peripheral views. It was obtained from the
  [Open-CMSIS-Pack STM32H7xx DFP v4.1.3](https://github.com/Open-CMSIS-Pack/STM32H7xx_DFP/tree/v4.1.3/CMSIS/SVD),
  file `CMSIS/SVD/STM32H723.svd`, and is accompanied by
  [`LICENSE-Apache-2.0.txt`](LICENSE-Apache-2.0.txt).

- [WeAct STM32H723VGT6 hardware/software interface](../hsi/WeAct-STM32H723VGT6-hardware-software-interface.md)
  records firmware-visible MCU configuration and behavior.

The board profile and connector reference are the source of truth for the
physical board wiring. MCU alternate functions are defined by the ST
datasheet and reference manual.

## Build and hardware test

The workspace is a dependency-free `no_std` Rust firmware. `src/drv` is the
[STM32H723 driver submodule](https://github.com/dhellhake/STM32H723VGT6),
`src/os` is the MCU-independent CortexOs scheduler submodule, and `src/mcu`
owns board pins, clocks and task deployment. `memory.x` owns the internal
memory map; `build.rs` ensures linker-script edits trigger a rebuild.

From the workspace root:

```powershell
git submodule update --init --recursive
rustup target add thumbv7em-none-eabihf
cargo build
cargo build --release --config profile.release.debug=2
openocd -f .devenv/STM32H723VGT6/STM32H723VGT6.cfg
```

Leave OpenOCD running, then use a second terminal:

```powershell
arm-none-eabi-gdb -q -batch -x .devenv/STM32H723VGT6/enable-550mhz.gdb
arm-none-eabi-gdb -q -batch target/thumbv7em-none-eabihf/release/X2CityMCU -x .devenv/STM32H723VGT6/smoke-test.gdb
```

The [provisioning script](enable-550mhz.gdb) enables the persistent
`CPU_FREQ_BOOST` option required for the specified maximum 550 MHz CPU clock.
It preserves other option bits and verifies the runtime mirror after reset;
running it again leaves an already-enabled option unchanged. ST specifies that
this mode disables ITCM/DTCM ECC. Firmware checks the option while running from
HSI and stops initialization if it is absent. See [DS13313](https://www.st.com/resource/en/datasheet/stm32h723vg.pdf)
and [RM0468](https://www.st.com/resource/en/reference_manual/dm00603761.pdf).

The clock tree uses the onboard 25 MHz HSE with PLL1 M=5, N=110 and P=1:
CPU 550 MHz, AXI/AHB 275 MHz, and APB1–4 137.5 MHz. VOS0 and Flash timing
are configured before the switch. SysTick, USART1 and WWDG1 use these clocks.

The [smoke test](smoke-test.gdb) programs internal flash, compares the loadable
sections, checks MCU/register configuration and task progress, injects a missing
watchdog service, verifies recovery, and observes both PE3 heartbeat states.
It leaves the firmware running. Replace `release` with `debug` to test the
debug image. The release `debug=2` setting supplies symbols for inspection;
it retains release optimization.

VS Code's Cortex-Debug launch configuration uses the same target configuration.
OpenOCD backs up its DTCM work area around flash/checksum algorithms because
that area overlaps the relocated vectors and task state. The optional
[live-image verification](verify-live-image.gdb) checks Flash and resumed
scheduling; its two `target/dtcm-*-verify.bin` snapshots must have identical hashes.
USART1 uses PA9/PA10 at 115200 8N1 with an external 3.3 V UART adapter; USB
communication and the fitted ST7735 LCD driver are not implemented. Board
peripherals beyond LED, SWD and USART1 remain unconfigured.

See the [current 550 MHz hardware test record](../hsi/evidence/2026-09-13-stm32h723-550mhz.md)
for results and limits. The [earlier migration test record](../hsi/evidence/2026-09-12-stm32h723-migration.md)
is retained as historical context.
