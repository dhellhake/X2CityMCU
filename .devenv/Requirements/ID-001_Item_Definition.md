# ID-001 — Item Definition Elaboration

| Attribute | Value |
|---|---|
| Revision / release | 1.1 Draft, 2026-09-11; prior release ID-001-R1.0 in Git |
| Status | Draft: incorporates owner-confirmed battery/BMS/UART, riding-temperature, charging and storage changes |
| Upstream | [PD-001 Draft1.2](../../README.md); released PD-001-R1.1 retained in [Git](README.md#release-and-history) |
| Related records | [Requirements](REQ-001_Requirements.md); [decisions/issues](DEC-001_Decisions_and_Open_Issues.md); [index](README.md) |

## 1. Purpose, authority and coverage

This document defines operational context, boundary interactions and safety-analysis inputs for the **Modified BMW X2City personal electric scooter**. PD-001 owns project scope, component selections, mission/performance/environment, constraints and broader scenarios. DEC-001 owns current owner decisions and their supersession. REQ-001 owns approved obligations and planned verification; the summaries here introduce no additional requirements. Its [PD obligation disposition](REQ-001_Requirements.md#pd-obligation-disposition) records upstream retention and remaining derivation across the full PD scope.

The original ID-001-R1.0 input baseline is released; this changed working revision is Draft. Unresolved engineering and verification work remains assigned downstream. Owner decisions, approved requirements, provisional assumptions and demonstrated evidence remain distinct. Historical interface/software observations do not verify the proposed vehicle behavior. The built pack/BMS selection is fixed; remaining architecture, sensing realization, algorithms, safety classifications/goals and technical safety mechanisms are downstream work.

## 2. Item boundary, actors and interfaces

### 2.1 Vehicle item and functional development system

The item is the complete modified scooter in its riding configuration: retained mechanical platform, steering and mechanical brakes; lights and brake-handle networks; installed rear hub motor, accelerator and VD18MT; installed removable battery; and all supporting electrical/electronic equipment, wiring, enclosures, software and calibration. Retained parts remain inside vehicle validation scope.

The **Electrical Propulsion and Control System (EPCS)** is the functional development system in PD-001 §4.4, covering energy storage/supervision, charging, distribution, motor/rider/brake control, vehicle supervision, HMI, lighting and diagnostics. It is not a particular controller board; development-responsibility interfaces do not remove provided components from the functional system.

The same battery when removed, its mobile charger and removal/refitting interfaces remain inside the broader project/safety scope, outside the installed riding configuration. Electrically connected but unseated/unlocked is an intermediate handling configuration, not readiness. External charging is dry and off-vehicle only and must work without powered vehicle electronics; installed regeneration is separate. The upstream USB-C source/electrical installation is outside project development scope. Pack/charger allocation and final connections remain open. See PD-001 §§4–5, 11.8.

### 2.2 Actors and boundary interactions

| Actor/entity | Interaction | PD-001 interface |
|---|---|---|
| Rider | Support, steering, accelerator, mechanical levers, VD18MT controls and battery handling/locking | IF-EXT-001 |
| Private paved surface | Grip, grade, tyre forces and disturbances | IF-EXT-002 |
| Other people, vehicles, obstacles | External collision/interference context | IF-EXT-003 |
| Ambient/parking environment | Heat/cold, sun, moisture, contamination, snow and freeze/thaw; exposed battery bay | IF-EXT-004, IF-EXT-007 |
| Removed battery/mobile charger | Same pack crosses riding, handling, storage and off-vehicle charging configurations | IF-EXT-005 |
| USB-C source/cable | Negotiated input, constrained by source, cable, battery and temperature capability | IF-EXT-008 |
| Maintainer/developer/service equipment | Inspection, isolation, measurement, calibration and controlled development | IF-EXT-006 |

The EPCS receives accelerator position, shared brake-handle information, VD18MT level/speed/light commands and the VD18MT power-control interface. Mechanical steering and braking remain available independently of EPCS power.

The **fixed brake interface** is a passive, polarity-independent, resistance-coded network: each normally open contact has a parallel release resistor and permanent series resistor; two branches join through a passive Y into one two-wire trunk. Four finite codes represent neither/left/right/both pressed. It is not two independent electrical channels. The [brake reference](evidence/Brake_Input_Reference.md) owns resistance values, terminal measurements, provenance and inherent diagnostic limits. The left lever operates the front mechanical brake; the right operates the rear. Only that interface is adopted; sensing, excitation/loading, protection, acquisition, classification, filtering, timing and diagnostic coverage must be derived (DEC-REF-002; WS-OI-012).

The [VD18MT reference](../VD18MT/VD18MT_Tongsheng_UART_Interface.md) owns project-independent device/protocol facts. Vehicle meanings and selected-unit qualification belong to this workstream. Historical implementation reuse under DEC-REF-001 is not evidence for new vehicle behavior (WS-OI-008–010).

### 2.3 Fixed battery and BMS integration

The same removable pack contains **70 Samsung INR18650-35E cells in 14S5P**; construction, initial bay fit and working operation are owner-confirmed. **JBD SP14S004P14S50A** and its **UART** are selected. The owner confirms the BMS is connected but not fully configured; deriving its configuration is current engineering work. [BAT-001](../Battery/BAT-001_Selected_Pack_and_BMS.md) owns ratings, derivations and source limitations; [ARCH-001](../Architecture/ARCH-001_System_Architecture.md) allocates the cell bank and UART interpretation while treating the supplied BMS, including its firmware, as a composite integration boundary.

The nominal pack reference is 50.4 V; full-cell-test voltage 58.8 V is not an 80% SOC charger setpoint. The cell bank limits the ideal continuous battery discharge/charge ceilings to 40/10 A, subject to stricter integrated limits. BMS observations cover 14 parallel-group voltages and available probes, not every individual cell condition. Qualified SOC, current, temperatures, protection and path status feed the existing control/charging rules; vendor recovery or readback alone does not establish Ready or release a latched system fault.

Resolve the non-isolated UART's manufacturer restriction, switched-negative/power references, B+ exposure and physical protection integration before interconnection. BMS charge-path interruption during motor generation, communication faults, automatic recovery and controller/BMS resets require coordinated energy/fault handling. Normal battery handling, detached independence and charging completion-hold behavior remain controlling. See [battery integration requirements](System_Requirements/Battery_Integration.md), DEC-BAT-002 and PD OI-040/041/045/046/048/061.

The [battery event matrix](System_Requirements/Battery_Integration.md#battery-event-and-recovery-matrix) distinguishes initial qualification, ordinary restrictions, recognized telemetry/protection faults and expected versus failed energy paths. Required physical protection remains applicable when the vehicle controller/UART is unavailable. [ARCH-001](../Architecture/ARCH-001_System_Architecture.md#battery-protection-and-reset-responsibilities) separates BMS, riding-controller, charging-controller and charging-connection reset effects.

## 3. Intended use and operating envelope

PD-001 §§6–8 control the one-adult-plus-luggage private-property mission, reference range/acceleration/grades, mass, environmental exposure and off-vehicle charging. RQ-001 qualifies at least 70 km using a new battery inside **20–80% actual SOC**; energy outside that window receives no qualification credit. Riding ambient is now **−10…+40°C** under DEC-BAT-002; fitted/empty-bay outdoor storage remains −15…+40°C. Cell-surface discharge limits are −10…60°C and charging, including regeneration, 0…45°C, with conservative integrated limits to be derived. Cold/weather performance allowances apply only within applicable temperature limits.

For mass planning, [DEC-MAS-001](DEC-001_Decisions_and_Open_Issues.md#dec-mas-001) permits the provisional [PD DV-012 budget](../../README.md#dv-012--payload-and-vehicle-mass-budget) without first weighing the gutted scooter. This does not change the 30 kg vehicle / 100 kg minimum payload limits or the 130 kg performance/range reference; complete mass verification remains a later acceptance gate.

Storage duty is **168 h outdoors with the battery fitted or empty bay exposed**, and **672 h for the detached pack dry indoors at 15–30°C**. Both battery duties start at normal full charge, 80% actual SOC subject to qualified conservative tolerance; entry above 80% or below qualified normal full is outside duration qualification. Normal post-storage conditioning/charging and qualification may precede use, with stored condition inspected first. No guaranteed remaining range or forced discharge is implied ([DEC-STO-001–002](DEC-001_Decisions_and_Open_Issues.md#dec-sto-001); PD §8.2).

Road grip, load, motor/battery capability and operating/safety limits constrain the rider-demand behavior below. A torque-demand accelerator does not replace vehicle performance obligations. Unspecified numerical limits, tolerances and response bounds remain open; §6 identifies the derivation work.

## 4. Operating conditions and transitions

### 4.1 Use of the existing operating-state vocabulary

These externally meaningful conditions elaborate PD-001 §9; they do not prescribe an internal state machine. Vehicle off/parked can coexist with removed-pack charging/storage.

| State | Operational meaning |
|---|---|
| VS-001 — Service-isolated | Apply the upstream isolation definition. Zero commanded torque does not establish absence of stored energy or motor-generated voltage. |
| VS-002 — Parked/off | VD18MT power control; no motor stationary holding. |
| VS-003 — Startup/initialization | Every normal or unexpected restart runs fresh self-tests and reassesses Ready prerequisites. Both torque signs remain unavailable before Ready. |
| VS-004 — Ready | Complete entry guard below is satisfied. Readiness permits valid demand; it does not command torque. |
| VS-005 — Propelling | Valid positive demand under active profile, brake priority and current limits; forward torque may be requested during rollback after Ready. |
| VS-006 — Coasting/braking | Profile-dependent coasting/regeneration and independent mechanical braking; §5 governs their interaction. |
| VS-007 — Removed-battery charging | Dry off-vehicle charging; normal 80% actual-SOC external-charging ceiling. |
| VS-008 — Fault/performance-limited | Common fault inhibition (§4.4), temperature faults (§5.8), low-charge limits (§5.7) and continued operation after VD18MT communication loss have distinct conditions. |
| VS-009 — Shutdown | Accepted while moving; withdraw both torque signs and reject new torque requests. Abrupt withdrawal is permitted. |
| VS-010 — Diagnostic/development | Upstream controlled test context; no additional torque permission defined here. |
| VS-011 — Battery removal/refitting | §4.2 sequence; no commanded propulsion during handling. Fit/connection alone establishes neither isolation nor Ready. |
| VS-012 — Removed-pack storage/awaiting charge | Detached-pack temperature, storage and residual-energy conditions remain applicable. |

Removed charging supports a minimum 9 V / 2 A USB-C supply with actual net charging when permitted ([DEC-CHG-004](DEC-001_Decisions_and_Open_Issues.md#dec-chg-004)); source input power differs from battery charge power. Sessions follow [DEC-CHG-001–003](DEC-001_Decisions_and_Open_Issues.md#dec-chg-001): eligible incomplete sessions resume after ordinary cold/warm waiting, including automatic resumption after cooling a healthy too-warm battery within its qualified non-charging limits; completion/initial-full hold requires a new connection or qualified USB power restoration before a new charge-need assessment. Unexpected charging-controller restart discards old fault history/indication, shows Waiting during fresh checks and retains completion/initial eligibility. Newly recognized faults take priority; charging remains unavailable until checks and conditions permit. Four-state indication works without the VD18MT; the [charging policy](Abstract_Software_Requirements/Charging_Session_Policy.md) allocates logical behavior only.

**Ready entry**, after every normal or unexpected restart, requires together: successful startup self-tests; valid accelerator/brake information; valid VD18MT level and speed settings received during that startup; trustworthy actual SOC; qualified required temperature information; standstill; physical accelerator rest; no current-session fault inhibition; and applicable operating permissives. Unknown speed is not standstill. Physical rest is fully released, not the 35% virtual neutral. Earlier pedal release while rolling or stored settings alone do not qualify. Initial interpretable speed requests of zero or above 40 km/h qualify as 40 km/h. Valid brake actuation or displaced accelerator position is not inherently a fault, although entry/torque guards still apply.

Trace: DEC-STA-001, DEC-FLT-007, DEC-TMP-002; REQ-SYS-STA-001–007. Qualification, restart boundaries and measurable guards remain open.

### 4.2 Normal battery handling and power-control sequence

Refitting: **connect scooter power connector → place pack in base tray → lock with the original BMW X2City mechanism**.

Removal: **VD18MT switch-off → unlock → lift from tray → disconnect**. Subsequent switch-on uses the VD18MT power button and the full Ready guard. The same switch-off action is accepted while stationary or moving; gradual torque withdrawal is not required.

Connection before seating/locking is intentional. Contact energization/isolation, lock/fit detection, residual energy, contamination and abnormal handling remain unresolved; no interlock is implied (DEC-BAT-001, DEC-PWR-001; REQ-VEH-BAT-001–002, REQ-SYS-BAT-001, REQ-SYS-PWR-001–003; WS-OI-007, WS-OI-011).

### 4.3 Requested and active riding levels

The scooter uses the level communicated by the VD18MT at every normal or unexpected startup, including after power loss or battery removal. No scooter-defined default or cross-boot restoration of a prior selection is required; current-startup receipt still gates Ready (DEC-LVL-003).

Changed level or speed requests apply only at **simultaneous standstill and physical accelerator rest**. Until then, the display can show the requested setting while the previous active value governs behavior. The latest valid pending request applies when the guard is met, without another selection. No pending-change or distinct Ready indication is required (DEC-HMI-007). Pending level changes cannot alter the active torque mapping or resumption profile (DEC-LVL-001–003, DEC-SPD-001; detailed setting rules in REQ-001).

### 4.4 Communication loss, common fault response and startup assessment

VD18MT communication loss alone preserves otherwise available operation using last valid settings, including normal lighting. Active/pending settings remain distinct and their application guards continue. Current valid accelerator/brake input controls torque; the last torque command is not frozen. Communication return alone requires neither restart nor a new Ready transition. Current-startup receipt of valid level/speed information remains mandatory before initial Ready; deliberate shutdown/supply loss is separate (DEC-FLT-001; REQ-SYS-FLT-001–002).

**Common fault response:** recognized faults requiring fixing, invalid accelerator/brake/speed information, SOC-information loss, recognized invalidity/loss of previously qualified required actual motor-output information (DEC-FLT-011), temperature-limit violations and required-temperature-information faults inhibit both commanded torque signs for the uninterrupted session. The same response applies during startup and riding; detection during startup prevents Ready. Abrupt withdrawal is permitted in every level. Fault clearance, late qualification, repeated successful checks, standstill, pedal/brake actions or communication restoration cannot release inhibition.

Recovery requires a normal or unexpected restart, successful fresh self-tests and all Ready/current operating prerequisites. No fault history or old report persists across a restart; current faults must be recognized anew and inhibit that new session even if they subsequently clear. Clearing history is not proof of validity or readiness. Ordinary initial qualification is not automatically a fault; failure to qualify SOC within its allowed initialization period is a battery fault. Detection coverage, qualification periods and finite responses remain downstream.

While powered, VD18MT and front/rear lighting continue wherever electrical protection and the affected functions permit. Normal commands and brake-light rules remain effective. Torque inhibition/reporting alone neither switches lights off nor forces brake brightness; continued function through a failed device/supply or after shutdown is not promised.

Trace: DEC-FLT-002–011, DEC-TMP-001–003; REQ-SYS-FLT-003–012, REQ-SYS-TMP-001–002, REQ-VEH-AUX-001. Report selection (§5.6), brake-light release (§5.5), charge recovery (§5.7) and torque recovery have different conditions.

## 5. Rider-demand and braking behavior

### 5.1 Torque interpretation and riding profiles

The accelerator requests **signed motor-produced rear-wheel torque**, not travel speed or acceleration. Positive is the scooter's forward direction; actual motion also depends on grade, grip, load and mechanical braking.

| Active level | Position-to-torque behavior |
|---|---|
| 0 | Entire travel requests positive torque; physical rest coasts at zero commanded torque; no regeneration. Gentlest initial positive response and greatest upward curvature. |
| 1–4 | Below common neutral: negative regenerative demand; neutral: zero; above neutral: positive demand. Curves become progressively more linear and regenerative strength increases with level. |
| 5 | Linear positive/negative branches, strongest permitted regeneration, no intentionally added response ramp/delay. Physical response bounds and operating limits still apply. |

All levels share the same maximum permitted positive-torque endpoint at full accelerator under equivalent conditions; equal regenerative maxima are not required. The positive curve preference is exponential-like, with no selected equation/exponents. Levels 1–5 share a provisional **35% neutral**, normalized from physical rest at 0% to full application at 100%. Curve shape, time response and low-speed taper are separate properties.

Trace: DEC-TRQ-001–002, DEC-LVL-001; REQ-SYS-TRQ-001–009; WS-OI-002–003.

### 5.2 Mechanical braking, priority and resumption

Either lever inhibits positive propulsion. Levers request mechanical braking only; permitted accelerator-requested regeneration remains additive. Mechanical stopping remains independent of electrical power/regeneration.

When both valid levers are released, current valid positive accelerator demand resumes automatically under remaining permissives, without a normal brake-release pedal reset. Resumption uses the active level's ramp; **Level 0 uses Level 1's ramp only**, retaining its own full-travel mapping/no regeneration; Level 5 adds no ramp. This does not bypass Ready or fault inhibition.

Shared brake-network codes can conceal physical faults: an open contact-only bypass may appear released, while resistance/leakage faults can imitate valid codes. Complete opens/shorts differ from nominal codes, but coverage is unproven. The shared trunk/Y affects both identities; invalidity need not identify a handle. The fixed reference owns these limitations. REQ-SYS-BRK-009–011 remain deferred diagnostic proposals, not adopted sensing requirements.

Trace: DEC-BRK-001–002, DEC-REF-002; REQ-SYS-BRK-001–012; WS-OI-003, WS-OI-012.

### 5.3 Regenerative availability, stopping and restoration

Regeneration requires valid accelerator demand and all applicable permissives, including battery charge acceptance and the **90% actual-SOC ceiling**. Recovered charge above 80% is available for ordinary propulsion, excluded from RQ-001 qualification. Low charge alone does not disable regeneration. Profile selection cannot override limits.

| Condition | Behavior |
|---|---|
| Approaching standstill under regeneration | Progressively taper negative torque to zero. Levels 1–5 share a taper start speed to be established during system validation; equal taper shapes are not required. |
| Stationary scooter | No motor holding torque; deliberate positive launch remains permitted after Ready. |
| Backward rolling | Regenerative-range demand commands zero torque. Valid positive demand requests forward torque under the profile/limits, without an intermediate stop or pedal reset after Ready. |
| Hand parking after each riding stop | Manual forward/backward movement produces no commanded regeneration. Re-enable application only after actual forward travel with applied positive motor torque resumes. A blocked request, stationary torque or forward torque during rollback does not qualify. |
| Regenerative SOC protective cutoff | Abrupt withdrawal is permitted in all regenerative levels; no anticipatory comfort fade is required. |
| Active VD18MT speed cutoff or 40 km/h | Both torque signs are withdrawn abruptly; §5.5 applies. |

For **nonfault operating restrictions eligible for recovery without restart**, previously lost regenerative capability cannot increase while motion continues and the accelerator continuously stays in the regenerative range. Leaving that range **or** full standstill qualifies recovery for that restriction episode, even if qualification precedes clearance. Once qualified and current limits permit, capability returns automatically without another rider action. Already being stationary qualifies; partial reductions follow the same rule. Each separate episode needs its own qualification.

Capability recovery is not a torque command. Demand, low-speed taper, limits and the powered-forward-travel condition after a stop still govern application. Common/temperature fault inhibition requires restart and cannot be cleared by this rule. The HMI has no dedicated regeneration-availability indication; underlying faults remain reportable.

Trace: DEC-REG-001–006, DEC-TRQ-003, DEC-HMI-001, DEC-HMI-006; REQ-SYS-REG-001–011, REQ-SYS-TRQ-010; WS-OI-005–006, WS-OI-013.

### 5.4 Rider-visible battery charge

Display rider-usable charge linearly over **20–80% actual SOC**, clamped to empty/full outside that window; hide the actual limits from normal charge presentation. Thus 15% actual is empty and 90% is full. Visible percentage, where supported, uses the same scale. Displayed 0% includes restricted propulsion and the 10% propulsion stop; it is not a control SOC or proof that all usable energy is exhausted.

Unknown/untrustworthy SOC displays empty/0% only as a fallback. Trustworthy data restores the normal mapping independently of retained fault reporting/torque inhibition. The fallback cannot qualify Ready or falsely set/clear actual-SOC charge thresholds. Display resolution, rounding and selected-unit presentation remain unverified.

Trace: DEC-HMI-002, DEC-HMI-005; REQ-VEH-HMI-002–003, REQ-VEH-HMI-012; WS-OI-008–009, WS-OI-018.

### 5.5 Lighting and remaining HMI control functions

Front and rear normal illumination follow the VD18MT light command together. Before the first valid powered-session command, normal lights are off; afterward, communication loss retains the last valid command.

The two-wire VCC/GND rear light provides dim normal illumination and full-bright brake indication. While powered, **either operated lever**, **actual active electrical braking**, or **unqualified brake-lever or actual motor-braking information** independently requires full rear brightness, including during startup (DEC-LGT-002), overriding normal off/dim. Lever actuation applies at standstill and without net deceleration; passive slowing or a wholly suppressed regenerative request is insufficient. The front retains its normal command. Return the rear to normal dim/off only when both levers are qualified released and active electrical braking is qualified absent, even if torque inhibition or a fault report remains. Dimming suitability/brightness/response are unverified; supply PWM was only an owner example.

Valid VD18MT speed requests are clamped to **at most 40 km/h**, including the first startup request. A decoded **0 km/h** means no limit requested and normalizes to **40 km/h** under the same application guards. A change still waits for standstill/rest: 25 km/h active plus a 50 km/h request means 40 km/h pending, then 40 km/h active at the guard. Uninterpretable speed values preserve prior active/valid pending settings and cannot satisfy initial receipt; their treatment does not reject other valid fields automatically.

At/above the active forward speed cutoff, and unconditionally at 40 km/h, **both commanded torque signs are zero with abrupt withdrawal** in every level. Gravity may still increase speed; mechanical brakes control downhill overspeed. Below the cutoff, positive demand returns automatically from current pedal position using §5.2's resumption profile, without pedal reset/standstill and subject to other permissives. Regenerative recovery remains separate. This differs from the positive-only low-SOC speed cap (§5.7).

Control speed uses fixed nominal **16-inch wheels**, independent of VD18MT wheel-size settings. Incorrect displayed speed caused solely by rider wheel-size misconfiguration is accepted; actual control limits remain unchanged. Loaded circumference, raw/special setting validity, speed accuracy and finite responses remain open.

Powered walk assistance is excluded; a walk command alone requests no torque. Normal valid accelerator propulsion and manual parking remain applicable.

Trace: DEC-HMI-003–004, DEC-LGT-001–002, DEC-SPD-001–002; REQ-VEH-LGT-001–009, REQ-SYS-SPD-001–009, REQ-VEH-WLK-001; WS-OI-008–010, WS-OI-015–016.

Battery current is provided continuously to the VD18MT through recurring messages while powered and communication is available (DEC-HMI-008; REQ-VEH-HMI-020). Report discharge or regenerative charging current as a positive magnitude clamped to 51 A; the unsigned field does not distinguish direction. Unavailable/invalid battery-current information is reported as 0 A; valid data restores the normal mapping. This reporting fallback does not establish zero physical current or valid control/protection information. Quantization, validity criteria, accuracy and update bounds remain WS-OI-009.

### 5.6 Fault indication

Faults are reportable independently of their functional reaction or current torque demand, subject to communication availability and report selection. Project codes are transmitted values, not verified visible hexadecimal text; some assignments broaden the device reference's labels.

The [project code and reporting table](DEC-001_Decisions_and_Open_Issues.md#dec-flt-003) defines the assignments, including low-charge warning, input/battery/temperature faults, blocked motor and the generic fallback. Invalid brake reporting does not identify a handle.

The **0x0A/0x0D/0x03/0x07/0x06/0x04/0x05 group** uses first-detected selection retained until normal/unexpected restart, including after the selected condition clears; every group member outranks 0x01. Indistinguishably ordered faults may select either using a consistent tie rule. Exact tie-breaking remains open. Repair-fault and temperature indications retain their required lifetime; restart discards prior reports and assesses current faults afresh. No simultaneous/alternating presentation is implied. Physical fault responses and brake-light release do not depend on which report is selected.

Trace: DEC-FLT-003–008, DEC-HMI-006, DEC-TMP-001; REQ-VEH-HMI-004–018; WS-OI-008–010, WS-OI-018–019.

### 5.7 Low-charge operation and recovery

| Actual SOC / prior condition | Positive propulsion |
|---|---|
| Above 20% | Normal capability under remaining limits |
| Discharge reaches 20%, before a 10% stop | Drastically reduced maximum torque and speed; values require system validation |
| At/below 10% | Stop positive propulsion |
| Recovery after a reached 10% stop, through 20% inclusive | Keep positive propulsion inhibited; recover only above 20% |

Restart alone does not establish charge recovery. Continuity across restart/battery handling remains to be derived without prescribing storage; charge-restriction continuity is distinct from prohibited persistent fault history.

Abrupt entry to reduced capability/propulsion stop is permitted, not mandated. At/above the reduced low-SOC speed cap, positive demand is suppressed while otherwise permitted requested regeneration remains available; the cap itself requests no braking. Return below that cap, or charge recovery above 20%, automatically restores permitted current demand using §5.2's resumption profile. These events cannot release a reached 10% cutoff prematurely, bypass Ready or clear fault inhibition. Other both-sign speed cutoffs and hand-parking/regenerative rules still apply.

Low charge alone preserves eligible regeneration and powered VD18MT/lighting wherever battery protection permits. Warning 0x01 follows §5.6. The 10% propulsion cutoff is not an established all-load protection/storage floor; auxiliary energy and protection limits remain open. No distance below 20% is guaranteed; RQ-001 remains inside 20–80%.

Trace: DEC-SOC-001; REQ-SYS-SOC-001–009, REQ-VEH-PWR-001; WS-OI-017.

### 5.8 Temperature-limit faults and common fault response

Recognized violation of an applicable upper **or lower** component temperature limit invokes §4.4's common response: **both torque signs inhibited, no reduced/selective operation, no Ready after startup recognition, recovery only after a qualifying restart**. Normal temperature or restored information within the session cannot release inhibition. This applies regardless of the initially affected component/function and permits abrupt withdrawal in every level.

Required temperature information must qualify before Ready. Recognized invalidity/unavailability invokes the same fault response; ordinary initial qualification alone is not a fault. Invalid information does not itself prove a hot/cold violation: use the applicable specific fault code, otherwise 0x05. Known limit violations use retained 0x06 under §5.6.

DEC-TMP-003 clarifies that qualified discharge-permissible/charge-ineligible cell temperature allows otherwise eligible propulsion with regeneration ordinarily unavailable. It creates no new fault/availability indication; regeneration recovers under its normal restriction rules. Actual applicable operating-limit violations, required-temperature-information faults and recognized forbidden charge transfer retain the fault response above.

Integrated limits, reference/margins, information requirements, qualification/fault boundaries, coverage and finite responses remain open. No pre-limit derating curve, sensor, estimator or heating/cooling mechanism is selected. These riding decisions do not define off-vehicle charging recovery.

Trace: DEC-TMP-001–002; REQ-SYS-STA-007, REQ-SYS-TMP-001–002; WS-OI-019.

## 6. Safety-analysis handoff and unresolved definition work

PD-001 §7 owns the broader normal-situation, fault and foreseeable-misuse register. These interactions supplement it for hazard analysis; they are not assessed hazards, safety goals or selected safeguards.

| Situation / potential malfunction | Analysis focus and trace |
|---|---|
| Torque during moving restart, held-accelerator startup or incomplete qualification | Unintended positive/negative torque; complete simultaneous Ready guard, persistent-fault rediscovery and fresh tests without retained history. DEC-STA-001, DEC-FLT-007; WS-OI-001–002, WS-OI-007, WS-OI-010, WS-OI-018–019. |
| Level/speed change applied before its guard; faulty above-40 normalization | Torque magnitude/sign changes at fixed pedal position, especially Level 0 versus regenerative levels; active/pending separation and clamp-to-40. DEC-LVL-002, DEC-SPD-001; WS-OI-003, WS-OI-009, WS-OI-015. |
| Brake override fails, valid code hides actuation, or automatic resumption is incorrect | Mechanical braking/propulsion conflict; shared-loop aliases/common dependencies and unproven detection coverage; Level 5 direct resumption. DEC-BRK-001–002, DEC-REF-002; WS-OI-003, WS-OI-012. |
| Regeneration withdraws during descent or returns unexpectedly | Independent mechanical braking duty, no dedicated availability warning, abrupt SOC/speed/fault withdrawal, partial recovery and event ordering. An owner expectation of rare cutoff is not frequency evidence. DEC-REG-001–004, DEC-SPD-001, DEC-HMI-001; WS-OI-005, WS-OI-013, WS-OI-015. |
| Braking during hand pushing, failure to resume after powered forward travel, incorrect rollback/taper/holding | Distinguish capability from application, repeated-stop behavior, deliberate launch from holding, and torque direction from travel direction. DEC-REG-002–003, DEC-REG-005–006, DEC-TRQ-003; WS-OI-001, WS-OI-003, WS-OI-005–006. |
| Torque persists above a cutoff or returns incorrectly during repeated speed crossings | Mandatory both-sign speed cutoff versus positive-only low-SOC cap, current demand/ramp/brake priority and downhill overspeed. DEC-SPD-001, DEC-SOC-001; WS-OI-013, WS-OI-015, WS-OI-017. |
| Charge/temperature limits exceeded, SOC display mistaken for actual charge, or false Ready/recovery | Charge acceptance, actual-SOC uncertainty, 20–80% display/range versus 10/20/80/90% operating boundaries, empty fallback, missing information and temperature common fault response. DEC-REG-001, DEC-SOC-001, DEC-FLT-005–007, DEC-HMI-002, DEC-HMI-005, DEC-TMP-001–002; WS-OI-005, WS-OI-017–019. |
| Continued low-charge/auxiliary operation exceeds battery capability | Reached-cutoff recovery continuity, permitted abrupt limits, residual auxiliary consumption and separate all-load/storage protection. DEC-SOC-001, DEC-FLT-009; WS-OI-017–018. |
| VD18MT communication fails/recovers or wheel size is misconfigured | Continued live rider control without usable HMI, guarded retained settings, startup receipt, trustworthy actual speed independent of accepted display mismatch. DEC-FLT-001, DEC-SPD-001–002; WS-OI-001, WS-OI-008–010, WS-OI-015. |
| A fault is undetected, its reaction fails, or restart grants operation despite a current fault | Diagnostic/self-test coverage, initial qualification versus fault recognition, retained within-session inhibition and sudden loss of propulsion/electrical braking. Passing defined tests is not proof of complete coverage. DEC-FLT-002–007, DEC-TMP-001–002; WS-OI-007, WS-OI-010, WS-OI-012, WS-OI-018–019. |
| Fault indication is wrong, premature, replaced/cleared incorrectly or survives restart as stale history | Wire/display correspondence, priority/ties, fresh selection, reporting without torque demand, and separation from physical reaction. DEC-FLT-003–008, DEC-HMI-006; WS-OI-008–010, WS-OI-019. |
| Normal/brake lighting is missing or misleading | Overlapping brake triggers, invalid-input brightness, valid-release return despite retained faults, passive-slowing exclusion, protection-limited auxiliary continuity and lamp suitability. DEC-HMI-003, DEC-LGT-001, DEC-FLT-009; WS-OI-012–013, WS-OI-016. |
| Walk command creates torque; moving shutdown removes torque | Excluded walk assistance, permitted abrupt shutdown and residual/motor-generated energy. DEC-HMI-004, DEC-PWR-001; WS-OI-007–010, WS-OI-013. |
| Connected battery is unseated/unlocked or contacts are contaminated | Intentional handling intermediates, energized misuse, retention, isolation, exposed contacts and off-vehicle transition. [REQ-SYS-BAT-003](System_Requirements/Battery_Handling_and_Charging.md#req-sys-bat-003) defines accessible-interface protection without selecting sensing/interlocks. DEC-BAT-001; FM-018, FM-024; WS-OI-011. |

Battery selection adds explicit supplied-BMS/UART, temperature, generated-energy and limited-observability analysis inputs (§2.3); the earlier lifecycle review below does not qualify that integration.

DEC-001 records this workstream's unresolved thresholds, tolerances, profiles, interfaces, diagnostic coverage, timing, reporting and protection/qualification dependencies; it supplements PD-001's upstream issue register. REQ-001 retains proposed acceptance cases. No safety assessment or vehicle execution evidence is asserted here.

### Lifecycle coverage review

Historical document review against released PD-001-R1.1, 2026-09-09: all eight OS situations, 26 FM misuse entries, 12 VS states and eight IF-EXT interfaces are accounted for by PD coverage and the item elaboration/references. No omitted lifecycle area or conflicting required behavior was identified in the areas below. This supports item-definition/hazard-analysis input; it does not close downstream issues, assess all hazards or verify vehicle behavior.

| Area | Controlling PD coverage | Item elaboration | Remaining derivation / evidence |
|---|---|---|---|
| Riding | §§6.1–6.6, 7–9; OS-001–003, OS-006–008 | §§3–5; startup, controls, braking, limits and faults | Profiles/limits, fault coverage and performance evidence: WS-OI-001–003/005–006/010/013/015–019 |
| Shutdown | §9 VS-002/009; OBJ-005 | §§4.1–4.2/4.4; moving shutdown and fresh restart | Completion, residual/generated energy and supply behavior: WS-OI-007–008 |
| Battery handling | §§5.1, 6.7, 9, 11.8; OS-005/007, FM-003/018/024 | §§2.1/4.2/6; connection before seating, normal sequence and energized misuse | Contact/lock suitability, exposed energy and abnormal handling: WS-OI-011; OI-062 |
| Removed-pack charging | §§6.7, 8.4, 9, 11.8; OS-005, VS-007/012, FM-004/005/022 | §§2.1/3/4.1; external charging independent of vehicle electronics | Source-loss/recovery, cold limits, interfaces and charging protection: OI-041/042/057/058 |
| Storage | §§6.6–6.7, 8.2–8.4, 9; OS-004/005, VS-002/012, FM-024/026 | §§2–4.1/5.7; vehicle/removed-pack conditions and residual consumption | Normal-full entry tolerance, exposure, protection and energy allowances: OI-056/061/063 |
| Maintenance | OBJ-009, IU-019/020, CON-027, §§9/11.8; VS-001/010, IF-EXT-006 | §§2.2/4.1/4.4; competent maintainer, isolation/test context and fresh startup | Service procedures/access, isolation, maintenance/replacements and durability acceptance: OI-045–047/050 |
| Foreseeable misuse | §7 FM-001–026; additional situations in §9; exclusions in §17 | §§2/4/6 supplement the upstream register | Assess consequences and acceptable responses in hazard analysis, then derive safeguards/verification; inclusion does not promise normal functionality during misuse |

Service return is configuration-specific: riding requires fresh startup and the full Ready guard; detached charging uses its own checks, recovery and completion/initial-eligibility rules. Service completion is not a new charge session or fault-clearing event. The [service contract](System_Requirements/Service_and_Durability.md#service-acceptance-contract) distinguishes diagnostic observations from retained inhibition, physical output and isolation; its information presentation is partially allocated in ARCH-001. Battery/wear-part replacement does not restart the modified-vehicle life clock.

## 7. Revision record

Revision 1.0 was reviewed and released by Dominik on 2026-09-09 with controlled open issues. Earlier drafting and release records are retained in [Git history](README.md#release-and-history).
