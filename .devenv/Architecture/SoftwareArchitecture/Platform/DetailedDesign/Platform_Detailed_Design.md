# DD-001 — Software unit design: Platform

## Input, traction and platform derivation gates

`U-PLATFORM-CONTEXT` creates/invalidate contexts and orchestrates startup; `U-PLATFORM-BINDING` owns project peripheral/vector/DMA binding, the static shared fast-resource wrappers, bounded PRIMASK/barrier contract and routes each vector to its named unit; `U-PLATFORM-RETENTION` restores only host-provided items after integrity/context qualification; `U-PLATFORM-HEALTH` publishes scheduling/local-health events without asserting a safe physical reaction.
