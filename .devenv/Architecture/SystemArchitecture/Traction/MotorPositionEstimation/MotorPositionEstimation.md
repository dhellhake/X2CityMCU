# MotorPositionEstimation
## Motor position estimation

`LE-MOTOR-POSITION` is a child of Traction and a sibling of `LE-MOTOR-CTRL`. It combines the hardware leaf `MotorSignalMeasurement` (`LE-MOTOR-SIGNAL`) and the software leaf `MotorPositionProcessing` (`LE-MOTOR-POSITION-PROC`) to supply electrical rotor position and explicit phase-current feedback to MotorControl.

Hall evidence is always required. A static accepted Hall sector is permitted at startup without an edge or qualified vehicle-standstill assertion, while interpolation is bounded. Current plus applied-winding voltage can improve the estimate only when observable; they never provide a sensorless fallback. No forced alignment, deliberate stationary holding, or motor actuation belongs here.

```mermaid
flowchart LR
    PHYS["physical motor / traction board\nmulti-role realization"] -->|direct Hall / phase / bridge observation| MSM["LE-MOTOR-SIGNAL\nMotorSignalMeasurement"]
    MSM -->|physical measurement evidence| MPP["LE-MOTOR-POSITION-PROC\nMotorPositionProcessing"]
    MPP -->|MotorPosition composite| MC["LE-MOTOR-CTRL"]
    MPP -->|same MotorPosition composite| PL["LE-PLATFORM"]
    MPP -->|same MotorPosition composite| SP["LE-RIDING"]
    MPP -->|phase current| MC
```

| Exchange | Producer → consumer | Required content / owner |
|---|---|---|
| `hallSignalsIn`, `motorPhaseElectricalIn` | Physical motor/traction board → `MotorSignalMeasurement` | Raw physical Hall electrical levels, phase current and bridge-voltage observation enter MotorPositionEstimation directly. The board may also realize TractionHardware, but it is not the logical producer on this path. No ADC/DMA/pin allocation. `REQ-SYS-MSM-001`–002. |
| `motorSignalMeasurementsOut` | `MotorSignalMeasurement` → `MotorPositionProcessing` | Physical evidence and integrity for subsequent timestamped software acquisition and semantic conversion. |
| `motorPositionOut` | `MotorPositionProcessing` → `LE-MOTOR-CTRL`, `LE-PLATFORM`, and `LE-RIDING` | The same complete `MotorPosition` (`Position` + `Qualification`) to all consumers, with angle, separately valid signed speed, reference time, accepted uncertainty and limited Hall evidence. Publication continues when angle is unavailable or only `Qualification` changes; qualification-only updates retain the actual position evidence reference time. Existing RidingControl session fault response owns inhibition and retention. `REQ-SYS-MPE-001`–004. |
| `phaseCurrentOut` | `MotorPositionProcessing` → `LE-MOTOR-CTRL` | Qualified semantic phase-current feedback from the logical processing responsibility. Applied-winding voltage stays internal observer evidence; fast DC-link voltage remains a separate existing control route. `REQ-SYS-MPE-005`. |

The caller supplies a fresh monotonic `ExecutionTime` for each software invocation; acquisition evidence retains its actual measurement/capture time. The software leaf owns this conversion and uses immutable compiled calibration. See [parent requirements](MotorPositionEstimation.md), [signal measurement](MotorSignalMeasurement/MotorSignalMeasurement.md), and [position processing](MotorPositionProcessing/MotorPositionProcessing.md).

## Motor position estimation requirements

**Draft addition — 2026-09-21.** **Type:** System Requirement. **Target:** [LE-MOTOR-POSITION](../../X2CityMCU.md#le-motor-position).

`MotorPosition` is one composite with `Position` and `Qualification`. `Position` carries electrical angle, separately qualified signed electrical speed, the reference time, accepted angle uncertainty, and only the Hall sector/edge evidence needed by consumers to assess motion independently. No System-level port selects ADC, DMA, pin, driver, scheduler, service or context mechanism.


### Member, consumer and requirement map

| Member / exchange | Consumer | Requirement source |
|---|---|---|
| Complete `MotorPosition` composite (`Position` + `Qualification`), including angle/evidence and signed-speed validity | `LE-MOTOR-CTRL`, `LE-PLATFORM`, and `LE-RIDING`; vehicle-motion qualification remains independent | [MPE-001](Specification/Requirements.sysml), [MPE-002](Specification/Requirements.sysml), [TRQPOS-001](MotorPositionProcessing/Specification/Requirements.sysml) |
| `PhaseCurrentMeasurements` | `LE-MOTOR-CTRL` FOC contribution | [MPE-005](Specification/Requirements.sysml), `REQ-SYS-MPP-005`; fast DC-link voltage is a separate existing route |
| Recognized fault/qualification status within `MotorPosition.Qualification` | `LE-PLATFORM` and `LE-RIDING`, as members of the complete composite; MotorControl receives the same composite | [MPE-001](Specification/Requirements.sysml), [MPE-004](Specification/Requirements.sysml), `REQ-SYS-MPP-004` |

Numerical error, interpolation, age, skew and observer-observability bounds are explicitly deferred to the stated software and HSI evidence gates; this set selects no motor numerical value.

## Specification

- [Requirements](Specification/Requirements.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)
