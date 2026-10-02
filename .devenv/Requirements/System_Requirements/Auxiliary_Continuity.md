# Auxiliary continuity

**Type:** System Requirement. **Target:** `LE-VEH`. This cross-cutting obligation remains canonical here because its contributors include HMIControl, LightControl and vehicle electrical protection.

| ID | Requirement | Planned verification / distinguishing cases | Sources | Open dependencies / qualifications |
| --- | --- | --- | --- | --- |
| <a id="req-veh-aux-001"></a>`REQ-VEH-AUX-001` | During powered-on faults, HMI and front/rear lighting shall continue wherever electrical protection and affected functions permit, preserving normal commands and brake-light trigger/priority/release rules. | `I`, `A`, `T-SYS`, `T-FI`. F/L: battery, temperature-limit/information and other faults before/after Ready; separately exercise protection requiring supply withdrawal. | [DEC-FLT-009](../DEC-001_Decisions_and_Open_Issues.md#dec-flt-009) | `WS-OI-007`, `WS-OI-008`, `WS-OI-010`, `WS-OI-016`, `WS-OI-018`, `WS-OI-019`: No operation through failed display/light/supply, indefinite duration, off-state lighting or protection bypass is promised. |

