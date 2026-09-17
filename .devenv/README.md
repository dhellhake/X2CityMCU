# Development Documentation

- [Functional concept](Architecture/FC-001_Functional_Concept.md) and [function trace](Architecture/FC-002_Function_Trace.md)
  are released as **FC-001-R1.1 / FC-002-R1.1**, with 19 functions and the approved Hall/FOC contribution refinement.
  The [release record](Architecture/FC-001_Functional_Concept.md#release-record) preserves logical architecture
  Draft0.3 as a historical snapshot and REQ-001 Draft1.7, including 12 proposed safety-derived requirements, as supporting Drafts.
- [Component architecture](Architecture/SystemArchitecture/ARCH-001_System_Architecture.md), [hardware](Architecture/ARCH-002_Hardware_Architecture.md)
  and [software](Architecture/SoftwareArchitecture/ARCH-003_Software_Architecture.md) retain released **ARCH-001-R1.0 / ARCH-002/003-R1.1**;
  **ARCH-002/003 Draft1.3** refine the selected EVM traction-board and WeAct vehicle-host boundaries pending review.
  Their [release record](Architecture/SystemArchitecture/ARCH-001_System_Architecture.md#release-identity) preserves the historical released composition, while the current vehicle-only architecture and completion B remain open.
- [ARCH-003 static port registry and route catalogue](Architecture/SoftwareArchitecture/ARCH-003_Software_Architecture.md#static-port-registry-and-connection-catalogue)
  indexes the 14 component types, 19 local instances, architectural ports and complete local/external route catalogue.
- [Detailed design](Architecture/SoftwareArchitecture/DetailedDesign/DD-001_Software_Unit_Design.md), [battery-protection design](Architecture/SoftwareArchitecture/DetailedDesign/DD-002_Battery_Protection_Unit_Design.md),
  [static views](Architecture/SoftwareArchitecture/DetailedDesign/DD-003_Static_Software_Architecture_Views.md) and [dynamic views](Architecture/SoftwareArchitecture/DetailedDesign/DD-004_Dynamic_Software_Architecture_Views.md)
  retain **DD-002-R1.0** and REQ-001-R2.0; **DD-001/003/004 Draft1.3/1.3/1.3** are working successors. They cover unit composition, local host instances,
  interfaces and documented interaction/state examples; they make no implementation or physical-acceptance claim.
- [Motor evidence](Motor/MOT-001_Motor_Interface_Evidence.md) and [Hall-sensored FOC technical design](Motor/MCD-001_Hall_Sensored_FOC_Technical_Design.md)
  record the observed hub-motor interface and selected traction-control realization. **MCD-001 Draft1.2** records the selected EVM/WeAct boundary; calibration, traction hardware and 40-km/h voltage-headroom qualification remain open.
- [Hazard analysis](Safety/HARA-001_Hazard_Analysis.md) and [safety goals](Safety/SG-001_Safety_Goals.md)
  are released as **HARA-001-R1.0 / SG-001-R1.0**, with trace to REQ-001-R1.6.
  The [release record](Safety/HARA-001_Hazard_Analysis.md#release-record) retains the analysis assumptions
  and open safety-concept/validation gates; no formal ASIL claim is made.
- [Requirements workstream](Requirements/README.md) indexes the historical releases, current PD/item drafts,
  released REQ-001-R1.6 clusters, completion gates and [logical architecture](Architecture/SystemArchitecture/ARCH-001_System_Architecture.md).
- [Selected battery and BMS](Battery/BAT-001_Selected_Pack_and_BMS.md) records the built
  14S5P Samsung 35E pack, JBD SP14S004P14S50A UART and derived integration limits.
- [WeAct STM32H723VGT6 board documentation](STM32H723VGT6/README.md) contains the
  WeAct board profile, physical connector reference, OpenOCD
  configuration and debugger SVD.
- The owner-selected WeAct STM32H723VGT6 is the vehicle main controller; its
  EVM interface and qualification boundary is recorded with the board documents.
- [WeAct STM32H723VGT6 hardware/software interface](hsi/WeAct-STM32H723VGT6-hardware-software-interface.md)
  contains the firmware-visible MCU configuration for the owner-confirmed V1.2
  board with fitted 0.96 inch 80x160 ST7735 LCD, including 550 MHz startup,
  memory, scheduler, watchdog and peripheral requirements.
- [DRV8300DRGE-EVM vendor reference](DRV8300DRGE-EVM/README.md) retains
  the reduced vendor documentation set. The owner-selected-board [integration and
  requirements fit](Architecture/DRV8300DRGE-EVM/DRV8300DRGE-EVM_Integration_and_Requirements_Fit.md)
  records the separate project allocation, host/adapter and acceptance boundaries.
  The canonical [EVM–WeAct traction HSI](Architecture/DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md)
  contains the one vehicle pin/peripheral/epoch/inhibit contract and its Draft qualification gates. The Draft
  [vehicle runtime integration contract](Architecture/SoftwareArchitecture/Runtime_Integration_Contract.md) maps the logical
  software units to project startup/IRQ/DMA bindings, direct fast calls and deferred static routes.

The owner-selected WeAct Studio STM32H723VGT6 is the vehicle controller board; its existing firmware evidence remains a controlled development configuration. Its physical
facts belong under `STM32H723VGT6/`; MCU/software configuration belongs under
`hsi/`; documentation for attached development hardware belongs in its named
directory.
