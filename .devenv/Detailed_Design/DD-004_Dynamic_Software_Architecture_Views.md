# DD-004 — Dynamic software architecture views

**Released 1.0 — 2026-09-13; DD-004-R1.0.** These views supplement the canonical unit designs in [DD-001](DD-001_Software_Unit_Design.md) and [DD-002](DD-002_Energy_Charging_Unit_Design.md), and the static component, deployment and interface views in [DD-003](DD-003_Static_Software_Architecture_Views.md).  They do not introduce components, state, timing, algorithms, APIs, physical behavior, or verification evidence.  A sequence is one documented interaction example, not an exhaustive state model.

## Scope and reading rules

Every received or published record retains value, qualification/freshness and producer/reset context.  In these diagrams, `qualified` means the consumer may use the stated fact under its canonical contract; it never means a physical condition is proved.  An intent, command, acknowledgement, zero request, or logical light/status mode is software intent.  `actual-output` and `actual-activity/path` are qualified observations; their physical truth, response and protection remain system acceptance work.

The diagrams cover all 14 ARCH-003 project component roles.  `.V` and `.C` are independent instances: they do not share runtime state, reset context, retention, or a live vehicle-to-charger connection.  Supplied BMS and VD18MT firmware are shown only as external participants where their boundary helps explain the interaction.

## Vehicle startup, Ready and command acceptance

This is an example of the successful path after a fresh vehicle context.  The full Ready guard remains [REQ-SYS-STA-001](../Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-001): simultaneous standstill and physical accelerator rest, current-startup accelerator/brake and VD18MT setting qualification, trustworthy actual SOC, required temperature information, passing required self-tests, no current-session inhibition and applicable permissives.  Before that guard and separate traction acceptance, neither torque sign is authorized.

```mermaid
sequenceDiagram
    participant P as SC-PLATFORM.V
    participant I as SC-INPUT-QUAL.V
    participant H as SC-HMI.V
    participant B as SC-BMS-LINK.V
    participant BP as SC-BAT-POLICY.V
    participant S as SC-SESSION.V
    participant D as SC-DEMAND.V
    participant T as SC-TRACTION-CTRL.V
    participant L as SC-LIGHT-POLICY.V
    participant SI as SC-SERVICE-INFO.V

    P->>P: create new vehicle context, invalidate prior inputs
    P->>I: startup/reset context
    P->>B: startup/reset context
    P->>T: startup/reset context
    P->>BP: retention candidate with validity/context
    I-->>S: qualified current-startup input and self-test facts
    H-->>S: qualified current-startup level and speed receipt
    B-->>BP: qualified BMS observations in current BMS context
    BP-->>S: current envelope, restrictions and battery-fault information
    T-->>S: self-test and output-observation qualification
    Note over S: initially ineligible, evaluate the complete Ready guard
    alt all current guard facts hold
        S-->>D: current authority token
        S-->>T: current authority token
        D->>D: form signed command from qualified current inputs and capability
        D-->>T: signed demand with context/expiry
        T->>T: accept only current, qualified, unexpired, context-matched authority and command
        T-->>S: qualified acceptance/output observation
        T-->>L: qualified or unqualified active-braking/output observation
    else a guard fact is absent, invalid, expired, mismatched, or inhibited
        S-->>T: no usable authority
        T->>T: request zero of both signs
    end
    S-->>H: selected report
    BP-->>H: usable charge/current information or presentation fallback input
    H-->>SI: current HMI-related observation
    L-->>SI: current logical light intent
    T-->>SI: requested versus qualified actual-output observation
```

`SC-TRACTION-CTRL.V` requesting zero does not prove zero physical torque or protection.  `SC-SERVICE-INFO.V` only assembles producer-tagged current observations and cannot grant authority or clear inhibition.

## Settings application, HMI loss and lighting feedback

The following interaction separates current VD18MT receipt from retained settings and current rider/traction evidence.  Loss after a valid receipt retains valid active/pending settings and the normal-light request; it neither freezes torque nor creates authority.  Missing current-startup receipt still blocks Ready.

