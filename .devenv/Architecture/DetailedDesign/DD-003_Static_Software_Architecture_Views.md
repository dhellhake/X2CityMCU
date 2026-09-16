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
        INPUT[SC-INPUT-QUAL] -->|contains| UIC[U-INPUT-CONTEXT]
        INPUT -->|contains| UIQ[U-INPUT-QUALIFIER]
        TRACTION[SC-TRACTION-CTRL] -->|contains| UTA[U-TRACTION-ACCEPT]
        TRACTION -->|contains| UTP[U-TRACTION-POSITION]
        TRACTION -->|contains| UTC[U-TRACTION-CONTROL]
        TRACTION -->|contains| UTAQ[U-TRACTION-ACQUISITION]
        TRACTION -->|contains| UTO[U-TRACTION-OUTPUT]
        PLATFORM[SC-PLATFORM] -->|contains| UPC[U-PLATFORM-CONTEXT]
        PLATFORM -->|contains| UPB[U-PLATFORM-BINDING]
        PLATFORM -->|contains| UPR[U-PLATFORM-RETENTION]
        PLATFORM -->|contains| UPH[U-PLATFORM-HEALTH]
    end
```

### Hall evidence and traction interpretation

```mermaid
flowchart LR
    H[HC-MOTOR Hall1..3] -->|J7 1..3| E[Selected DRV8300 EVM]
    V5[External qualified 5-V Hall supply] -->|planned J3 HALL_EXT then J7-4| E
    E -->|fixed 3.3-V R9/R10/R11 pull-ups and J2 13/15/17| FE[HC-INPUT-FE / host adapter]
    FE -->|conditioned acquired state/edges, open host realization| I[SC-INPUT-QUAL.V]
    I -->|sampled state + edge evidence, validity/freshness/context| P[U-TRACTION-POSITION]
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

`U-INPUT-*`, `U-TRACTION-ACCEPT` and `U-PLATFORM-*` refine approved ASW allocations. `U-TRACTION-POSITION` and `U-TRACTION-CONTROL` are approved Hall interpretation and selected-FOC-control refinements. `U-TRACTION-ACQUISITION` owns completed ADC-epoch publication and `U-TRACTION-OUTPUT` owns compare-latch/inhibit sequencing under Draft HSI-009; the [traction HSI](../DRV8300DRGE-EVM/DRV8300DRGE-EVM_WeAct_STM32H723VGT6_Traction_HSI.md) owns the concrete platform contract. None proves physical output behaviour.

The implementation contract makes the ownership exact: `U-PLATFORM-CONTEXT` orchestrates startup/context invalidation and `U-PLATFORM-BINDING` starts selected resources and dispatches ADC1/ADC2 JEOS to `U-TRACTION-ACQUISITION`; it snapshots JDR data and directly hands an immutable epoch to `U-TRACTION-CONTROL`. Control emits compare/context data, including the next sampling-plan `CCR4`; `U-TRACTION-OUTPUT` alone stages/commits literal TIM8 `CCR1..4` and JSQR. `U-INPUT-CONTEXT` owns regular-ADC and Hall DMA buffers/handlers and its direct stable Hall accessor. The direct fast chain is neither a CortexOs scheduled task nor current intercom usage; the qualified [runtime contract](../SoftwareArchitecture/Runtime_Integration_Contract.md) owns remaining project/generic-driver and future-intercom detail.

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
        DMA[U-INPUT-CONTEXT\nB-REGULAR-ADC-DMA / B-HALL-DMA]
    end
    subgraph F[Direct fast traction chain]
        JEOS[U-TRACTION-ACQUISITION\nB-FAST-TRACTION-IRQ / FastEpochV1]
        FOC[U-TRACTION-CONTROL\nFastCommandV1: CCR1..3, CCR4, ADC context]
        OUT[U-TRACTION-OUTPUT\nsole CCR1..4 + JSQR / UDIS commit lease]
    end
    OS[CortexOs cyclic scheduler\ncurrent tasks] -->|scheduled regular qualification/policy| DMA
    DMA -->|direct stable Hall accessor| FOC
    BOOT --> DISP
    DISP --> JEOS
    FUT -. generic operations .-> BOOT
    FUT -. generic operations .-> DMA
    FUT -. generic operations .-> JEOS
    JEOS == direct, no queue ==> FOC
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
        V6[SC-INPUT-QUAL.V]
        V7[SC-TRACTION-CTRL.V]
        V8[SC-BMS-LINK.V]
        V9[SC-BAT-POLICY.V]
        V10[SC-SERVICE-INFO.V]
        V11[SC-PLATFORM.V]
    end
