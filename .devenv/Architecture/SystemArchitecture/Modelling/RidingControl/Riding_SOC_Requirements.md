# RidingControl discharge capability recovery

**Type:** System Requirement. **Target:** `LE-RIDING`.

Part of **REQ-001-R1.6**. [Model, status and cluster index](../../../../Requirements/REQ-001_Requirements.md) · [Shared verification](../../../../Requirements/REQ-001_Requirements.md#reading-and-verification-rules) · [Common interpretation](../../../../Requirements/REQ-001_Requirements.md#common-interpretation-and-upstream-scope). These rules apply to every row; relocation preserves its approval/status and qualifications.
BatteryControl supplies independently qualified directional current capabilities. RidingControl consumes the allocated traction discharge budget and retains responsibility for resumption when it and the other applicable guards permit propulsion.

The current requirement body is a Draft successor; historical approval remains provenance. BatteryControl owns voltage- and temperature-based capability decisions.

## Capability recovery

| ID | Requirement | Planned verification / distinguishing cases | Sources | Open dependencies / qualifications |
| --- | --- | --- | --- | --- |
| <a id="req-sys-soc-008"></a>`REQ-SYS-SOC-008` **Draft successor** | After propulsion stop, when the communicated qualified traction discharge budget and the other applicable guards permit positive propulsion resumption, that resumption shall use [REQ-SYS-BRK-005](../../../../Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-005) resumption ramps. | `A`, `T-SYS`. E: assess recovery across levels, including pack capability recovery while the reserve leaves the traction budget zero, and overlapping brake/speed/fault constraints; verify the ramp is not consumed before resumption is permitted; warning clearance is independent of ramp completion. | [DEC-SOC-001](../../../../Requirements/DEC-001_Decisions_and_Open_Issues.md#dec-soc-001), [DEC-BRK-002](../../../../Requirements/DEC-001_Decisions_and_Open_Issues.md#dec-brk-002) | `WS-OI-003`, `WS-OI-005`, `WS-OI-007`, `WS-OI-010`, `WS-OI-013`, `WS-OI-017`: Level 0 uses Level 1's ramp while keeping its static mapping; Level 5 adds none. |
