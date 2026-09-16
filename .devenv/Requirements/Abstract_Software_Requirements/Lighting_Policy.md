# Lighting policy

**Type:** Abstract Software Requirement. **Target:** [LE-LIGHT-POLICY](../../Architecture/SystemArchitecture/ARCH-001_System_Architecture.md#le-light-policy), realized by **SC-LIGHT-POLICY** within LE-AUX. Part of **REQ-001-R1.6**; [model and shared verification](../REQ-001_Requirements.md).

This leaf owns current-session normal-light command retention and logical mode selection. Physical lamp output, power-on/reset behavior, supply protection and brightness remain system obligations. No PWM, sensing circuit, software host or detailed unit is selected.

| ID | Requirement | Derived from | Planned verification / acceptance | Sources and open dependencies |
|---|---|---|---|---|
| <a id="req-sys-lgtpol-001"></a>`REQ-SYS-LGTPOL-001` | While powered, the lighting policy shall maintain the current-session normal-light request from valid VD18MT commands, initially Off and retained during communication loss, and produce independent front On/Off and rear Off/Dim/Full modes. The front shall follow the normal request. The rear shall select Full if either lever is qualified actuated, active electrical braking is qualified present, or either required state is unqualified; otherwise it shall select Dim for normal On and Off for normal Off. | [LGT-001](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-001), [LGT-002](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-002), [LGT-003](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-003), [LGT-004](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-004), [LGT-005](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-005), [LGT-006](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-006), [LGT-007](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-007), [LGT-008](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-008), [LGT-009](../System_Requirements/HMI_and_Lighting.md#req-veh-lgt-009) | `A`, `T-SW`, `T-SYS`. Cover the table below, ordered qualification/loss/recovery, normal-command changes during Full, communication loss and fresh sessions. Fault report/inhibition retention cannot freeze the light mode. Compare software modes with physical brightness separately. | DEC-LGT-001/002, DEC-FLT-001/009/011; IF-A-005/006; [INT-003](../System_Requirements/Interface_Qualification.md#req-sys-int-003); WS-OI-007/008/012/016. Derive state freshness/coherence, mode-transfer/response bounds, power/reset continuity and physical lamp acceptance. No successful execution or complete physical parent coverage is claimed. |

## Mode and transition contract

`N` is the latest valid normal request, Off before its first receipt in a powered session. The protocol endpoint supplies accepted commands; this policy owns their retained normal-light state. A change requires neither standstill nor pedal rest. `B` is the qualified four-state lever result or Unqualified; `E` is qualified active electrical braking Present/Absent or Unqualified. Unqualified includes never qualified, invalid, unavailable and stale; it does not itself identify a physical lever press or recognized fault.

| B | E | Front | Rear |
|---|---|---|---|
| Unqualified | Any | N | Full |
| Any qualified lever state | Unqualified | N | Full |
| Either/both actuated | Present or Absent | N | Full |
| Both released | Present | N | Full |
| Both released | Absent | N | Dim if N is On; otherwise Off |

Evaluate current information after each applicable command/state change within the derived response budget. Qualifying both released and braking absent releases Full even if a fault remains latched. A fresh powered session resets N to Off; rear mode still follows current qualification/triggers. Recovery of VD18MT communication alone changes no retained request until a valid new command arrives.

Actual electrical braking includes forward torque retarding rollback and motor braking during constant-speed descent. Passive slowing, unrealized torque request, torque sign alone or net battery-current direction alone cannot establish E. Source qualification and inference remain [System Requirements](../System_Requirements/Interface_Qualification.md). Powered-start/reset physical output must meet the system parents even before this software can execute; that coverage remains with LE-AUX/LE-ENERGY integration.
