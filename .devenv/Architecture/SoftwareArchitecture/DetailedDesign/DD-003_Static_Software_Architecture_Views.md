# DD-003 — Static software architecture views

**Draft vehicle baseline — 2026-09-16.** Full static composition, Hall/FOC ownership, runtime realization, battery/BMS units, deployment and local-interface views are retained.
**Draft 1.3 — 2026-09-14; successor to DD-003-R1.1.** These controlled views include Hall-position/FOC composition and the selected EVM physical boundary, and make the Draft [ARCH-003 component and host allocation](../ARCH-003_Software_Architecture.md) and the unit catalogues in [DD-001](DD-001_Software_Unit_Design.md) and [DD-002](DD-002_Battery_Protection_Unit_Design.md) easier to inspect.

## Scope and notation


The detailed behaviour, qualification, reset, retention and physical-acceptance limits remain authoritative in DD-001, DD-002 and ARCH-003. The [runtime integration contract](../Runtime_Integration_Contract.md) separately maps units to project bindings, direct fast calls and deferred scheduled routes; it is not a claim that every unit is a task. A requested zero, a command or an output observation is not proof of physical regeneration, protection or output.

## Draft MotorControl specialization pilot

This draft controlled pilot follows one architecture chain only: the system logical leaf
`LE-MOTOR-CTRL` is modeled by `MotorControl`, `SC-TRACTION-CTRL` specializes that
canonical logical boundary as the software view, and
`TractionControlImplementation` specializes the software view for detailed design.
The implementation owns the five existing traction units shown below; those units
remain unit parts and are not new component types, runtime components or tasks.

The logical and software views select one detailed-design implementation occurrence.
SysML `:>>` feature redefinitions carry the same occurrence selection through the
chain; they do not create a second MotorControl or TractionControl instance. The
selected containing context is defined by the detailed-design model. See the
[system MotorControl model](../../SystemArchitecture/Modelling/MotorControl.sysml),
[software TractionControl model](../TractionControl/TractionControl.sysml),
the [TractionControlImplementation model](../TractionControl/DetailedDesign/TractionControlImplementation.sysml),
and [detailed-design container model](Modelling/X2CityDetailedDesign.sysml).

The selected container path is `vehicle.epcs.traction.motorControl`. The detailed
model specializes `Traction` as `SelectedTraction` and redefines `motorControl` to
the implementation, then specializes `ElectricalPropulsionControlSystem` as
`SelectedEpcs` and redefines `traction`, and specializes `ProjectVehicleModel` as
`VehicleDetailedDesign` and redefines `epcs`. The existing `vehicle.traction` path
is retained as a reference alias to the selected traction occurrence. The system
`x2CityVehicle` and software `tractionControlVehicle` views remain unbound
references; bind statements inside the detailed-design model select the same
occurrence for this pilot.

```mermaid
flowchart TB
    SYS["MotorControl\nLE-MOTOR-CTRL"] -->|is specialized by| SW["TractionControl\nSC-TRACTION-CTRL"]
    SW -->|is specialized by| DD["TractionControlImplementation\nDD type"]
    subgraph OCC["vehicle.epcs.traction.motorControl\none selected detailed-design occurrence (:>>)\ncontaining the existing traction unit parts"]
        A["U-TRACTION-ACCEPT"]
        AO["U-TRACTION-ACTUAL-OUTPUT"]
        M["U-TRACTION-MOTION"]
        C["U-TRACTION-CONTROL"]
        O["U-TRACTION-OUTPUT"]
    end
    DD -->|owns| OCC
    ALIAS["vehicle.traction\nreference alias"] -.->|same occurrence| OCC
```

The selected chain preserves the existing allocation and requirement IDs. It does
not imply that the other system/software/detailed-design chains have been migrated
to the same specialization pattern.

### TractionControl boundary to unit ownership

The table maps every public TractionControl boundary port to the existing detailed
unit owner. `P-*`, `SW-I-*` and `R-*` references remain the canonical ARCH-003
contracts; unit model files are linked for review of the corresponding ports.

