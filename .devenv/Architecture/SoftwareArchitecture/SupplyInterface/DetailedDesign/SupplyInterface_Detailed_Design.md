# DD-001 — Software unit design: SupplyInterface

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


## Input, traction and platform derivation gates

`U-SUPPLY-FAST` publishes current same-operation Vdc evidence; it does not use regular scans or historical values. It invalidates its own result on producer/reset/configuration/health failure and preserves no prior value as a substitute.
