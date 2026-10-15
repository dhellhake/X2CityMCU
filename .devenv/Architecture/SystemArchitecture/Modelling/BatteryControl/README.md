# BatteryControl

`LE-BATTERY-CONTROL` is an `LE-EPCS` child. It contains the owner-built physical `BatteryAssembly` (`Cells` plus the supplied `Bms` hardware and vendor firmware) and the vehicle-host `BatterySupervision` project software, realized by the existing BmsLink and BatteryProtection contributions. The energy wrapper is retired; `LE-ENERGY-PATH` is an EPCS sibling. BatteryControl supplies qualified battery information and capability; it does not own motor-controller enforcement or vehicle-wide physical protection.

## Decomposition and required information contracts

```mermaid
flowchart LR
  EPCS[LE-EPCS] --> BC[LE-BATTERY-CONTROL]
  EPCS --> EP[LE-ENERGY-PATH]
  BC --> PBA[BatteryAssembly]
  PBA --> Cells[Cells]
  PBA --> Bms[Bms: supplied HW + vendor FW]
  BC --> BS[BatterySupervision: project SW]
  Bms -->|battery observations| BS
  Cells <-->|cellPower / cellGroupTaps| Bms
  Cells -->|packThermalObservation| Bms
  BS -->|batteryReadinessAndFaultOut| RidingControl[LE-RIDING]
  BS -->|batteryOperatingLimitsOut| RidingControl[LE-RIDING]
  BS -->|stateOfChargeOut| HMI[LE-HMI]
  BS -->|stateOfChargeOut| RidingControl
  BS -->|batteryCurrentOut| HMI
  BC <-->|batteryPower| EP
```

| Port or internal exchange | Mandatory members / consumer | Requirement source |
|---|---|---|
| `batteryPower` ↔ `LE-ENERGY-PATH` | physical pack energy only; energy-path protection and generated/residual energy remain EPCS responsibility | [BMS-004](Battery_Integration.md#req-sys-bms-004), [BMS-005](Battery_Integration.md#req-sys-bms-005), [BMS-009](Battery_Integration.md#req-sys-bms-009) |
| `batteryReadinessAndFaultOut` → `LE-RIDING` | `startupChecksPassed`; recognized thermal and battery faults, each with common `FaultRecognitionOrder` (zero unrecognized; a nonzero tie uses the existing RidingControl report rule). BatterySupervision reports all recognized faults; RidingControl selects the existing earliest fault and no battery-local suppression is introduced. No inference of isolation. | [BMS-005](Battery_Integration.md#req-sys-bms-005), [BMS-006](Battery_Integration.md#req-sys-bms-006), [BMS-007](Battery_Integration.md#req-sys-bms-007), [HMI-007/018](../../../../Requirements/System_Requirements/Session_Report_Policy.md#req-veh-hmi-007), [HMI-011](../DriverInteraction/Decomposition/HMIControl/HMIControl_Requirements.md#req-veh-hmi-011), [HMI-013](../DriverInteraction/Decomposition/HMIControl/HMIControl_Requirements.md#req-veh-hmi-013) |
| `batteryOperatingLimitsOut` → `LE-RIDING` | independent discharge and regenerative-charge branches: `Qualified`, `Permitted`, `CurrentLimitAmperes`, `RestrictionActive/Reason`; plus SOC positive-propulsion permission, torque limit in N·m and speed limit in km/h. The reached-10% latch remains BatterySupervision retention, not a port member. RidingControl demand unit retains demand arbitration and downstream enforcement remains external. | [BMS-001](Battery_Integration.md#req-sys-bms-001), [BMS-008](Battery_Integration.md#req-sys-bms-008), [REQ-SYS-BMSPOL-001](Decomposition/BatterySupervision.sysml), [SOC-001–006](Battery_SOC.md) |
| `stateOfChargeOut` → `LE-HMI`, `LE-RIDING` | qualified `actualStateOfChargePercent` and validity; HMI consumes the display members in HMI-002/003 and RidingControl consumes its low-charge-warning state in HMI-009. | [BMS-003](Battery_Integration.md#req-sys-bms-003), [HMI-002/003](../DriverInteraction/Decomposition/HMIControl/HMIControl_Requirements.md#req-veh-hmi-002), [HMI-009](../../../../Requirements/System_Requirements/Session_Report_Policy.md#req-veh-hmi-009) |
| `batteryCurrentOut` → `LE-HMI` | qualified `signedPackCurrentAmperes` and validity; positive is charging and negative is discharging. Display fallback never authorizes control. | [BMS-003](Battery_Integration.md#req-sys-bms-003), [HMI-020](../DriverInteraction/Decomposition/HMIControl/HMIControl_Requirements.md#req-veh-hmi-020) |
| Bms → BatterySupervision read requests/responses | read-only UART `0x03`, `0x04`, `0x05`, carrying `recordKind` (Basic/FourteenGroup/Identity), `packVoltageVolts`, `packCurrentAmperes`, `stateOfChargeCandidatePercent`, `cellGroupVoltagesVolts[14]`, `availableTemperatures` (`probeIdentifier`, `temperatureCelsius`), `protectionPathState` (`protectionFlags`, charge/discharge-path enabled) and `socSourceEvidence` (reported remaining/full capacity, series count, identity/version). Basic `0x03` supplies its version evidence; identity evidence is separately read through `0x05`. | [BMS-003](Battery_Integration.md#req-sys-bms-003), [REQ-SYS-BMSIF-001](Decomposition/BatterySupervision.sysml) |
| Cells ↔ Bms `cellPower` / `cellGroupTaps` | pack energy and 14-group taps exchange for BMS supervision and balancing | [CELL-001](Decomposition/Cell_Bank.md#req-sys-cell-001), [BMS-002](Battery_Integration.md#req-sys-bms-002), [BMS-003](Battery_Integration.md#req-sys-bms-003) |
| Cells → Bms `packThermalObservation` | available pack thermal observation; count and availability do not prove all individual-cell or thermal fault coverage | [BMS-003](Battery_Integration.md#req-sys-bms-003) |

`BatteryMeasurements` projects these source fields only after fieldwise validity, consistency, qualification and age evidence; each qualified value has an independently named validity indication. Its host-computed update-reference evidence is never a manufactured BMS measurement timestamp. Raw BMS RSOC/capacity is only `stateOfChargeCandidatePercent` until BMS-002/BMS-003 and the SOC policy qualify actual SOC. A UART value, FET/path bit, or project-software limit does not prove physical isolation or protection; the EPCS duties in BMS-004/005/009 remain applicable.
