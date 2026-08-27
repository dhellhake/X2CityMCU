# Application specification

[Specification index](../README.md) · [SoM reference](../som/fet1061-s.md)

These pages describe the X2CityMCU carrier, firmware deployment, and connected system. They are deliberately separate from the reusable FET1061-S module reference.

## Topics

| Topic | Current authority |
|---|---|
| [Clocking](clocking.md) | Implemented firmware configuration; 600 MHz remains an explicitly unsupported operating point. |
| [Communication interfaces](communication-interfaces.md) | BMS and level-shifted VD18MT links are implemented; ESC and debug-UART integration remain open. |
| [External connector](external-connector.md) | Established assignments supplied for the 48-position Molex connector; unlisted positions remain unknown. |
| [Power domains and isolation](power-domains-and-isolation.md) | Known external power domains plus an unresolved isolation decision. |
| [Debug and boot](debug-and-boot.md) | Established Atmel-ICE SWD wiring and the implemented RAM/QSPI workflows. |
| [Throttle input](throttle-input.md) | Proposed analog front end and acquisition concept; hardware verification is still required. |
| [Brake-handle input](brake-input.md) | Proposed passive two-wire handle identification and hard open/short diagnostics, with explicit architectural limits. |
| [Verification](verification.md) | Cross-topic checks required before a production release. |

## Status language

- **Established**: confirmed project wiring, implementation, or explicitly accepted project decision.
- **Implemented**: present in the current workspace; this does not by itself imply production qualification.
- **Proposed**: selected direction that still needs schematic, hardware, or system confirmation.
- **Open**: no final project decision has been recorded.

Signal direction in application documents is always stated from a named endpoint. Labels such as `BMS Tx` alone retain the connector naming but are not used to infer which device drives the wire.
