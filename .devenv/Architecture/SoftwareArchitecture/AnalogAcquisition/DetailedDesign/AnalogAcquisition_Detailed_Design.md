# DD-001 — Software unit design: AnalogAcquisition

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


## Input, traction and platform derivation gates

`U-ANALOG-ACQ-REGULAR` owns completed regular scans. Its shared fast-epoch and qualification constraints are retained in [shared DD-001](../../DetailedDesign/DD-001_Software_Unit_Design.md#input-traction-and-platform-derivation-gates).
