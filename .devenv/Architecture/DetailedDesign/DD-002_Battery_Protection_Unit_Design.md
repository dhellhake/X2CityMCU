# DD-002 — Battery protection and BMS software-unit design

**Draft vehicle baseline — 2026-09-16.** Full BMS transaction/decode/publication, battery evaluation/restriction, service snapshot, reset invariants and acceptance vectors are retained.
**Draft — 2026-09-13.** This split detailed design preserves the complete vehicle unit contracts for `SC-BMS-LINK.V`, `SC-BAT-POLICY.V` and `SC-SERVICE-INFO.V`.  It derives Draft Unit Requirements only from the four approved Abstract Software Requirements listed in [Battery_Unit_Requirements].../../../Requirements/Unit_Requirements/Battery_Unit_Requirements.md).  It neither changes the 197 canonical records nor selects electrical interfaces, hosts, numeric limits, physical protection, vendor internals, BMS writes, an immutable pack identity, or diagnostic coverage.

## Design-wide execution and data rules

Every received publication has `{producer, producerContext, receiptOrder, value, validity, freshness, qualification}`. A consumer first rejects a foreign/old context, then checks validity and applicable age/qualification before using its value. `Unknown`, `Invalid`, `Stale`, and `Qualified` are different states; a presentation fallback is never a qualified value. The platform supplies ordering and a new local context after reset, but no deadline or scheduler is selected here.

The vehicle component instances `SC-BMS-LINK.V`, `SC-BAT-POLICY.V` and `SC-SERVICE-INFO.V` execute on `HC-CONTROLLER` with independent producer/reset contexts. `SC-BAT-POLICY.V` alone owns the `reached10%` operating restriction. Retention means a platform-provided candidate plus its validity/context; it is never retained fault history.

| Component | Owned units | Local outputs | Exclusions |
|---|---|---|---|
| `SC-BMS-LINK` | `U-BMS-LINK-TRANSACTION`, `U-BMS-LINK-DECODE`, `U-BMS-LINK-PUBLISH` | producer-tagged BMS observations | UART electrical acceptance, BMS measurement accuracy, command writes and vendor firmware |
| `SC-BAT-POLICY` | `U-BAT-POLICY-EVALUATE`, `U-BAT-POLICY-RESTRICTION` | charge/discharge envelopes, reasons and battery-fault information | current regulation, protection, session latching and numeric calibration |
| `SC-SERVICE-INFO` | `U-SERVICE-INFO-COLLECT`, `U-SERVICE-INFO-SNAPSHOT` | current service snapshot | diagnostic creation, configuration writes, persistence and operating permission |

## SC-BMS-LINK

### Units, interfaces and executable order

`U-BMS-LINK-TRANSACTION` accepts only read transactions for `0x03`, `0x04`, and `0x05`. For a received frame it verifies framing, echoed requested command, success status, declared payload length, checksum, and unambiguous frame boundary before forwarding its payload. Any envelope failure produces a whole-frame rejection and refreshes no field.

`U-BMS-LINK-DECODE` dispatches accepted payloads by command. It decodes `0x03` only after the selected-unit layout is qualified; binds current/capacity scale to the same response; preserves signed-current meaning; requires reported series count 14 for pack-data qualification; and keeps optional fields independently unavailable where their qualified layout permits. It accepts `0x04` only as exactly 28 bytes of 14 ordered big-endian mV group values, preserving position identity. It accepts `0x05` only with selected-unit-supported encoding/length. Temperature conversion preserves probe position/count and uses the approved conversion. It does not infer source accuracy, actual SOC, physical plausibility limits, or configuration identity from generic protocol material.

`U-BMS-LINK-PUBLISH` updates a field only from the decoder's accepted, internally consistent result. It stores receipt freshness separately from measurement age. A malformed/inconsistent frame supplies no qualifying update; an optional-field failure need not invalidate independently accepted fields. At host startup, recognized BMS reset, or loss of required source qualification, it marks affected fields for requalification. A wake or short interruption alone retains an otherwise justified unexpired field. It emits each field and set with value, validity/freshness, layout/scale/probe/group metadata and BMS producer context.

Execution is: request/receive → transaction gate → command decoder → field/set qualification → atomic publication. Publication consumes one accepted frame; consumers may combine fields only through their own cross-field qualification. Command order, retry policy, polling rate, response deadline and stale thresholds remain parameter-derivation gates from captured selected-unit behavior and energy/control budgets.

### State, reset and invariants

Volatile state is the outstanding read command, accepted field/set records, receipt timestamps and current BMS context. None is restored across host reset. A recognized BMS reset begins requalification of affected information but does not command session changes or clear a riding latch. `0x04` failure cannot corrupt prior independent `0x03`/`0x05` records, although consumers must withhold a permission that needs the complete group set.

