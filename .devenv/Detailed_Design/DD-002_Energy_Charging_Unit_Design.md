# DD-002 — Energy and charging software-unit design

**Released 1.0 — 2026-09-13; DD-002-R1.0.** This detailed design refines the released component allocation in [ARCH-003](../Architecture/ARCH-003_Software_Architecture.md) for `SC-BMS-LINK`, `SC-BAT-POLICY`, `SC-CHARGE-POLICY` and `SC-SERVICE-INFO`.  It derives Unit Requirements only from the approved Abstract Software Requirements listed in [Energy_Charging_Unit_Requirements](../Requirements/Unit_Requirements/Energy_Charging_Unit_Requirements.md).  It neither changes prior released records nor selects electrical interfaces, hosts, numeric limits, physical protection, vendor internals, BMS writes, an immutable pack identity, or diagnostic coverage.

## Design-wide execution and data rules

Every received publication has `{producer, producerContext, receiptOrder, value, validity, freshness, qualification}`. A consumer first rejects a foreign/old context, then checks validity and applicable age/qualification before using its value. `Unknown`, `Invalid`, `Stale`, and `Qualified` are different states; a presentation fallback is never a qualified value. The platform supplies ordering and a new local context after reset, but no deadline or scheduler is selected here.

The shared component *types* have independent instances and state: `SC-BMS-LINK.V`, `SC-BAT-POLICY.V`, and `SC-SERVICE-INFO.V` execute on `HC-CONTROLLER`; `.C` instances execute on `HC-CHARGE-HOST`, along with `SC-CHARGE-POLICY.C`. No instance reads or restores state from the other host. `SC-BAT-POLICY.V` alone owns the `reached10%` operating restriction. `SC-CHARGE-POLICY.C` alone owns detached charging-session state. Retention means a platform-provided candidate plus its validity/context; it is never a retained fault history.

| Component | Owned units | Local outputs | Exclusions |
|---|---|---|---|
| `SC-BMS-LINK` | `U-BMS-LINK-TRANSACTION`, `U-BMS-LINK-DECODE`, `U-BMS-LINK-PUBLISH` | producer-tagged BMS observations | UART electrical acceptance, BMS measurement accuracy, command writes and vendor firmware |
| `SC-BAT-POLICY` | `U-BAT-POLICY-EVALUATE`, `U-BAT-POLICY-RESTRICTION` | charge/discharge envelopes, reasons and battery-fault information | current regulation, protection, session latching and numeric calibration |
| `SC-CHARGE-POLICY.C` | `U-CHARGE-POLICY-SESSION`, `U-CHARGE-POLICY-INTENT`, `U-CHARGE-POLICY-INDICATION` | charge-enable intent and logical four-state status | source/path qualification, physical transfer/control and visible indicator realization |
| `SC-USB-PD.C` | `U-USB-PD-SOURCE-PUBLISH` | qualified source/cable/contract capability and source-event context | negotiation profile, timeout, electrical behavior and physical source acceptance |
| `SC-CHARGE-CTRL.C` | `U-CHARGE-CTRL-INTENT-ADAPT` | conditioned charge-control translation and qualified actual-activity/path observation | regulator/control algorithm, electrical charging behavior and transfer proof |
| `SC-SERVICE-INFO` | `U-SERVICE-INFO-COLLECT`, `U-SERVICE-INFO-SNAPSHOT` | current service snapshot | diagnostic creation, configuration writes, persistence and operating permission |

## SC-BMS-LINK

### Units, interfaces and executable order

`U-BMS-LINK-TRANSACTION` accepts only read transactions for `0x03`, `0x04`, and `0x05`. For a received frame it verifies framing, echoed requested command, success status, declared payload length, checksum, and unambiguous frame boundary before forwarding its payload. Any envelope failure produces a whole-frame rejection and refreshes no field.

