# DD-001 — Software unit design: AcceleratorInterface

## Input, traction and platform derivation gates

`U-ACCELERATOR-QUALIFY` alone converts completed regular scans into its typed rider record. It invalidates its own result on producer/reset/configuration/health failure and preserves no prior value as a substitute. The cross-component consumer statement is retained in [shared DD-001](../../DetailedDesign/DD-001_Software_Unit_Design.md#input-traction-and-platform-derivation-gates).
