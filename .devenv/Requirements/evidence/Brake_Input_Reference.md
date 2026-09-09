# Fixed two-wire brake-handle interface

**Revision 1.0, released 2026-09-09.** Given electrical interface for downstream development, as clarified and reviewed by the owner. This reference adopts the handle/harness interface only. The sensing realization remains to be derived; no implementation or sensing verification is adopted.

[Workstream index](../README.md) · [Item definition](../ID-001_Item_Definition.md) · [Decisions](../DEC-001_Decisions_and_Open_Issues.md#dec-ref-002) · [Requirements](../REQ-001_Requirements.md)

## Source and adoption boundary

| Source | Recorded identity |
|---|---|
| Historical commit | `9dd60546a82fee2378cfa95ee90f783e7083c84a`, 2026-08-28, “Implemented Brake Input detection” |
| Source path | `.devenv/specification/application/brake-input.md` at that commit |
| Source Git blob | `8c194d784d9186b0ba0ea325e49db9a2484b7045` |
| Current owner direction | Restore the shared two-wire resistance-coded interface as fixed/given; derive its sensing realization in downstream activities |

The adopted boundary is the two terminals of the common brake harness. The handle networks, passive Y, polarity independence and resistance codes below are given interface characteristics. Their sensing circuit, electrical excitation, input protection, observation method, acquisition, classification, filtering, timing and hardware/software allocation are downstream design work.

The complete historical source remains in Git. Its sensing realization, operating values, software contracts, diagnostic implementation and execution records are not transferred into this interface definition or used to qualify a future realization. Existing owner decisions about vehicle behavior, including invalid-input inhibition, recovery after restart and fault codes, remain controlling.

## Given handle and harness interface

Each normally open handle contact is incorporated into a passive two-terminal resistance network: a permanent series resistor is followed by the parallel combination of the contact and a release-state resistor.

- Released handle resistance: `R_SER + R_REL`.
- Pressed handle resistance: `R_SER`.
- Both coded handle branches connect in parallel through a passive Y to one shared two-wire trunk.

Both released and pressed states have finite resistance. Pressing a handle does not directly short the two harness terminals. Unequal left/right resistance values encode four combinations. Reversing either handle branch's two connections does not change its resistance code. Exchanging the complete left/right networks exchanges their identities and must be controlled in assembly.

The interface provides four distinguishable resistance codes; it does not prescribe how the EPCS senses them or represents the results internally. The shared Y/trunk is not two independent electrical channels. Mechanical braking remains independent of EPCS power. The owner specifies left lever/front brake and right lever/rear brake; verification of the fitted assembly remains downstream.

### Given nominal/effective branch values

| Handle | `R_SER` | `R_REL` | Released resistance | Pressed resistance |
|---|---:|---:|---:|---:|
| Left | 6.113 kΩ | 12.845 kΩ | 18.958 kΩ | 6.113 kΩ |
| Right | 2.171 kΩ | 2.175 kΩ | 4.346 kΩ | 2.171 kΩ |

These source-specified nominal/effective values form the provided coding. They are not a completed constituent BOM or a tolerance specification. Individual completed-handle measurements were not separately recorded in the source.

### Terminal resistance and interface measurements

The source records the following measurements at the assembled Y's two-pin connector, before connection to sensing electronics:

| Handle state | Calculated nominal network resistance | Recorded development-harness resistance |
|---|---:|---:|
| Neither pressed | 3.5355 kΩ | 3.543 kΩ |
| Left pressed | 2.5401 kΩ | 2.540 kΩ |
| Right pressed | 1.9479 kΩ | 1.947 kΩ |
| Both pressed | 1.6020 kΩ | 1.602 kΩ |

These are interface observations from one development harness, not acceptance limits or evidence for any sensing realization. Characterization must establish constituent tolerances, temperature effects, joints, cable/contact resistance, aging and measurement uncertainty. It supplements the given interface; it does not silently replace its topology or nominal coding.

The exact contact specification, permitted electrical loading, environmental limits and final connector/as-built identification remain to be established as interface constraints for downstream design. No historical excitation voltage or loop current is adopted.

## Interface-inherent limitations

| Physical condition | What follows from the given passive network |
|---|---|
| Hard trunk open or complete branch loss | Produces an impedance different from the nominal four valid codes. Required detection coverage, margins and timing must be derived and verified downstream. |
| Hard short between harness conductors | Produces a near-zero impedance, distinct from the finite both-pressed code. This does not itself select a detection circuit or establish fault survival. |
| Open switch-only bypass: contact, lead, trace or joint | Can remain indistinguishable from a released handle through the release-state resistor and hide a genuine press. Complete-branch continuity does not prove that the bypass will close. |
| Arbitrary series resistance or leakage | Can imitate another valid code, including a less-pressed state. Universal resistance-damage detection does not follow from the interface. |
| Release-state resistor short or certain series-resistor faults | Can imitate a valid press. In particular, the right branch's 2.171/2.175 kΩ values allow a shorted series resistor to resemble right/both pressed. |
| Shared trunk/Y failure | Can affect information about both handles; distinct resistance codes do not establish independent fault containment. |

Other electrical fault cases, including faults to vehicle supplies or ground, require a fault envelope and sensing design. No excitation rail, conductor common-mode signature, diagnostic coverage or protection realization is fixed by this reference.

When information is detected invalid, current vehicle requirements govern torque inhibition, recovery after restart and `0x0D` reporting. Invalidity does not prove a physical press or identify a handle. A fault electrically indistinguishable from a valid code cannot be assumed detectable merely because its physical cause is known. Residual-fault analysis must address these limitations without treating a historical mitigation or proof-test procedure as selected.

## Downstream derivation and trace

PD-001 §§10.6 / 11.6 and CON-010 carry the fixed interface. DEC-REF-002 records the owner's adoption boundary.

`REQ-SYS-BRK-006`–`REQ-SYS-BRK-008` and `REQ-SYS-BRK-012` remain approved functional requirements concerning valid state information, unknown invalid state, information quality and startup eligibility. Their realization is open. The historical detection proposals `REQ-SYS-BRK-009`–`REQ-SYS-BRK-011` are deferred records, not adopted diagnostic requirements.

WS-OI-012 / OI-037 track derivation of the sensing realization and its measurable requirements: electrical compatibility with the given interface, state recognition, necessary diagnostic coverage, response, fault-envelope/protection requirements and qualification. Current owner decisions in DEC-FLT-002 / DEC-FLT-003 / DEC-LGT-001 define fresh fault assessment after normal or unexpected restart, first-detected input-fault indication retained within each uninterrupted session, and full rear brightness while powered with invalid brake information. Valid both-released information and absence of electrical braking restore normal illumination even while current-session torque inhibition/reporting persists. Drive-off still requires input/HMI qualification under DEC-STA-001. WS-OI-007 / WS-OI-010 / WS-OI-016 retain measurable startup/fault transitions and lighting verification. These vehicle decisions do not extend the fixed interface into a sensing realization. No new hardware, software or vehicle verification was performed for this clarification.
