# Development Documentation

- [Functional concept](Architecture/FC-001_Functional_Concept.md) and [function trace](Architecture/FC-002_Function_Trace.md)
  are released as **FC-001-R1.1 / FC-002-R1.1**, with 19 functions and the approved Hall/FOC contribution refinement.
  The [release record](Architecture/FC-001_Functional_Concept.md#release-record) preserves logical architecture
  Draft0.3 as a historical snapshot and REQ-001 Draft1.7, including 12 proposed safety-derived requirements, as supporting Drafts.
- [Component architecture](Architecture/ARCH-001_System_Architecture.md), [hardware](Architecture/ARCH-002_Hardware_Architecture.md)
  and [software](Architecture/ARCH-003_Software_Architecture.md) are released as **ARCH-001-R1.0 / ARCH-002/003-R1.1**.
  Their [release record](Architecture/ARCH-001_System_Architecture.md#release-record) approves composition, interfaces and deployment,
  including the separate mobile charger; detailed engineering and completion B remain open.
- [Detailed design](Detailed_Design/DD-001_Software_Unit_Design.md), [energy/charging design](Detailed_Design/DD-002_Energy_Charging_Unit_Design.md),
  [static views](Detailed_Design/DD-003_Static_Software_Architecture_Views.md) and [dynamic views](Detailed_Design/DD-004_Dynamic_Software_Architecture_Views.md)
  are released as **DD-001/003/004-R1.1 with DD-002-R1.0** and REQ-001-R2.0. They cover unit composition, local host instances,
  interfaces and documented interaction/state examples; they make no implementation or physical-acceptance claim.
- [Motor evidence](Motor/MOT-001_Motor_Interface_Evidence.md) and [Hall-sensored FOC technical design](Motor/MCD-001_Hall_Sensored_FOC_Technical_Design.md)
  record the observed hub-motor interface and selected traction-control realization. The selection is conditional on calibration, traction hardware and 40-km/h voltage-headroom qualification.
- [Hazard analysis](Safety/HARA-001_Hazard_Analysis.md) and [safety goals](Safety/SG-001_Safety_Goals.md)
  are released as **HARA-001-R1.0 / SG-001-R1.0**, with trace to REQ-001-R1.6.
  The [release record](Safety/HARA-001_Hazard_Analysis.md#release-record) retains the analysis assumptions
  and open safety-concept/validation gates; no formal ASIL claim is made.
- [Requirements workstream](Requirements/README.md) indexes the historical releases, current PD/item drafts,
  released REQ-001-R1.6 clusters, completion gates and [logical architecture](Architecture/ARCH-001_System_Architecture.md).
- [Selected battery and BMS](Battery/BAT-001_Selected_Pack_and_BMS.md) records the built
  14S5P Samsung 35E pack, JBD SP14S004P14S50A UART and derived integration limits.
- [WeAct STM32H723VGT6 board documentation](STM32H723VGT6/README.md) contains the
  WeAct board profile, physical connector reference, OpenOCD
  configuration and debugger SVD.
- [WeAct STM32H723VGT6 hardware/software interface](hsi/WeAct-STM32H723VGT6-hardware-software-interface.md)
  contains the firmware-visible MCU configuration for the owner-confirmed V1.2
  board with fitted 0.96 inch 80x160 ST7735 LCD, including 550 MHz startup,
  memory, scheduler, watchdog and peripheral requirements.
- [DRV8300DRGE-EVM integration reference](DRV8300DRGE-EVM/README.md) contains
  the reduced vendor documentation set for motor-control firmware development
  with the external three-phase power stage.

The WeAct Studio STM32H723VGT6 is the only supported development controller board. Its physical
facts belong under `STM32H723VGT6/`; MCU/software configuration belongs under
`hsi/`; documentation for attached development hardware belongs in its named
directory.