```mermaid
sequenceDiagram
    participant VD as Supplied SC-VD18MT
    participant H as SC-HMI.V
    participant I as SC-INPUT-QUAL.V
    participant SET as SC-SET.V
    participant D as SC-DEMAND.V
    participant T as SC-TRACTION-CTRL.V
    participant L as SC-LIGHT-POLICY.V

    VD->>H: settings and normal-light request
    H-->>SET: current qualified decoded request
    I-->>SET: qualified standstill and physical accelerator-rest facts
    alt interpretable setting and both application facts hold
        SET->>SET: atomically apply latest valid pending setting
    else setting valid but application guard not complete
        SET->>SET: retain as pending, active setting unchanged
    end
    SET-->>D: current active setting
    I-->>D: qualified rider/motion facts
    D-->>T: current signed demand when authority and capability permit
    T-->>L: active electrical-braking observation or unqualified state
    I-->>L: qualified lever state or unqualified state
    H-->>L: normal-light request
    L->>L: front follows normal request, rear mode follows canonical policy
    Note over VD,H: endpoint loss after valid receipt
    H-->>SET: no new qualified receipt
    SET->>SET: retain existing active/pending settings
    L->>L: retain normal-light request
    I-->>D: live qualified rider/motion facts continue
    D-->>T: do not reuse a frozen demand
```

The rear logical mode can be Full for an actuated lever, active electrical braking, or either unqualified fact; it is otherwise Dim for normal request On and Off for Off.  This is logical intent, not lamp output or visible-light evidence.

## Battery capability, reset and retained operating restriction

This state view is intentionally limited to `SC-BAT-POLICY.V` ownership of the retained `reached10%` propulsion restriction.  It is not a BMS state model and does not retain battery-fault history.  `SC-BMS-LINK` requalifies observations after host startup, recognized BMS reset, or required-source qualification loss; a BMS wake/short interruption alone does not by itself clear a justified unexpired record.

```mermaid
stateDiagram-v2
    [*] --> AwaitingQualifiedInputs: new vehicle/BMS context
    AwaitingQualifiedInputs --> EvaluateEnvelope: qualified BMS, path/output, configuration and operation context
    EvaluateEnvelope --> NormalOperation: no approved cutoff entry
    EvaluateEnvelope --> Reached10Restriction: qualified entry to approved 10% cutoff
    NormalOperation --> AwaitingQualifiedInputs: required input unavailable, stale, invalid or foreign context
    NormalOperation --> Reached10Restriction: qualified cutoff entry
    Reached10Restriction --> Reached10Restriction: actual SOC not qualified above 20%
    Reached10Restriction --> NormalOperation: qualified actual SOC exceeds 20%
    Reached10Restriction --> RestoreCandidate: vehicle reset or relevant battery handling
    RestoreCandidate --> Reached10Restriction: retained candidate qualified
    RestoreCandidate --> AwaitingQualifiedInputs: candidate unqualified or absent
    note right of Reached10Restriction
      Restricts positive propulsion only.
      It does not remove auxiliary discharge,
      become a fault history, or clear session inhibition.
    end note
```

`SC-BMS-LINK.V` publishes accepted observations only; rejected frames do not refresh them.  `SC-BAT-POLICY.V` keeps charge and discharge envelopes distinct, withholds a dependent permission when a required contribution is unavailable, and reports normal restrictions separately from recognized battery faults.  A newly available envelope cannot authorize torque, clear `SC-SESSION.V` inhibition, or bypass charging-session state.

## Detached charging: event ordering, intent and actual activity

This sequence shows the canonical serialization for a qualified physical connection/reconnection or qualified USB interruption/restoration: new-session identity first, then observation qualification/fresh checks, fault/recovery, completion, and finally intent/indication.  An enable intent or control acceptance is not evidence of physical transfer; Charging requires true intent and qualified actual-charging activity.

```mermaid
sequenceDiagram
    participant P as SC-PLATFORM.C
    participant U as SC-USB-PD.C
    participant I as SC-INPUT-QUAL.C
    participant B as SC-BMS-LINK.C
    participant BP as SC-BAT-POLICY.C
    participant CP as SC-CHARGE-POLICY.C
    participant CC as SC-CHARGE-CTRL.C
    participant SI as SC-SERVICE-INFO.C

    P->>CP: qualified new-session event or reset context
    U-->>CP: qualified source/cable/contract capability and event context
    I-->>CP: qualified connection facts
    B-->>BP: qualified battery observations
    BP-->>CP: charge envelope, restrictions and battery-fault information
    CP->>CP: assess initial need using evidence valid for this event
    alt qualified actual SOC below 80%
        CP->>CP: initial need = EligibleIncomplete
    else qualified actual SOC at/above 80%
        CP->>CP: initial need = Completed, set completion hold
    else actual SOC unknown or unqualified
        CP->>CP: initial need = Unqualified
    end
    CP->>CP: apply fresh checks, recognized fault/recovery and completion state
    alt eligible incomplete, checks/conditions permit, no inhibition
        CP-->>CC: charge-enable intent
        CC->>CC: condition translation while source/path/battery remain qualified
        CC-->>CP: qualified actual-activity/path observation
    else prerequisite failed or unknown
        CP-->>CC: withdraw intent
    end
    CP-->>SI: current session state and logical mode
    CC-->>SI: actual-activity/path observation
```

