# External 48-position connector

[Application index](README.md) · [Power domains and isolation](power-domains-and-isolation.md) · [Debug and boot](debug-and-boot.md)

**Status:** the listed assignments are established; all other positions are undocumented. The exact Molex series, part number, keying, and pin numbering must still be recorded from the production connector definition.

## Orientation

The connector is a 12 × 4 matrix. Columns run `A` through `M`, omitting `I`; rows run `1` through `4`.

The view below looks **into the mating/contact face of the male end**. `A1` is the top-left contact, `M1` is the top-right contact, and `M4` is the bottom-right contact. A rear/wire-side view reverses the columns.

`—` means only that no assignment has been documented here. It does not mean the contact is electrically unconnected.

| Row ↓ / column → | `A` | `B` | `C` | `D` | `E` | `F` | `G` | `H` | `J` | `K` | `L` | `M` |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **`1` (top)** | — | — | — | — | `ESC PWR` | — | — | `VD18MT Rx` | `BAT-` | `SWCLK` | — | `12V` |
| **`2`** | — | — | — | — | `ESC Tx` | `AcHdl 3V3` | `BrkHdl B` | `VD18MT Tx` | `BMS Tx` | `Vref` | — | `12V` |
| **`3`** | — | — | — | — | `ESC Rx` | `AcHdl Sig` | `BrkHdl A` | `VD18MT B+` | `BMS Rx` | `GND` | — | `GND` |
| **`4` (bottom)** | — | — | — | — | `ESC Gnd` | `AcHdl Gnd` | `VD18MT Gnd` | `BAT+` | `SWDIO` | `RESET` | — | `GND` |

## Established assignments

| Contact | Assignment | Direction or meaning |
|:---:|---|---|
| `E1` | `ESC PWR` | ESC power-on control input; intended to be driven by the controller through the carrier's level-shifting circuit. |
| `E2` | `ESC Tx` | ESC-driven UART output; intended to reach controller LPUART3 RX. |
| `E3` | `ESC Rx` | ESC UART receive input; intended to be driven by controller LPUART3 TX. |
| `E4` | `ESC Gnd` | ESC UART and power-control reference; its relationship to the controller ground domain must be fixed in the schematic. |
| `F2` | `AcHdl 3V3` | 3.3 V supply to the Hall accelerator handle; `THROTTLE_3V3` in the [throttle-input specification](throttle-input.md). Production protection remains open. |
| `F3` | `AcHdl Sig` | Hall accelerator-handle analog output to the throttle signal front end; `THROTTLE_SIGNAL` in the [throttle-input specification](throttle-input.md). |
| `F4` | `AcHdl Gnd` | Dedicated accelerator-handle signal and supply return; `THROTTLE_GND` in the [throttle-input specification](throttle-input.md). |
| `G2` | `BrkHdl B` | Brake-handle coded-loop conductor B; see [Brake-handle input](brake-input.md). |
| `G3` | `BrkHdl A` | Brake-handle coded-loop conductor A; see [Brake-handle input](brake-input.md). |
| `G4` | `VD18MT Gnd` | VD18MT ground/reference connection; its relationship to the other ground domains must be fixed in the schematic. |
| `H1` | `VD18MT Rx` | External VD18MT receive input; intended to be driven by controller LPUART2 TX. |
| `H2` | `VD18MT Tx` | External VD18MT transmit output; intended to drive controller LPUART2 RX. |
| `H3` | `VD18MT B+` | VD18MT battery-positive supply connection; its voltage and protection requirements must be fixed in the schematic. |
| `H4` | `BAT+` | Battery-positive connection; the documented battery maximum is 58.8 V. |
| `J1` | `BAT-` | Permanent battery-negative connection. |
| `J2` | `BMS Tx` | BMS-driven UART output; intended to reach controller LPUART6 RX. |
| `J3` | `BMS Rx` | BMS receive input; intended to be driven by controller LPUART6 TX. |
| `J4` | `SWDIO` | Atmel-ICE Serial Wire Debug data. |
| `K1` | `SWCLK` | Atmel-ICE Serial Wire Debug clock. |
| `K2` | `Vref` | Debugger target-voltage sense (`VTG`), not target power. |
| `K3` | `GND` | Debug ground/reference. |
| `K4` | `RESET` | Active-low debugger reset connected to SoM `POR_B`. |
| `M1` | `12V` | 12 V system supply; it is not `BAT+`. |
| `M2` | `12V` | 12 V system supply; it is not `BAT+`. |
| `M3` | `GND` | System ground; its relationship to BMS-switched ground must be fixed in the schematic. |
| `M4` | `GND` | System ground; its relationship to BMS-switched ground must be fixed in the schematic. |

## Open connector work

- Record the exact Molex housing/header/terminal part numbers and keying.
- Reconcile the connector's mechanical pin-number convention with this matrix before releasing a harness drawing.
- Define the electrical domain for each `GND`, `12V`, `BAT+`, and `BAT-` contact in the schematic; names alone are not an isolation definition.
- Document every remaining contact or explicitly mark it reserved/no-connect.

## Related documents

- [Communication interfaces](communication-interfaces.md)
- [Throttle input](throttle-input.md)
- [Brake-handle input](brake-input.md)
- [Verification](verification.md)