`U-BMS-LINK-DECODE` dispatches accepted payloads by command. It decodes `0x03` only after the selected-unit layout is qualified; binds current/capacity scale to the same response; preserves signed-current meaning; requires reported series count 14 for pack-data qualification; and keeps optional fields independently unavailable where their qualified layout permits. It accepts `0x04` only as exactly 28 bytes of 14 ordered big-endian mV group values, preserving position identity. It accepts `0x05` only with selected-unit-supported encoding/length. Temperature conversion preserves probe position/count and uses the approved conversion. It does not infer source accuracy, actual SOC, physical plausibility limits, or configuration identity from generic protocol material.

`U-BMS-LINK-PUBLISH` updates a field only from the decoder's accepted, internally consistent result. It stores receipt freshness separately from measurement age. A malformed/inconsistent frame supplies no qualifying update; an optional-field failure need not invalidate independently accepted fields. At host startup, recognized BMS reset, or loss of required source qualification, it marks affected fields for requalification. A wake or short interruption alone retains an otherwise justified unexpired field. It emits each field and set with value, validity/freshness, layout/scale/probe/group metadata and BMS producer context.

Execution is: request/receive → transaction gate → command decoder → field/set qualification → atomic publication. Publication consumes one accepted frame; consumers may combine fields only through their own cross-field qualification. Command order, retry policy, polling rate, response deadline and stale thresholds remain parameter-derivation gates from captured selected-unit behavior and energy/control budgets.

### State, reset and invariants

Volatile state is the outstanding read command, accepted field/set records, receipt timestamps and current BMS context. None is restored across host reset. A recognized BMS reset begins requalification of affected information but does not command session changes and does not clear a riding or charging latch. `0x04` failure cannot corrupt prior independent `0x03`/`0x05` records, although consumers must withhold a permission that needs the complete group set.

Invariants: no rejected frame changes an observation; a group set is qualified only with 14 values; a current/capacity value always carries its response's scale; an accepted identity remains an observed identity, not immutable pack proof; and no interface exposes BMS write/control capability.

### Acceptance scenarios

Software vectors cover valid captured `0x03/04/05`, checksum/status/wrong-command/length/framing faults, concatenated/truncated frames, both scale modes and signed-current boundaries, 13/14/15 group counts, and optional-temperature loss. Integration scenarios cover selected-unit startup, sleep/wake, BMS and host reset, delayed/missing responses and recovery. Electrical coupling, installed firmware/configuration support, board identity, measurement comparison and timing/power qualification remain gates, not acceptance claimed by this design.

## SC-BAT-POLICY

### Units, interfaces and executable order

`U-BAT-POLICY-EVALUATE` consumes qualified BMS observations, qualified path/output observations, effective configuration and local operating context through `SW-I-003`/`SW-I-009`. It constructs independent charge and discharge envelope candidates, each with permission/limit availability and a reason set. It applies the most restrictive available qualified contribution and withholds the dependent permission when any required contribution is unavailable. It classifies each cause as a normal restriction or recognized battery fault; it does not make a vendor protection release permission.

`U-BAT-POLICY-RESTRICTION` applies operation context to those candidates. It publishes separate propulsion, regeneration and external-charging consequences. In `.V`, qualified entry to the approved 10% cutoff sets `reached10%`; positive propulsion remains restricted until qualified actual SOC exceeds 20%. The state does not remove auxiliary discharge capability and does not become a session fault/history. A qualified discharge-permissible/charge-forbidden temperature becomes a regeneration restriction, not a battery fault solely because charge is forbidden.

Execution is: invalidate old-context inputs → evaluate availability and candidate causes → update `.V` cutoff state → publish one coherent envelope/reason/fault snapshot. A newly available envelope cannot clear `SC-SESSION` inhibition, authorize torque, or bypass `SC-CHARGE-POLICY` session state.

### State, reset and invariants

