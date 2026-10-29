# RidingControl
## RidingControl system component

`LE-RIDING` is the system responsibility for riding control. Its software-allocated leaves are `LE-RIDING-POLICY`, retaining settings, session, authority, reporting, demand and existing abstract software policy, and `LE-CURRENT-CONSUMPTION-COORDINATION`, the sole shared battery-current budget authority. Software realization remains pending. RidingControl receives battery operating limits and qualified pack current and makes them available to the coordinator; battery operating limits also support the existing Ready guards. The coordinator sends independently qualified traction budgets to riding policy for publication with the wheel-torque command. MotorControl enforces these budgets using its qualified average inverter DC-current estimate, not a second pack-current feedback loop. No dynamic auxiliary request/grant protocol is selected.

The [current coordination requirements](CurrentConsumptionCoordination/CurrentConsumptionCoordination.sysml) allocate a validated worst-case auxiliary reserve for full-bright lights, display, compute, board/conversion consumption, and justified error and transient allowances. Discharge traction budget is `max(0, battery discharge maximum − reserve)`; regenerative charge allocation does not credit auxiliary draw. Qualified pack current supports shared-budget supervision, but its absence alone does not invalidate a qualified capability or reserve-based budget. If auxiliary load alone exceeds discharge capability, zero traction cannot resolve it; existing all-load protection and auxiliary continuity policies apply. The compiled full-bright lighting component is provisionally 0.2 A battery-side equivalent for front On and rear Full over the qualified operating envelope, pending product validation; changing it requires a rebuild. Total reserve is that component plus the configuration-specific other auxiliary reserve, including nonlighting loads and common margins; the other component and complete reserve remain to be validated. Lighting availability uses this same reserve ahead of traction: qualified zero discharge capability yields qualified false, and otherwise qualified capability and a validated reserve determine availability at the inclusive threshold. Missing required inputs yield unqualified availability. Measurement error, timing, transient and supervision acceptance remain open.

RidingControl owns [resumption when the allocated discharge budget and operating guards permit](RidingControl.md). BatteryControl owns directional current capability from qualified cell/group, temperature, path and other applicable limits; normal discharge uses the qualified lowest-group-voltage endpoint, with no explicit SOC threshold. SOC is used for HMI display only; BatteryStatus supplies independent low-voltage and MOS warning causes. RidingControl consumes qualified capabilities. A qualified zero capability is distinct from an unqualified assessment. The architecture allocation and external interfaces are documented in [ARCH-001](../X2CityMCU.md).

## RidingControl discharge capability recovery

**Type:** System Requirement. **Target:** `LE-RIDING`.

