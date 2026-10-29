# BrakeStateIdentification
## Brake state identification requirements

**Draft successor allocation — 2026-09-26.** **Type:** Abstract Software Requirement. **Target:** [LE-BRAKE-STATE](../../../X2CityMCU.md#le-brake-state).

`BrakeStateCalibration` contains four immutable compile-time resistance bands in ohms: one inclusive `minResistanceOhms`/`maxResistanceOhms` pair for each of `Neither`, `Left`, `Right`, and `Both`. The bands are established during vehicle validation; nominal reference values are characterization inputs, not acceptance thresholds. Changing the calibration requires rebuilding, deploying, and restarting software.

## Specification

- [Requirements](Specification/Requirements.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)