| MotorControl / SC-TRACTION-CTRL boundary | Canonical port / route | Existing DD owner and port | Requirement/interface trace |
|---|---|---|---|
| `SC-TRACTION-CTRL.tractionObservationOut` | `P-TR-OBS-O`; `SW-I-005` | [`U-TRACTION-ACCEPT.observationOut`](../TractionControl/DetailedDesign/UTractionAccept.sysml) → Session, Battery and Light consumers | `REQ-SYS-HSI-008`, `REQ-SYS-HSI-009` |
| `ridingAuthorityIn` | `P-TR-AUTH-I`; `SW-I-004` / `R-V15` | [`U-TRACTION-ACCEPT.authorityIn`](../TractionControl/DetailedDesign/UTractionAccept.sysml) | `REQ-SYS-HSI-004`, `REQ-SYS-TRQACC-001` |
| `wheelTorqueRequestIn` | `P-TR-COMMAND-I`; `SW-I-004` / `R-V14` | [`U-TRACTION-ACCEPT.commandIn`](../TractionControl/DetailedDesign/UTractionAccept.sysml) | `REQ-SYS-HSI-004`, `REQ-SYS-TRQACC-001` |
| `hallElectricalPositionIn` | `P-TR-HALL-I`; `R-V27` | [`U-TRACTION-CONTROL.electricalPositionIn`](../TractionControl/DetailedDesign/UTractionControl.sysml), [`U-TRACTION-MOTION.electricalPositionIn`](../TractionControl/DetailedDesign/UTractionMotion.sysml), [`U-TRACTION-ACTUAL-OUTPUT.electricalPositionIn`](../TractionControl/DetailedDesign/UTractionActualOutput.sysml) | `REQ-SYS-TRQPOS-001`, `REQ-SYS-TRQCTL-001` |
| `phaseCurrentEpochIn` | HSI-009 fast feedback boundary | [`U-TRACTION-CONTROL.phaseFeedbackIn`](../TractionControl/DetailedDesign/UTractionControl.sysml), [`U-TRACTION-ACTUAL-OUTPUT.phaseFeedbackIn`](../TractionControl/DetailedDesign/UTractionActualOutput.sysml) | `REQ-SYS-HSI-009`, `REQ-SYS-TRQCTL-001` |
| `fastDcLinkVoltageIn` | HSI-009 fast supply boundary | [`U-TRACTION-CONTROL.fastDcLinkVoltageIn`](../TractionControl/DetailedDesign/UTractionControl.sysml) | `REQ-SYS-HSI-009`, `REQ-SYS-TRQCTL-001` |
| `sensorHealthIn` | HSI-009 health qualification | [`U-TRACTION-CONTROL.sensorHealthIn`](../TractionControl/DetailedDesign/UTractionControl.sysml) | `REQ-SYS-HSI-009`, `UR-TRACTION-CONTROL-001` |
| `motionHealthIn` | `P-TR-MOTION-HEALTH-I`; `R-V27` Hall-health family | [`U-TRACTION-MOTION.motionHealthIn`](../TractionControl/DetailedDesign/UTractionMotion.sysml) | `REQ-SYS-TRQMOTION-001` |
| `tractionOutputStageExchange` | `P-TR-OUTPUT-I/O` | [`U-TRACTION-OUTPUT.outputStageEvidenceIn`](../TractionControl/DetailedDesign/UTractionOutput.sysml) ← boundary; [`U-TRACTION-OUTPUT.outputObservationOut`](../TractionControl/DetailedDesign/UTractionOutput.sysml) → [`U-TRACTION-ACTUAL-OUTPUT.outputStageEvidenceIn`](../TractionControl/DetailedDesign/UTractionActualOutput.sysml) and boundary | `REQ-SYS-HSI-009`, `REQ-SYS-TRQEX-001` |
| `qualifiedMotionOut` | `P-TR-QUALIFIED-MOTION-O`; `SW-I-005` / `R-V05-*`, `R-V13` | [`U-TRACTION-MOTION.qualifiedMotionOut`](../TractionControl/DetailedDesign/UTractionMotion.sysml) | `REQ-SYS-TRQMOTION-001` |
| `appliedTractionStateOut` | `P-TR-ACTUAL-OUTPUT-O`; `SW-I-005` / `R-V13` | [`U-TRACTION-ACTUAL-OUTPUT.appliedTractionStateOut`](../TractionControl/DetailedDesign/UTractionActualOutput.sysml) → [`U-TRACTION-ACCEPT.actualOutputIn`](../TractionControl/DetailedDesign/UTractionAccept.sysml); [`U-TRACTION-ACCEPT.appliedTractionStateOut`](../TractionControl/DetailedDesign/UTractionAccept.sysml) → public boundary | `REQ-SYS-TRQCTL-001`, `UR-TRACTION-ACTUAL-OUTPUT-001` |
| `platformContextIn` | `SW-I-009`; current-context service input | [`U-TRACTION-MOTION.platformContextIn`](../TractionControl/DetailedDesign/UTractionMotion.sysml), [`U-TRACTION-ACTUAL-OUTPUT.platformContextIn`](../TractionControl/DetailedDesign/UTractionActualOutput.sysml) | `REQ-SYS-HSI-007`, `REQ-SYS-PLT-001` |
| `platformHealthIn` | `SW-I-009`; current-health service input | [`U-TRACTION-MOTION.platformHealthIn`](../TractionControl/DetailedDesign/UTractionMotion.sysml), [`U-TRACTION-ACTUAL-OUTPUT.platformHealthIn`](../TractionControl/DetailedDesign/UTractionActualOutput.sysml) | `REQ-SYS-HSI-007`, `REQ-SYS-PLT-001` |

