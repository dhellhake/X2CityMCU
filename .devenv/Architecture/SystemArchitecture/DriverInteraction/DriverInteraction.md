# DriverInteraction
## DriverInteraction requirements

**Draft addition — 2026-10-13.** **Type:** System Requirement. **Target:** [LE-INPUT (`DriverInteraction`)](../X2CityMCU.md#le-input). **Status:** Draft.

The grouped logical boundary retains the three separately typed child interfaces. This requirement covers their parent-level composition; each child remains responsible for its own interface behavior and acceptance.


| Child function | Grouped member and boundary | Required child contract coverage |
|---|---|---|
| `LE-ACCELERATOR` | `acceleratorConnection`: selected accelerator electrical signal | [REQ-SYS-ACC-003](AcceleratorPositionIdentification/AcceleratorSignalMeasurement/Specification/Requirements.sysml), [REQ-SYS-ACC-031](AcceleratorPositionIdentification/Specification/Requirements.sysml), [REQ-SYS-ACC-043](AcceleratorPositionIdentification/AcceleratorSignalMeasurement/Specification/Requirements.sysml) |
| `LE-MECHANICAL-BRAKE` | `brakeLeverConnection`: passive, shared coded two-wire brake interface | [REQ-SYS-BRK-006](MechanicalBrakeDetection/Specification/Requirements.sysml), [REQ-SYS-BRKHW-001](MechanicalBrakeDetection/BrakeSignalMeasurement/Specification/Requirements.sysml), [REQ-SYS-BRKHW-002](MechanicalBrakeDetection/BrakeSignalMeasurement/Specification/Requirements.sysml) |
| `LE-HMI-CONTROL` | `vd18mtConnection`: supplied VD18MT display, UART, and power-lock interface | [REQ-SYS-HMIE-001](HMIControl/HmiElectricalInterface/Specification/Requirements.sysml), [REQ-SYS-HMIE-002](HMIControl/HmiElectricalInterface/Specification/Requirements.sysml) |

## Specification

- [Requirements](Specification/Requirements.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)
