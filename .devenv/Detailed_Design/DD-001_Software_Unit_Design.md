# DD-001 — Software unit design

**Released 1.1 — 2026-09-14; DD-001-R1.1.** This controlled refinement defines the Hall-position/FOC-control units. It implements no code, makes no physical-control claim, and does not revise the approved system/component architecture.

## Scope and modelling rules

Each `U-*` unit has one owning `SC-*` component. Unit Requirements derive only from an Abstract Software Requirement (ASW); no Unit Requirement derives directly from System, HSI, FSC, or hardware requirements.

Every local record carries a semantic value, qualification, freshness, producer identity, configuration, and reset/operation context. A consumer accepts it only if all are current, coherent and qualified; absent, stale, invalid and context-mismatched values remain unavailable. A command, acknowledgement, status bit or zero request never proves a physical state. Inputs are immutable snapshots and state/output updates are atomic.

No final host, board, pin, task rate, timeout, calibration, diagnostic coverage or physical output is selected. The selected Hall-sensored FOC realization is defined in [MCD-001](../Motor/MCD-001_Hall_Sensored_FOC_Technical_Design.md); its board/timing/calibration/protection gates remain open. The repository's firmware and WeAct STM32H723VGT6 V1.2/DRV8300 EVM material are development references only, not final-product design or acceptance evidence.

## Unit catalogue

| Unit | Owner | Purpose / governing interfaces | ASW disposition |
|---|---|---|---|
| `U-SET-STATE` | SC-SET | requested/pending/active settings, SW-I-001/002 | UR-SET-001 |
| `U-SESSION-ELIGIBILITY` | SC-SESSION | Ready authority and current-session inhibition, SW-I-004 | UR-SESSION-001 |
| `U-SESSION-REPORT` | SC-SESSION | report-group selection | UR-SESSION-002 |
| `U-DEMAND-ARBITER` | SC-DEMAND | signed wheel-demand arbitration, SW-I-001–005 | UR-DEMAND-001 |
| `U-HMI-ADAPTER` | SC-HMI | VD18MT receipt and outgoing report formation, SW-I-002/006 | UR-HMI-001 |
| `U-LIGHT-MODE` | SC-LIGHT-POLICY | retained normal request and front/rear mode, SW-I-005/006 | UR-LIGHT-001 |
| `U-INPUT-CONTEXT`, `U-INPUT-QUALIFIER` | SC-INPUT-QUAL | acquisition context, semantic qualification and Hall sampled-state/edge evidence, SW-I-001 | REQ-SYS-INP-001 |
| `U-TRACTION-ACCEPT` | SC-TRACTION-CTRL | authority/command acceptance and observation publication, SW-I-004/005 | REQ-SYS-TRQACC-001 |
| `U-TRACTION-POSITION` | SC-TRACTION-CTRL | qualified Hall evidence → electrical rotor sector/direction/edge time, internal traction input | UR-TRACTION-POSITION-001 |
| `U-TRACTION-CONTROL` | SC-TRACTION-CTRL | Hall-sensored FOC current regulation and output/energy observation, internal traction realization | UR-TRACTION-CONTROL-001 |
| `U-PLATFORM-CONTEXT`, `U-PLATFORM-RETENTION`, `U-PLATFORM-HEALTH` | SC-PLATFORM | context, retention result and health events, SW-I-009 | REQ-SYS-PLT-001 |
| DD-002 units | BMS-LINK, BAT-POLICY, CHARGE-POLICY, SERVICE-INFO | energy/charging/service owner scope | DD-002 owner |

## Vehicle policy units

### U-SET-STATE

Consumes qualified current-context VD18MT requests and coherent qualified standstill/physical-accelerator-rest evidence. It retains distinct requested, pending and active state. On an interpretable speed request `r`, it applies the parent normalization `N(r)=r` for `0<r<40` km/h and `N(r)=40` for `r=0` or `r>=40`; unrecognized input changes neither valid active nor pending state. The latest valid pending settings apply atomically only when both guard facts hold. Active values remain otherwise, and active/pending speed never exceeds 40 km/h. No received setting is inferred from initialization, retention, absence or an unqualified receipt.

