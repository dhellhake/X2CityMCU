# DD-002 — Battery protection and BMS software-unit design: BmsLink

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


## SC-BMS-LINK

### Units, interfaces and executable order

`U-BMS-LINK-TRANSACTION` accepts only read transactions for `0x03`, `0x04`, and `0x05`. For a received frame it verifies framing, echoed requested command, success status, declared payload length, checksum, and unambiguous frame boundary before forwarding its payload. Any envelope failure produces a whole-frame rejection and refreshes no field.

`U-BMS-LINK-DECODE` dispatches accepted payloads by command. It decodes `0x03` only after the selected-unit layout is qualified; binds current/capacity scale to the same response; preserves signed-current meaning; requires reported series count 14 for pack-data qualification; and keeps optional fields independently unavailable where their qualified layout permits. It accepts `0x04` only as exactly 28 bytes of 14 ordered big-endian mV group values, preserving position identity. It accepts `0x05` only with selected-unit-supported encoding/length. Temperature conversion preserves probe position/count and uses the approved conversion. It does not infer source accuracy, actual SOC, physical plausibility limits, or configuration identity from generic protocol material.

`U-BMS-LINK-PUBLISH` updates a field only from the decoder's accepted, internally consistent result. It stores transaction receipt qualification separately from any measurement age reported by the selected unit; it never fabricates a remote sample timestamp. A malformed/inconsistent frame supplies no qualifying update; an optional-field failure need not invalidate independently accepted fields. At host startup, recognized BMS reset, or loss of required source qualification, it marks affected fields for requalification. A wake or short interruption alone retains an otherwise justified unexpired field. It emits each field and set with value, validity, layout/scale/probe/group metadata and BMS producer context.

Execution is: request/receive → transaction gate → command decoder → field/set qualification → atomic publication. Publication consumes one accepted frame; consumers may combine fields only through their own cross-field qualification. Command order, retry policy, polling rate, response deadline and stale thresholds remain parameter-derivation gates from captured selected-unit behavior and energy/control budgets.

### State, reset and invariants

Volatile state is the outstanding read command, accepted field/set records, receipt timestamps and current BMS context. None is restored across host reset. A recognized BMS reset begins requalification of affected information but does not command session changes or clear a riding latch. `0x04` failure cannot corrupt prior independent `0x03`/`0x05` records, although consumers must withhold a permission that needs the complete group set.

Invariants: no rejected frame changes an observation; a group set is qualified only with 14 values; a current/capacity value always carries its response's scale; an accepted identity remains an observed identity, not immutable pack proof; and no interface exposes BMS write/control capability.

### Acceptance scenarios

Software vectors cover valid captured `0x03/04/05`, checksum/status/wrong-command/length/framing faults, concatenated/truncated frames, both scale modes and signed-current boundaries, 13/14/15 group counts, and optional-temperature loss. Integration scenarios cover selected-unit startup, sleep/wake, BMS and host reset, delayed/missing responses and recovery. Electrical coupling, installed firmware/configuration support, board identity, measurement comparison and timing/power qualification remain gates, not acceptance claimed by this design.