```

`SC-BMS` remains supplied opaque firmware on `HC-BMS`; `SC-VD18MT` remains supplied opaque firmware in the VD18MT assembly within `HC-RIDER`. Neither receives a `U-*` node in these views.

## Static local-interface view

The interface names and endpoint scopes below are the released `SW-I-*` contracts from ARCH-003. Flow labels distinguish **data** publications, **control** token/data, and **event/service** interactions. They do not introduce timing, protocol, electrical or physical semantics. The complete port-to-port route catalogue is [ARCH-003 port registry and route catalogue](../SoftwareArchitecture/ARCH-003_Software_Architecture.md#static-port-registry-and-connection-catalogue); this view intentionally labels interface groups rather than every `P-*` endpoint.

```mermaid
flowchart LR
    subgraph V[HC-CONTROLLER / .V]
        IQ[SC-INPUT-QUAL.V]
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
        IQ -->|SW-I-001 data| SET
        IQ -->|SW-I-001 data| SES
        IQ -->|SW-I-001 data| DEM
        IQ -->|SW-I-001 data| LGT
        HMI -->|SW-I-002 data| SET
        HMI -->|SW-I-002 data| SES
        HMI -->|SW-I-002 data| DEM
        BMS -->|SW-I-003 data| BAT
        BAT -->|SW-I-003 data| SES
        BAT -->|SW-I-003 data| DEM
        SES -->|SW-I-004 control token| TR
        DEM -->|SW-I-004 control data| TR
        TR -->|SW-I-005 data| SES
        TR -->|SW-I-005 data| DEM
        TR -->|SW-I-005 data| LGT
        SES -->|SW-I-006 data| HMI
        BAT -->|SW-I-006 data| HMI
        PLV -->|SW-I-009 event/service| IQ
        PLV -->|SW-I-009 event/service| SES
        PLV -->|SW-I-009 event/service| BAT
        PLV -->|SW-I-009 event/service| TR
        PLV -->|SW-I-009 event/service| SIV
        IQ -->|SW-I-008 data| SIV
        SES -->|SW-I-008 data| SIV
        BAT -->|SW-I-008 data| SIV
        TR -->|SW-I-008 data| SIV
    end
        BMSC -->|SW-I-003 data| BATC
        BATC -->|SW-I-003 data| CP
        USB -->|SW-I-007 data| CP
        CC -->|SW-I-007 data| CP
        IQC -->|SW-I-007 data| CP
        CP -->|SW-I-007 control intent| CC
        PLC -->|SW-I-009 event/service| BMSC
        PLC -->|SW-I-009 event/service| BATC
        PLC -->|SW-I-009 event/service| CP
        PLC -->|SW-I-009 event/service| CC
        PLC -->|SW-I-009 event/service| USB
        BMSC -->|SW-I-008 data| SIC
        BATC -->|SW-I-008 data| SIC
        CP -->|SW-I-008 data| SIC
        CC -->|SW-I-008 data| SIC
    end
```

`SW-I-008` is representative in the drawing: ARCH-003 defines it from all local producers to `SC-SERVICE-INFO`; the omitted producer edges are not a change in endpoint scope. `SW-I-009` likewise applies to all local components; selected edges keep the view legible. This figure also suppresses parts of `SW-I-003`, `SW-I-006` and `SW-I-007` where their crossing edges would obscure the host boundary. The complete endpoint, route, fanout and representational-omission record is [ARCH-003 port registry and route catalogue](../SoftwareArchitecture/ARCH-003_Software_Architecture.md#static-port-registry-and-connection-catalogue); the `SW-I-*` interface definitions remain in [ARCH-003](../SoftwareArchitecture/ARCH-003_Software_Architecture.md#typed-software-interactions).

## Cross-view use

Read this document with [DD-001](DD-001_Software_Unit_Design.md) for vehicle-policy unit semantics, [DD-002](DD-002_Battery_Protection_Unit_Design.md) for energy, regenerative acceptance and service semantics, and [DD-004](DD-004_Dynamic_Software_Architecture_Views.md) for documented interaction and state examples. The released ARCH-003 deployment diagram is the source allocation view; this document restates it at unit and instance resolution for detailed-design review only.