### U-SESSION-ELIGIBILITY and U-SESSION-REPORT

Eligibility starts ineligible in each new vehicle context. Only the complete parent Ready guard issues an authority token with current context and expiry; any absent, invalid, expired or mismatched prerequisite withdraws it. A recognized parent-defined riding fault latches current-session inhibition, which cleared observation alone cannot remove. The unit consumes self-test results and does not claim their diagnostic coverage or physical inhibition.

Report selection starts empty per context. With no selection, retain the earliest recognized reportable group fault; for an indistinguishable earliest set retain the lowest assigned code. Retain it until restart, above low-charge `0x01`; it cannot rank physical severity, clear inhibition or establish display receipt.

### U-DEMAND-ARBITER

Forms one signed wheel-demand record from qualified rider/motion/settings information, authority and capability/restriction information under the existing parent torque, brake, speed and override rules. Positive denotes forward torque. Each applicable both-sign inhibition produces zero; a positive-only restriction remains distinct from a permitted negative/regenerative command. A usable command needs current coherent evidence and authority. The unit defines neither motor-control law nor actual torque/protection.

### U-HMI-ADAPTER and U-LIGHT-MODE

The HMI adapter distinguishes current qualified receipt from decoder initialization, retained setting and transport activity. Endpoint loss, restart or unqualified receipt creates no setting or authority. Each outgoing update forms only parent-defined fields from selected report, usable charge and unsigned current magnitude/fallback, preserving internal validity separately from a transmitted fallback. Encoding, rounding, timing, electrical transport and display presentation remain gates.

Light mode starts normal request `N` Off in each powered session and retains it through communication loss. Front follows `N`; rear is Full for an actuated lever, active electrical braking, or either unqualified fact, otherwise Dim for `N=On` and Off for `N=Off`. It publishes logical intent only; physical conservative rear behavior before policy execution remains hardware/system work.

## Input, traction and platform derivation gates

`U-INPUT-CONTEXT` invalidates affected observations on producer/reset/power context change. `U-INPUT-QUALIFIER` maps acquisition only through a later qualified contract to semantic values with qualification/freshness; it never substitutes a previous value for unknown. For motor Hall inputs it publishes sampled logic state independently from edge evidence; a static qualifying state can support later rotor-sector interpretation at genuine rest, but neither it nor an absent edge proves vehicle speed/standstill or a complete fault diagnosis. `U-TRACTION-ACCEPT` accepts authority and signed command only when current, qualified, unexpired and context-matched; otherwise it requests zero of both signs and separately reports acceptance/output observation. `U-TRACTION-POSITION` consumes electrical rotor-sector/direction/edge-time only after map/alignment qualification. `U-TRACTION-CONTROL` performs the selected Hall-sensored FOC algorithm defined in MCD-001: same-epoch valid phase-current samples, bounded electrical angle, `Id*=0`, calibrated `Iq*`, common vector saturation/anti-windup and separately qualified actual torque/energy observation. A reference or PWM state does not prove torque, braking or energy direction. `U-PLATFORM-CONTEXT` creates/invalidate contexts; `U-PLATFORM-RETENTION` restores only host-provided items after integrity/context qualification; `U-PLATFORM-HEALTH` publishes scheduling/local-health events without asserting a safe physical reaction.

These are explicit SW realizations in ARCH-003 and support HSI-001/004/007. Their distinct ASW requirements and Unit children are recorded in the Control Unit Requirements catalogue. Electrical/sensing, command representation, response bounds, host resources, reset domains, retention integrity, physical outputs and diagnostic coverage remain parent acceptance gates.

## Traceability and verification intent

The catalogue and [Control Unit Requirements](../Requirements/Unit_Requirements/Control_Unit_Requirements.md) provide stable unit→SC and ASW→UR mappings; each UR names its parents. Planned unit verification covers state transitions, unavailable/stale/context mismatch, reset and simultaneous-event cases. It is not executed evidence. Parent System requirements retain their stated-level verification including physical output and end-to-end timing.
