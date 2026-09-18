# DD-001 — Software unit design: MotorPhaseInterface

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


## Input, traction and platform derivation gates

`U-MOTOR-PHASE-FAST` publishes current same-operation phase-current evidence; it does not use regular scans or historical values. It invalidates its own result on producer/reset/configuration/health failure and preserves no prior value as a substitute.
