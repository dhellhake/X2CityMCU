# Motor position estimation

`LE-MOTOR-POSITION` is a child of Traction and a sibling of `LE-MOTOR-CTRL`. It combines the hardware leaf `MotorSignalMeasurement` (`LE-MOTOR-SIGNAL`) and the software leaf `MotorPositionProcessing` (`LE-MOTOR-POSITION-PROC`) to supply electrical rotor position and explicit phase-current feedback to MotorControl.

Hall evidence is always required. A static accepted Hall sector is permitted at startup without an edge or qualified vehicle-standstill assertion, while interpolation is bounded. Current plus applied-winding voltage can improve the estimate only when observable; they never provide a sensorless fallback. No forced alignment, deliberate stationary holding, or motor actuation belongs here.

```mermaid
flowchart LR
    THW["LE-TRACTION-HW"] -->|raw Hall / phase / bridge observation| MSM["LE-MOTOR-SIGNAL\nMotorSignalMeasurement"]
    MSM -->|physical measurement evidence| MPP["LE-MOTOR-POSITION-PROC\nMotorPositionProcessing"]
    MPP -->|MotorPosition| MC["LE-MOTOR-CTRL"]
    MPP -->|phase current| MC
    MPP -->|Qualification projection| FS["Existing fault supervision"]
```

| Exchange | Producer → consumer | Required content / owner |
|---|---|---|
| `hallSignalsIn`, `motorPhaseElectricalIn` | `LE-TRACTION-HW` → `MotorSignalMeasurement` | Raw physical Hall electrical levels, phase current and bridge-voltage observation; no ADC/DMA/pin allocation. `REQ-SYS-MSM-001`–002. |
| `motorSignalMeasurementsOut` | `MotorSignalMeasurement` → `MotorPositionProcessing` | Physical evidence and integrity for subsequent timestamped software acquisition and semantic conversion. |
| `motorPositionOut` | `MotorPositionProcessing` → `LE-MOTOR-CTRL` | `MotorPosition` (`Position` + `Qualification`) with angle, separately valid signed speed, reference time, accepted uncertainty and limited Hall evidence. `REQ-SYS-MPE-001`–004. |
| `phaseCurrentOut` | `MotorPositionProcessing` → `LE-MOTOR-CTRL` | Qualified semantic phase-current feedback, jointly realized by the existing MotorPhaseInterface conversion path. Applied-winding voltage stays internal observer evidence; fast DC-link voltage remains a separate existing control route. `REQ-SYS-MPE-005`. |
| `motorPositionHealthOut` | `MotorPositionProcessing` → existing fault supervision | Exact `MotorPosition.Qualification` projection; existing Session fault response owns inhibition and retention. `REQ-SYS-MPE-004`. |

The caller supplies a fresh monotonic `ExecutionTime` for each software invocation; acquisition evidence retains its actual measurement/capture time. The software leaf owns this conversion and uses immutable compiled calibration. See [parent requirements](MotorPositionEstimation_Requirements.md), [signal measurement](Decomposition/MotorSignalMeasurement_Requirements.md), and [position processing](Decomposition/MotorPositionProcessing_Requirements.md).
