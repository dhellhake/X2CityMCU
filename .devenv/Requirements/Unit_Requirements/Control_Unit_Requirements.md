# Control unit requirements

**Released in REQ-001-R1.9 — 2026-09-13.** These records derive only from the named ASW parent(s). They preserve the R1.8 197-record release and do not replace parent System verification.

| ID | Target unit / SC | Requirement | Derived from | Planned verification |
|---|---|---|---|---|
| `UR-SET-001` | U-SET-STATE / SC-SET | Retain distinct requested, pending and active level/speed state from current-context interpretable requests; normalize speed as parents specify; replace only the latest valid pending request; atomically apply only at qualified standstill plus physical accelerator rest; preserve valid state on unrecognized speed input; and never manufacture a setting or exceed 40 km/h. | REQ-SYS-LVL-001, REQ-SYS-LVL-002, REQ-SYS-LVL-003, REQ-SYS-LVL-004, REQ-SYS-SPD-002, REQ-SYS-SPD-004, REQ-SYS-SPD-005, REQ-SYS-SPD-008 | `T-SW`, `A`: all levels, speed boundaries, guard combinations, multiple pending values, startup/restart, absent/unrecognized input. |
| `UR-SESSION-001` | U-SESSION-ELIGIBILITY / SC-SESSION | Begin each vehicle context ineligible; issue authority only for complete current qualified Ready evidence; withdraw it for absent, invalid, expired or mismatched prerequisites; latch current-session parent fault inhibition without clearing it merely when observation clears. | REQ-SYS-CTL-001 | `T-SW`, `A`: independently vary prerequisites/faults; reset with old records; expiry/context mismatch; clear fault without restart. |
| `UR-SESSION-002` | U-SESSION-REPORT / SC-SESSION | Select the earliest recognized reportable group fault; for indistinguishable earliest faults select the lowest assigned code; retain the selection until restart above low-charge `0x01`. | REQ-SYS-CTL-004 | `T-SW`, `A`: ordered/tied sets, existing selection, cleared conditions, low-charge ordering and fresh context. |
| `UR-DEMAND-001` | U-DEMAND-ARBITER / SC-DEMAND | Form one current-context signed wheel-demand record from qualified rider/settings, authority and capability/restriction information under parent torque/override rules; emit zero for each both-sign inhibition and distinguish positive-only restriction from permitted negative command. | REQ-SYS-CTL-002 | `T-SW`, `A`: Ready/fault/brake/limit transitions, settings, directions, positive restriction and regeneration; inspect record separately from actual output. |
| `UR-HMI-001` | U-HMI-ADAPTER / SC-HMI | For every outgoing VD18MT update form only parent-defined fields from selected report, usable charge and unsigned current magnitude/fallback, keeping internal validity separate; never treat initialization, loss or unqualified receipt as setting receipt or display acknowledgement. | REQ-SYS-CTL-003 | `T-SW`, `A`: fields/boundaries, invalid fallback, retained report, loss/restart and controlled-reference byte comparison. |
| `UR-LIGHT-001` | U-LIGHT-MODE / SC-LIGHT-POLICY | Retain valid current-session normal-light request initially Off and through communication loss; produce independent front/rear logical modes; select conservative rear Full for unqualified lever/braking information or parent Full triggers. | REQ-SYS-LGTPOL-001 | `T-SW`, `A`: all qualification combinations, normal changes during Full, loss/recovery and fresh session; compare brightness separately. |
| `UR-INPUT-QUAL-001` | U-INPUT-QUALIFIER / SC-INPUT-QUAL | On an affected producer/configuration/reset context change, publish a semantic value only when current qualification/freshness evidence is coherent; otherwise publish unavailable without substituting a prior value. | REQ-SYS-INP-001 | `T-SW`, `A`: initial/invalid/stale/mismatch/reset and independent field qualification. |
| `UR-TRACTION-ACCEPT-001` | U-TRACTION-ACCEPT / SC-TRACTION-CTRL | Reject absent, invalid, expired or context-mismatched authority/command records, request zero of both signs on rejection, and publish a separately qualified acceptance/output-observation record. | REQ-SYS-TRQACC-001 | `T-SW`, `A`: each rejection cause, recovery and context rollover; physical zero separately. |
| `UR-PLATFORM-CONTEXT-001` | U-PLATFORM-CONTEXT / SC-PLATFORM | Create a new local context for an affected event, make old-context local records unusable, and publish retention/health result as qualified or unavailable without clearing a consumer-owned latch or creating a session. | REQ-SYS-PLT-001 | `T-SW`, `A`: reset, failed retention, producer-only restart and shared event cases. |

## ASW coverage index

| ASW requirement(s) | Design / Unit Requirement disposition |
|---|---|
| REQ-SYS-LVL-001, REQ-SYS-LVL-002, REQ-SYS-LVL-003, REQ-SYS-LVL-004, REQ-SYS-SPD-002, REQ-SYS-SPD-004, REQ-SYS-SPD-005, REQ-SYS-SPD-008 | DD-001 U-SET-STATE; UR-SET-001 |
| REQ-SYS-CTL-001/004 | DD-001 U-SESSION-ELIGIBILITY/REPORT; UR-SESSION-001/002 |
| REQ-SYS-CTL-002 | DD-001 U-DEMAND-ARBITER; UR-DEMAND-001 |
| REQ-SYS-CTL-003 | DD-001 U-HMI-ADAPTER; UR-HMI-001 |
| REQ-SYS-LGTPOL-001 | DD-001 U-LIGHT-MODE; UR-LIGHT-001 |
| REQ-SYS-BMSIF-001, REQ-SYS-BMSPOL-001, REQ-SYS-CHGPOL-001, REQ-SYS-SVCIF-001 | DD-002 / Energy_Charging_Unit_Requirements owner scope |
| REQ-SYS-INP-001, REQ-SYS-TRQACC-001, REQ-SYS-PLT-001 | Detailed_Design_Interface_Allocations; DD-001 and their Unit children. |
