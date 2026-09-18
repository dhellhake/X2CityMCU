# Accelerator signal measurement requirements

**Draft addition — 2026-09-18.** **Type:** Abstract Hardware Requirement. **Target:** [LE-ACCELERATOR-HW](../../../ARCH-001_System_Architecture.md#le-accelerator-hw).

`AcceleratorMeasurement` contains the measured signal value and an integrity indication. It does not prescribe acquisition implementation, firmware metadata, or universal fault detection.

| ID | Requirement | Derived from | Related / governing contracts | Planned verification / acceptance |
|---|---|---|---|---|
| <a id="req-sys-acc-003"></a>`REQ-SYS-ACC-003` **Draft** | `LE-ACCELERATOR-HW` shall transform the rider electrical accelerator signal into an observable measured signal value over the allocated electrical input domain. | [REQ-SYS-ACC-001](../AcceleratorPositionIdentification_Requirements.md#req-sys-acc-001), [REQ-SYS-HSI-001](../../../../../Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-001) | Electrical-domain gate: `WS-OI-002`; evidence: `REQ-SYS-ACC-014`. | `T-HW`: stimulate the approved range and verify a measured value. |
| <a id="req-sys-acc-014"></a>`REQ-SYS-ACC-014` **Draft** | `LE-ACCELERATOR-HW` shall provide a coherent `AcceleratorMeasurement` with measured signal value, defined interpretation, and an available integrity indication for software use. | [REQ-SYS-ACC-006](../AcceleratorPositionIdentification_Requirements.md#req-sys-acc-006), [REQ-SYS-HSI-001](../../../../../Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-001) | Software consumer: `REQ-SYS-ACC-002`. | `I`, `T-HW`: present usable and nonusable evidence; verify the integrity indication is available. |
| <a id="req-sys-acc-043"></a>`REQ-SYS-ACC-043` **Draft** | `LE-ACCELERATOR-HW` shall be electrically compatible with the selected accelerator sensor's allocated supply, reference, signal, and loading domain in powered, startup, shutdown, and unpowered integration states. | [REQ-SYS-ACC-031](../AcceleratorPositionIdentification_Requirements.md#req-sys-acc-031) | Characterize electrical limits under `WS-OI-002`, `WS-OI-007`. | `T-HW`, `T-FI`: verify the boundary in each integration state. |
