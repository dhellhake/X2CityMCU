# RidingPolicy

`LE-RIDING-POLICY` is the policy component inside RidingControl. It consumes qualified operation requests, runtime readiness, rider inputs, motion and motor-position information, battery status and operating limits, traction condition and output evidence, and rider-settings requests. It also consumes the independently qualified traction current budgets from CurrentConsumptionCoordination. See [RidingPolicy.sysml](RidingPolicy.sysml) for the complete modeled boundary.

The modeled outputs include riding authority, signed wheel-torque demand, selected fault indication, and compute sleep request. The component boundary is defined in [RidingPolicy.sysml](RidingPolicy.sysml); its canonical abstract software requirement allocation is maintained in [Settings and control policy](RidingPolicy.md).

<a id="context-rider-control-specification"></a>
<a id="context-settings-and-control-policy-specification"></a>
## Specification

- [SettingsAndControlPolicy](Specification/SettingsAndControlPolicy.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)

<a id="context-rider-control-assist-levels-torque-regeneration-and-speed-limits"></a>
## Assist levels, torque, regeneration and speed limits

**Target:** [LE-EPCS](../../../REQ-001_Requirements.md#le-epcs).

Part of **REQ-001-R1.6**. [Model, status and cluster index](../../../REQ-001_Requirements.md) · [Shared verification](../../../REQ-001_Requirements.md#reading-and-verification-rules) · [Common interpretation](../../../REQ-001_Requirements.md#common-interpretation-and-upstream-scope). These rules apply to every row; relocation preserves its approval/status and qualifications.

The fixed pack's qualified charging envelope also limits accelerator-requested regeneration; see [battery integration](../../BatteryControl/BatteryControl.md). BMS 50 A naming does not establish positive or negative wheel-torque capability. Derive battery-current-to-wheel-torque capability through the motor/inverter while retaining the level mappings, charge-acceptance recovery and common fault behavior below.

<a id="context-rider-control-level-selection-and-application"></a>
### Level selection and application

The four active level-selection requirements are allocated in [Settings and control policy](RidingPolicy.md#context-settings-and-control-policy-level-selection-and-application); their behavior remains unchanged. The withdrawn historical record stays below.


<a id="context-rider-control-accelerator-to-torque-behavior"></a>


<a id="context-rider-control-regenerative-limits-standstill-and-recovery"></a>


<a id="context-rider-control-vd18mt-speed-settings-and-walk-assistance-exclusion"></a>
### VD18MT speed settings and walk-assistance exclusion

[Speed-selection policy](RidingPolicy.md#context-settings-and-control-policy-speed-selection-and-application) contains unchanged SPD-002/004/005/008 under LE-RIDING. The requirements below retain physical cutoff/recovery, fixed-wheel and walk-exclusion responsibilities.


<a id="context-rider-control-torque-profile-calibration-acceptance"></a>
### Torque-profile calibration acceptance

This **approved acceptance definition** refines TRQ-001–009, REG-003 and the existing resumption requirements; it does not select calibrated values or replace their approval. Define and verify ideal static maps separately from dynamic shaping, current operating limits and actual wheel-torque response. Calibrated neutral, acquisition/rest tolerance, any permitted neutral deadband, curve representation, endpoint envelopes, gradients and physical-response bounds remain WS-OI-002/003/005/006/013 validation work.

Let qualified pedal travel be p∈[0,1], with common provisional neutral n=0.35 (0<n<1) for Levels 1–5. Compare branches on their own normalized displacement x:

| Branch | Normalized displacement | Ideal reference torque before dynamic shaping and masking overrides |
|---|---|---|
| Level 0 positive | x=p | T+(s) P0(x) |
| Levels 1–5 positive, p≥n | x=(p−n)/(1−n) | T+(s) Pl(x) |
| Levels 1–5 regenerative, p≤n | x=(n−p)/n | −Ml(s) Rl(x) |

Here s is a declared equivalent operating/reference condition; T+ is the common positive endpoint and Ml the level's regenerative endpoint at that condition. At full positive travel every level requests the maximum currently permitted positive torque; compare shape at conditions where intervening limits do not mask it. Requested regenerative endpoints increase through Levels 1–5, with Level 5 reaching the permitted maximum at the reference condition. A common restriction may make actual limited outputs equal; comparison of capped outputs alone cannot establish or disprove requested endpoint progression. No battery-current-to-wheel-torque conversion or runtime limit-scaling order is selected by these expressions.

All normalized maps stay within [0,1], are nondecreasing, start at zero and end at one; P5(x)=R5(x)=x. Positive maps have the defined gentle initial rise and steeper later rise (convex ideal shape), progressively approaching the line. For a shape F define D(F)=sup over x∈[0,1] of abs(F(x)−x). The approved linearity acceptance is D(P0)≥…≥D(P5)=0 and D(R1)≥…≥D(R5)=0, with the intended adjacent-level progression demonstrated at qualified calibration resolution. Negative-map curvature side and pointwise cross-level ordering are not prescribed by the existing increasing-linearity statement. Select calibration values and distinguishability tolerances at review; neither this metric nor matching endpoints alone completes curve acceptance. Compare normalized displacement, not the same raw p across Level 0 and the shifted branches.

For an unmasked fixed nonzero regenerative request, express low-speed taper by a factor al(v,x,s): al(0,x,s)=0, 0≤al≤1, nondecreasing with forward speed below the common onset von, and al=1 at/above that onset. The tapered reference is −al(v,x,s) Ml(s) Rl(x). Dependence on demand/operating condition is retained; no pedal-independent taper shape is imposed. Levels share the calibrated onset, not necessarily the taper shape or torque. Confirm progressive reduction at held conditions; changing demand or another active limit can change the observed trajectory. This factor is an acceptance representation, not a selected multiplication algorithm. Zero regeneration at standstill does not prohibit deliberate positive launch or authorize stationary holding.

Keep static target, shaped command and actual torque traces distinct. Levels 1–4 need declared progressively more direct regenerative responses; compare equal normalized transitions and the declared fraction-of-change response so differing endpoints do not disguise timing. Level 5 adds no profile ramp/delay; finite sampling, protection and physical response still require acceptance. Positive resumption after brake release, speed-cutoff recovery and discharge-capability recovery follows [BRK-005](../../Specification/BrakeInterfaceAndPriority.sysml), [SPD-007](../../Specification/RiderControl.sysml) and the [capability recovery rules](../RidingControl.md): Level 0 uses Level 1's resumption ramp but keeps its own static map; Level 5 adds none. This does not impose new continuous positive-demand smoothing.

Verify endpoints, neutral and declared interior points using p=x for Level 0, p=n+(1−n)x for positive Levels 1–5 and p=n(1−x) for regenerative Levels 1–5. Justify coverage between points from the calibrated representation; a few samples cannot prove the full-domain ordering or limits. Then exercise dynamic steps, below/at/above taper onset, both valid levers releasing, coincident recovery triggers and renewed cutoffs. Required speed-cutoff withdrawal bypasses comfort shaping; coincident positive recoveries do not apply successive duplicate ramps. Regenerative capability recovery and post-stop actual-powered-forward qualification remain separate guards under REG-005–007/009–011. Repeat masking restrictions and commanded-versus-actual observations at system level; software map evidence alone does not verify wheel torque or rider controllability.

<a id="context-settings-and-control-policy-settings-and-control-policy"></a>
## Settings and control policy

**Targets:** `LE-RIDING-POLICY`, the software-allocated policy leaf of RidingControl; REQ-SYS-LVL-001–004 and REQ-SYS-SPD-002/004/005/008 → `LE-RIDING-POLICY`; CTL requirements identify their target individually.

Part of **REQ-001-R1.6 — 2026-09-11**. [Model and shared verification](../../../REQ-001_Requirements.md). The four level and four speed-selection requirements retain their approved wording, sources and verification; their software allocation is approved. REQ-SYS-CTL-001 retains historical approval provenance, while its current body is a Draft successor. REQ-SYS-CTL-002 also retains historical approval provenance; its current body is a Draft successor that consumes directional capability budgets. Other approved command/interface children do not replace system-level physical obligations. Component contracts and unresolved hosts/timing are in [ARCH-001](../../X2CityMCU.md#allocation-records-and-component-contracts).

<a id="context-settings-and-control-policy-level-selection-and-application"></a>


<a id="context-settings-and-control-policy-speed-selection-and-application"></a>
### Speed selection and application

These existing requirements are allocated to LE-RIDING-POLICY without new parents or changed obligations. Qualified request interpretation and jointly valid standstill/rest evidence remain input dependencies; software setting state does not prove actual speed or physical cutoff.


For an interpretable request r in km/h, normalization is N(r)=r when 0<r<40, otherwise N(r)=40 for r=0 or r≥40. This defines no interpretation for missing, invalid or other special encodings. Qualification/decoding precedes normalization; no received value means no startup speed-setting qualification.

Process accepted requests in their established order, retain the latest valid normalized request, and evaluate the standstill/physical-rest application guard against coherent current observations. At a qualifying application decision, use that latest request without replaying obsolete ones. An unrecognized request neither overwrites nor cancels existing valid active/pending state, including while the guard is true. A pending setting never changes the active cutoff; cutoff/recovery at the active value and the unconditional 40 km/h ceiling do not wait for this guard. Qualification, transport order, numeric limits and finite application timing remain IF-A-001/002 and WS-OI-001/002/008/009/015 work; no new frame format, simultaneous-frame priority or host is selected.

<a id="context-settings-and-control-policy-command-and-information-interfaces"></a>
### Command and information interfaces

The software leaves realize only the following refinements. Qualified input generation, actual self-tests, physical torque/protection and visible presentation remain obligations of the system parents and their other contributors. Inspection/analysis and software-interface tests supplement, rather than replace, the planned system tests.


<a id="context-settings-and-control-policy-req-sys-ctl-002-detailed-design-trace-and-release-gate"></a>
#### REQ-SYS-CTL-002 detailed-design trace and release gate

The canonical `REQ-SYS-CTL-002` retains its historical approval provenance; the current row is a Draft successor. Its logical obligations include the command record, typed evidence, capability recovery state, directional current limits, post-stop rearm evidence and simultaneous-event precedence. Detailed realization and unit derivation are pending; these obligations do not add a rider decision or replace parent-system physical-output verification.

The following derived values remain an engineering release gate: full level maps and same-positive endpoints, 35% neutral interpretation, ramps and low-speed taper shapes, velocity/standstill interpretation, freshness/coherency and authority/command expiry bounds, and command-transfer/traction-response bounds. The applicable compiled-parameter and validation contract is REQ-SYS-PLT-CAL-001 in [SystemInterfaceAllocations](../../Compute/Platform/Specification/SystemInterfaceAllocations.sysml). No implicit numeric default applies; missing, unreleased or failed-validation values yield unavailable/withdrawal behavior. An unavailable per-sign battery branch withdraws only that branch and never enlarges it. Parameter changes require rebuild, deployment and restart, with no activation or runtime-context transition. This is not evidence that the policy is implementation-ready.

<a id="context-settings-and-control-policy-fault-report-tie-selection"></a>
### Fault-report tie selection

The following approved software refinement selects one deterministic implementation of the already approved consistent-tie rule; it does not rank physical fault severity or change the response to any recognized fault.