Envelope snapshots are volatile and context-tagged in both instances. `reached10%` is owned only by `.V`; the vehicle platform may restore a candidate across vehicle reset/battery handling, after which the unit exposes restored-valid, restored-unqualified, or newly evaluated state. It clears only under the approved actual-SOC recovery guard. `.C` has no such restriction state. Neither instance retains battery-fault history.

Invariants: no unknown required input enlarges charge or discharge permission; charge and discharge remain distinct; every published restriction identifies its operation; a restriction is not reported as a fault; and software policy output is not physical current limitation or protection evidence.

### Acceptance scenarios

Exercise independent loss/recovery of BMS, path/configuration and output observations; overlapping SOC/current/temperature causes; normal restriction versus recognized fault; and vehicle restart/restoration at the 10%/20% state guards using qualified test abstractions. System acceptance still must establish numeric envelopes, source error/age margins, BMS accuracy, protective response and retention integrity/continuity.

## SC-CHARGE-POLICY.C

### Units, interfaces and state transition

`U-CHARGE-POLICY-SESSION` owns `initialNeed = Unqualified | EligibleIncomplete | Completed`, completion hold, retained-candidate qualification, fresh-check state and current-execution fault inhibition. On a qualified physical connection/reconnection or qualified USB restoration after interruption, it starts a new initial-need assessment and fresh checks. Only evidence valid for that event can resolve initial need: below 80% is eligible incomplete, at/above 80% is completed, and unknown stays unqualified. A later SOC decline cannot create eligibility. Ordinary unsuitable-temperature waiting or temporary source interruption retains the session. Qualified completion sets completion hold; uninterrupted later SOC decline does not reopen it. Recognized charging fault inhibits until the specified recovery event and checks/conditions pass.

`U-CHARGE-POLICY-INTENT` returns true only when initial need is qualified eligible-incomplete, retained state (if used) is qualified, fresh checks passed, current charge conditions permit and no fault inhibits. It withdraws intent on any failed/unknown prerequisite. It sends intent to `SC-CHARGE-CTRL` through `SW-I-007`; acceptance of that intent is not activity or transfer evidence.

`U-CHARGE-POLICY-INDICATION` evaluates the current session snapshot after intent: Fault has priority, then Waiting for pending checks/state qualification, then Completed for qualified completion hold, then Charging only for true intent plus qualified active-charging evidence, otherwise Waiting. It emits a logical mode only; indicator supply and visible behavior remain external.

For each serialized relevant event the order is: first apply qualified new-session/reset identity; second update affected observation qualification and fresh checks; third apply newly recognized fault/recovery; fourth update completion; fifth compute intent and indication. If reset and a new-session event coincide, the new event wins over restored state. A BMS reset/wake/telemetry return alone preserves session/completion/fault state, marks dependent information for requalification, and cannot clear inhibition.

### Reset, retention and invariants

On an unexpected charger-controller reset without a new-session event, discard old fault history/previous indication, force intent false and Waiting while fresh checks run, and restore only a platform candidate for initial eligibility/completion. Requalify that candidate before use. A qualified physical new-session event supersedes it. There is no retained fault history. A service-readout reset cannot affect this controller state.

Invariants: the only event that opens a fresh initial-need assessment is a qualified new-session event; unavailable initial need never means deficit/full; enable intent never asserts physical charging; current fault overrides all modes without erasing completion hold; and no BMS packet, SOC drift, source-contract change or physical fault clearance alone grants new eligibility.

### Acceptance scenarios

Test event priorities in both orders: connection/restoration plus reset, initial-SOC late/unknown/qualified, ordinary waiting auto-resume, completion then SOC decline, fault/clear/recovery, BMS reset, and retained/unqualified state after controller reset. Assert intent and logical mode separately from activity. Source-profile, physical connection/activity, electrical charging control, indication hardware, numeric thresholds, controller host and retention mechanism remain system/HW qualification work.

## Released refinements: SC-USB-PD.C and SC-CHARGE-CTRL.C