`U-TRACTION-ACCEPT` forwards the independently produced actual-output record to
Demand without gating or refreshing it and publishes the legacy observation
envelope. `U-TRACTION-MOTION` keeps its Hall capture/position-specific health
qualification, while `U-TRACTION-CONTROL.sensorHealthIn` remains the broader FOC
health fan-in. `U-TRACTION-CONTROL` produces the sampling plan, while
`U-TRACTION-OUTPUT` remains the sole literal stage/commit owner. This mapping
records ownership and traceability; it does not change any requirement body or
select a new execution mechanism.

External detailed-design traffic for this pilot terminates at the public
`TractionControlImplementation` boundary. The implementation model contains the
five unit-to-unit flows once; the `vehicle.traction` reference alias does not add
a second wiring graph.

The pilot retains the shared qualification context ancestry: software
`ContextualSoftwareInformation` refines the logical qualified-information record,
and detailed `UnitInformationEnvelope` refines that software context. Traction
unit sensor inputs accept the software schema types; producer wrappers
`HallElectricalPositionRecord`, `PhaseCurrentFeedbackRecord` and
`FastDcLinkVoltageRecord` remain detailed subtypes. The DD observation boundary
`TractionObservationRecord` refines `TractionObservation` while retaining
`UnitInformationEnvelope`. Software `ExpiryTimeMicroseconds` is an `Integer`
refinement, while logical `Expiry` remains abstract and opaque. Values, field
meanings and expiry semantics remain unchanged; this schema alignment is scoped
to the MotorControl pilot and does not alter requirement contracts.

## Static component-to-unit composition

### Vehicle-control domain

```mermaid
flowchart TB
    subgraph V[Vehicle-control component types]
        SET[SC-SET] -->|contains| US[U-SET-STATE]
        SESSION[SC-SESSION] -->|contains| USE[U-SESSION-ELIGIBILITY]
        SESSION -->|contains| USR[U-SESSION-REPORT]
        DEMAND[SC-DEMAND] -->|contains| UDA[U-DEMAND-ARBITER]
        HMI[SC-HMI] -->|contains| UHA[U-HMI-ADAPTER]
        LIGHT[SC-LIGHT-POLICY] -->|contains| ULM[U-LIGHT-MODE]
        ANALOG[SC-ANALOG-ACQ] -->|contains| UAR[U-ANALOG-ACQ-REGULAR]
        ANALOG -->|contains| UAF[U-ANALOG-ACQ-FAST]
        ACCEL[SC-ACCELERATOR-IF] -->|contains| UAQ[U-ACCELERATOR-QUALIFY]
        BRAKE[SC-BRAKE-IF] -->|contains| UBQ[U-BRAKE-QUALIFY]
        TEMP[SC-TEMPERATURE-IF] -->|contains| UTQ[U-TEMPERATURE-QUALIFY]
        SUPPLY[SC-SUPPLY-IF] -->|contains| USF[U-SUPPLY-FAST]
        SUPPLY -->|contains| USREG[U-SUPPLY-REGULAR]
        PHASE[SC-MOTOR-PHASE-IF] -->|contains| UMPF[U-MOTOR-PHASE-FAST]
        PHASE -->|contains| UMPD[U-MOTOR-PHASE-DIAG]
        HALL[SC-HALL-IF] -->|contains| UHC[U-HALL-CAPTURE]
        HALL -->|contains| UHP[U-HALL-POSITION]
        TRACTION[SC-TRACTION-CTRL] -.->|specialized by| TRDD[TractionControlImplementation]
        TRDD -->|contains| UTA[U-TRACTION-ACCEPT]
        TRDD -->|contains| UTAO[U-TRACTION-ACTUAL-OUTPUT]
        TRDD -->|contains| UTM[U-TRACTION-MOTION]
        TRDD -->|contains| UTC[U-TRACTION-CONTROL]
        TRDD -->|contains| UTO[U-TRACTION-OUTPUT]
        PLATFORM[SC-PLATFORM] -->|contains| UPC[U-PLATFORM-CONTEXT]
        PLATFORM -->|contains| UPB[U-PLATFORM-BINDING]
        PLATFORM -->|contains| UPR[U-PLATFORM-RETENTION]
        PLATFORM -->|contains| UPH[U-PLATFORM-HEALTH]
    end
```