`SC-USB-PD.C` and `SC-CHARGE-CTRL.C` hold no charging-session, completion, or fault history.  Their reset makes their outputs unavailable until requalified and is not itself a new session or recovery.  `SC-SERVICE-INFO.C` has no control return path.

## Detached charging-session states and reset distinctions

The state diagram captures `SC-CHARGE-POLICY.C` session ownership.  The status mapping is Fault first, then Waiting for pending checks/state qualification, then Completed for qualified completion hold, then Charging only with true intent and qualified active-charging evidence; otherwise Waiting.  It omits source-profile, numerical, electrical, timing, and physical-indicator design.

```mermaid
stateDiagram-v2
    [*] --> Waiting: new controller context, intent false
    Waiting --> AssessInitialNeed: qualified physical connection/reconnection or USB interruption/restoration
    AssessInitialNeed --> EligibleIncomplete: qualified event SOC below 80%
    AssessInitialNeed --> Completed: qualified event SOC at/above 80%
    AssessInitialNeed --> Waiting: event SOC unknown or unqualified
    EligibleIncomplete --> Waiting: ordinary temperature waiting or temporary source interruption
    Waiting --> EligibleIncomplete: current conditions permit, existing eligible incomplete session
    EligibleIncomplete --> Charging: true intent and qualified actual-charging activity
    Charging --> Waiting: activity/path or a prerequisite no longer qualified
    Charging --> Completed: qualified completion hold
    Waiting --> Completed: qualified completion hold
    Completed --> Completed: later SOC decline with connection and USB uninterrupted
    EligibleIncomplete --> Fault: recognized charging fault
    Waiting --> Fault: recognized charging fault
    Charging --> Fault: recognized charging fault
    Completed --> Fault: recognized charging fault
    Fault --> AssessInitialNeed: qualified reconnection or USB interruption/restoration, fresh checks
    Fault --> Waiting: unexpected charger-controller reset, old fault history discarded, fresh checks
    Completed --> Waiting: unexpected charger-controller reset, retain only qualified completion/initial-eligibility candidate while checks run
    note right of Fault
      Fault clearance alone does not recover.
      BMS reset/wake/telemetry return alone does not recover.
    end note
```

An ordinary source interruption retains an eligible incomplete session and can resume automatically when conditions permit.  By contrast, qualified USB interruption/restoration is a new-session event: it supersedes restored state and reassesses initial need.  Unexpected charger-controller reset discards fault history/previous fault indication, forces intent false and shows Waiting during fresh checks; it may restore only a qualified completion/initial-eligibility candidate.  A service-readout reset affects neither this state nor vehicle state.

## Traceability and limits

The vehicle views elaborate `SW-I-001` through `SW-I-006` and `SW-I-008/009`; the charging views elaborate `SW-I-003`, `SW-I-007` through `SW-I-009`.  They retain the ownership and constraints of [ARCH-003](../Architecture/ARCH-003_Software_Architecture.md), especially its [startup sequence](../Architecture/ARCH-003_Software_Architecture.md#startup-and-critical-sequences), [retention rules](../Architecture/ARCH-003_Software_Architecture.md#retained-restriction-and-reset-state), and [typed interactions](../Architecture/ARCH-003_Software_Architecture.md#typed-software-interactions).

The source is intentionally underdefined on event-detection mechanism, ordering across simultaneously arriving external observations, timing bounds, physical activity/path evidence, self-test scope, retained-state integrity, and diagnostic coverage.  These views use only the documented serialized order within `SC-CHARGE-POLICY.C`; they do not resolve the remaining external ordering or qualification gates.
