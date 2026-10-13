# DD-001 — Software unit design: BrakeInterface

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


## Input, traction and platform derivation gates

`U-BRAKE-QUALIFY` alone converts completed regular scans into the exact System `BrakeLeverState` composite. `State` holds only `leverCombination` and the actual `measurementTimeMicroseconds`; `Qualification` holds logical qualification plus `initialQualificationPending` and `recognizedMeasurementFault`, with a software refinement for fault reason, recognition time, configuration and reset context. It uses its immutable `BrakeCalibration`, which reuses `BrakeStateCalibration` with all four named resistance acceptance bands and only adds its source/rank binding. Physical excitation and ADC-to-resistance transfer calibration remain derivation/acceptance work; this unit selects no circuit, transfer coefficient or new threshold. It invalidates its own result on producer/reset/configuration/health failure and preserves no prior value as a substitute. RidingControl internal units and Light receive the full composite through strict typed ports; Platform alone receives the exact Qualification projection. Health-only qualification updates do not refresh measurement time, and ongoing qualification is independent of Session's fault latch. The cross-component consumer statement is retained in [shared DD-001](../../DetailedDesign/DD-001_Software_Unit_Design.md#input-traction-and-platform-derivation-gates).
