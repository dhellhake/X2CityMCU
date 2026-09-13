# DEC-001 — Decisions and Open Issues

**Draft revision 1.6 — 2026-09-13**, based on approved **DEC-001-R1.0**. Adds owner-selected separate mobile charger placement (DEC-ARCH-001). Earlier decisions retain their status; their reviewed requirement elaborations remain approved through REQ-001-R1.6. This working decision document is not released, and owner confirmation does not establish physical verification.

[PD-001 Draft1.3](../../README.md) owns project scope, missions, performance and constraints; [ID-001](ID-001_Item_Definition.md) owns item context; [REQ-001](REQ-001_Requirements.md) owns approved obligations and planned verification. [Index](README.md) defines source/status conventions. PD-001-R1.1 is the historical released upstream baseline; current PD1.3 and ID1.2 are Draft changes under the new owner instruction. The 2026-09-09 item-definition release remains in [history](README.md#release-and-history). The 2026-09-11 [REQ-001-R1.6 release](README.md#req-001-r16-system-requirements-release) approves the reviewed requirements using the Draft1.5 snapshot in Git as its source; it does not globally release DEC-001.

## Current owner decisions

These entries consolidate the owner discussion recorded 2026-09-06–10; later explicit corrections supersede earlier choices. Derived interpretations and preferences are marked. Owner answers 5–8 on 2026-09-09 also authorize PD PERF-001 acceptance just below 40 km/h, in-window RQ-001 regeneration credit, DUR-001 service life and the left/front–right/rear brake association (DEC-REF-002). REQ-001 carries requirement-to-decision traceability; the issue register below retains unresolved definition and evidence. No numerical tolerance, sensing/control realization, formal safety classification or successful test is implied.

Unless stated otherwise, torque means commanded motor-produced rear-wheel torque: positive points forward, negative provides regeneration during forward travel. Every torque permission remains subject to Ready, valid demand, brake priority and applicable operating/safety limits. Zero commanded torque does not promise zero passive drag or generated voltage. “Abrupt permitted” allows but does not mandate that response; “abrupt required” excludes deliberately added comfort ramps. Finite physical response and measurement bounds remain to be derived.

<a id="dec-bat-001"></a>
### DEC-BAT-001 — Battery removal and refitting

Refit: connect the scooter power connector → place the battery in the base tray → engage the original BMW mechanical lock → switch on through VD18MT. Remove: switch off through VD18MT → unlock → lift from tray → disconnect. No commanded propulsion during normal handling (PD VS-011). Connection outside the tray is possible and alone establishes neither readiness nor safe touch conditions; no lock sensor/interlock is selected. Source: owner sequence; PD §§5.1, 6.7, 9, 11.8 / OI-062.

<a id="dec-bat-002"></a>
### DEC-BAT-002 — Built pack, selected BMS and riding temperature

Owner, 2026-09-10: the already fabricated, working battery fits the bay and comprises **14S5P / 70 Samsung INR18650-35E cells** (exact model explicitly confirmed). Use the selected **JBD SP14S004P14S50A BMS through UART**. These are fixed inputs; no repeated cell/topology/BMS selection or initial-fit study is required. The owner subsequently confirms the BMS is connected but not fully configured, and expects its configuration to be derived by this engineering. Board/firmware identity, effective settings and physical integration acceptance remain to be recorded/qualified; reported operation does not establish mass, range, environmental or protection qualification.

After review of the 35E cell limits, the owner changed the minimum **riding ambient from −15°C to −10°C**. Riding maximum remains +40°C; outdoor storage separately retains −15…+40°C. Cell discharge/charge limits and margins still govern actual operation; regeneration is charging. No heating/cooling design is selected.

[BAT-001](../Battery/BAT-001_Selected_Pack_and_BMS.md) records manufacturer evidence and derived voltage, capacity, current, mass, storage and interface consequences. Its JBD documents are family/protocol references, not verified actual-unit settings. Preserve all existing SOC, range, speed, handling, charging and fault policies. PD OI-012/040/041/062 selection/initial-fit portions are resolved; integration and acceptance remain open. The requirement records and their stated Type/Target assignments are now approved through REQ-001-R1.6; the component-selection instruction did not globally release the PD/ID revisions.

<a id="dec-mas-001"></a>
### DEC-MAS-001 — Proceed with mass assumptions

Owner, 2026-09-10: no scale is available to weigh the current gutted scooter; proceed using assumptions. This authorizes assumption-based requirements, architecture and feasibility planning without first obtaining an empty/non-pack measurement. It does not relax the 30 kg vehicle, 100 kg minimum payload or 130 kg combined-mass requirements.

Engineering planning allowances, rather than owner-specified weights, are canonical in [PD DV-012](../../README.md#dv-012--payload-and-vehicle-mass-budget): 21 kg current assembly including its installed motor, 5 kg complete pack, 2 kg remaining fitted equipment; 28 kg total with 2 kg headroom. Count each item once. The 21 kg historical donor figure is only a rough reference; the 5 kg pack includes assumed ancillary mass beyond the cell-only bound. These are revisable assumptions, not measured upper bounds, accepted mass compliance or new subsystem requirements.

Continue all load-dependent performance/range models at the required 130 kg. Complete configured-vehicle mass verification remains due before final mass acceptance and mass-dependent physical qualification; separate gutted-scooter weighing is not required. Other safety, integration and physical-test gates retain their existing scope. Trace: PD ASM-017 / OI-012/040/062; REQ-VEH-MAS-001. Future changes to released requirements require controlled revision; their source drafts retain separate document control.

<a id="dec-pwr-001"></a>
### DEC-PWR-001 — Power control and shutdown

The VD18MT power button switches operation on/off. The same switch-off action works while moving and at standstill; movement need not delay shutdown. Both commanded torque signs cease; abrupt withdrawal is permitted. Mechanical braking remains independent. Shutdown completion, residual/generated energy and handling conditions remain WS-OI-007 / WS-OI-011.

<a id="dec-sta-001"></a>
### DEC-STA-001 — Common Ready-entry guard

After every normal start or unexpected restart, Ready requires all of these together:

- Valid accelerator and brake information.
- Valid VD18MT level and speed-setting information received during that startup.
- Trustworthy actual SOC and qualified information needed to establish operation within temperature limits.
- Successful startup self-tests, standstill and fully released physical accelerator rest.
- No current-session fault inhibition; all other operating permissives satisfied.

Neither torque sign is allowed before Ready. Ready permits demand; it does not command torque. Standstill/rest are simultaneous entry conditions, not continuing riding conditions. Releasing while rolling and reapplying before stopping does not qualify. Physical rest is not the virtual neutral; unknown speed is not standstill. Absence of a detected fault or a stored/displayed value does not establish valid current-startup information.

Initial qualification alone is not automatically a fault; failed SOC initialization follows DEC-FLT-007. An interpretable initial speed request of zero or above 40 km/h qualifies as 40 under DEC-SPD-001. Missing initial settings still block Ready. Sources: owner startup clarifications; PD OBJ-003 / VS-003–004 / FM-001.

<a id="dec-lvl-001"></a>
### DEC-LVL-001 — Six riding profiles

| Level | Behavior |
|---|---|
| 0 | Positive propulsion over full accelerator travel; rest gives zero torque/coasting; no regeneration. It is not assistance-off. |
| 1–4 | Progressively more linear positive/negative mappings and stronger permitted regeneration; level-dependent response ramps. |
| 5 | Linear mapping within each torque branch; strongest permitted regeneration and no deliberately added smoothing, delay or time ramp. |

Operating limits and low-speed taper still apply; curve/response definitions are DEC-TRQ-001–002.

<a id="dec-lvl-002"></a>
### DEC-LVL-002 — Requested and active levels

The VD18MT may display and retain a new selection immediately. The previous active profile remains until standstill and physical accelerator rest coincide, then the current requested level applies without another selection. Requested and active levels can therefore differ temporarily; no storage/state-machine realization is selected.

<a id="dec-lvl-003"></a>
### DEC-LVL-003 — VD18MT authority across restarts

At every normal or unexpected startup, including after power loss or battery removal, the scooter takes the level communicated by the VD18MT. No scooter-defined default, cross-boot level restoration or requirement that the VD18MT preserve a prior selection remains. A parser's initial Level 0 is not a received selection. Current-startup receipt and all Ready guards remain mandatory; subsequent changes retain DEC-LVL-002's standstill/rest guard. This supersedes the earlier last-selected-level retention requirement. Source: owner functional-ambiguity answers 3–4, 2026-09-09.

<a id="dec-trq-001"></a>
### DEC-TRQ-001 — Signed wheel-torque request and profiles

Accelerator position requests wheel torque, not speed or closed-loop vehicle acceleration/deceleration. At full accelerator, all six levels request the same maximum available permitted positive torque under equivalent conditions; that maximum can vary with speed, SOC, temperature and other limits.

Lower-level positive mappings start gently and rise more sharply later, becoming linear at Level 5. An exponential-like shape is an owner preference, not a selected equation. Negative mappings in Levels 1–5 also become more linear with level, with increasing maximum regenerative strength; their negative endpoints need not be equal. Level 5 is proportional within each branch without deliberate delay/ramp. Level-dependent regenerative time gradients in Levels 1–4 become more direct with level; static curve and time response are separate.

Low-speed taper and event-specific withdrawal/recovery in DEC-REG-002–004 / DEC-SPD-001 / DEC-SOC-001 override ordinary profile shaping where specified. Sources: owner torque/profile clarifications; PD OBJ-003 / OBJ-012 / PERF-001–004.

<a id="dec-trq-002"></a>
### DEC-TRQ-002 — Accelerator travel and provisional neutral

Travel is 0% at fully released physical rest and 100% at maximum. In Levels 1–5, a common **35% provisional virtual neutral** separates negative demand below, zero at neutral and positive demand above. System validation may change it; measurement, tolerance and deadband remain open. Level 0 uses its entire travel for positive torque, with zero at rest.

<a id="dec-trq-003"></a>
### DEC-TRQ-003 — Positive demand during rollback

After Ready, positive accelerator demand while moving backwards applies forward torque using the active positive profile in any Level 0–5. Backward motion alone requires neither an extra stop nor a pedal reset. Brake priority and normal permissives apply; valid demand may continue through zero into forward travel. This is deliberate propulsion, not automatic holding/rollback arrest. It does not establish a rollback stopping time/distance or qualify return to regeneration until forward motion with applied positive torque occurs. Source: owner, 2026-09-07; PD PERF-004 / WS-OI-006.

<a id="dec-brk-001"></a>
### DEC-BRK-001 — Mechanical braking and accelerator priority

Either lever inhibits positive accelerator propulsion. Levers operate mechanical brakes only and never request regeneration. Otherwise permitted accelerator-requested regeneration may act alongside mechanical braking. Mechanical braking is additive and independent of electrical operation; lever priority does not cancel permitted negative accelerator demand. Sources: owner; PD OBJ-004 / OS-006 / FM-002 / CON-008 / CON-010.

<a id="dec-brk-002"></a>
### DEC-BRK-002 — Positive-torque resumption profile

When both valid levers are released, act on current valid positive accelerator demand without a pedal reset, subject to other permissives. Levels 1–4 use their active resumption ramp, Level 0 uses Level 1's ramp while retaining its own static mapping/no regeneration, and Level 5 has no deliberately added ramp. The same response governs positive return below a VD speed cutoff, above 20% SOC and below a low-SOC speed cap (DEC-SPD-001 / DEC-SOC-001).

<a id="dec-reg-001"></a>
### DEC-REG-001 — Regeneration permissives and SOC ceiling

Regeneration is supplemental accelerator-requested braking, permitted only when all operating/safety conditions allow it, up to **90% actual SOC** with conservative margins still to be derived. SOC below the ceiling alone does not guarantee charge acceptance or braking.

External charging remains dry, removed-pack and capped at **80% actual SOC**. Recovered energy above 80% up to 90% is available for normal propulsion, not reserved. PD RQ-001 still requires at least 70 km for a new battery on level ground at +20 °C and 130 kg within **20–80% actual SOC**, without intermediate external charging or extra-distance guarantee; energy outside this window is excluded and preliminary sizing takes no regeneration credit. The 90% headroom does not enlarge qualification.

DEC-SOC-001 replaces the former protected 20% floor; DEC-SPD-001 imposes both-sign speed cutoffs. Sources: owner inclusion/90% decision and 2026-09-06 recovered-energy confirmation; PD OBJ-014 / CON-048 / RQ-001 / OI-048 / OI-061; release status WS-OI-004.

<a id="dec-reg-002"></a>
### DEC-REG-002 — Low-speed taper and no holding

During regeneration toward standstill, negative torque progressively decreases to zero. The taper starts at the same forward speed in Levels 1–5; its value is to be determined during system validation. Common onset does not require equal torque or taper shape across levels, and another operating limit may act earlier. At standstill, regenerative torque is zero and the motor never holds the stationary scooter. Deliberate positive launch remains permitted, including PD PERF-004. Source: owner, including common-onset confirmation 2026-09-07.

<a id="dec-reg-003"></a>
### DEC-REG-003 — Recovery of regenerative capability after operating restrictions

For each normal restriction episode eligible for recovery without restart:

1. Required reductions can take effect as needed. While moving continuously within the regenerative accelerator range, restriction clearance/relaxation alone must not restore or increase available braking capability.
2. Leaving that range **or being at standstill** qualifies recovery. Qualification may occur before clearance, including exit then re-entry before clearance or an episode beginning while already stationary.
3. Once qualified, capability returns automatically only as remaining conditions permit, with no repeated rider action. A prior separate episode's event does not qualify a new episode.

The same rules govern full inhibition and partial reduction/relaxation. Reduced capability may remain usable; actual torque follows demand/profile/taper within the remaining envelope rather than freezing. Capability restoration itself commands no torque. DEC-REG-006 separately governs application after a stop. Fault/temperature inhibition follows clean-restart recovery under DEC-FLT-007, not these events.

<a id="dec-reg-004"></a>
### DEC-REG-004 — Withdrawal at the regenerative SOC cutoff

Abrupt regenerative withdrawal at the protective cutoff for the 90% actual-SOC ceiling is permitted in Levels 1–5; no anticipatory comfort fade is required. A gradual response is also allowed if binding limits are met. This withdraws regeneration, not vehicle power, and does not guarantee full braking until estimated SOC equals 90%. The owner's 2026-09-07 expectation of rare occurrence is not measured evidence or completed safety assessment. Actual threshold, uncertainty/margins, finite response and descent implications remain WS-OI-005 / WS-OI-013 / OI-048 / OI-054.

<a id="dec-reg-005"></a>
### DEC-REG-005 — Regenerative demand during rollback

While moving backwards with Level 1–5 accelerator demand in the regenerative range, command zero torque: no backward propulsion, regeneration or automatic motor rollback arrest. The rider uses mechanical brakes. Capability recovery does not override this condition. Positive demand follows DEC-TRQ-003; deliberate launch is preserved. Source: owner, 2026-09-07.

<a id="dec-reg-006"></a>
### DEC-REG-006 — Hand parking and return to riding regeneration

After each stop from riding, the scooter can be pushed forward or backward without commanded regenerative resistance, including while powered on with the accelerator at rest/in its regenerative range. No switch-off or change to Level 0 is required. The rider controls rolling with mechanical brakes; passive drag is not excluded.

Regeneration can act again only after **actual forward motion with positive motor torque applied** resumes, then under the active profile and all remaining permissives/recovery rules. Manual motion, a blocked positive request, positive torque at standstill or forward torque while still rolling backwards does not qualify. The condition repeats after every riding stop whether or not hand pushing occurs, and never inhibits deliberate positive launch/rollback demand. Source: owner and return-condition confirmations, 2026-09-07; PD OS-007 / FM-003.

<a id="dec-soc-001"></a>
### DEC-SOC-001 — Low-charge propulsion and recovery

Source: owner thresholds/recovery clarifications, 2026-09-08–09; PD OBJ-014 / CON-048–050 / OI-061 / OI-063.

| Actual SOC / event | Behavior |
|---|---|
| Falling to 20% | Drastically reduce maximum positive torque and propulsion speed; values determined during system validation. No pre-20% taper is specified. |
| Above 10% through 20%, before a reached cutoff | Restricted propulsion may continue. |
| At/below 10% | Stop positive propulsion. Retain this stop through recovery up to and including 20%. |
| Strictly above 20% | Automatically restore normal propulsion capability using DEC-BRK-002 ramps and current valid demand, subject to all other permissives. |
| At/above the low-SOC speed cap | Zero positive torque; otherwise permitted requested regeneration remains available. |
| Speed falls below that cap before a reached 10% cutoff | Automatically resume current valid positive demand with DEC-BRK-002 ramps within the reduced envelope. No pedal reset; e.g. 15% SOC before cutoff. |

**Derived setting interaction:** these automatic operating limits are not rider setting changes; entry does not wait for standstill/rest. Abrupt positive reduction at 20% and withdrawal at 10% are permitted in every level. Low charge never itself disables otherwise permitted regeneration; VD speed cutoffs and all regenerative conditions still apply. All levels retain equal maximum permitted positive endpoints under the same reduced envelope.

At/below 20%, low-charge error-field **0x01** is active; it clears automatically only above 20%. Display/report priority follows DEC-FLT-003. Warning clearance is not delayed by a propulsion-return ramp, and charge recovery clears neither a fault inhibition nor its report. The normal battery indicator remains empty below 20%.

The 10% cutoff is positive-propulsion protection, not vehicle shutdown or an all-load battery floor. HMI/lighting continue while battery protection permits (DEC-FLT-009). **Derived continuity:** restart alone is not charge recovery and cannot bypass the reached cutoff; restart/battery-handling realization remains open. The no-persistent-failure-history rule concerns faults, not this charge condition. RQ-001 and charging windows remain DEC-REG-001; auxiliary energy, storage margins and all-load protection remain downstream.

<a id="dec-hmi-001"></a>
### DEC-HMI-001 — No dedicated regeneration-availability indication

No dedicated indication of reduced/unavailable regeneration is provided. This does not suppress underlying fault reports under DEC-HMI-006 or low-charge 0x01. Ordinary operating restriction alone acquires no fault code.

<a id="dec-hmi-007"></a>
### DEC-HMI-007 — Ready and pending-setting feedback

No distinct Ready/drive-state indication or indication of a pending level/speed-setting change is required. Requested and active settings may differ under their existing guards without additional rider feedback; pending-feedback behavior during communication loss is therefore not applicable. This supersedes the earlier additional-feedback requirement. Source: owner functional-ambiguity answers 1–2, 2026-09-09.

<a id="dec-hmi-008"></a>
### DEC-HMI-008 — Continuous battery-current reporting

Provide battery current continuously to the VD18MT. **Derived communication scope:** supply up-to-date current in recurring controller-to-display messages while powered and communication is available; reporting is not conditional on propulsion demand. The independent interface defines byte 4 as unsigned 0–51 A in 0.2 A increments, with no signed charging-current representation. Report the magnitude of battery current for both discharge and regenerative charging, clamped to 51 A: represented target = min(abs(battery current), 51 A). The transmitted current value does not distinguish direction. When battery-current information is unavailable or invalid, send 0 A (raw byte 0); return to the normal mapping when valid information is available. **Derived interpretation:** this display fallback is not evidence of zero physical current and does not substitute for valid control/protection information. Quantization/rounding, validity criteria, accuracy and update bounds remain WS-OI-009. No current-sensing realization or numerical reporting period is selected. Source: owner functional-ambiguity answer 5 and subsequent magnitude/clamping and invalid-data fallback confirmations, 2026-09-09.

<a id="dec-hmi-006"></a>
### DEC-HMI-006 — Fault visibility independent of reaction

Every recognized fault is reportable when communication and applicable selection rules permit, regardless of current demand or observable functional effect. Zero requested/applied torque does not suppress a report. Visibility does not require simultaneous/cycling presentation of competing faults; DEC-FLT-003/008 owns selection. The earlier regeneration-only temperature example established visibility; DEC-TMP-001 subsequently requires both-sign inhibition for actual limit violations. Source: owner confirmation, 2026-09-09.

<a id="dec-hmi-002"></a>
### DEC-HMI-002 — Normal usable-charge indication

Display the normal **20–80% actual-SOC window** as empty/0% to full/100%, hiding actual-SOC limits. For actual SOC s in percentage points, displayed usable percentage is **u = min(100, max(0, 100 × (s − 20) / 60))**, to the selected display's supported resolution.

Examples: actual 15% → 0%, 35% → 25%, 50% → 50%, 65% → 75%, 90% → 100%. Empty marks entry into restricted propulsion, not exhaustion of all permitted energy; energy outside the display window follows DEC-SOC-001 / DEC-REG-001. Clamping is presentation, not SOC estimation or a control/protection input. Discrete sixth-state thresholds, rounding, visible percentage, accuracy and update timing require selected-unit evidence (WS-OI-009). Source: owner, 2026-09-07–08.

<a id="dec-hmi-005"></a>
### DEC-HMI-005 — Unknown-SOC display fallback

While actual SOC is unknown/untrustworthy, including startup, show empty/0%. This is display-only: it cannot qualify SOC, assert actual 0%, falsely set/clear charge thresholds or release a reached cutoff. No “unknown” label or disclosure of actual limits is required. **Derived return:** restore normal usable-charge presentation when SOC becomes trustworthy, independently of retained fault torque/report lifetime. Recognized SOC faults follow DEC-FLT-005–007; initial unqualified information alone is not automatically a fault. Source: owner, 2026-09-09.

<a id="dec-hmi-003"></a>
### DEC-HMI-003 — Normal light command

VD18MT switches normal front/rear illumination together. Before the first valid light command in the powered session, normal lights are off; afterward communication loss retains the last valid command (DEC-FLT-001). No cross-boot light-retention requirement is selected. Rear brake indication overrides dim/off; front light always follows current/retained normal demand. Source: owner, 2026-09-07–08.

<a id="dec-lgt-001"></a>
### DEC-LGT-001 — Rear running and brake light

The owner reports two rear-light wires, VCC/GND, without a separate brake-light connection. The retained light provides dim normal illumination and full-bright brake indication; supply PWM is only an example, not selected implementation or verified suitability.

While powered, full rear brightness is required whenever **either lever is operated, actual active electrical braking occurs, or brake-actuation information is invalid**, regardless of motion, normal light command or which fault code is selected. Passive coasting/drag/uphill slowing alone is excluded. With valid information showing both levers released and no active electrical braking, return to normal dim/off even if fault torque inhibition/reporting persists. Invalidity does not prove a press or handle identity.

| Normal command | Brake indication required | Front | Rear |
|---|---|---|---|
| On | No | On | Dim |
| Off / no initial command | No | Off | Off |
| On | Yes | On | Full |
| Off / no initial command | Yes | Off | Full |

**Derived electrical-trigger interpretation:** applied motor braking opposing travel counts even at constant downhill speed or when forward torque retards rollback; torque sign or net speed decrease alone is insufficient. Unavailable/suppressed requests alone are not braking; reduced but applied braking is. No post-shutdown/battery-removal operation is required. Initial qualification/fault boundaries, timing, brightness, electrical pinout/voltage/polarity and dimming suitability remain WS-OI-012 / WS-OI-016. Source: owner, 2026-09-08; PD CON-009 / OI-038–039.

<a id="dec-lgt-002"></a>
### DEC-LGT-002 — Brake indication while information is unqualified

Owner-confirmed 2026-09-10: while powered, rear brake indication remains **full bright whenever brake-lever state or actual motor-braking state is unqualified**, including initial startup, unavailable, invalid or stale information. Return to current normal dim/off only after both levers are qualified released and actual electrical braking is qualified absent. Front normal illumination is unchanged. This light response does not itself classify initial qualification as a fault; recognized faults retain their separate response/reporting rules. Information recovery may release the light trigger while session torque inhibition/reporting remains retained. Powered/protection boundaries follow DEC-FLT-009. Trace: [REQ-VEH-LGT-009](System_Requirements/HMI_and_Lighting.md#req-veh-lgt-009); WS-OI-012/016.

<a id="dec-spd-001"></a>
### DEC-SPD-001 — Speed requests, cutoff and recovery

An interpretable VD18MT request strictly between 0 and 40 km/h sets that lower limit. A decoded **0 km/h** means **no limit requested** and sets **40 km/h**, as does a request of 40 or more, including the first request after normal/unexpected startup. Active/pending limits never exceed 40. This supersedes ignoring above-40 requests. Missing/uninterpretable initial settings still block Ready; clamping is not a default.

Changed limits apply only when standstill and physical accelerator rest coincide; until then the old active limit remains. Apply the latest valid request automatically at that guard. Example: 25 active + 50 requested → 40 pending → 40 active at standstill/rest. A later above-40 request replaces an earlier pending lower request. **Derived unrecognized-value interaction:** after qualification, an unrecognized value neither replaces nor cancels valid active/pending settings or unrelated valid commands; exceeding 40 alone is not unrecognized. Decoded zero follows the same normalization, pending replacement and application guards as above-40 requests; other special encodings remain open.

At/above the active lower limit, and unconditionally at/above 40 km/h forward travel, command zero torque of **both signs**. Withdrawal on reaching either cutoff is **abrupt required** in every level and accelerator/brake state, overriding comfort ramps. This is not automatic braking or a gravity-proof speed guarantee; the rider uses mechanical brakes for downhill overspeed.

Below the cutoff, current valid positive demand returns automatically through DEC-BRK-002 ramps, without pedal reset or another stop. Regenerative capability instead follows DEC-REG-003 and application follows DEC-REG-006. Lower operating limits remain applicable. Source: owner speed decisions 2026-09-07–09, latest clamp correction 2026-09-09; PD PERF-001 / WS-OI-015.

<a id="dec-spd-002"></a>
### DEC-SPD-002 — Fixed vehicle wheel basis

Control motion/speed uses the retained BMW nominal **16-inch wheel basis**, independently of the VD18MT wheel-size setting. Rider wheel-size misconfiguration may give an incorrect displayed speed; compensation is not required, and this alone is not a speed-input fault. It must not change actual-speed limits, direction/standstill or regeneration logic.

Nominal diameter is not measured loaded rolling circumference. PD §11.3 measurement/calibration and actual-speed accuracy/tolerances remain required; no sensor, conversion or calibration allocation is selected. Source: owner, 2026-09-08.

<a id="dec-hmi-004"></a>
### DEC-HMI-004 — No powered walk assistance

No motor-powered walk assistance. Any emitted VD18MT walk request does not itself command torque; normal accelerator propulsion and manual parking remain available under their rules. Historical parser rejection is not vehicle verification or proof the device cannot emit such requests. Selected-unit/combined-value handling remains WS-OI-008–010. Source: owner, 2026-09-07.

<a id="dec-flt-001"></a>
### DEC-FLT-001 — VD18MT communication-loss continuity

After valid settings are received, communication loss alone preserves otherwise permitted propulsion, regeneration, lighting and vehicle functions using last valid settings and **current valid rider inputs**, not a frozen torque command. Supply loss and deliberate switch-off are separate.

**Derived setting interaction:** retain active and valid pending level/speed requests; apply pending changes only under their standstill/rest guards. New requests after reconnection follow the same rules, including speed clamping. An already Ready vehicle need not restart or stop solely on reconnection. Initial missing level/speed information still prevents Ready; no cross-boot light/speed persistence is imposed. Normal lights retain their last command and brake priority continues. Detection/freshness and power-lock/supply interaction require evidence; the historical 20 ms partial-frame timeout is not a vehicle communication deadline. Source: owner, 2026-09-08.

<a id="dec-flt-002"></a>
### DEC-FLT-002 — Invalid accelerator/brake input and restart

Detected invalid accelerator input inhibits both torque signs. **Derived brake entry:** the same applies to detected invalid shared brake-actuation information, elaborating the owner's common loss/recovery instruction. Both use DEC-FLT-007's retained session inhibition and clean-restart recovery; VD18MT off/on is sufficient without battery disconnection, and an unexpected restart needs no additional deliberate cycle.

A valid displaced accelerator or operated lever is not itself a fault. Initial unqualified input blocks Ready without automatically becoming a fault. Invalid brake information leaves actuation/handle identity unknown; release becoming valid again does not clear session torque inhibition. DEC-LGT-001 independently governs brake-light release. Aliased physical brake faults are not proven detectable merely from their cause (DEC-REF-002). Source: owner, 2026-09-08; speed/SOC extensions DEC-FLT-004–005.

<a id="dec-flt-003"></a>
### DEC-FLT-003 — Project fault codes and report lifetime

Project assignments to VD18MT controller-to-display **byte 5**:

| Recognized condition | Code | Reporting rule |
|---|---|---|
| Invalid accelerator | 0x0A | First-detected group |
| Invalid shared brake-actuation information | 0x0D | First-detected group; no handle identity claimed |
| Unreliable vehicle-speed information | 0x03 | First-detected group |
| Actual battery fault, including SOC-information loss/failed initialization, except temperature-limit faults | 0x07 | First-detected group |
| Upper/lower temperature-limit fault, including battery temperature | 0x06 | First-detected group |
| Blocked-motor fault | 0x04 | First-detected group |
| Fault without a specific project assignment | 0x05 | First-detected group |
| Actual SOC at/below 20% | 0x01 | Low-charge warning; clears only above 20% |

Within the defined seven-category group, the first detected fault retains the single report until **any normal/unexpected restart**, even after condition recovery; later group faults do not replace/alternate it. The selected group report outranks 0x01 regardless of detection order. Indistinguishable order follows DEC-FLT-008.

Reports for faults requiring fixing, and temperature-limit reports, remain retained within the session. Communication loss/return neither clears selection nor restarts the session; transmit when available and selected. Physical reactions and brake light do not depend on which report is visible.

Every restart discards the old report and evaluates current faults afresh, independently of Ready/standstill/rest. Example: accelerator fault first, later brake fault, accelerator restored → after restart only the recognized persistent brake fault reports 0x0D unless another current group fault is detected earlier. Absence of a carried report does not qualify inputs.

Codes are wire values, not proven literal display text. Specific project extensions are 0x0D (reference: cadence sensor), 0x07 (battery overcurrent) and 0x06 (overtemperature, extended to undertemperature). Manual/selected-unit correlation remains OI-026 / WS-OI-008. Source: owner, 2026-09-08–09; extensions DEC-FLT-006 / DEC-FLT-008.

<a id="dec-flt-004"></a>
### DEC-FLT-004 — Loss of vehicle-speed information

Recognized inability to determine vehicle speed reliably invokes common both-sign inhibition and clean-restart recovery (DEC-FLT-007), reported as 0x03. Unknown speed cannot establish standstill. Ordinary startup qualification, VD18MT communication loss, unrecognized speed settings and display-only wheel misconfiguration are distinct. Initial validity, coverage and finite response remain WS-OI-001 / WS-OI-010 / WS-OI-015. Source: owner, 2026-09-08.

<a id="dec-flt-005"></a>
### DEC-FLT-005 — SOC qualification and information loss

Trustworthy actual SOC is required before Ready; an assumed or displayed percentage cannot substitute. Recognized loss invokes DEC-FLT-007 both-sign inhibition/clean-restart recovery and 0x07 reporting. Valid information returning or charging above 20% cannot clear that session's fault inhibition. Initial qualification/failure follows DEC-FLT-007; unknown display follows DEC-HMI-005; auxiliary continuity follows DEC-FLT-009. This information fault is distinct from DEC-SOC-001's positive-only operating restrictions. Source: owner, 2026-09-08.

<a id="dec-flt-006"></a>
### DEC-FLT-006 — Battery category and retained fault indication

Actual battery faults use 0x07, except the specific 0x06 assignment for temperature-limit faults, including battery temperature. Ordinary low charge/operating restriction is not automatically a battery fault. The owner generalized retention until normal/unexpected restart to indications for all problems requiring explicit fixing; current selection and specific/generic rules are DEC-FLT-003/008. Classification of overlapping physical faults and additional protection/isolation/charging actions remain WS-OI-018. Source: owner, 2026-09-09.

<a id="dec-flt-007"></a>
### DEC-FLT-007 — Common fault reaction and clean restart

Recognition of any fault requiring fixing invokes **zero commanded torque of both signs** at startup or during operation, in every level and demand state, irrespective of reporting priority. Abrupt withdrawal is permitted. Inhibition remains for the entire uninterrupted session even if the condition clears, inputs later qualify or repeated checks pass. Standstill, pedal/brake release, reconnection or ordinary restriction recovery cannot release it.

Recovery requires a **normal or unexpected restart**, successful fresh startup self-tests, the complete DEC-STA-001 Ready guard and all current permissives. A persistent/new fault recognized in the new startup establishes new-session inhibition, even if it clears later. Every restart discards all past-failure records, including diagnostic history and old reports; no extra rider cycle is needed after an unexpected restart. Fresh no-fault assumption does not replace qualification/tests.

**SOC initialization:** failure to qualify trustworthy SOC within the allowed startup period is an actual battery fault with the same inhibition and 0x07 reporting. Late qualification cannot recover that session. Ordinary qualification within the period blocks Ready without automatically being a fault; a separately recognizable fault need not wait for expiry. Period, self-test scope, diagnostic coverage and finite response remain open.

DEC-TMP-001–002 explicitly use this response for temperature-limit/information faults. Normal charge/recovery restrictions and communication continuity retain their own rules. A reached 10% SOC cutoff is not past-failure history. No complete detection guarantee is claimed. Source: owner and clean-restart confirmation, 2026-09-09.

<a id="dec-tmp-001"></a>
### DEC-TMP-001 — Temperature-limit faults

A recognized violation of an applicable upper or lower temperature limit uses DEC-FLT-007's common both-sign inhibition and clean-restart recovery, including at startup. No reduced operation, preserved torque direction or Ready entry is permitted after recognition; normalization alone cannot release inhibition. Abrupt withdrawal is permitted.

Retain 0x06 for both hot/cold faults, including battery temperature; DEC-FLT-003 defines its first-detected group membership above 0x01. The within-limit cold/weather allowance in PD does not authorize operation after a recognized limit violation or introduce a pre-limit derating curve. Applicable component limits/margins, recognition and finite response remain WS-OI-019; external removed-pack charging recovery remains separate. Source: owner's final thermal-reaction clarification, 2026-09-09.

<a id="dec-flt-008"></a>
### DEC-FLT-008 — Additional reporting and indistinguishable order

Owner answers 1–4 on 2026-09-09 confirm 0x06 membership in the established first-detected group above 0x01, generic **0x05** when no specific project code applies, and **0x04** for a recognized blocked motor. DEC-FLT-003 is the consolidated code/selection table.

When detection order is indistinguishable, either tied fault may be selected using a **consistent tie-breaking rule**, retained until restart. DEC-FLT-010 specifies the exact rule accepted in REQ-001-R1.6; detection-order resolution remains downstream. The owner subsequently confirmed that 0x04 and 0x05 join the same first-detected group, including its restart-based retention and priority over 0x01.

Fault classification must establish a specific assignment; otherwise use 0x05. Standstill, applied mechanical brakes or inability to move alone is not a defined blocked-motor diagnosis. Invalid temperature information alone does not prove a hot/cold limit violation. Recognition, specific/generic overlap and selected-display evidence remain WS-OI-009 / WS-OI-010 / WS-OI-019.

<a id="dec-tmp-002"></a>
### DEC-TMP-002 — Required temperature information

Before Ready after every normal/unexpected startup, qualify the information needed to establish operation within temperature limits. Recognized invalidity/unavailability uses DEC-FLT-007's common fault response; information recovery alone cannot restore torque. Ordinary initial qualification is not automatically a fault.

Required information, validity/freshness/plausibility, startup qualification/fault boundary, coverage and finite response remain downstream. Missing/invalid readings do not themselves prove a temperature-limit violation; reporting follows specific/generic classification in DEC-FLT-008. Source: owner answer 5, 2026-09-09.

<a id="dec-tmp-003"></a>
### DEC-TMP-003 — Discharge-permissible, charge-ineligible cell temperature

Owner confirmation, 2026-09-10: **allow propulsion; restrict regeneration** when valid cell temperature is inside the qualified discharge envelope but outside the charging envelope. With the 35E source references, the differing regions are −10°C ≤ T < 0°C and 45°C < T ≤ 60°C; conservative integrated limits and thermal coverage remain to be qualified.

This is an ordinary regenerative operating restriction, not a temperature fault merely because charging is unavailable. It creates no new HMI fault/availability indication and recovers under DEC-REG-003 after restriction clearance and its range-exit/standstill qualification; no restart is required solely for this restriction. DEC-REG-006's post-stop powered-forward application condition remains separate. Required-temperature-information faults, violations of applicable discharge/other operating limits and recognized actual charge transfer outside the qualified charging envelope retain their actual-fault responses. The same measured-temperature condition can therefore permit discharge while forbidding charging. External ordinary cold/warm waiting and actual charging faults retain their separate DEC-CHG-001–002 recovery rules.

This clarifies applicability of DEC-TMP-001; it does not relax the 35E charging limits or authorize charging outside them. Trace: REQ-SYS-BMS-008; WS-OI-005/019; PD CON-039/040/048.

<a id="dec-flt-010"></a>
### DEC-FLT-010 — Deterministic report tie selection

**Engineering choice accepted through the owner's REQ-001-R1.6 review/release on 2026-09-11, within DEC-FLT-008's permission:** when the earliest recognized fault-group events have indistinguishable order and no group report is yet selected, select the numerically lowest assigned code among that tied set. Thus the tie ordering is 0x03, 0x04, 0x05, 0x06, 0x07, 0x0A, 0x0D. This is a reproducible tie rule, not a severity ranking. A distinguishably earlier or already selected fault remains first even if a later code is lower. Every group report still outranks low-charge 0x01 and persists until restart.

Category assignment precedes report selection; physical responses apply to all recognized conditions regardless of which report wins. The rule is elaborated by REQ-SYS-CTL-004. Detection-order resolution and event timing remain WS-OI-009/010/019; selection alone does not close those issues.

<a id="dec-flt-011"></a>
### DEC-FLT-011 — Loss of actual motor-output information

Owner-confirmed 2026-09-10: recognized loss or invalidity of previously qualified information needed to determine actual motor output invokes the common **both-sign torque inhibition until a clean normal/unexpected restart**, with the complete Ready guard and fresh passing checks. Use generic `0x05` unless the recognized fault has an existing specific code; apply the existing first-fault/tie/reporting rules. Information restoration alone cannot release the riding inhibition. Initial unqualified information remains subject to its defined startup/self-test criteria, not automatically this loss fault. Neither unqualified values nor zero requested torque establish actual absence of electrical braking; DEC-LGT-002 governs the independent light response. Trace: [REQ-SYS-FLT-012](System_Requirements/Power_Startup_and_Faults.md#req-sys-flt-012), INT-003; WS-OI-001/006/007/010/016. Observation method, coverage, qualification and finite recognition/response bounds remain engineering derivations.

<a id="dec-flt-009"></a>
### DEC-FLT-009 — Auxiliary continuity during faults

During powered-on battery, temperature or other fault operation, continue VD18MT and front/rear lighting wherever electrical protection and those functions permit. Current/retained normal light commands and DEC-LGT-001's brake triggers, priority and release remain effective. Torque inhibition or a retained error alone neither switches lights off nor forces full rear brightness.

Protection may require supply withdrawal; continued function through a failed display, lamp or supply is not promised. Normal switch-off remains DEC-PWR-001. Protection/supply boundaries, isolation and charging actions remain downstream; no power architecture is selected. Source: owner answer 6, 2026-09-09; extends low-SOC/SOC-information continuity.

<a id="dec-ref-001"></a>
### DEC-REF-001 — Independent VD18MT reference and implementation evidence

The owner identifies commit **30fcc91f2066eb2d2e554e1c2776fe32549a0752**, path **src/vd18mt**, as tested/proven in use (PD OBJ-008 / §10.4). Reuse supported interface mappings while keeping the [device reference](../VD18MT/VD18MT_Tongsheng_UART_Interface.md) project-independent and [historical implementation/evidence](evidence/VD18MT_Implementation_Reference.md) separate. Parser/numeric/scheduling choices and qualified HIL counters are not new vehicle requirements or final qualification. Manual displayed-code versus raw-wire correlation remains OI-026.

<a id="dec-ref-002"></a>
### DEC-REF-002 — Fixed two-wire brake interface; sensing open

The owner adopted only the shared two-terminal resistance-coded brake interface from commit **9dd60546a82fee2378cfa95ee90f783e7083c84a**, **.devenv/specification/application/brake-input.md**, on 2026-09-08. [Brake interface evidence](evidence/Brake_Input_Reference.md) is canonical for topology, nominal/effective values, one-harness terminal measurements and inherent limitations.

A passive Y connects two polarity-independent coded branches to one shared trunk. Each normally open contact parallels a release-state resistor after a permanent series resistor. Both states are finite; unequal branches encode neither/left/right/both pressed. This is not two independent electrical channels; The left lever operates the front mechanical brake; the right operates the rear. Measured values are not production tolerance or sensing qualification.

Derive sensing, excitation, protection, acquisition/classification, filtering, timing, validity and diagnostic coverage downstream; no historical sensing realization, proof-test rider action or implementation test evidence is adopted. REQ-SYS-BRK-006–008/012 are approved functional requirements; **REQ-SYS-BRK-009–011 are Deferred**, not detection obligations.

Switch-only bypass opens can hide actuation; resistance/leakage or resistor failures can alias valid codes, and shared trunk/Y faults affect both handles. Do not infer universal detection or handle identity from invalidity. **Derived initialization distinction:** ordinary unqualified startup blocks Ready; recognized failure invokes DEC-FLT-002/007, not historical local recovery. Sources: PD CON-010 / §§10.6, 11.6 / OI-037; WS-OI-012.

<a id="dec-perf-001"></a>
### DEC-PERF-001 — Propulsion-performance qualification in Level 5

The owner confirms that the PD's flat-speed, 0–20 km/h acceleration, hill-launch and climbing targets (PERF-001–004) are expected and verified only in the highest assist level, **active Level 5**, using full accelerator demand under their respective reference conditions. REQ-VEH-PERF-001–004 incorporate this qualification condition; those numerical performance targets are not required in Levels 0–4.

Existing torque-profile, maximum-positive-torque, brake-priority, speed-limit and protection requirements retain their applicability across levels. This decision leaves mechanical-descent qualification and RQ-001's separate fixed-profile selection unchanged. Response/rollback tolerances, hill SOC coverage and measurement criteria remain OI-054 / WS-OI-013 work. Source: owner answer, 2026-09-09: “these performance targets are only expected and to be verified at the highest assist level.”

<a id="dec-rng-001"></a>
### DEC-RNG-001 — Range qualification in Level 5

RQ-001's 70 km range qualification shall use the highest assist level, **active Level 5 throughout the qualifying run**. The owner selected this level separately from DEC-PERF-001's full-accelerator propulsion tests. Accelerator and mechanical-brake use follow the fixed RQ-001 riding sequence, with the nominal stop/cruise sequence subsequently fixed by DEC-RNG-002; the underlying PD traffic estimates remain provisional. Full accelerator throughout is not a range-test condition.

Otherwise eligible regeneration within actual 20–80% SOC may contribute, while preliminary capacity sizing retains zero regeneration credit. The remaining riding sequence, tolerances and acceptance evidence stay under OI-053 / OI-059 / WS-OI-013. Source: owner answer, 2026-09-09, to the fixed RQ-001 level question: “It should use the highest level as well.”


<a id="dec-chg-001"></a>
### DEC-CHG-001 — Normal removed-pack charging sessions

The owner selected automatic charging start once all applicable conditions are valid, without a separate start action, and automatic resumption after ordinary cold or warm waiting, or temporary USB power interruption. These are normal-session choices; actual charging-fault classification and recovery remain separate from riding fault/restart rules.

Owner-confirmed 2026-09-11: a detached battery too warm to charge, but otherwise healthy and within its qualified non-charging limits, waits and resumes automatically after cooling into the qualified charging envelope. All other charging/session conditions must also permit charging. Cooling requires no extra rider action and does not clear an actual charging fault or reopen a completed/initially-full session; Waiting, Completed and Fault retain their existing priority. Failed protection, required-information faults and actual forbidden charge transfer remain actual faults.

At each physical connection/reconnection or qualified USB power restoration, a battery already at or above **80% actual SOC** counts as a completed session without starting a charging cycle. It must require at least some charge (actual SOC below 80%) at the new-session event to be eligible for automatic charging; no separate minimum charge deficit is selected. After completion, including this initially full condition, no automatic replenishment occurs merely because SOC falls while the battery's charging connection and USB power remain uninterrupted. Physical disconnection/reconnection permits a new session. The owner additionally confirmed that **USB supply off/on also permits a new session while the battery remains physically attached**. If other conditions are still unsuitable, charging starts automatically when they later qualify; another reconnection is not required. Completion therefore overrides ordinary recovery unless one of these new-session events occurs.

The 80% actual-SOC external-charge ceiling and qualified cell/BMS/charger limits remain controlling. Reconnection or USB restoration does not by itself authorize charging through an actual fault. Initial charge-need qualification, numerical completion criteria, SOC uncertainty, supply/connection qualification, response bounds and operating-state continuity remain OI-041/042/049/057/061 work. Unknown SOC cannot qualify a charge need. No storage implementation or new sensing realization is selected here; DEC-BAT-002 supplies the fixed pack/BMS choice, and DEC-ARCH-001 subsequently fixes charger placement.

Sources: owner charging answers, USB-power-cycle follow-up and initially-full-battery clarification, 2026-09-09; automatic warm-wait resumption confirmed 2026-09-11. Elaborated by [REQ-SYS-CHG-005–007](System_Requirements/Battery_Handling_and_Charging.md#normal-charging-sessions).


<a id="dec-env-001"></a>
### DEC-ENV-001 — Outdoor-storage configurations and provisional snow depth

The owner confirms that the required **at least 168 h unattended outdoor-storage duty applies both with the battery fitted and with it removed, leaving the empty battery bay exposed**, under the PD's −15 °C to +40 °C sun/rain/snow domain. This resolves only the parking-configuration assumption in PD §8.2 / ASM-031; DEC-STO-002 subsequently fixes normal-full entry; exposure profiles, entry tolerance and acceptance remain OI-056/063 work. The detached pack retains separately defined storage/charging conditions.

The owner retains **20 mm loose snow without underlying ice as a provisional qualification interpretation** of light snow under PD §8.1 / ASM-030, rather than adopting it as a fixed depth requirement. OI-055 still derives/validates the snow/traction boundary and usable reduced performance. Existing cold/weather allowances and temperature-fault responses remain controlling; no full winter reference performance or new HMI indication is selected.

Source: owner environment/storage answers, 2026-09-09. Elaborated by [REQ-VEH-ENV-001–003](System_Requirements/Environment_and_Storage.md#riding-and-outdoor-storage) and [REQ-SYS-STO-001](System_Requirements/Environment_and_Storage.md#req-sys-sto-001).

<a id="dec-chg-002"></a>
### DEC-CHG-002 — Charging-fault recovery and visible charging states

Owner-confirmed 2026-09-10: an actual external-charging fault inhibits charging until a qualifying battery charging reconnection, USB power cycle, **or unexpected charging-controller restart**, followed by fresh passing checks and valid charging conditions. Clearance alone cannot resume charging. The owner explicitly added the unexpected-controller-restart recovery path after reviewing the distinction from a new charging connection. Ordinary cold/warm waiting and temporary source interruption retain DEC-CHG-001's normal recovery; neither may bypass an actual fault.

The powered removed-pack charging arrangement shall visibly distinguish **charging, completed, waiting for valid conditions, and actual charging fault**, without depending on the VD18MT. Indicator realization, visibility/timing and fault detail remain to be derived. Fault state has priority while current-execution charging-fault inhibition remains; unexpected-controller-restart indication follows DEC-CHG-003; completion-hold and initial-full rules remain controlling. No indication powered without an available supply is selected.

Physical reconnection/qualified USB power cycling opens a new charging session under DEC-CHG-001. An unexpected charging-controller restart may clear charging-fault inhibition after fresh passing checks, but **shall retain the completed-session hold** and does not by itself create a new connection or authorize a new initial charge-need assessment. An interrupted incomplete cycle remains subject to its existing charge eligibility and valid conditions. Completion-state continuity is an architecture dependency, not a selected persistent fault log. Riding Ready guards are not imposed on the detached charger. Source/connection qualification, checks, classification, finite response and additional energy protection remain OI-041/042/049/057/061. See [REQ-SYS-CHG-008–010](System_Requirements/Battery_Handling_and_Charging.md#charging-faults-and-status).

<a id="dec-chg-003"></a>
### DEC-CHG-003 — Indication and qualification after charger restart

Owner-confirmed 2026-09-10: an unexpected charging-controller restart discards the previous fault indication/history and shows **Waiting while fresh checks run**. A newly recognized fault shows Fault; after passing checks, show Completed for a retained completion hold, Charging for qualified active charging, or Waiting while ordinary conditions remain unsuitable. Charge permission remains withheld until the required fresh checks and charging conditions permit it. Completion and initial-charge eligibility remain retained and must be qualified; restart alone creates no new charging connection or charge-need assessment. A recognized new fault during checks takes indication priority. Indicator power and finite response remain subject to CHG-010's acceptance. This refines DEC-CHG-002 without changing its recovery events or selecting a state-storage implementation.

<a id="dec-chg-004"></a>
### DEC-CHG-004 — Minimum supported charging supply

Owner-confirmed 2026-09-11: a USB-C supply offering **9 V at 2 A (18 W)** shall support actual removed-pack charging when battery/session conditions permit. Stronger sources remain supported through a compatible qualified profile, up to the existing 140 W USB-input limit. Source power is not net battery power; no charge-time guarantee follows.

**Acceptance derivation:** demonstrate positive net battery charging after charger/pack auxiliary consumption, not negotiation alone. Supported-profile and cable qualification, conversion losses, finite transitions and measurement margins remain engineering work under OI-042/057/058; an unsupported/insufficient source alone is ordinary waiting, not an actual charging fault. See [REQ-SYS-CHG-002](System_Requirements/Battery_Handling_and_Charging.md#req-sys-chg-002).

<a id="dec-rng-002"></a>
### DEC-RNG-002 — Nominal reproducible range profile

Owner-confirmed 2026-09-10: use the nominal RQ-001 profile of **70 km in Level 5, 140 intermediate full stops evenly spaced, 30 s dwell at each, 30 km/h cruise, and target acceleration/deceleration of 0.5/1.0 m/s²**. Departure and arrival are additional separate events, giving 141 equal travel segments. During deceleration, use physical rest when its permitted regeneration does not exceed the target; otherwise move the pedal toward virtual neutral to reduce regeneration and follow the 1.0 m/s² target. Mechanical brakes supply any shortfall. The owner confirmed this pedal-modulation clarification on 2026-09-10. Modulate positive torque during acceleration/cruise to follow the trace; no special test-only torque profile or change to normal Level 5 behavior is introduced.

This fixes the nominal qualification profile, not measured traffic facts or a constant-acceleration product guarantee. RQ-001's actual-SOC window and other conditions remain controlling; in-window regeneration may count but is not guaranteed or credited in preliminary sizing. Environmental/measurement tolerances, physical trace-following acceptance and feasibility still require derivation. The [qualification trace](System_Requirements/Vehicle_Qualification.md#nominal-reproducible-rq-001-trace) records the exact events and model arithmetic.

<a id="dec-sto-001"></a>
### DEC-STO-001 — Detached-battery storage duty

Owner-confirmed 2026-09-10: the removed battery shall support **at least 672 h (28 days) unattended storage, dry indoors at 15–30 °C**. This is separate from the vehicle's 168 h outdoor-storage duty, which includes an exposed empty bay. DEC-STO-002 now fixes normal-full entry/preparation; residual loads/self-discharge, uncertainty and post-storage acceptance remain OI-056/061/063; no arbitrary-entry-SOC or guaranteed post-storage range is selected. See [REQ-SYS-STO-002](System_Requirements/Environment_and_Storage.md#req-sys-sto-002).

<a id="dec-sto-002"></a>
### DEC-STO-002 — Storage preparation and qualification entry

Owner-confirmed 2026-09-10: both the **168 h fitted outdoor** and **672 h detached indoor** storage duties require entry at **normal full charge, 80% actual SOC**, subject to the qualified conservative charging/control tolerance. Entry below that normal-full condition or above 80% is outside these duration qualifications; entry up to 90% after regeneration is not included. No automatic forced-discharge function is selected. These conditions govern the two unattended storage duties, while ordinary parking/handling retains its normal protection requirements.

Normal temperature conditioning and, if needed, normal charging may precede post-storage riding/function qualification; establish stored condition first. No immediate Ready, fixed remaining range or restored charge without recharging is promised. Storage limits, load/self-discharge budget, SOC uncertainty and environmental exposure still require engineering qualification. This closes the entry/preparation choice, not physical storage acceptance; trace STO-001/002, ENV-003 and OI-056/061/063.

<a id="dec-life-001"></a>
### DEC-LIFE-001 — Service-life origin and permitted replacement

Owner-confirmed 2026-09-10: DUR-001's **50,000 km or five years, whichever comes first**, is measured from commissioning of the completed modified scooter. Battery and normal wear-part replacement is permitted. Retained donor parts' existing age/wear must still be assessed; commissioning does not renew them physically. Required maintenance, replacement criteria, accumulated duty and durability acceptance remain OI-050 work; no aged-battery 70 km guarantee is introduced. See [REQ-VEH-DUR-001](System_Requirements/Service_and_Durability.md#req-veh-dur-001).

<a id="dec-arch-001"></a>
### DEC-ARCH-001 — Separate mobile charger adapter

Owner, 2026-09-13: place the USB-C socket, charging electronics and four-state charging indicator in a **separate mobile charger adapter**. It operates with the removed existing battery/BMS without powered vehicle electronics or VD18MT. This closes equipment placement for PD CON-051; charging behavior, the fixed cell bank/BMS and the prescribed battery handling remain unchanged.

[ARCH-001](../Architecture/ARCH-001_System_Architecture.md) and [ARCH-002](../Architecture/ARCH-002_Hardware_Architecture.md) define the subsequently released component split; [ARCH-003](../Architecture/ARCH-003_Software_Architecture.md) records the approved local charger-host and session-ownership allocation. Exact host hardware, connectors, conversion/protection, BMS electrical coupling, retention mechanisms and acceptance remain downstream. This placement decision alone did not approve the architecture. The subsequent owner architecture review/release is recorded in [ARCH-001](../Architecture/ARCH-001_System_Architecture.md#release-record); this DEC document remains Draft1.6.

## Superseded interpretations

Only changes that affect interpretation of older material are retained here; apply current entries according to the document's release/decision status.

| Earlier interpretation | Current disposition |
|---|---|
| Levels 1–5, Level 1 coasting; various scooter defaults | Levels 0–5, Level 0 coasting, VD18MT level authority; no scooter factory default — DEC-LVL-001/003 |
| Cross-boot restoration of the last selected level | Always use the level communicated by VD18MT, including normal/unexpected startup — DEC-LVL-003 |
| Additional pending-setting indication required | No pending-change indication required — DEC-HMI-007 |
| Immediate riding-level changes; above-40 speed requests ignored | Standstill/rest application of changes; above-40 requests clamp to 40 including startup — DEC-LVL-002 / DEC-SPD-001 |
| Accelerator commands speed/deceleration; neutral in every level | Signed wheel torque; provisional 35% neutral only in Levels 1–5 — DEC-TRQ-001/002 |
| Original Level 1 uses Level 2's return ramp | Renumbered Level 0 uses Level 1's ramp — DEC-BRK-002 |
| Level 5 literally unlimited/instantaneous | No deliberate smoothing; actual limits, finite response and taper still apply — DEC-TRQ-001 |
| Regeneration-availability warning or fault visibility dependent on effect | No dedicated availability status; underlying faults remain visible — DEC-HMI-001/006 |
| Partial operation or automatic thermal recovery after an actual temperature fault | Common both-sign inhibition until clean restart — DEC-TMP-001/002. Qualified discharge-only cell temperatures instead cause an ordinary regeneration restriction — DEC-TMP-003 |
| Recovery event must follow restriction clearance; all partial reductions mean zero/frozen torque | Event may precede clearance; remaining capability can be used — DEC-REG-003 |
| Rev1.0's 80% regeneration ceiling and protected 20% floor | Released PD Rev1.1: external 80%, regeneration 90%, low-SOC restriction 20%, positive stop 10% held until above 20%; RQ-001 stays 20–80% — DEC-REG-001 / DEC-SOC-001 |
| Regeneration returns on manual forward motion after stopping; all rollback torque prohibited | Return requires forward motion with applied positive torque; deliberate positive rollback demand allowed — DEC-REG-006 / DEC-TRQ-003 |
| Communication loss turns lights off after a valid command | Retain last valid normal light state — DEC-FLT-001 |
| Separate bare brake switches or inherited historical sensing/diagnostic recovery | Fixed shared coded interface only; sensing/coverage derived; historical diagnostic IDs Deferred — DEC-REF-002 |
| Unexpected restart retains past faults until deliberate power cycle; report clearing requires Ready | Every restart assesses afresh; current-session inhibition lasts until a clean restart, while old reporting ends at any restart — DEC-FLT-003/007 |
| 0x06 priority remains unresolved | In first-detected group above 0x01; 0x04/0x05 also join that group — DEC-FLT-008 |

## Open issues and dependencies

These 20 workstream records (19 open, WS-OI-004 closed) supplement, without renumbering or closing, PD-001's issue register. The project owner is responsible. “Define/verify” identifies needed downstream work, not an executed test. Settled behavior is referenced rather than repeated.

| ID | Open matter / trace | Required resolution and evidence |
|---|---|---|
| `WS-OI-001` | Standstill, direction, motion latency; DEC-SPD-002 / OI-049 / OI-054 | Measure fixed-wheel loaded circumference and speed accuracy; define near-zero/direction tolerances and latency. Verify forward-to-rollback and requested-forward-torque reversal, readiness, setting changes and regeneration events. |
| `WS-OI-002` | Accelerator travel/rest/neutral; OI-034–035 | Characterize selected accelerator, return behavior, calibrated endpoints and uncertainty; define physical rest and provisional-neutral/deadband acceptance. |
| `WS-OI-003` | Torque profiles, ramps and permitted envelopes | [Released profile acceptance](System_Requirements/Rider_Control.md#torque-profile-calibration-acceptance) defines branch normalization, endpoint/linearity checks, separate dynamic response and common-onset/per-level taper. System validation still selects curves, negative endpoints, gradients, torque envelopes, distinguishability and physical tolerances; preserve event-specific limits/withdrawal and Level 0/1 positive-resumption equivalence. |
| `WS-OI-004` | **CLOSED — PD Rev1.1 review/release** | Owner confirmed review and instructed release on 2026-09-09. [release authority and history](README.md#release-and-history) establishes the new upstream baseline. The later item/requirements approval is recorded in the index; quantitative, hazard and qualification evidence remains outstanding and technical issues stay open. |
| `WS-OI-005` | Actual SOC, charge acceptance and regeneration permissives; OI-041 / OI-048 / OI-061 | Use BAT-001 selected-cell/BMS limits; define SOC reference/uncertainty, conservative margins, actual cutoff and finite withdrawal bounds, charge acceptance and other limiting-condition evidence. Assess overlapping restrictions and remaining entry transitions; no hysteresis or protection mechanism selected. |
| `WS-OI-006` | Low-speed taper, rollback and hand parking; OI-048 / OI-054 | Determine common taper-onset speed during system validation; define taper shape, direction/applied-torque criteria, response and repeated-stop transitions, including deliberate launch and powered return after hand pushing. |
| `WS-OI-007` | Startup/shutdown, Ready and energy state; VS-003 / VS-009 | BMS-006 now defines battery qualification content and ARCH-001 separates BMS/riding/charging reset domains. Complete remaining self-test scope, numeric completion/duration, reset observability and residual/generated-energy/handling criteria. Verify simultaneous guards, moving restart and initial speed clamping; correlate reset/brownout coverage with WS-OI-010. |
| `WS-OI-008` | Selected VD18MT and electrical evidence; OI-026–031 | Record hardware/firmware/manual identity and actual wire/display correspondence. Characterize continuous supply/brownout, active/off current, pin-5 power-lock voltage/drop/current/leakage/timing/abnormal states, UART thresholds/loading/unpowered behavior, mating connector/retention/sealing. Historical HIL or device-family ratings do not close selected-unit qualification. |
| `WS-OI-009` | HMI/settings integration; OI-032 | Define usable-charge discrete thresholds/rounding/update accuracy and visible-percentage correspondence, selected-code visibility/response, specific/generic classification, DEC-FLT-010 tie-rule verification and recognition-order resolution. Qualify valid/special/combined requests and continuous battery-current reporting (DEC-HMI-008): magnitude/clamping verification, quantization/rounding, validity criteria, 0 A fallback/recovery verification, accuracy and update bounds. Level selection follows VD18MT across all restarts; no cross-boot retention or Ready/pending indication is required (DEC-LVL-003 / DEC-HMI-007). |
| `WS-OI-010` | Fault/communication/reset behavior; OI-049 | The battery matrix and nonbattery startup/runtime catalogue distinguish qualification, restrictions and recognized faults; DEC-FLT-011 closes actual-output-information loss policy. Complete the wider detectable-fault catalogue, selected-unit coverage, finite entry/reporting bounds, nonbattery self-tests, reset/brownout and protective realization. Verify session retention, failed startup/late qualification, persistent/new faults after restart, report order independent of physical reaction, communication continuity and pending settings. Historical parser timeout is not a vehicle deadline. DEC-CHG-002/003 fix charging recovery/status, including Waiting/fresh fault assessment after controller restart with completion/initial-eligibility retention. CHGPOL-001 allocates policy; the charging classification table distinguishes waiting, recognized data/path failures and forbidden transfer. Qualify restart/connection events, initial-SOC evidence, checks, continuity and physical response/indication. DEC-CHG-001 now settles automatic resumption after ordinary warm waiting; qualify thermal references/margins and fault classification under OI-057. |
| `WS-OI-011` | Battery handling; OI-062 / packaging interfaces | REQ-SYS-BAT-003 makes accessible-contact protection explicit throughout normal handling and exposed-bay states. Inspect connector, tray and lock; derive touch/exposure/energy limits, credible abnormal-handling cases and inspection/recovery criteria before interface acceptance. No connection/lock sensor or interlock is assumed. |
| `WS-OI-012` | Fixed brake interface and downstream sensing; CON-010 / OI-037 | Characterize BOM/contact/harness/environmental tolerances, permitted loading, final identification and verification of left/front and right/rear association. Derive sensing, valid-state/unknown information, necessary diagnostics/protection/fault envelope and response; address bypass-open/resistive aliases/shared dependencies. Preserve Deferred BRK-009–011 and separate initial qualification from recognized failure. Verify current torque/report/light behavior with WS-OI-010/016. |
| `WS-OI-013` | Performance/range qualification; PERF-001–004 / RQ-001 / OI-052–059 / OI-063 | Propulsion-performance and range level coverage are settled by DEC-PERF-001 / DEC-RNG-001. DEC-RNG-002 fixes nominal RQ-001 events and pedal modulation. The qualification cluster now defines conservative evidence rules and conditional energy/motor calculations; close their physical inputs, reference-trace tolerances, launch/rollback, adverse-weather performance and storage margins. Calculations are not test evidence. Set the accepted just-below-40 sustained-speed tolerance and remaining RQ-001 trace-following acceptance in Level 5 with permitted in-window regeneration credit; coordinate RQ-001's 20–80% endpoint with low-SOC entry; assess abrupt braking loss/descent/rider control. |
| `WS-OI-014` | Release evidence and process alignment | Frozen Rev1.0 was restored with the release-record hash. Rev0.7 archive, promotion patch and checksum manifest remain absent; earlier promotion/review content cannot be independently reconstructed from them. Align future HSI revision with PD's tailored process; its ASIL/FTTI assumptions are not adopted here. Details below. |
| `WS-OI-015` | Speed-setting/cutoff evidence; PERF-001 / OI-032 / OI-049 | SPD-002/004/005/008 are allocated unchanged to LE-SET. Define remaining encodings/special meanings and fixed-wheel error/age bounds; the [cutoff budget](System_Requirements/Interface_Qualification.md#speed-cutoff-uncertainty-and-response-budget) requires numeric motion/response evidence, including compatibility with sustained-speed acceptance. Verify clamped startup/pending requests, standstill/rest guards, communication transitions, control/display separation and repeated cutoff crossings with separate regenerative recovery. |
| `WS-OI-016` | Lighting suitability and response; CON-009 / OI-038–039 | DEC-LGT-002 settles full-bright output for unqualified lever/braking states, and LGTPOL-001 allocates mode policy. Characterize rear VCC/GND dimming compatibility, powered-start/reset output and lamp visibility/environmental suitability; define trigger/release and response tolerances. Verify lever/invalid-input/actual-braking overlaps, normal dim/off return despite retained faults, no-command/startup/communication cases and fault auxiliary protection boundaries. |
| `WS-OI-017` | Low-SOC transitions and energy; OBJ-014 / CON-048–050 / OI-041 / OI-053 / OI-061 / OI-063 | System validation sets severe torque/speed caps; derive finite entry/recovery/ramp bounds, SOC margins and repeated-boundary acceptance. Verify speed-only versus charge recovery, warning suppression/return and restart/battery-handling continuity of a reached cutoff. Derive all-load protection, post-cutoff auxiliary energy and RQ-001 endpoint compatibility. DEC-STO-001 fixes detached storage at 672 h dry indoors, 15–30 °C; DEC-STO-002 requires normal-full 80% entry for that and the 168 h fitted duty, excluding higher entry SOC. Qualify entry tolerance and the storage charge budget, actual BMS/wake/poll loads, self-discharge and post-storage condition. |
| `WS-OI-018` | SOC information/battery faults; VS-003–004 / OI-032 / OI-041 / OI-049 / OI-061 | The battery integration event/qualification matrix now defines initial versus lost information, expected path states, actual trips and reset domains. Define SOC trustworthiness/freshness/accuracy, initialization period, diagnostic coverage, actual-unit event mapping and finite response. Verify display-only unknown fallback, late qualification, fresh restart, battery/temperature overlaps and auxiliary continuity/protection boundaries; BMS UART is selected by DEC-BAT-002; qualify its RSOC, signed current, 14-group voltages, available probes and protection/path status. Estimator qualification and remaining power allocation stay open. |
| `WS-OI-019` | Temperature limits/information; PERF-007 / OI-023 / OI-025 / OI-041 / OI-049 | 35E cell discharge −10…60°C / charge 0…45°C are fixed source limits (BAT-001); riding minimum revised to −10°C. Derive stricter integrated limits, references/margins, sensor coverage, validity/freshness, qualification/fault boundary, self-tests and finite response/restart cases. DEC-TMP-003 settles discharge-only temperature as an ordinary regeneration restriction; DEC-FLT-010 specifies tied-report selection. Resolve remaining fault overlap, recognition-order resolution and selected-display evidence. Known violations use 0x06; invalid information alone is not proof of a violation. Derive protection/supply/isolation/charging boundaries; external charging recovery remains separate. |
| `WS-OI-020` | System-requirements completion points and allocation | **A RELEASED — REQ-001-R1.6, 2026-09-11:** owner confirmed review of all System Requirements and instructed release; [release record](README.md#req-001-r16-system-requirements-release). **B remains OPEN:** [ARCH-001/002/003](../Architecture/ARCH-001_System_Architecture.md) are released as ARCH-001/002/003-R1.0, approving the initial logical/HW/SW decomposition, component interfaces and local vehicle/charger host roles. Complete requirement refinements/parent coverage, numerical contracts, protection/measurement mechanisms and component/host acceptance. The 171 active requirements, current Type/Target assignments and planned acceptance are approved with their controlled parameters. Source documents retain separate statuses; physical feasibility, diagnostic/protection and verification gates remain. This issue stays open for B. |

### WS-OI-014 — Missing release artifacts

The available Rev1.0/1.1 archives and release records are preserved in [Git history](README.md#release-and-history). The older PD-001_Project_Definition_Rev0.7.md, PD-001_Rev0.7_to_Rev1.0.patch and PD-001_Rev1.0_SHA256SUMS.txt were already unavailable; cleanup does not reconstruct them. Their absence still limits independent reconstruction of the original promotion.

## Maintenance

Keep owner intent here, verifiable requirements in REQ-001 and actual observations in the evidence references. Close an issue only with its required definition/evidence; editorial consistency fixes and compaction do not supply technical verification or release approval.
