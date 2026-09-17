# DD-003 — Static software architecture views

**Draft vehicle baseline — 2026-09-16.** Full static composition, Hall/FOC ownership, runtime realization, battery/BMS/service units, deployment and local-interface views are retained.
**Draft 1.3 — 2026-09-14; successor to DD-003-R1.1.** These controlled views include Hall-position/FOC composition and the selected EVM physical boundary, and make the Draft [ARCH-003 component and host allocation](../SoftwareArchitecture/ARCH-003_Software_Architecture.md) and the unit catalogues in [DD-001](DD-001_Software_Unit_Design.md) and [DD-002](DD-002_Battery_Protection_Unit_Design.md) easier to inspect.

## Scope and notation


The detailed behaviour, qualification, reset, retention and physical-acceptance limits remain authoritative in DD-001, DD-002 and ARCH-003. The [runtime integration contract](../SoftwareArchitecture/Runtime_Integration_Contract.md) separately maps units to project bindings, direct fast calls and deferred scheduled routes; it is not a claim that every unit is a task. A requested zero, a command or an output observation is not proof of physical regeneration, protection or output.

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
        TRACTION[SC-TRACTION-CTRL] -->|contains| UTA[U-TRACTION-ACCEPT]
        TRACTION -->|contains| UTAO[U-TRACTION-ACTUAL-OUTPUT]
        TRACTION -->|contains| UTM[U-TRACTION-MOTION]
        TRACTION -->|contains| UTC[U-TRACTION-CONTROL]
        TRACTION -->|contains| UTO[U-TRACTION-OUTPUT]
        PLATFORM[SC-PLATFORM] -->|contains| UPC[U-PLATFORM-CONTEXT]
        PLATFORM -->|contains| UPB[U-PLATFORM-BINDING]
        PLATFORM -->|contains| UPCA[U-PLATFORM-CALIBRATION]
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

`U-ANALOG-ACQ-*`, the named sensor-interface units, `U-TRACTION-ACCEPT`, `U-TRACTION-MOTION`, `U-TRACTION-ACTUAL-OUTPUT` and `U-PLATFORM-*` refine approved ASW allocations. `U-HALL-CAPTURE` and `U-HALL-POSITION` own Hall buffer/capture integrity and qualified electrical position; `U-TRACTION-CONTROL` consumes that position with qualified phase feedback and fast Vdc for selected FOC. `U-TRACTION-OUTPUT` owns compare-latch/inhibit sequencing under Draft HSI-009; the [traction HSI](../DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md) owns the concrete platform contract. None proves physical output behaviour.

The implementation contract makes the ownership exact: `U-PLATFORM-CONTEXT` orchestrates startup/context invalidation and `U-PLATFORM-BINDING` starts selected resources and dispatches ADC1/ADC2 JEOS to `U-ANALOG-ACQ-FAST`, which snapshots raw JDR data into `InjectedEpochV1`. `U-MOTOR-PHASE-FAST` and `U-SUPPLY-FAST` convert the raw epoch into qualified phase feedback and fast Vdc; `U-HALL-CAPTURE`/`U-HALL-POSITION` provide electrical position. `U-TRACTION-CONTROL` consumes those qualified records and emits compare/context data, including the next sampling-plan `CCR4`; `U-TRACTION-OUTPUT` alone stages/commits literal TIM8 `CCR1..4` and JSQR. `U-ANALOG-ACQ-REGULAR` owns regular-DMA completed-record publication, while `U-HALL-CAPTURE` owns Hall capture storage and `U-HALL-POSITION` its interpretation. The direct fast chain is neither a CortexOs scheduled task nor current intercom usage; the qualified [runtime contract](../SoftwareArchitecture/Runtime_Integration_Contract.md) owns remaining project/generic-driver and future-intercom detail.

### Vehicle runtime realization boundary

