# DD-002 — Battery protection and BMS software-unit design: BatteryProtection

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


## SC-BAT-POLICY

### Units, interfaces and executable order

`U-BAT-POLICY-EVALUATE` consumes typed qualified battery measurements, effective configuration and local operating context through `SW-I-003`/`SW-I-009`. It constructs independent charge and discharge envelope candidates, each with permission/limit availability and a reason set. It applies the most restrictive available qualified contribution and withholds the dependent permission when any required contribution is unavailable. It classifies each cause as a normal restriction or recognized battery fault; it does not make a vendor protection release permission or infer physical path protection from a reported status.

`U-BAT-POLICY-RESTRICTION` applies operation context to those candidates. It publishes separate propulsion and regenerative-charge consequences. In `.V`, qualified entry to the approved 10% cutoff sets `reached10%`; positive propulsion remains restricted until qualified actual SOC exceeds 20%. The state does not remove auxiliary discharge capability and does not become a session fault/history. A qualified discharge-permissible/charge-forbidden temperature becomes a regeneration restriction, not a battery fault solely because charge is forbidden.

Execution is: invalidate old-context inputs → evaluate availability and candidate causes → update `.V` cutoff state → publish one coherent envelope/reason/fault snapshot. A newly available envelope cannot clear `SC-SESSION` inhibition, authorize torque, or bypass the distinct regeneration acceptance conditions.

### State, reset and invariants

Envelope snapshots are volatile and vehicle-context-tagged. `reached10%` is owned only by `SC-BAT-POLICY.V`; the vehicle platform may restore a candidate across vehicle reset/battery handling, after which the unit exposes restored-valid, restored-unqualified or newly evaluated state. It clears only under the approved actual-SOC recovery guard. The vehicle instance retains no battery-fault history.

Invariants: no unknown required input enlarges charge or discharge permission; charge and discharge remain distinct; every published restriction identifies its operation; a restriction is not reported as a fault; and software policy output is not physical current limitation or protection evidence.

### Acceptance scenarios

Exercise independent loss/recovery of required BMS measurement/configuration evidence; overlapping SOC/current/temperature causes; normal restriction versus recognized fault; and vehicle restart/restoration at the 10%/20% state guards using qualified test abstractions. System acceptance still must establish numeric envelopes, source error/age margins, BMS accuracy, protective response and retention integrity/continuity.
