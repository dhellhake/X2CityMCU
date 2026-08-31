# FK743M2-IIT6 V1.1 Board Documentation

This directory is the entry point for the FK743M2-IIT6 V1.1 board documentation
and development resources.

## Documents

- [FK743M2-IIT6 V1.1 board profile](FK743M2-IIT6-V1.1-board.md) records the
  board identity, fitted devices, fixed MCU nets and board-specific constraints.
- [FK743M2-IIT6 V1.1 connector reference](FK743M2-IIT6-V1.1-connectors.md)
  records the physical P1, edge-header and LCD connector pinouts.
- [Hardware/software interface specification](../hsi/FK743M2-IIT6-V1.1-hardware-software-interface.md)
  records firmware-visible MCU configuration and behavior.

## Tooling Resources

- [`STM32H743IIT6.cfg`](STM32H743IIT6.cfg) configures the target for OpenOCD.
- [`STM32H743IIT6.svd`](STM32H743IIT6.svd) describes the MCU register map for
  debugger peripheral views.

The board profile and connector reference are the single source of truth for
physical board wiring. The HSI may reference them but shall not duplicate their
pinout tables or fitted-component claims.
