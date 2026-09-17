# DD-002 — Battery protection and BMS software-unit design

**Draft vehicle baseline — 2026-09-16.** Full BMS transaction/decode/publication, battery evaluation/restriction, service snapshot, reset invariants and acceptance vectors are retained in their owning component folders.

**Draft — 2026-09-13.** This split detailed design preserves the complete vehicle unit contracts for `SC-BMS-LINK.V`, `SC-BAT-POLICY.V` and `SC-SERVICE-INFO.V`. It derives Draft Unit Requirements only from the four approved Abstract Software Requirements listed in [Battery Unit Requirements](../../../Requirements/Unit_Requirements/Battery_Unit_Requirements.md). It neither changes the 197 canonical records nor selects electrical interfaces, hosts, numeric limits, physical protection, vendor internals, BMS writes, an immutable pack identity, or diagnostic coverage.

## Design-wide execution and data rules

Every received publication has `{producer, producerContext, receiptOrder, value, validity, freshness, qualification}`. A consumer first rejects a foreign/old context, then checks validity and applicable age/qualification before using its value. `Unknown`, `Invalid`, `Stale`, and `Qualified` are different states; a presentation fallback is never a qualified value. The platform supplies ordering and a new local context after reset, but no deadline or scheduler is selected here.

The vehicle component instances `SC-BMS-LINK.V`, `SC-BAT-POLICY.V` and `SC-SERVICE-INFO.V` execute on `HC-CONTROLLER` with independent producer/reset contexts. `SC-BAT-POLICY.V` alone owns the `reached10%` operating restriction. Retention means a platform-provided candidate plus its validity/context; it is never retained fault history.

| Component | Owned units | Local outputs | Exclusions |
|---|---|---|---|
| `SC-BMS-LINK` | `U-BMS-LINK-TRANSACTION`, `U-BMS-LINK-DECODE`, `U-BMS-LINK-PUBLISH` | producer-tagged BMS observations | UART electrical acceptance, BMS measurement accuracy, command writes and vendor firmware |
| `SC-BAT-POLICY` | `U-BAT-POLICY-EVALUATE`, `U-BAT-POLICY-RESTRICTION` | charge/discharge envelopes, reasons and battery-fault information | current regulation, protection, session latching and numeric calibration |
| `SC-SERVICE-INFO` | `U-SERVICE-INFO-COLLECT`, `U-SERVICE-INFO-SNAPSHOT` | current service snapshot | diagnostic creation, configuration writes, persistence and operating permission |