```mermaid
flowchart LR
    subgraph D[Generic src/drv: current and proposed register access]
        CORE[Core/RCC/GPIO/USART/WWDG: current]
        FUT[ADC/TIM/DMA/IRQ and compiler plus hardware barrier support: proposed]
    end
    subgraph P[Project bindings inside named units]
        BOOT[U-PLATFORM-BINDING\nB-PLATFORM-BOOT]
        DISP[U-PLATFORM-BINDING\nB-PLATFORM-IRQ-DISPATCH]
        DMA[U-ANALOG-ACQ-REGULAR\nB-REGULAR-ADC-DMA]
    end
    subgraph F[Direct fast traction chain]
        JEOS[U-ANALOG-ACQ-FAST\nB-FAST-ANALOG-JEOS / InjectedEpochV1]
        QUAL[U-MOTOR-PHASE-FAST + U-SUPPLY-FAST + U-HALL-POSITION\nqualified phase/Vdc/electrical position]
        FOC[U-TRACTION-CONTROL\nFastCommandV1: CCR1..3, CCR4, ADC context]
        OUT[U-TRACTION-OUTPUT\nsole CCR1..4 + JSQR / UDIS commit lease]
    end
    OS[CortexOs cyclic scheduler\ncurrent tasks] -->|scheduled regular qualification/policy| DMA
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

Solid fast-path edges are direct calls. Dashed nodes identify capability work, not implemented drivers or intercom endpoints. Project route identity, context, freshness, expiry and fault policy remain outside generic `src/os` transport mechanics.

### Battery, BMS and service domain

```mermaid
flowchart TB
    subgraph E[Energy and service component types]
        BMS[SC-BMS-LINK] -->|contains| UBT[U-BMS-LINK-TRANSACTION]
        BMS -->|contains| UBD[U-BMS-LINK-DECODE]
        BMS -->|contains| UBP[U-BMS-LINK-PUBLISH]
        BAT[SC-BAT-POLICY] -->|contains| UBPE[U-BAT-POLICY-EVALUATE]
        BAT -->|contains| UBPR[U-BAT-POLICY-RESTRICTION]
        SERVICE[SC-SERVICE-INFO] -->|contains| USIC[U-SERVICE-INFO-COLLECT]
        SERVICE -->|contains| USIS[U-SERVICE-INFO-SNAPSHOT]
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
        V10[SC-SERVICE-INFO.V]
        V11[SC-PLATFORM.V]
    end
```

`SC-BMS` remains supplied opaque firmware on `HC-BMS`; `SC-VD18MT` remains supplied opaque firmware in the VD18MT assembly within `HC-RIDER`. Neither receives a `U-*` node in these views.

## Demand-arbitration typed boundary

`U-DEMAND-ARBITER` has no generic `inputsIn` collection. Each ingress below carries its own value, qualification, freshness, producer/context, configuration identity and generation. Demand evaluates one coherent snapshot; a route being drawn does not make a prior record current.

```mermaid
flowchart LR
    ACC[U-ACCELERATOR-QUALIFY\nAcceleratorPositionV1] -->|P-DEM-ACCELERATOR-I| D[U-DEMAND-ARBITER]
    BRK[U-BRAKE-QUALIFY\nBrakeStateV1] -->|P-DEM-BRAKE-I| D
    SET[U-SET-STATE\nActiveRidingSettingsV1] -->|P-DEM-ACTIVE-SETTINGS-I| D
    SES[U-SESSION-ELIGIBILITY\nPSesAuthOInformation] -->|P-DEM-AUTHORITY-I| D
    BAT[U-BAT-POLICY-RESTRICTION\nPBatEnvelopeOInformation] -->|P-DEM-BATTERY-CAPABILITY-I| D
    MOT[U-TRACTION-MOTION\nQualifiedMotionV1] -->|P-DEM-MOTION-I| D
    OUT[U-TRACTION-ACTUAL-OUTPUT\nActualTractionOutputV1 estimate] -->|P-DEM-ACTUAL-OUTPUT-I| D
    PLT[U-PLATFORM-CONTEXT / HEALTH\ncurrent generation] --> D
    CAL[U-PLATFORM-CALIBRATION\nresolved validated DemandPolicyCalibration data] --> D
    D -->|P-DEM-COMMAND-O\nrequestedWheelTorqueNewtonMetres, authorityGeneration, commandExpiryTimestampTicks, commandClockId/context| TA[U-TRACTION-ACCEPT]
    TA -->|accepted signed request\neffectiveAcceptedExpiryTimestampTicks with acceptanceClockId/context| TC[U-TRACTION-CONTROL]
    D -->|P-DEM-DIAGNOSTIC-O\nservice only| SI[U-SERVICE-INFO-COLLECT]
