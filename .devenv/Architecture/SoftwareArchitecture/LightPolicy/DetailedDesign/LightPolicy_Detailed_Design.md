# DD-001 — Software unit design: LightPolicy

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


### U-LIGHT-MODE

Light mode starts normal request `N` Off in each powered session and retains it through communication loss. Front follows `N`; rear is Full for an actuated lever, active electrical braking, or either unqualified fact, otherwise Dim for `N=On` and Off for `N=Off`. It publishes logical intent only; physical conservative rear behavior before policy execution remains hardware/system work.
