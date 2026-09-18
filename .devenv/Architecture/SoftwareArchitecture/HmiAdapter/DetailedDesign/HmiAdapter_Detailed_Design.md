# DD-001 — Software unit design: HmiAdapter

## Caller supplied execution time

Invocation timing follows the canonical caller supplied `ExecutionTime` contract in [Runtime Integration Contract](../../Runtime_Integration_Contract.md). Component-specific age, expiry and timeout ownership remains defined by each unit contract.


### U-HMI-ADAPTER

The HMI adapter distinguishes current qualified receipt from decoder initialization, retained setting and transport activity. Endpoint loss, restart or unqualified receipt creates no setting or authority. Each outgoing update forms only parent-defined fields from selected report, usable charge and unsigned current magnitude/fallback, preserving internal validity separately from a transmitted fallback. Encoding, rounding, timing, electrical transport and display presentation remain gates.
