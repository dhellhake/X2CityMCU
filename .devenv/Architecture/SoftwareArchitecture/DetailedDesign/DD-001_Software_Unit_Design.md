# DD-001 — Software unit design

**Draft vehicle baseline — 2026-09-16.** Complete vehicle policy, input, traction and platform unit contracts are retained in their owning component folders.

**Draft 1.3 — 2026-09-14; successor to DD-001-R1.1.** This controlled refinement defines the Hall-position/FOC-control units for the selected EVM traction-board and WeAct vehicle-host boundaries. It implements no code, makes no physical-control claim, and does not revise approved requirement bodies.

## Scope and modelling rules

Each `U-*` unit has one owning `SC-*` component. Unit Requirements derive only from an Abstract Software Requirement .ASW); no Unit Requirement derives directly from System, HSI, FSC, or hardware requirements.

Every local record carries a semantic value, qualification, freshness, producer identity, configuration, and reset/operation context. A consumer accepts it only if all are current, coherent and qualified; absent, stale, invalid and context-mismatched values remain unavailable. A command, acknowledgement, status bit or zero request never proves a physical state. Inputs are immutable snapshots and state/output updates are atomic.

The DRV8300DRGE-EVM and WeAct STM32H723VGT6 are selected vehicle traction-board baseline and host, respectively, but no adapter pin map, task rate, timeout, calibration, diagnostic coverage or physical output is selected. The selected Hall-sensored FOC realization is defined in [MCD-001](../../../Motor/MCD-001_Hall_Sensored_FOC_Technical_Design.md), its [EVM integration contract](../../DRV8300DRGE-EVM/DRV8300DRGE-EVM_Integration_and_Requirements_Fit.md) and its [WeAct host contract](../../DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md); timing/calibration/protection gates remain open. Existing firmware remains development evidence, not final-product acceptance.

## Unit catalogue

| Unit | Owner | Purpose / governing interfaces | ASW disposition |
|---|---|---|---|
| `U-SET-STATE` | [SC-SET](../SettingsPolicy/DetailedDesign/SettingsPolicy_Detailed_Design.md) | requested/pending/active settings, SW-I-001/002 | UR-SET-001 |
| `U-SESSION-ELIGIBILITY` | [SC-SESSION](../SessionPolicy/DetailedDesign/SessionPolicy_Detailed_Design.md) | Ready authority and current-session inhibition, SW-I-004 | UR-SESSION-001 |
| `U-SESSION-REPORT` | [SC-SESSION](../SessionPolicy/DetailedDesign/SessionPolicy_Detailed_Design.md) | report-group selection | UR-SESSION-002 |
| `U-DEMAND-ARBITER` | [SC-DEMAND](../DemandPolicy/DetailedDesign/DemandPolicy_Detailed_Design.md) | signed wheel-demand arbitration, SW-I-001–005 | UR-DEMAND-001 |
| `U-HMI-ADAPTER` | [SC-HMI](../HmiAdapter/DetailedDesign/HmiAdapter_Detailed_Design.md) | VD18MT receipt and outgoing report formation, SW-I-002/006 | UR-HMI-001 |
| `U-LIGHT-MODE` | [SC-LIGHT-POLICY](../LightPolicy/DetailedDesign/LightPolicy_Detailed_Design.md) | retained normal request and front/rear mode, SW-I-005/006 | UR-LIGHT-001 |
| `U-ANALOG-ACQ-REGULAR`, `U-ACCELERATOR-QUALIFY`, `U-BRAKE-QUALIFY` | [SC-ANALOG-ACQ.V](../AnalogAcquisition/DetailedDesign/AnalogAcquisition_Detailed_Design.md), [SC-ACCELERATOR-IF.V](../AcceleratorInterface/DetailedDesign/AcceleratorInterface_Detailed_Design.md), [SC-BRAKE-IF.V](../BrakeInterface/DetailedDesign/BrakeInterface_Detailed_Design.md) | completed regular acquisition and typed rider qualification, SW-I-001 | REQ-SYS-INP-001/002 |
| `U-HALL-CAPTURE`, `U-HALL-POSITION`, `U-MOTOR-PHASE-FAST`, `U-SUPPLY-FAST` | [SC-HALL-IF.V](../HallInterface/DetailedDesign/HallInterface_Detailed_Design.md), [SC-MOTOR-PHASE-IF.V](../MotorPhaseInterface/DetailedDesign/MotorPhaseInterface_Detailed_Design.md), [SC-SUPPLY-IF.V](../SupplyInterface/DetailedDesign/SupplyInterface_Detailed_Design.md) | current Hall/motion, phase-current and Vdc evidence, SW-I-005 | REQ-SYS-TRQPOS-001, REQ-SYS-TRQIO-001 |
| `U-TRACTION-ACCEPT` | [SC-TRACTION-CTRL](../TractionControl/DetailedDesign/TractionControl_Detailed_Design.md) | authority/command acceptance and observation publication, SW-I-004/005 | REQ-SYS-TRQACC-001 |
| `U-TRACTION-ACTUAL-OUTPUT` | [SC-TRACTION-CTRL](../TractionControl/DetailedDesign/TractionControl_Detailed_Design.md) | qualified applied-wheel-torque estimate from post-stage/current/position evidence for Demand, SW-I-005 | REQ-SYS-TRQCTL-001 / UR-TRACTION-ACTUAL-OUTPUT-001 |
| `U-TRACTION-MOTION` | [SC-TRACTION-CTRL](../TractionControl/DetailedDesign/TractionControl_Detailed_Design.md) | qualified vehicle speed/direction/standstill for Demand, Settings and Session, SW-I-005 | REQ-SYS-TRQMOTION-001 / UR-TRACTION-MOTION-001 |
| `U-TRACTION-CONTROL` | [SC-TRACTION-CTRL](../TractionControl/DetailedDesign/TractionControl_Detailed_Design.md) | Hall-sensored FOC current regulation, `PWMAndADCSamplingPlan` production and output/energy observation, internal traction realization | UR-TRACTION-CONTROL-001 |
| `U-TRACTION-OUTPUT` | [SC-TRACTION-CTRL](../TractionControl/DetailedDesign/TractionControl_Detailed_Design.md) | literal CCR1..4/ADC-context stage-commit, deadline-bound PWM latch and inhibit observation | UR-TRACTION-OUTPUT-001 |
| `U-PLATFORM-CONTEXT`, `U-PLATFORM-BINDING`, `U-PLATFORM-RETENTION`, `U-PLATFORM-HEALTH` | [SC-PLATFORM](../Platform/DetailedDesign/Platform_Detailed_Design.md) | context, project startup/vector/DMA binding, retention result and health events, SW-I-009 | REQ-SYS-PLT-001; Draft REQ-SYS-PLT-002 / UR-PLATFORM-BINDING-001 |
| DD-002 units | [BMS-LINK](../BmsLink/DetailedDesign/BmsLink_Detailed_Design.md), [BAT-POLICY](../BatteryProtection/DetailedDesign/BatteryProtection_Detailed_Design.md), [SERVICE-INFO](../ServiceInformation/DetailedDesign/ServiceInformation_Detailed_Design.md) | vehicle energy, regenerative acceptance and service owner scope | DD-002 owner |

