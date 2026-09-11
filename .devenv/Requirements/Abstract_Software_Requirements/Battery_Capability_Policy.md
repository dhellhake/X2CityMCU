# Battery capability policy

**Type:** Abstract Software Requirement. **Target:** [LE-BAT-POLICY](../../Architecture/ARCH-001_System_Architecture.md#le-bat-policy), realized by SC-BAT-POLICY; final host and configuration-specific deployment remain open.

Part of **REQ-001-R1.6**. [Model and verification rules](../REQ-001_Requirements.md) apply. This allocation derives battery permission/limit information; physical current regulation, protective switching and truthful source information remain system responsibilities.

| ID | Requirement | Derived from | Planned verification / acceptance | Open dependencies / qualifications |
|---|---|---|---|---|
| <a id="req-sys-bmspol-001"></a>`REQ-SYS-BMSPOL-001` | The battery capability policy shall produce qualified battery-side charge/discharge envelopes, operation-specific permission/restriction reasons and recognized battery-fault information from qualified battery observations, effective configuration and the current operating context. Outputs shall distinguish a normal restriction from a fault and shall not grant dependent permission from unavailable required information. | [REQ-SYS-BMS-001](../System_Requirements/Battery_Integration.md#req-sys-bms-001), [REQ-SYS-BMS-006](../System_Requirements/Battery_Integration.md#req-sys-bms-006), [REQ-SYS-BMS-007](../System_Requirements/Battery_Integration.md#req-sys-bms-007), [REQ-SYS-BMS-008](../System_Requirements/Battery_Integration.md#req-sys-bms-008) | `A`, `T-SW`, `T-SYS`, `T-FI`. Exercise the [battery event matrix](../System_Requirements/Battery_Integration.md#battery-event-and-recovery-matrix) with independently varied data quality, path/configuration states and overlapping current/SOC/temperature restrictions. Compare output permissions/limits and causes against the qualified envelope and owner policy; verify physical enforcement separately. | IF-A-003/009; OI-041/045/048/049/061. Derive effective numerical bounds, error/age margins, output representation/update budget and classification evidence. Software outputs do not prove protection with the host unavailable. |

## Output responsibility and system integration

| Contract | Allocation and remaining contribution |
|---|---|
| Physical battery capability | Keep charge and discharge capabilities distinct, including qualified current limits and charge-path acceptance. Limits account for the most restrictive applicable cell/group, temperature, configured protection and connected-component envelope. An unknown required limit cannot enlarge permission. |
| Operation-specific restrictions | Distinguish propulsion limits, regenerative charge acceptance and removed-pack external charging. The 10% propulsion cutoff does not automatically remove auxiliary discharge capability. A discharge-permissible/charge-forbidden temperature is an ordinary regeneration restriction under DEC-TMP-003. |
| Riding integration | LE-SESSION owns the common fault latch and Ready guard; LE-DEMAND owns rider/brake/speed/profile arbitration and regeneration re-entry behavior; LE-TRACTION must enforce physical torque/current capability. A newly available battery envelope alone does not re-enable torque, clear a session fault or increase regeneration while its recovery guard remains unmet. |
| Detached charging integration | LE-CHARGE owns source/connection qualification, 80% ceiling, initial charge need, completion hold, actual charging-fault latch and four visible states. It must operate without vehicle electronics; this software allocation does not select a host or make vehicle-host execution an off-vehicle dependency. |
| Physical protection | LE-ENERGY and the supplied BMS/other derived protection contributors retain the system obligation for energized paths, residual/generated energy, faults and host/UART loss. Vendor protection release is an observation, not automatic permission to resume a system session. |

Only the information-policy contribution is allocated here. Calibration, source accuracy, diagnostics, actual protection and parent system acceptance remain open; no software unit, inverter algorithm or circuit is selected.
