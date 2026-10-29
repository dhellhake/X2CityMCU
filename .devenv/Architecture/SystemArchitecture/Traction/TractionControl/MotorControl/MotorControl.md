# MotorControl
## MotorControl requirements

**Draft successor allocation — 2026-10-02.** **Type:** Abstract Software Requirement. **Target:** `LE-MOTOR-CTRL`; software realization pending.

The rows below are the canonical successors for the transferred traction-control and temperature/supply allocations. `REQ-SYS-INP-002` remains the separate Platform-owned acquisition allocation. MotorControl decides neither Session's retained fault/report policy nor hardware shutdown; it reports qualified observations and commands actuation.


The local estimate covers the inverter branch, not total BMS pack current; excluded conversion/board loads and estimation/transient allowances belong in the upstream allocation reserve. BMS pack-current unavailability alone does not invalidate this estimate. The phase-current FOC loops remain in force. A duty-weighted estimate requires matched applied modulation and reconstructed phase currents; phase-current sum or requested voltage is not DC-current evidence. The ADC's later third-current rank is not simultaneous with the first pair.

The qualified rail prerequisite and recognized runtime rail-fault contributions are the system rows [TRQRAIL-001](../Specification/Requirements.sysml) and [TRQRAIL-002](../Specification/Requirements.sysml). Temperature limits retain the existing `REQ-SYS-TMP-001/002` both-sign fault/restart behavior; this allocation introduces no temperature derating.

## Specification

- [Requirements](Specification/Requirements.sysml)
- [SystemHardwareSoftwareInterface](Specification/SystemHardwareSoftwareInterface.sysml)
- [SystemInterfaceAllocations](Specification/SystemInterfaceAllocations.sysml)