## Input, traction and platform derivation gates

`U-ANALOG-ACQ-REGULAR` owns completed regular scans; `U-ACCELERATOR-QUALIFY` and `U-BRAKE-QUALIFY` alone convert them into the typed rider records consumed by Settings, Session, Demand and Light. `U-HALL-CAPTURE` owns current sampled-state/edge evidence and capture health, and `U-HALL-POSITION` publishes electrical position only with accepted map/alignment. `U-MOTOR-PHASE-FAST` and `U-SUPPLY-FAST` publish current same-operation phase-current and Vdc evidence; they do not use regular scans or historical values. These seven units invalidate their own result on producer/reset/configuration/health failure and preserve no prior value as a substitute. The traction-specific ownership and derivation gates are retained in the [TractionControl detailed design](../TractionControl/DetailedDesign/TractionControl_Detailed_Design.md). The platform-specific ownership and derivation gates are retained in the [Platform detailed design](../Platform/DetailedDesign/Platform_Detailed_Design.md).

These are explicit SW realizations in ARCH-003 and support HSI-001/004/007/009. `U-ANALOG-ACQ-FAST`, `U-TRACTION-CONTROL` and `U-TRACTION-OUTPUT` implement the completed fast-epoch, command-data and literal latch sequence defined by the [allocated traction HSI](../../DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md) and [runtime integration contract](../Runtime_Integration_Contract.md). The latter distinguishes project bindings from generic drivers and direct fast calls from scheduled routes. Their distinct ASW requirements and Unit children are recorded in the Control Unit Requirements catalogue. Electrical/sensing, command representation, response bounds, host resources, reset domains, retention integrity, physical outputs and diagnostic coverage remain parent acceptance gates.

## Traceability and verification intent

The catalogue and [Control Unit Requirements](../../../Requirements/Unit_Requirements/Control_Unit_Requirements.md) provide stable unit→SC and ASW→UR mappings; each UR names its parents. Planned unit verification covers state transitions, unavailable/stale/context mismatch, reset and simultaneous-event cases. It is not executed evidence. Parent System requirements retain their stated-level verification including physical output and end-to-end timing.