Part of **REQ-001-R1.6**. [Model, status and cluster index](../../REQ-001_Requirements.md) · [Shared verification](../../REQ-001_Requirements.md#reading-and-verification-rules) · [Common interpretation](../../REQ-001_Requirements.md#common-interpretation-and-upstream-scope). These rules apply to every row; relocation preserves its approval/status and qualifications.
BatteryControl supplies independently qualified directional current capabilities. RidingControl consumes the allocated traction discharge budget and retains responsibility for resumption when it and the other applicable guards permit propulsion.

The current requirement body is a Draft successor; historical approval remains provenance. BatteryControl owns voltage- and temperature-based capability decisions.

### Capability recovery

<a id="context-power-startup-and-faults-specification"></a>
<a id="context-riding-safety-functions-specification"></a>
<a id="context-session-report-policy-specification"></a>
## Specification

- [CurrentBudgeting](Specification/CurrentBudgeting.sysml)
- [Requirements](Specification/Requirements.sysml)
- [SessionReportPolicy](Specification/SessionReportPolicy.sysml)

<a id="context-power-startup-and-faults-power-startup-and-fault-handling"></a>
## Power, startup and fault handling

**Targets:** `REQ-SYS-*` → [LE-EPCS](../../REQ-001_Requirements.md#le-epcs).

Part of **REQ-001-R1.6**. [Model, status and cluster index](../../REQ-001_Requirements.md) · [Shared verification](../../REQ-001_Requirements.md#reading-and-verification-rules) · [Common interpretation](../../REQ-001_Requirements.md#common-interpretation-and-upstream-scope). These rules apply to every row; relocation preserves its approval/status and qualifications.

For the selected BMS, apply [battery integration](../BatteryControl/BatteryControl.md) to telemetry qualification, actual protection events and controller-startup effects. Restored communication alone cannot release existing system fault inhibition. Battery-related fault versus ordinary charge-acceptance restriction and known-temperature-violation versus unknown information retain their distinct classifications. [DEC-TMP-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-003) makes qualified discharge-only cell temperatures an ordinary regeneration restriction, preserving otherwise eligible propulsion. Battery operation-required input qualification and event effects are elaborated in [BMS-006–009](../BatteryControl/BatteryControl.md#battery-qualification-and-operating-classification); the wider diagnostic coverage and numeric timing remain open.

<a id="context-power-startup-and-faults-power-control-and-normal-startup"></a>


<a id="context-power-startup-and-faults-communication-loss-fault-response-and-startup-assessment"></a>


<a id="context-power-startup-and-faults-temperature-limit-faults-and-common-fault-response"></a>


<a id="context-power-startup-and-faults-startup-and-runtime-fault-scope"></a>
### Startup and runtime fault scope

This approved coverage catalogue refines the existing obligations; it is not a completed hazard analysis or a claim that the listed faults are detectable. Battery cases remain in the [battery event matrix](../BatteryControl/BatteryControl.md#battery-event-and-recovery-matrix). For each diagnostic, record the actual observation/inference, applicable startup/runtime phase, pass/fail/incomplete criteria, source/common dependencies, recognition bound and evidence. Where startup checks cannot expose a latent or load-dependent fault, assign runtime monitoring, a controlled service check or an explicit unresolved coverage gap; do not declare full coverage from a passing startup.

All recognized riding faults in the common category command both signs to zero and retain inhibition until a clean normal/unexpected restart with all Ready prerequisites. Physical inhibition and residual/generated-energy response need separate evidence under ENE-002/003. The selected first-fault report persists independently of physical clearance; reporting absence cannot suppress the response. Existing codes/ties apply after fault classification, not as a ranking of protective action.

| Coverage group | Required qualification / classification | Report and response trace; responsible contributors |
|---|---|---|
| Startup and execution context | Qualify current-startup inputs/settings, calibration/configuration correspondence and required self-test results. Incomplete checks block Ready. Define control execution, power/reset and command-output checks without applying an unqualified drive command to perform them. A reset must not reuse old pass results or queued authority. | No report solely for initial waiting; explicit failed checks use their assigned category. SOC-only unavailability does not generate 0x07. STA-001–007, INT-002/004, FLT-010; LE-EPCS, LE-RIDING, LE-HMI, LE-BATTERY-CONTROL, LE-TRACTION |
| Accelerator information | Qualify physical range/rest, freshness and defined plausibility. Distinguish valid displacement from recognized electrical/data failure. A value stuck within a plausible range is not proven detectable by range checking. | 0x0A; FLT-003/005/006/009, HMI-004; LE-ACCELERATOR, LE-RIDING, LE-TRACTION |
| Shared coded brake information | Qualify the four states and unknown state against derived electrical/environmental envelopes. Valid actuation is not a fault; continuity and nominal code separation do not detect every bypass-open or valid-code alias. | Recognized fault 0x0D; FLT-004, BRK-006–008/012, HMI-005. Unqualified state independently requires full rear light under LGT-009; LE-INPUT, LE-RIDING, LE-LIGHT-CONTROL, retained LE-MECH |
| Motion and speed | Qualify speed/direction/standstill, fixed-wheel reference and defined loss/plausibility conditions. Wrong VD18MT wheel setting alone and valid stationary motion are not speed faults. | Recognized loss 0x03; FLT-007, HMI-008, INT-001/003; LE-TRACTION, LE-RIDING |
| Motor, commutation, inverter and command/output path | Define command acceptance/tracking, commutation and output-source checks against permitted envelopes. Expected limiting is not a tracking fault; standstill, a held brake or absent motion alone is not a blockage diagnosis. Unqualified actual-output data cannot assert powered forward travel or absence of braking. | Recognized blockage 0x04; output-information loss FLT-012 and other recognized fixing-required faults use 0x05 unless specifically assigned. INT-003/004, HMI-016/017, REG-011, ENE-002/003; LE-TRACTION, LE-RIDING, LE-EPCS |
| Nonbattery temperature | Qualify each required source and applicable component envelope. A known hot/cold violation differs from missing/invalid information; normal permitted performance limits differ from recognized faults. | Known violation 0x06; information fault uses specific code or 0x05. TMP-001/002, STA-007, HMI-013/014/016; LE-INPUT, LE-TRACTION, LE-RIDING |
| Control supply, energy and protection paths | Define observable supply/reset, output/protection-path, short/overcurrent and externally generated-energy failures across applicable configurations. Output-off commands do not prove switching/isolation; host loss requires allocated physical protection, not a hoped-for software report. | Recognized nonbattery riding fault 0x05 unless specifically assigned; FLT-005/006/009, ENE-001–003, AUX-001. Off, service and regenerative physical responses remain configuration-specific; LE-EPCS, LE-TRACTION, LE-RIDING, LE-LIGHT-CONTROL |
| VD18MT communication exception | Missing initial level/speed blocks Ready; loss after receipt preserves settings and normal-light request, with live rider/limit/fault processing. Do not retain a frozen torque command. Deliberate shutdown or actual supply loss is separate. | No common fault response solely for link loss; FLT-001/002, STA-004, LGT-001/002/009; LE-HMI, LE-RIDING, LE-LIGHT-POLICY |

Verification covers each defined diagnostic at startup and during positive, negative and zero demand, including masked reports, restored sources without restart, stale/contradictory observations, producer/consumer resets and persistent/new faults after restart. Mechanical brakes remain independent. Define fault injection and independent output references within the qualified test envelope; no uncontrolled riding test or new sensing/protection mechanism is selected. Remaining coverage and numerical bounds stay under OI-037/043/045/047/049 and WS-OI-001/002/007/010/012/015/016/019.

<a id="context-riding-safety-functions-riding-safety-functions"></a>
## Riding safety functions

**Role:** functional safety / vehicle controllability. **Status:** four Draft additions for REQ-001 Draft1.7. Each requirement has one explicit responsible target; supporting functions and elements do not retarget the parent.

These requirements derive from the released [safety goals](../../../Safety/SG-001_Safety_Goals.md) and are developed in [FC-001](../../FC-001_Functional_Concept.md). REQ-001-R1.6 behavior remains controlling. They add physical output and interaction acceptance to the existing command, independence and profile obligations; they do not introduce new rider controls, ramps, sensors or fault-history retention. All referenced safety goals remain mandatory. Derivation is partial; a passing child alone does not satisfy a complete goal.


Numerical acceptance is derived through FC-001's response and control budgets and the existing issue gates. A conflict with a fixed interface or released rider behavior requires explicit impact review and owner decision before acceptance; an unresolved envelope is not a usable calibration default.

<a id="context-session-report-policy-ridingcontrol-session-fault-report-policy"></a>
## RidingControl session fault-report policy

**Target:** `LE-RIDING`. These retained approved HMI report-policy requirements are Session obligations; RidingControl owns report selection, first-recognition order, priority, session lifetime and independent report monitoring/watchdog. BatteryStatus supplies reporting observations only, independently of operating-limit qualification. HMIControl encodes and transmits the selected report without changing selection, priority or retention.
