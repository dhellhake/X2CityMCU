# MOT-001 — Installed rear hub-motor interface evidence

**Released 1.0 — 2026-09-14; MOT-001-R1.0.** Canonical record of owner-supplied motor-interface observations. It replaces no released baseline and does not by itself identify the unknown motor brand/type, select a control method, or qualify the motor for vehicle use. The distinct selected control design is [MCD-001](MCD-001_Hall_Sensored_FOC_Technical_Design.md).

## Provenance and observed interface

The owner reports an unknown-brand/type rear hub motor. The following bench observations were supplied on 2026-09-13. The test equipment, motor isolation/stationary status, lead-compensation method and external pull-up resistance/tolerance are not yet recorded; values therefore are observations, not component ratings or acceptance limits.

| Subject | Observation | Qualification boundary |
|---|---|---|
| Phase leads | Resistance between each of the three pairs: **0.56 ohm** (displayed measurement precision only). | This is line-to-line resistance including unknown leads/contact/test error. It is not a per-winding resistance: only under an equal star winding would it imply 0.28 ohm/winding, and only under an equal delta winding 0.84 ohm/winding. Topology is unknown. |
| Six-pin sensor connector | Functions identified as `Vcc`, `Gnd`, `Temp`, `Hall1`, `Hall2`, `Hall3`; no physical pin order supplied. | Bench wiring confirms +5 V to Vcc and a common Gnd. It does not establish numbered-pin order/orientation, mating-view mapping, final harness routing or current capability. |
| Hall signals | Three Hall outputs switched cleanly at **3.3 V** while the wheel rotated, with **+5 V to Vcc** and common Gnd for the 5 V and 3.3 V supplies; external 3.3 V pull-ups were used. | Hall count, supply polarity and shared reference are confirmed. Output topology, compatible pull-up range, truth-table order, electrical angle, 60/120-degree placement, edge timing, speed accuracy and fault coverage are unqualified. No Honeywell identity is established. |
| Temperature pair | `Temp` to `Gnd`: **9.257 kilohm**; motor housing measured **23.8 °C** with an infrared thermometer after it had sat for a while. | Resistance-test supply/excitation/isolation state, meter accuracy and lead compensation are unreported. The owner assumes thermal soak; the internal sensor temperature was not independently measured. This is a static two-terminal resistance observation, not confirmation of an NTC, its beta/curve, location, thermal coupling, limits or sensor health. |

## Derived integration meaning

The three observed Hall signals support an eventual **electrical rotor-sector** observation: sampled/edge-qualified logic levels, their validity/freshness and a configuration-qualified sector/direction/edge-time result. It is not a calibrated mechanical angle, pole count, rotational speed, torque, phase order, commutation table or FOC selection. A static valid Hall state at rest may establish a sector only after the sector map/alignment is qualified; it must not require an edge and deadlock drive-off. It also cannot alone prove the vehicle-speed channel healthy or establish standstill. Do not pre-classify any static three-bit code as impossible before the unverified 60/120-degree convention and actual state map are known. Edge absence, stale data and correlation with commanded/applied motion need separate operating-condition-specific qualification before they can be detected or used as faults.

Electrical rotor speed inferred from Hall edges, if later qualified, remains distinct from vehicle mechanical speed. Converting it to wheel/vehicle speed requires qualified pole-pair conversion, direction, the existing nominal fixed 16-inch wheel geometry and its separate loaded-circumference calibration/uncertainty; it cannot replace the existing independent vehicle-speed calibration.

`Temp` may become a candidate motor-temperature observation only after its electrical identity, reference, curve, location, thermal lag and fault coverage are qualified. No temperature limit or thermal fault action follows from the resistance reading.

## Remaining evidence and use gates

Record connector family/orientation and pin mapping; record pull-up values and test method; repeat phase resistance with suitable lead compensation and conditions; measure insulation and inductance; characterize Hall output type/levels/timing/state order and electrical-mechanical relation; characterize the temperature path against a traceable temperature reference. These are characterization and integration inputs for `OI-021`–`025`, not owner choices of controller, topology, FOC, poles or protection settings.

The required signal path is allocated as: physical Hall supply/conditioning/acquisition → `SC-INPUT-QUAL.V` qualified Hall state → `SC-TRACTION-CTRL.V` electrical rotor-sector/direction/edge-time interpretation and traction use. It must preserve source/reset context, validity and freshness; it may not authorize torque by itself. Existing Ready, torque-authority and recognized-fault rules remain controlling.