### Hall evidence and traction interpretation

```mermaid
flowchart LR
    HM[HC-MOTOR Hall1..3] -->|J7 1..3| E[Selected DRV8300 EVM]
    V5[External qualified 5-V Hall supply] -->|planned J3 HALL_EXT then J7-4| E
    E -->|fixed 3.3-V R9/R10/R11 pull-ups and J2 13/15/17| FE[HC-INPUT-FE / host adapter]
    FE -->|conditioned acquired state/edges, open host realization| HIF[SC-HALL-IF.V]
    HIF -->|capture buffer and valid state/edge evidence| P[U-HALL-POSITION]
    P -->|qualified electrical sector/direction/edge time| T[SC-TRACTION-CTRL.V]
    P -.->|unavailable without map/alignment| T
    T -.->|separate qualified conversion required| S[mechanical/vehicle speed]
```

The physical prefix records the EVM schematic boundary, not a measured jumper configuration: board revision, J3 setting, common return, backfeed, host thresholds and adapter continuity remain qualification work. `HC-INPUT-FE` owns host-side conditioning/acquisition; it neither owns the EVM pull-ups nor supplies the independent traction gate-inhibit. Static state may support sector at rest after map/alignment qualification; it does not prove speed/standstill. The dashed speed path requires pole-pair and loaded-wheel calibration evidence and is not selected here.

### Selected traction-board ownership boundary

```mermaid
flowchart LR
    HOST[Selected WeAct vehicle host / adapter] -->|six PWM: J2 1/3/5/7/9/11| EVM[HC-TRACTION-POWER: selected EVM]
    EVM -->|J1 ISENA/B/C and SEN_PVDD/GVDD/TEMP| HOST
    PACK[HC-ENERGY-DIST / pack] -->|PVDD| EVM
    EVM -->|three phases| MOTOR[HC-MOTOR]
    PROT[External independent gate-inhibit/protection] -->|defined fail-safe inhibit, not EVM FAULT LED| EVM
```

The EVM owns its bridge, shunts, dividers, Hall pull-ups and board-temperature sensor. The selected WeAct `HC-CONTROLLER` plus `HC-INPUT-FE`/host adapter owns the still-unallocated interface and acquisition; `HC-ENERGY-DIST` and the external protection assembly own the additional energy/protection realization. The EVM's J2 `FAULT` is only a host-driven LED indication and is deliberately not drawn as a protection path. All paths remain draft integration contracts rather than acceptance evidence.

`U-ANALOG-ACQ-*`, the named sensor-interface units, `U-TRACTION-ACCEPT`, `U-TRACTION-MOTION`, `U-TRACTION-ACTUAL-OUTPUT` and `U-PLATFORM-*` refine approved ASW allocations. `U-HALL-CAPTURE` and `U-HALL-POSITION` own Hall buffer/capture integrity and qualified electrical position; `U-TRACTION-CONTROL` consumes that position with qualified phase feedback and fast Vdc for selected FOC. `U-TRACTION-OUTPUT` owns compare-latch/inhibit sequencing under Draft HSI-009; the [traction HSI](../../DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md) owns the concrete platform contract. None proves physical output behaviour.