```

`U-TRACTION-MOTION` is a real producer route, not a reinterpretation of a Demand command: it interprets current qualified Hall capture/position evidence only with current capture health, map/pole-pair/final-drive/loaded-wheel calibration and a released bounded-observability/standstill criterion before publishing speed, direction and standstill. A static Hall state or no edge alone is unavailable for this purpose. `U-TRACTION-ACTUAL-OUTPUT` publishes `ActualTractionOutputV1` only as a current qualified estimate from post-stage physical evidence with provenance plus same-operation phase-current/position and qualified vehicle-motion evidence with activated estimator calibration. It operates independently of acceptance; `U-TRACTION-ACCEPT` passes that observation without refreshing or gating it while separately issuing accepted demand to control. Its applied-torque and powered-forward-travel fields must be unavailable if that chain has only a requested torque, FOC reference, register/PWM state, output-stage event or acceptance result. The command is a request; neither observation proves physical torque or vehicle travel.

| Decision input/output | Consumer acceptance and ownership |
|---|---|
| Active settings | Only the active level/speed setting is used. Pending values, receipt order and setting activation remain `SC-SET` ownership. |
| Authority and command | `authorityExpiryTimestampTicks` and `commandExpiryTimestampTicks` carry independent decision sequences and named `authorityClockId`/`authorityClockContextId` and `commandClockId`/`commandClockContextId`. Acceptance emits `effectiveAcceptedExpiryTimestampTicks` only after clock/context equality or qualified conversion; Demand cannot refresh authority by issuing a command. |
| Motion and actual output | Demand requires current qualified motion for speed/standstill decisions and current qualified actual positive applied torque plus forward travel to re-arm regeneration after stop. Hand-push travel cannot satisfy the latter proof. |
| Capability | `PBatEnvelopeOInformation` supplies independently qualified positive/negative ceilings, reasons and restriction generations. Demand clamps signs independently, owns regeneration-recovery episode qualification, and does not own protection. |
| Calibration and diagnostic | `DemandPolicyCalibration` carries resolved, validated release-controlled maps, ramps, taper, reference limits and timing-bound data. Diagnostic reason/generation goes one way to service; it has no rider or control route. |

## Static local-interface view

The interface names and endpoint scopes below are the released `SW-I-*` contracts from ARCH-003. Flow labels distinguish **data** publications, **control** token/data, and **event/service** interactions. They do not introduce timing, protocol, electrical or physical semantics. The complete port-to-port route catalogue is [ARCH-003 port registry and route catalogue](../SoftwareArchitecture/ARCH-003_Software_Architecture.md#static-port-registry-and-connection-catalogue); this view intentionally labels interface groups rather than every `P-*` endpoint.

```mermaid
flowchart LR
    subgraph V[HC-CONTROLLER / .V]
        ACC[SC-ACCELERATOR-IF.V]
        BRK[SC-BRAKE-IF.V]
        HMI[SC-HMI.V]
        SET[SC-SET.V]
        SES[SC-SESSION.V]
        DEM[SC-DEMAND.V]
        TR[SC-TRACTION-CTRL.V]
        BAT[SC-BAT-POLICY.V]
        LGT[SC-LIGHT-POLICY.V]
        BMS[SC-BMS-LINK.V]
        PLV[SC-PLATFORM.V]
        SIV[SC-SERVICE-INFO.V]
        ACC -->|SW-I-001 data| SET
        ACC -->|SW-I-001 data| SES
        ACC -->|SW-I-001 accelerator data| DEM
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
        PLV -->|SW-I-009 event/service| SIV
        ACC -->|SW-I-008 data| SIV
        BRK -->|SW-I-008 data| SIV
        DEM -->|SW-I-008 policy diagnostic| SIV
        SES -->|SW-I-008 data| SIV
        BAT -->|SW-I-008 data| SIV
        TR -->|SW-I-008 data| SIV
    end
```

`SW-I-008` is representative in the drawing: ARCH-003 defines it from all local producers to `SC-SERVICE-INFO`; the omitted producer edges are not a change in endpoint scope. `SW-I-009` likewise applies to all local components; selected edges keep the view legible. This figure also suppresses parts of `SW-I-003`, `SW-I-006` and `SW-I-007` where their crossing edges would obscure the host boundary. The complete endpoint, route, fanout and representational-omission record is [ARCH-003 port registry and route catalogue](../SoftwareArchitecture/ARCH-003_Software_Architecture.md#static-port-registry-and-connection-catalogue); the `SW-I-*` interface definitions remain in [ARCH-003](../SoftwareArchitecture/ARCH-003_Software_Architecture.md#typed-software-interactions).

## Cross-view use

Read this document with [DD-001](DD-001_Software_Unit_Design.md) for vehicle-policy unit semantics, [DD-002](DD-002_Battery_Protection_Unit_Design.md) for energy, regenerative acceptance and service semantics, and [DD-004](DD-004_Dynamic_Software_Architecture_Views.md) for documented interaction and state examples. The released ARCH-003 deployment diagram is the source allocation view; this document restates it at unit and instance resolution for detailed-design review only.
