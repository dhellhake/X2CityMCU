# Communication interfaces

[Application index](README.md) · [SoM UART routes](../som/fet1061-s.md#complete-exposed-uart-routes)

This page records application allocation. All listed SoM UART signals are unbuffered, non-isolated, nominal 3.3 V logic. Transceivers, isolation, protection, and external power-domain handling belong to the carrier design.

## Allocation

| Function | Required format/rate | Peripheral | SoM pads | Status |
|---|---|---|---|---|
| Debug UART | More than 1 Mbit/s requested | LPUART1 | TX 24, RX 23 | Allocated; no project UART1 driver is currently present. |
| BMS | 9600 bit/s, 8 data bits, no parity, 1 stop bit | LPUART6 | MCU TX 29, MCU RX 28 | Implemented and scheduled. |
| ESC | More than 500 kbit/s requested | LPUART3 | MCU TX 7, MCU RX 6 | Proposed allocation; hardware integration remains open. |
| VD18MT | 9600 bit/s, 8 data bits | LPUART2 | MCU TX 12, MCU RX 13 | Proposed allocation; parity/stop-bit requirements still need confirmation. |

`VD18MT` is the canonical connector name used here. Earlier discussion used `VT18MT`; confirm the external device's actual product name before release.

## BMS link

The BMS link is implemented by the [application binding](../../../src/mcu/bmscommunication/mod.rs) over the generic [LPUART driver](../../../src/drv/lpuart/mod.rs). The scheduler invokes the BMS communication task every 10 ms; receive handling itself is interrupt-driven.

The direction mapping is:

| Path | SoM side | External-connector label |
|---|---|---|
| Controller to BMS | LPUART6 TX, SoM pad 29 | `BMS Rx` at J3; the BMS receives this signal. |
| BMS to controller | LPUART6 RX, SoM pad 28 | `BMS Tx` at J2; the BMS drives this signal. |

The connector labels therefore use the BMS perspective. See [power domains and isolation](power-domains-and-isolation.md) before making a direct electrical connection.

## Proposed remaining routes

- LPUART3 on pads 7/6 avoids the SD bus and Ethernet-2 receive group. The inherited `CSI_*` pad labels do not imply a functional CSI peripheral on the RT1061.
- LPUART2 on pads 12/13 preserves the designated second UART pair. It leaves I2C1 usable as long as UART2 flow control is not selected.
- The debug UART remains on the vendor's normal LPUART1 pair.

Each implementation must configure both the pad mux and the matching input daisy. Baud-rate acceptance must be measured with the final root clock, physical loading, transceiver/isolation path, and cable.

## Related documents

- [External connector](external-connector.md)
- [Power domains and isolation](power-domains-and-isolation.md)
- [Verification](verification.md)
