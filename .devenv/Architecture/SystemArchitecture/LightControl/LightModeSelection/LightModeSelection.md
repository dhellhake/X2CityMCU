# LightModeSelection
## Light mode selection requirements

**Type:** Abstract Software Requirement. **Target:** `LE-LIGHT-POLICY`. **Status:** Draft.  It consumes `runningLightStateIn`, `brakeLeverStateIn` (the full qualified mechanical lever-state composite from MechanicalBrakeDetection), and `electricalBrakingStateIn` (actual motor braking from Traction).

Unqualified includes initial, invalid, unavailable, and stale information. A valid normal-light request changes without a standstill or pedal-rest guard; communication recovery alone does not change the retained request until a valid new request arrives.


`electricalBrakingStateIn` represents actual motor braking; it is not inferred solely from negative torque, charging current, or a request.  Fault-report and torque-inhibition latches do not freeze mode selection.

## Specification

- [Requirements](Specification/Requirements.sysml)
