# Development Documentation

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
