# Development Documentation

- [Functional concept](Architecture/FC-001_Functional_Concept.md) and [function trace](Architecture/FC-002_Function_Trace.md)
  are released as **FC-001-R1.1 / FC-002-R1.1**, with 19 functions and the approved Hall/FOC contribution refinement.
  The [release record](Architecture/FC-001_Functional_Concept.md#release-record) preserves logical architecture
  Draft0.3 as a historical snapshot and REQ-001 Draft1.7, including 12 proposed safety-derived requirements, as supporting Drafts.
- [Component architecture](Architecture/SystemArchitecture/X2CityMCU.md) and [hardware architecture](Architecture/ARCH-002_Hardware_Architecture.md) retain released **ARCH-001-R1.0 / ARCH-002-R1.1** as historical baselines. Current E/E scope and software realization remain Draft/pending; future allocation and acceptance remain open.
- [Hazard analysis](Safety/HARA-001_Hazard_Analysis.md) and [safety goals](Safety/SG-001_Safety_Goals.md)
  are released as **HARA-001-R1.0 / SG-001-R1.0**, with trace to REQ-001-R1.6.
  The [release record](Safety/HARA-001_Hazard_Analysis.md#release-record) retains the analysis assumptions
  and open safety-concept/validation gates; no formal ASIL claim is made.
- [Requirements workstream](Architecture/README.md) indexes the historical releases, current PD/item drafts,
  the 310-record Draft REQ-001 successor (five inactive records retained), completion gates and [logical architecture](Architecture/SystemArchitecture/X2CityMCU.md). System and abstract software/hardware obligations remain active; Unit Requirements remain a future requirement type with no active unit catalogue.
- Future architecture and requirements work follows the [AG-001 operational/reporting interface guideline](Architecture/SystemArchitecture/X2CityMCU.md#ag-001-operational-and-reporting-interfaces).
- [Selected battery and BMS](Architecture/SystemArchitecture/BatteryControl/BatteryAssembly/BatteryAssembly.md#fixed-inputs-and-provenance) records the built
  14S5P Samsung 35E pack, installed JBD SP14S004 hardware V1.0 / firmware 3.2,
  UART and derived integration limits.
- [WeAct STM32H723VGT6 board documentation](STM32H723VGT6/README.md) contains the
  WeAct board profile, physical connector reference, OpenOCD
  configuration and debugger SVD.
- The owner-selected WeAct STM32H723VGT6 is the vehicle main controller; its
  EVM interface and qualification boundary is recorded with the board documents.
- [WeAct STM32H723VGT6 hardware/software interface](hsi/WeAct-STM32H723VGT6-hardware-software-interface.md)
  contains the firmware-visible MCU configuration for the owner-confirmed V1.2
  board with fitted 0.96 inch 80x160 ST7735 LCD, including 550 MHz startup,
  memory, scheduler, watchdog and peripheral requirements.
- [DRV8300DRGE-EVM vendor reference](Architecture/SystemArchitecture/Traction/TractionControl/TractionHardware/TractionHardware.md#drv8300drge-evm-vendor-reference) retains
  the reduced vendor documentation set. The owner-selected-board [integration and
  requirements fit](Architecture/SystemArchitecture/Traction/TractionControl/TractionHardware/TractionHardware.md#drv8300drge-evm-integration-and-requirements-fit)
  records the separate project allocation, host/adapter and acceptance boundaries.
  The canonical [EVM–WeAct traction HSI](Architecture/SystemArchitecture/Traction/TractionControl/TractionHardware/TractionHardware.md#drv8300drge-evm--weact-stm32h723vgt6-traction-hsi)
  contains the one vehicle pin/peripheral/epoch/inhibit contract and its Draft qualification gates. Software realization and runtime integration remain pending.

The owner-selected WeAct Studio STM32H723VGT6 is the vehicle controller board; its existing firmware evidence remains a controlled development configuration. Its physical
facts belong under `STM32H723VGT6/`; MCU/software configuration belongs under
`hsi/`; documentation for attached development hardware belongs in its named
directory.
