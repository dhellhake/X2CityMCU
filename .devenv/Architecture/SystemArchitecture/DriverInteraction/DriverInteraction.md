# DriverInteraction
## DriverInteraction requirements

**Draft addition — 2026-10-13.** **Type:** System Requirement. **Target:** [LE-INPUT (`DriverInteraction`)](../X2CityMCU.md#le-input). **Status:** Draft.

The grouped logical boundary retains the three separately typed child interfaces. This requirement covers their parent-level composition; each child remains responsible for its own interface behavior and acceptance.

| ID | Requirement | Derived from | Related child interface contracts | Planned verification / remaining gate |
|---|---|---|---|---|
| <a id="req-sys-dri-001"></a>`REQ-SYS-DRI-001` **Draft** | `LE-INPUT` shall provide one grouped `DriverElectricalConnectionPort` containing distinct typed `acceleratorConnection`, `brakeLeverConnection`, and `vd18mtConnection` members, bind each member to its responsible child function, and preserve each constituent electrical contract. | [REQ-SYS-HSI-001](../../../Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-001), [REQ-SYS-HSI-002](../../../Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-002). The parent grouping rationale is recorded in [ARCH-001](../X2CityMCU.md#le-input). | See the coverage table below; these references identify endpoint obligations, not additional derivation parents. | `I`, `T-SYS`: inspect the typed members, directions, and bindings against the responsible child ports; trace representative signals through each delegation. Electrical compatibility and child acceptance remain open under the linked contracts. |

| Child function | Grouped member and boundary | Required child contract coverage |
|---|---|---|
| `LE-ACCELERATOR` | `acceleratorConnection`: selected accelerator electrical signal | [REQ-SYS-ACC-003](AcceleratorPositionIdentification/AcceleratorSignalMeasurement/AcceleratorSignalMeasurement.md#req-sys-acc-003), [REQ-SYS-ACC-031](AcceleratorPositionIdentification/AcceleratorPositionIdentification.md#req-sys-acc-031), [REQ-SYS-ACC-043](AcceleratorPositionIdentification/AcceleratorSignalMeasurement/AcceleratorSignalMeasurement.md#req-sys-acc-043) |
| `LE-MECHANICAL-BRAKE` | `brakeLeverConnection`: passive, shared coded two-wire brake interface | [REQ-SYS-BRK-006](MechanicalBrakeDetection/MechanicalBrakeDetection.md#req-sys-brk-006), [REQ-SYS-BRKHW-001](MechanicalBrakeDetection/BrakeSignalMeasurement/BrakeSignalMeasurement.md#req-sys-brkhw-001), [REQ-SYS-BRKHW-002](MechanicalBrakeDetection/BrakeSignalMeasurement/BrakeSignalMeasurement.md#req-sys-brkhw-002) |
| `LE-HMI-CONTROL` | `vd18mtConnection`: supplied VD18MT display, UART, and power-lock interface | [REQ-SYS-HMIE-001](HMIControl/HmiElectricalInterface/HmiElectricalInterface.md#req-sys-hmie-001), [REQ-SYS-HMIE-002](HMIControl/HmiElectricalInterface/HmiElectricalInterface.md#req-sys-hmie-002) |
