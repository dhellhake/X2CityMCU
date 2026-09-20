# DD-002 — Battery protection and BMS software-unit design

**Draft vehicle baseline — 2026-09-16.** Full BMS transaction/decode/publication, battery evaluation/restriction, reset invariants and acceptance vectors are retained in their owning component folders.

**Draft — 2026-09-13.** This split detailed design preserves the complete vehicle unit contracts for `SC-BMS-LINK.V` and `SC-BAT-POLICY.V`. It derives the two battery Abstract Software obligations now co-located in [BatteryControl](../../SystemArchitecture/Modelling/BatteryControl/README.md). Historical release identities and record counts remain historical; this successor neither selects electrical interfaces, hosts, numeric limits, physical protection, vendor internals, BMS writes, an immutable pack identity, or diagnostic coverage.

## Design-wide execution and data rules

Each typed battery record carries its stated semantic values, producer/reset context and field-specific qualification. Its producer does not invent a generic freshness/order field or a remote measurement time. The caller supplies `ExecutionTime`; each consumer evaluates applicable age, expiry and ordering locally from its own contract. `Unknown`, `Invalid`, `Stale`, and `Qualified` are different states; a presentation fallback is never qualified data.

The vehicle component instances `SC-BMS-LINK.V` and `SC-BAT-POLICY.V` execute on `HC-CONTROLLER` with independent producer/reset contexts. `SC-BAT-POLICY.V` alone owns the `reached10%` operating restriction. Retention means a platform-provided candidate plus its validity/context; it is never retained fault history.

| Component | Owned units | Local outputs | Exclusions |
|---|---|---|---|
| `SC-BMS-LINK` | `U-BMS-LINK-TRANSACTION`, `U-BMS-LINK-DECODE`, `U-BMS-LINK-PUBLISH` | producer-tagged BMS observations | UART electrical acceptance, BMS measurement accuracy, command writes and vendor firmware |
| `SC-BAT-POLICY` | `U-BAT-POLICY-EVALUATE`, `U-BAT-POLICY-RESTRICTION` | charge/discharge envelopes, reasons and battery-fault information | current regulation, protection, session latching and numeric calibration |
