# DD-001 — Software unit design: Platform

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


## Input, traction and platform derivation gates

`U-PLATFORM-CONTEXT` creates/invalidate contexts and orchestrates startup; `U-PLATFORM-BINDING` owns project peripheral/vector/DMA binding, the static shared fast-resource wrappers, bounded PRIMASK/barrier contract and routes each vector to its named unit; `U-PLATFORM-HEALTH` receives accelerator `Qualification` on dedicated typed `acceleratorQualificationIn`, the complete estimator `MotorPositionRecord` on `motorPositionIn`, and other sensor health on their existing inputs. It processes the estimator Qualification even if Position is unavailable without adding it to the generic health fan-in, and publishes scheduling/local-health events without asserting a safe physical reaction.

For the VD18MT on/wake path, `U-PLATFORM-CONTEXT` orchestrates fresh post-wake startup, context and monotonic-timebase recovery through `U-PLATFORM-BINDING`, which owns selected controller clock/peripheral configuration and low-power/wake hardware setup. The existing full normal-start guards still apply. Wake is not Ready or drive permission; exact MCU mode, wake input and timing remain open derivation. The established switch-off requirements remain in force while pin-5 deassertion response and MCU sleep-entry mechanism remain open.
