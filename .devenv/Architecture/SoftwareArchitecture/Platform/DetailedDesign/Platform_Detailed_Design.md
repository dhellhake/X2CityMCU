# DD-001 — Software unit design: Platform

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


## Input, traction and platform derivation gates

`U-PLATFORM-CONTEXT` creates/invalidate contexts and orchestrates startup; `U-PLATFORM-BINDING` owns project peripheral/vector/DMA binding, the static shared fast-resource wrappers, bounded PRIMASK/barrier contract and routes each vector to its named unit; `U-PLATFORM-RETENTION` restores only host-provided items after integrity/context qualification; `U-PLATFORM-HEALTH` receives accelerator `Qualification` on dedicated typed `acceleratorQualificationIn` plus other sensor health on their existing inputs, and publishes scheduling/local-health events without asserting a safe physical reaction.