The implementation contract makes the ownership exact: `U-PLATFORM-CONTEXT` orchestrates startup/context invalidation and `U-PLATFORM-BINDING` starts selected resources and dispatches ADC1/ADC2 JEOS to `U-ANALOG-ACQ-FAST`, which snapshots raw JDR data into `InjectedEpoch`. `U-MOTOR-PHASE-FAST` and `U-SUPPLY-FAST` convert the raw epoch into qualified phase feedback and fast Vdc; `U-HALL-CAPTURE`/`U-HALL-POSITION` provide electrical position. `U-TRACTION-CONTROL` consumes those qualified records and emits compare/context data, including the next sampling-plan `CCR4`; `U-TRACTION-OUTPUT` alone stages/commits literal TIM8 `CCR1..4` and JSQR. `U-ANALOG-ACQ-REGULAR` owns regular-DMA completed-record publication, while `U-HALL-CAPTURE` owns Hall capture storage and `U-HALL-POSITION` its interpretation. The direct fast chain is neither a CortexOs scheduled task nor current intercom usage; the qualified [runtime contract](../Runtime_Integration_Contract.md) owns remaining project/generic-driver and future-intercom detail.

### Vehicle runtime realization boundary

```mermaid
flowchart LR
    subgraph D[Generic src/drv: current and proposed register access]
        CORE[Core/RCC/GPIO/USART/WWDG: current]
        FUT[ADC/TIM/DMA/IRQ and compiler plus hardware barrier support: proposed]
    end
    subgraph P[Project bindings inside named units]
        CALL[CallingExecutionContextBoundary\ncallingExecutionContext / ExecutionTime]
        BOOT[U-PLATFORM-BINDING\nB-PLATFORM-BOOT]
        DISP[U-PLATFORM-BINDING\nB-PLATFORM-IRQ-DISPATCH]
        DMA[U-ANALOG-ACQ-REGULAR\nB-REGULAR-ADC-DMA]
        SLOW[Scheduled regular qualification and policy units]
    end
    subgraph F[Direct fast traction chain]
        JEOS[U-ANALOG-ACQ-FAST\nB-FAST-ANALOG-JEOS / InjectedEpoch]
        QUAL[U-MOTOR-PHASE-FAST + U-SUPPLY-FAST + U-HALL-POSITION\nqualified phase/Vdc/electrical position]
        FOC["U-TRACTION-CONTROL<br/>PWMAndADCSamplingPlan: CCR1..3, CCR4, ADC context"]
        OUT[U-TRACTION-OUTPUT\nsole CCR1..4 + JSQR / UDIS commit lease]
    end
    OS[CortexOs cyclic scheduler\ncurrent tasks] -->|releases selected cyclic invocations| DMA
    OS -->|releases selected cyclic invocations| SLOW
    CALL -->|fresh executionTimeIn per invocation| DMA
    CALL -->|fresh executionTimeIn per invocation| SLOW
    CALL -->|fresh executionTimeIn per direct fast invocation| JEOS
    JEOS == direct raw epoch ==> QUAL
    QUAL == direct, no queue ==> FOC
    BOOT --> DISP
    DISP --> JEOS
    FUT -. generic operations .-> BOOT
    FUT -. generic operations .-> DMA
    FUT -. generic operations .-> JEOS
    FOC == direct, no queue ==> OUT
    OUT -->|TIM8/ADC configured hardware| PWM[TIM8 PWM + ADC1/ADC2]
    FUT -.-> Q[Future static intercom mechanics]
    Q -. scheduled project routes only .-> OS
```

Solid fast-path edges are direct calls. `CallingExecutionContextBoundary` represents the task or IRQ caller, not CortexOs as a modeled time-consuming component: it samples live time and supplies `executionTimeIn` directly to each invoked unit or group. Bounded internal leaves may inherit one fixed reference within the parent invocation. Dashed nodes identify capability work, not implemented drivers or intercom endpoints. Project route identity, context, age, expiry and fault policy remain outside generic `src/os` transport mechanics.

### Battery and BMS domain

```mermaid
flowchart TB
    subgraph E[Energy component types]
        BMS[SC-BMS-LINK] -->|contains| UBT[U-BMS-LINK-TRANSACTION]
        BMS -->|contains| UBD[U-BMS-LINK-DECODE]
        BMS -->|contains| UBP[U-BMS-LINK-PUBLISH]
        BAT[SC-BAT-POLICY] -->|contains| UBPE[U-BAT-POLICY-EVALUATE]
        BAT -->|contains| UBPR[U-BAT-POLICY-RESTRICTION]
    end
```


