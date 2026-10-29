# MotorSignalMeasurement
## Motor signal measurement requirements

**Draft successor allocation — 2026-10-02; successor to Draft addition 2026-09-21.** **Type:** Abstract Hardware Requirement. **Target:** [LE-MOTOR-SIGNAL](../../../X2CityMCU.md#le-motor-signal).

`MotorSignalMeasurement` exposes physical evidence only. Its capture references preserve physical timing evidence for later software acquisition; software maps them to host-monotonic timestamps and context. The leaf selects no reset policy, peripheral, pin, DMA route, map/alignment or final position conversion.


Map/alignment, direct-sensing versus reconstruction selection, observer algorithm/constants and numerical acceptance limits remain downstream evidence gates.

## Specification

- [Requirements](Specification/Requirements.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)