Invariants: no rejected frame changes an observation; a group set is qualified only with 14 values; a current/capacity value always carries its response's scale; an accepted identity remains an observed identity, not immutable pack proof; and no interface exposes BMS write/control capability.

### Acceptance scenarios

Software vectors cover valid captured `0x03/04/05`, checksum/status/wrong-command/length/framing faults, concatenated/truncated frames, both scale modes and signed-current boundaries, 13/14/15 group counts, and optional-temperature loss. Integration scenarios cover selected-unit startup, sleep/wake, BMS and host reset, delayed/missing responses and recovery. Electrical coupling, installed firmware/configuration support, board identity, measurement comparison and timing/power qualification remain gates, not acceptance claimed by this design.

## SC-BAT-POLICY

### Units, interfaces and executable order

`U-BAT-POLICY-EVALUATE` consumes qualified BMS observations, qualified path/output observations, effective configuration and local operating context through `SW-I-003`/`SW-I-009`. It constructs independent charge and discharge envelope candidates, each with permission/limit availability and a reason set. It applies the most restrictive available qualified contribution and withholds the dependent permission when any required contribution is unavailable. It classifies each cause as a normal restriction or recognized battery fault; it does not make a vendor protection release permission.

`U-BAT-POLICY-RESTRICTION` applies operation context to those candidates. It publishes separate propulsion and regenerative-charge consequences. In `.V`, qualified entry to the approved 10% cutoff sets `reached10%`; positive propulsion remains restricted until qualified actual SOC exceeds 20%. The state does not remove auxiliary discharge capability and does not become a session fault/history. A qualified discharge-permissible/charge-forbidden temperature becomes a regeneration restriction, not a battery fault solely because charge is forbidden.

Execution is: invalidate old-context inputs → evaluate availability and candidate causes → update `.V` cutoff state → publish one coherent envelope/reason/fault snapshot. A newly available envelope cannot clear `SC-SESSION` inhibition, authorize torque, or bypass the distinct regeneration acceptance conditions.

### State, reset and invariants

Envelope snapshots are volatile and vehicle-context-tagged. `reached10%` is owned only by `SC-BAT-POLICY.V`; the vehicle platform may restore a candidate across vehicle reset/battery handling, after which the unit exposes restored-valid, restored-unqualified or newly evaluated state. It clears only under the approved actual-SOC recovery guard. The vehicle instance retains no battery-fault history.

Invariants: no unknown required input enlarges charge or discharge permission; charge and discharge remain distinct; every published restriction identifies its operation; a restriction is not reported as a fault; and software policy output is not physical current limitation or protection evidence.

### Acceptance scenarios

Exercise independent loss/recovery of BMS, path/configuration and output observations; overlapping SOC/current/temperature causes; normal restriction versus recognized fault; and vehicle restart/restoration at the 10%/20% state guards using qualified test abstractions. System acceptance still must establish numeric envelopes, source error/age margins, BMS accuracy, protective response and retention integrity/continuity.

## SC-SERVICE-INFO

### Units, interfaces and executable order

`U-SERVICE-INFO-COLLECT` receives producer-tagged publications through `SW-I-008` and reset/platform context through `SW-I-009`. It retains no source value across a producer-context change. It preserves source availability, validity, freshness and qualification; it does not replace unavailable battery current with the HMI's 0 A fallback or infer actual output from a command.

`U-SERVICE-INFO-SNAPSHOT` forms an atomic current readout keyed to service task and source contexts. It includes available identity/effective configuration, check state, current recognized conditions, restriction/inhibition reasons, selected indication, requested versus qualified actual output, relevant battery data and vehicle-session state. It labels incomplete/pass/fail separately and reports each unavailable part explicitly. The snapshot is read-only and has no control return path.

Execution is: receive producer publication/context event → withdraw affected old-context entries → update current source records → assemble on service request or publication boundary. A producer restart affects only that producer's old-context entries. A BMS reset/recovery may change BMS data freshness but cannot change riding latches. The service component's own restart clears only its cached snapshot and does not release an unaffected domain's inhibition.

### State, reset and invariants

State is a volatile cache indexed by producer and producer context. It contains no persistent fault history, calibration write staging or session state. Required operational retention remains owned by the originating policy and is reported as an observed state with its qualification.

Invariants: every record retains producer/context and qualification; selected report/mode cannot conceal other current observations supplied for service; unavailable remains unavailable; service reads cannot clear inhibition, establish a charging session, or grant torque or regenerative-charge permission; and a BMS path bit or zero command never establishes isolation.

### Acceptance scenarios

Use source stubs to cover unavailable/stale publications, incomplete/pass/fail checks, simultaneous faults, producer-context change, BMS-only reset/recovery, vehicle riding reset, and service-component-only reset. Verify source values against independent physical evidence at system level. Access transport, electrical/power conditions, source coverage, update bounds and service procedures remain acceptance gates.

## Open derivation and qualification gates

