# Development Documentation

- [Requirements workstream](Requirements/README.md) indexes the historical releases, current PD/item drafts,
  released REQ-001-R1.6 clusters, completion gates and [logical architecture](Architecture/ARCH-001_System_Architecture.md).
- [Selected battery and BMS](Battery/BAT-001_Selected_Pack_and_BMS.md) records the built
  14S5P Samsung 35E pack, JBD SP14S004P14S50A UART and derived integration limits.
- [FK743M2-IIT6 V1.1 board documentation](STM32H743IIT6/README.md) contains the
  FK743M2-IIT6 board profile, physical connector reference, OpenOCD
  configuration and debugger SVD.
- [FK743M2-IIT6 V1.1 hardware/software interface](hsi/FK743M2-IIT6-V1.1-hardware-software-interface.md)
  contains the firmware-visible MCU configuration, startup, memory, scheduler,
  watchdog and peripheral requirements.
- [DRV8300DRGE-EVM integration reference](DRV8300DRGE-EVM/README.md) contains
  the reduced vendor documentation set for motor-control firmware development
  with the external three-phase power stage.

The FK743M2-IIT6 V1.1 is the only supported controller board. Its physical
facts belong under `STM32H743IIT6/`; MCU/software configuration belongs under
`hsi/`; documentation for attached development hardware belongs in its named
directory.
