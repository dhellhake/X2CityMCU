# Communication interfaces

[Application index](README.md) · [SoM UART routes](../som/fet1061-s.md#complete-exposed-uart-routes)

This page records application allocation. All listed SoM UART signals are unbuffered, non-isolated, nominal 3.3 V logic. Transceivers, isolation, protection, and external power-domain handling belong to the carrier design.

## Allocation

| Function | Required format/rate | Peripheral | SoM pads | Status |
|---|---|---|---|---|
| Debug UART | More than 1 Mbit/s requested | LPUART1 | TX 24, RX 23 | Allocated; no project UART1 driver is currently present. |
| BMS | 9600 bit/s, 8 data bits, no parity, 1 stop bit | LPUART6 | MCU TX 29, MCU RX 28 | Implemented and scheduled. |
| ESC | More than 500 kbit/s requested | LPUART3 | MCU TX 7, MCU RX 6 | Proposed allocation; hardware integration remains open. |
| VD18MT | 9600 bit/s, 8 data bits, no parity, 1 stop bit | LPUART2 | MCU TX 12, MCU RX 13 | Implemented, scheduled, level-shifted, and target-tested; wire-level capture remains open. |

`VD18MT` is the canonical connector name used here. Earlier discussion used `VT18MT`; confirm the external device's actual product name before release.

## BMS link

The BMS link is implemented by the [application binding](../../../src/mcu/bmscommunication/mod.rs) over the generic [LPUART driver](../../../src/drv/lpuart/mod.rs). The scheduler invokes the BMS communication task every 10 ms; receive handling itself is interrupt-driven.

The direction mapping is:

| Path | SoM side | External-connector label |
|---|---|---|
| Controller to BMS | LPUART6 TX, SoM pad 29 | `BMS Rx` at J3; the BMS receives this signal. |
| BMS to controller | LPUART6 RX, SoM pad 28 | `BMS Tx` at J2; the BMS drives this signal. |

The connector labels therefore use the BMS perspective. See [power domains and isolation](power-domains-and-isolation.md) before making a direct electrical connection.

## VD18MT link

The restored [VD18MT protocol](../../../src/vd18mt/mod.rs) is connected through the RT1061-specific [LPUART2 binding](../../../src/mcu/vd18mtcommunication/mod.rs). The existing 10 ms communication task invokes both the VD18MT and BMS protocol steps; receive and transmit servicing is interrupt-driven.

The direction mapping is:

| Path | SoM side | External-connector label |
|---|---|---|
| Controller to display | LPUART2 TX, SoM pad 12 | `VD18MT Rx` at H1; the display receives this signal. |
| Display to controller | LPUART2 RX, SoM pad 13 | `VD18MT Tx` at H2; the display drives this signal. |

The recovered project treated the display-side UART as 5 V and required a 3.3 V/5 V level interface. The fitted carrier includes that level shifting between the display and the non-5-V-tolerant SoM pads. The exact circuit, component ratings, power-off behavior, and production margins still require schematic-level qualification; a direct 5 V connection to the SoM remains prohibited.

Received requests are validated for start byte, checksum, assist flag, and wheel diameter. The latest frame carries its scheduler timestamp; any future safety-relevant consumer must impose an explicit freshness limit rather than treating the last valid value as current indefinitely. Until application data is assigned, the controller transmits the protocol's empty/not-working/no-error/stationary state every 100 ms.

An Atmel-ICE RAM-debug HIL run on 2026-08-27 observed one uninterrupted scheduler interval containing 332 valid display frames and 419 controller frames accepted and drained by LPUART2, with zero invalid frames, checksum failures, parser errors, UART errors, or overruns. The latest received frame was `59 10 00 10 00 1E 97`; the controller's intentionally neutral transmitted frame was `43 00 00 00 00 00 07 07 51`. This run did not include an external logic-analyzer capture, so physical TX waveform and far-end reception remain separate verification items.

## Remaining route

- LPUART3 on pads 7/6 avoids the SD bus and Ethernet-2 receive group. The inherited `CSI_*` pad labels do not imply a functional CSI peripheral on the RT1061.
- The debug UART remains on the vendor's normal LPUART1 pair.

Each implementation must configure both the pad mux and the matching input daisy. Baud-rate acceptance must be measured with the final root clock, physical loading, transceiver/isolation path, and cable.

## Related documents

- [External connector](external-connector.md)
- [Power domains and isolation](power-domains-and-isolation.md)
- [Verification](verification.md)