## Deployment and instance boundaries

This view separates static type composition above from the local vehicle realization instances below.

```mermaid
flowchart LR
    subgraph HV[HC-CONTROLLER — WeAct STM32H723VGT6 vehicle host]
        direction TB
        VV[Vehicle instances]
        V1[SC-SET.V]
        V2[SC-SESSION.V]
        V3[SC-DEMAND.V]
        V4[SC-HMI.V]
        V5[SC-LIGHT-POLICY.V]
        V6[SC-ANALOG-ACQ.V and named sensor-interface .V instances]
        V7[SC-TRACTION-CTRL.V]
        V8[SC-BMS-LINK.V]
        V9[SC-BAT-POLICY.V]
        V10[SC-PLATFORM.V]
    end
```

`SC-BMS` remains supplied opaque firmware on `HC-BMS`; `SC-VD18MT` remains supplied opaque firmware in the VD18MT assembly within `HC-RIDER`. Neither receives a `U-*` node in these views.

## Demand-arbitration typed boundary

`U-DEMAND-ARBITER` has no generic `lightingContextIn` collection. Each ingress below carries its own value, qualification, producer/context, configuration identity and generation; age is evaluated locally from caller supplied `ExecutionTime`. Demand evaluates one coherent snapshot; a route being drawn does not make a prior record current.

```mermaid
flowchart LR
    ACC[U-ACCELERATOR-QUALIFY\nAcceleratorPosition: Position + Qualification] -->|P-DEM-ACCELERATOR-I| D[U-DEMAND-ARBITER]
    BRK[U-BRAKE-QUALIFY\nBrakeState] -->|P-DEM-BRAKE-I| D
    SET[U-SET-STATE\nActiveRidingSettings] -->|P-DEM-ACTIVE-SETTINGS-I| D
    SES["U-SESSION-ELIGIBILITY<br/>RidingAuthority"] -->|P-DEM-AUTHORITY-I| D
    BAT["U-BAT-POLICY-RESTRICTION<br/>BatteryCapabilityEnvelope"] -->|P-DEM-BATTERY-CAPABILITY-I| D
    MOT[U-TRACTION-MOTION\nQualifiedMotion] -->|P-DEM-MOTION-I| D
    OUT[U-TRACTION-ACTUAL-OUTPUT\nActualTractionOutput estimate] -->|P-DEM-ACTUAL-OUTPUT-I| D
    PLT[U-PLATFORM-CONTEXT / HEALTH\ncurrent generation] --> D
    CAL[SC-DEMAND build\nimmutable DemandPolicyCalibration] -.->|owner-local attribute| D
    D -->|"P-DEM-COMMAND-O<br/>requestedWheelTorqueNewtonMetres, authorityGeneration, commandExpiryTimeMicroseconds"| TA[U-TRACTION-ACCEPT]
    TA -->|accepted signed request\neffectiveAcceptedExpiryTimeMicroseconds| TC[U-TRACTION-CONTROL]
```

`U-TRACTION-MOTION` is a real producer route, not a reinterpretation of a Demand command: it interprets current qualified Hall capture/position evidence only with current capture health, its compiled map/pole-pair/final-drive/loaded-wheel parameters and a released bounded-observability/standstill criterion before publishing speed, direction and standstill. A static Hall state or no edge alone is unavailable for this purpose. `U-TRACTION-ACTUAL-OUTPUT` publishes `ActualTractionOutput` only as a current qualified estimate from post-stage physical evidence with provenance plus same-operation phase-current/position and qualified vehicle-motion evidence with its immutable compiled estimator parameters. It operates independently of acceptance; `U-TRACTION-ACCEPT` passes that observation without refreshing or gating it while separately issuing accepted demand to control. Its applied-torque and powered-forward-travel fields must be unavailable if that chain has only a requested torque, FOC reference, register/PWM state, output-stage event or acceptance result. The command is a request; neither observation proves physical torque or vehicle travel.