The two Abstract Software Requirements in [Charging_Adapter_Interfaces](../Requirements/Abstract_Software_Requirements/Charging_Adapter_Interfaces.md) refine `REQ-SYS-HSI-006`. They make the already released ARCH-003 component allocation explicit; they do not alter architecture or physical acceptance.

`U-USB-PD-SOURCE-PUBLISH` consumes only the adapter's qualified source/cable/contract observations and publishes their capability and source-event context through `SW-I-007`. It distinguishes unavailable, invalid, stale and qualified observations and invalidates previous-context data on producer reset. It does not choose a negotiation profile, timeout, USB electrical behavior, or prove physical source capability.

`U-CHARGE-CTRL-INTENT-ADAPT` consumes the charge-policy intent and current qualified source/path/battery conditions. It translates an intent only while those current conditions are qualified; it publishes qualified actual-activity/path observations with its producer context to `SW-I-007`. An intent, acceptance, command or activity observation is never treated as proof of physical energy transfer. It does not select a charging regulator, control algorithm, electrical behavior or protective action.

The adapter execution order is source/connection observation qualification → source publication → policy session/intent evaluation → conditioned charge-control translation → actual-activity/path observation publication → policy indication update. The condition/adaptation units retain no charging-session, completion or fault history; reset causes their outputs to become unavailable until requalified. A USB/source or charge-control producer reset is not by itself a new charging session, and cannot clear `SC-CHARGE-POLICY.C` inhibition.

## SC-SERVICE-INFO

### Units, interfaces and executable order

`U-SERVICE-INFO-COLLECT` receives producer-tagged publications through `SW-I-008` and reset/platform context through `SW-I-009`. It retains no source value across a producer-context change. It preserves source availability, validity, freshness and qualification; it does not replace unavailable battery current with the HMI's 0 A fallback or infer actual output from a command.

`U-SERVICE-INFO-SNAPSHOT` forms an atomic current readout keyed to service task and source contexts. It includes available identity/effective configuration, check state, current recognized conditions, restriction/inhibition reasons, selected indication, requested versus qualified actual output, relevant battery data and charging-session state. It labels incomplete/pass/fail separately and reports each unavailable part explicitly. The snapshot is read-only and has no control return path.

Execution is: receive producer publication/context event → withdraw affected old-context entries → update current source records → assemble on service request or publication boundary. A producer restart affects only that producer's old-context entries. A BMS reset/recovery may change BMS data freshness but cannot change riding/charging latches. The service component's own restart clears only its cached snapshot and does not release an unaffected domain's inhibition.

### State, reset and invariants

State is a volatile cache indexed by producer and producer context. It contains no persistent fault history, calibration write staging or session state. Required operational retention remains owned by the originating policy and is reported as an observed state with its qualification.

Invariants: every record retains producer/context and qualification; selected report/mode cannot conceal other current observations supplied for service; unavailable remains unavailable; service reads cannot clear inhibition, establish a charging session, or grant torque/charge permission; and a BMS path bit or zero command never establishes isolation.

### Acceptance scenarios

Use source stubs to cover unavailable/stale publications, incomplete/pass/fail checks, simultaneous faults, producer-context change, BMS-only reset/recovery, vehicle riding reset, charger-controller reset, and service-component-only reset. Verify source values against independent physical evidence at system level. Access transport, electrical/power conditions, source coverage, update bounds and service procedures remain acceptance gates.

## Open derivation and qualification gates

This document intentionally records, without closing: approval of `REQ-SYS-USBPD-001` and `REQ-SYS-CHGCTRL-001`; selected BMS board/firmware/configuration and UART electrical coupling; source accuracy/measurement age and numeric plausibility/freshness/polling limits; charge source/path/activity qualification; host/retention mechanism and integrity; physical charging/protection/indicator outcomes; service transport/access; and all end-to-end timing/diagnostic coverage. These must be resolved as downstream system, hardware or allocation work before integration acceptance.
