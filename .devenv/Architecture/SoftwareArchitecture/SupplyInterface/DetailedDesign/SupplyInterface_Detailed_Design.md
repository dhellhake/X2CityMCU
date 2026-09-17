# DD-001 — Software unit design: SupplyInterface

## Input, traction and platform derivation gates

`U-SUPPLY-FAST` publishes current same-operation Vdc evidence; it does not use regular scans or historical values. It invalidates its own result on producer/reset/configuration/health failure and preserves no prior value as a substitute.