| Decision input/output | Consumer acceptance and ownership |
|---|---|
| Active settings | Only the active level/speed setting is used. Pending values, receipt order and setting activation remain `SC-SET` ownership. |
| Authority and command | `authorityExpiryTimeMicroseconds` and `commandExpiryTimeMicroseconds` carry independent decision sequences in the shared host monotonic domain. Acceptance emits `effectiveAcceptedExpiryTimeMicroseconds`; Demand cannot refresh authority by issuing a command. |
| Motion and actual output | Demand requires current qualified motion for speed/standstill decisions and current qualified actual positive applied torque plus forward travel to re-arm regeneration after stop. Hand-push travel cannot satisfy the latter proof. |
| Capability | `BatteryCapabilityEnvelope` supplies independently qualified positive/negative ceilings, reasons and restriction generations. Demand clamps signs independently, owns regeneration-recovery episode qualification, and does not own protection. |
| Calibration | `SC-DEMAND` owns immutable compiled `DemandPolicyCalibration` maps, ramps, taper, reference limits and timing-bound data. Its startup checks govern profile availability; any change needs rebuild, deployment and restart. |

## Static local-interface view

The interface names and endpoint scopes below are the released `SW-I-*` contracts from ARCH-003. Flow labels distinguish **data** publications, **control** token/data, and **event/service** interactions. They do not introduce timing, protocol, electrical or physical semantics. The complete port-to-port route catalogue is [ARCH-003 port registry and route catalogue](../ARCH-003_Software_Architecture.md#static-port-registry-and-connection-catalogue); this view intentionally labels interface groups rather than every `P-*` endpoint.

```mermaid
flowchart LR
    subgraph V[HC-CONTROLLER / .V]
        ACC[SC-ACCELERATOR-IF.V]
        BRK[SC-BRAKE-IF.V]
        HMI[SC-HMI.V]
        SET[SC-SET.V\nacceleratorPositionIn]
        SES[SC-SESSION.V\nacceleratorPositionIn]
        DEM[SC-DEMAND.V]
        TR[SC-TRACTION-CTRL.V]
        BAT[SC-BAT-POLICY.V]
        LGT[SC-LIGHT-POLICY.V]
        BMS[SC-BMS-LINK.V]
        PLV[SC-PLATFORM.V\nacceleratorQualificationIn]
        ACC -->|SW-I-001 AcceleratorPosition| SET
        ACC -->|SW-I-001 full AcceleratorPosition| SES
        ACC -->|SW-I-001 qualified Position + Qualification| DEM
        ACC -->|R-V41-ACCELERATOR Qualification projection| PLV
        BRK -->|SW-I-001 data| SES
        BRK -->|SW-I-001 brake data| DEM
        BRK -->|SW-I-001 data| LGT
        HMI -->|SW-I-002 data| SET
        HMI -->|SW-I-002 data| SES
        SET -->|SW-I-002 active-settings data| DEM
        BMS -->|SW-I-003 data| BAT
        BAT -->|SW-I-003 data| SES
        BAT -->|SW-I-003 data| DEM
        SES -->|SW-I-004 control token| TR
        SES -->|SW-I-004 authority data| DEM
        DEM -->|SW-I-004 control data| TR
        TR -->|SW-I-005 data| SES
        TR -->|SW-I-005 qualified motion data| SET
        TR -->|SW-I-005 qualified motion/actual-output data| DEM
        TR -->|SW-I-005 data| LGT
        SES -->|SW-I-006 data| HMI
        BAT -->|SW-I-006 data| HMI
        PLV -->|SW-I-009 event/service| ACC
        PLV -->|SW-I-009 event/service| BRK
        PLV -->|SW-I-009 event/service| SES
        PLV -->|SW-I-009 event/service| BAT
        PLV -->|SW-I-009 event/service| TR
    end
```

`SW-I-009` applies to all local components; selected edges keep the view legible. This figure also suppresses parts of `SW-I-003`, `SW-I-006` and `SW-I-007` where their crossing edges would obscure the host boundary. The complete endpoint, route and fanout record is [ARCH-003 port registry and route catalogue](../ARCH-003_Software_Architecture.md#static-port-registry-and-connection-catalogue); the `SW-I-*` interface definitions remain in [ARCH-003](../ARCH-003_Software_Architecture.md#typed-software-interactions).

## Cross-view use

Read this document with [DD-001](DD-001_Software_Unit_Design.md) for vehicle-policy unit semantics, [DD-002](DD-002_Battery_Protection_Unit_Design.md) for energy and regenerative acceptance, and [DD-004](DD-004_Dynamic_Software_Architecture_Views.md) for documented interaction and state examples. The released ARCH-003 deployment diagram is the source allocation view; this document restates it at unit and instance resolution for detailed-design review only.
