# BAT-001 — Selected pack and BMS

**Draft 0.1 — 2026-09-10.** Canonical project component reference; [PD §10.8](../../README.md#108-built-battery-and-selected-bms) and [DEC-BAT-002](../Requirements/DEC-001_Decisions_and_Open_Issues.md#dec-bat-002) establish selection. Manufacturer ratings, calculations and owner observations have different evidence status. No qualification test was performed for this document.

## Fixed inputs and provenance

The owner reports an already fabricated, working pack which fits the actual bay: **14 series groups of five parallel Samsung INR18650-35E cells, 70 cells total**. The owner explicitly confirmed the cell model, revised minimum riding ambient to −10°C, and selected **JBD SP14S004P14S50A**, using its **UART** for system interaction. The BMS is connected to the working pack, but its configuration is incomplete and its installation, board/firmware revision and programmed values have not been recorded. Cell/topology/BMS selection and initial bay fit are settled; this report supplies no measured mass, range, thermal or protection acceptance. Configuration values are engineering derivations to qualify, not owner-supplied decisions.

| Source | Scope and qualification |
|---|---|
| [Samsung SDI INR18650-35E specification, V1.1, 2015-07-09](https://www.nkon.nl/novat/amfile/file/download/file/495/product/5627/) | Manufacturer-authored document hosted by NKON; §3 supplies the cell ratings below. Pack-design guidance and test conditions also apply. |
| [JBD SP14S004 NMC family specification, A03, 2024-09-19](https://cdn-files.myshopline.com/file/store/1777805905342/jbd-SP14S004-7s-14s-20a-50a-nmc-smart-bms-datasheet.pdf) | Manufacturer-hosted family reference, not confirmation of the exact installed suffix/revision/configuration. Use this lithium-ion version, not the different LiFePO4 parameter table. |
| [JBD universal UART protocol, V12](https://cdn-files.myshopline.com/file/store/1777805905342/jbd-bms-universal-protocol-rs485-rs232-uart-communication-specification-pdf.pdf) | Manufacturer protocol reference; commands, extensions and scaling need selected-unit qualification. Generic protocol support does not prove board support. |

## Cell ratings and pack arithmetic

| Samsung cell datum | Manufacturer value / condition |
|---|---|
| Nominal voltage | 3.60 V |
| Minimum standard capacity | 3,350 mAh at 0.68 A discharge; 4.20 V CC-CV charge, 2.65 V discharge test cutoff |
| Rated capacity at 1C | Minimum 3,250 mAh at 3.4 A |
| Charge current | 1.7 A standard; 1.02 A cycle-life test; 2 A maximum, not for cycle life |
| Discharge current | 8 A continuous; 13 A noncontinuous without a usable pulse-duration/duty specification |
| Cell-surface temperature | Charging 0…45°C; discharging −10…60°C |
| Maximum dimensions / mass | Diameter 18.55 mm, height 65.25 mm; 50 g |
| Storage reference | One month at −20…60°C, conditional on the manufacturer's storage/test state; not pack acceptance |

These are cell limits/test references, not vehicle regenerative setpoints or proof that every cell in the built pack meets its original specification. In particular, neither 4.20 V nor 2.65 V defines a project SOC threshold.

| Derived 14S5P quantity | Calculation / meaning |
|---|---|
| Nominal pack voltage | `14 × 3.60 = 50.4 V` |
| Upper cell-test voltage reference | `14 × 4.20 = 58.8 V`; not a vehicle regenerative target or a component transient rating |
| Lower cell-test voltage reference | `14 × 2.65 = 37.1 V`; not an operational floor or permission to discharge any group below its limit |
| Standard-capacity basis | `5 × 3.350 = 16.75 Ah`; nominal-voltage product `50.4 × 16.75 = 844.2 Wh`, not measured usable energy |
| 1C rated-capacity basis | `5 × 3.250 = 16.25 Ah`; nominal-voltage product 819 Wh under the separate cell test basis |
| Ideal continuous current ceilings | Discharge `5 × 8 = 40 A`; regenerative acceptance `5 × 2 = 10 A`. Actual limits must account for unequal sharing, temperature, ageing, connections and protection margins |
| Charge reference currents | Standard `5 × 1.7 = 8.5 A`; cycle-life test `5 × 1.02 = 5.1 A`; neither is a selected operating command |
| Bare-cell mass bound | `70 × 50 g = 3.50 kg`; excludes BMS, conductors, insulation, enclosure, connectors and retention |

No 65 A pulse capability is established. Battery DC current is not motor phase current or wheel torque. The BMS's 50 A designation cannot override the 40 A ideal continuous cell-bank ceiling, nor establish a 50 A regenerative allowance.

## BMS interface and protection basis

The NMC family specification describes 7–14S, 20–50 A options, common-port negative-side switching, passive balancing, one internal and one external temperature channel. Heating, charge-current regulation and secondary protection are unsupported. Board operation is specified at −20…75°C; this does not widen the cell envelope.

UART: **9600 baud, 8 data bits, no parity, one stop bit**. J5, HY2.0-4P: **1 GND; 2 RXD; 3 TXD; 4 B+**, directions at the BMS. B+ is pack potential. Connector orientation, logic levels and ground reference require actual-unit verification. The non-isolated UART carries a manufacturer warning against energy-source/load communication. Integration must resolve that restriction without bypassing protection; a direct controller connection is not qualified.

Family example temperature trips (charge −10/65°C; discharge −20/75°C) exceed cell permissions. They are not acceptable project operating limits or evidence of actual settings. Typical balancing starts at 3.9 V with 15 mV difference, about 40 mA pulsed. Verify effective balancing without exceeding the qualified cell envelope.

## BMS configuration derivation

The selected unit shall be configured and accepted as a **14-series lithium-ion/NMC 35E 5P pack**. This table derives constraints and the evidence needed to turn them into settings; it is a configuration derivation, with final programmable values dependent on the listed evidence and supported parameters.

| Configuration subject | Derived constraint and acceptance evidence |
|---|---|
| Series count and chemistry | Set/read back 14 series groups and the NMC/lithium-ion parameter family. Confirm cell-order readback against all 14 physical groups and prove the selected board/firmware accepts this chemistry/count; a generic 7–14S family label is insufficient. |
| Capacity parameter | `5 × 3.350 Ah = 16.75 Ah` is the initial configuration basis, explicitly provisional. Qualify the full-reference charge capacity corresponding to 100% actual SOC using a justified model/calibration procedure and recorded temperature/current conditions; update the parameter from that evidence. Do not configure the smaller usable operating interval as full BMS capacity. The 16.25 Ah 1C rating is a different test basis, not an interchangeable setting. |
| Cell-voltage protection | The cell data give 4.20 V charge-test upper reference and 2.65 V discharge-test cutoff per group (`58.8 V` and `37.1 V` for 14S). Derive over-voltage protection at or below the former and under-voltage protection at or above the latter after accounting for BMS measurement uncertainty, cell imbalance, response delay, release behavior and the selected operating reserve. Treat these as outer test-reference constraints; apply any stricter manufacturer pack-design/application limits and system qualification. They do not by themselves establish deployable protection settings, the 90% regeneration policy or a normal operating floor. Read back per-cell units/ranges, trip and release values/delays; test controlled approach and recovery without crossing qualified cell limits. |
| Current protection | The 5P cell basis gives ideal continuous ceilings of 10 A charging (including regeneration) and 40 A discharge. Derive charge/discharge over-current thresholds and delays so actual current, sensing/shunt error, imbalance, transient duration and protection delay cannot exceed the qualified cell-bank envelope. They must remain protective backstops to lower operating regulation. The family 50 A version's 70 A discharge-trip example does not meet this derivation; do not assert that the board can configure a 10 A charge trip or a 40 A discharge trip until its actual ranges, resolution and shunt scale are read back and tested. |
| Temperature protection | Permit charging only within 0…45°C and discharge only within −10…60°C at the applicable cell surface. Derive early prohibit/trip and release thresholds, hysteresis and delays inside those envelopes using sensor placement, measurement uncertainty, thermal lag and response time. The family examples of charge −10/65°C and discharge −20/75°C are rejected for this pack. Verify each enabled probe's identity, range and fault behavior; unobserved cell conditions remain an independent coverage limitation. |
| Required functions | Enable and verify available cell-voltage, charge-current, discharge-current, temperature and charge/discharge-path monitoring/protection required by the derived configuration. Capture parameter readback and provoke bounded representative conditions to verify indication, path action, release and no bypass. Unsupported, disabled or unobservable protection cannot be credited and requires separate system coverage. |
| Balancing | Configure and verify balancing across all 14 groups within the qualified cell envelope. Derive balance start, differential, stop and any temperature/current inhibit from a qualified cell-voltage/SOC relation and supported parameter units; do not copy the family 3.9 V/15 mV example without that evidence. |
| SOC calibration | Establish full and empty anchors by controlled, qualified actual-charge/capacity evidence consistent with the cell-voltage and protection derivation. Record the calibration method, capacity value, reference conditions and resulting uncertainty. Regeneration 90%, low-charge 20/10% and display mapping remain vehicle policies; none remaps to BMS full, empty, or a voltage threshold. |
| Configuration acceptance | Before final configuration qualification, identify the installed board/firmware/configuration, read back every available parameter with its unit, scale, range, resolution and write/read persistence, and compare it with this table. Test thresholds, delays, releases, count, capacity, balancing and enabled protections against independent references. No setting has been written, and no final configuration is qualified by this document. |

The unresolved engineering inputs are actual BMS parameter availability/ranges/resolution and shunt scale; voltage/current/temperature measurement error; sensor placement and response; cell imbalance; switching and protection delays/releases; supported balancing behavior; and controlled calibration evidence. They determine final margins and delays; neither the owner nor this family datasheet supplies deployable values for them.

## UART information contract

JBD reads use `DD A5 command length payload checksum 77`; responses use `DD command status length payload checksum 77`. The 16-bit two's-complement checksum covers command/length/payload on requests and status/length/payload on responses; multibyte values are high-byte first.

| Read | Data relevant to this project |
|---|---|
| `0x03` | Pack voltage, signed current, capacity/RSOC, version, balance/protection/FET status, series count and temperatures |
| `0x04` | Series-group voltages in mV; 14 groups imply 28 payload bytes |
| `0x05` | Device/version identification string; supplement with actual configuration identity |

Voltage uses 10 mV. Current is signed, positive charging, negative discharging, normally 10 mA; V12 FET-status bit 7 selects 100 mA and corresponding 100 mAh capacity scaling instead of 10 mAh. Temperature conversion is `(raw − 2731)/10 °C`. Qualify supported lengths/extensions and scaling; translated examples contain inconsistencies.

Fourteen voltage channels observe five-cell parallel groups, not 70 individual cell conditions. Two temperature channels do not establish complete cell/motor/inverter thermal coverage. Readback provides observations, not proof of trustworthy actual SOC or complete fault detection. The software must qualify framing, checksum, status, count, range, consistency and freshness before dependent use. Polling and timeout budgets remain to be derived. No automatic parameter writing, MOS override, Bluetooth, optional history or generic heating command is selected by this UART decision.

## Consequences and remaining acceptance

- **SOC and regenerative acceptance:** retain the vehicle regeneration 90%, low-charge 20/10% and display mapping. Voltage cannot be linearly mapped to these SOC percentages. Qualify BMS capacity configuration, RSOC calibration and uncertainty against actual charge evidence; a vendor full-voltage calibration procedure does not authorize vehicle operation beyond the qualified envelope.
- **Temperature:** The owner revised riding ambient to −10…+40°C, resolving the prior −15°C cell-discharge conflict. Outdoor storage retains −15…+40°C. Qualify actual cell temperatures and margins under `OI-040`/`WS-OI-019`; ambient permission alone does not grant torque after cold-soaked storage. Regeneration is cell charging and requires the charging envelope even when propulsion discharge is permissible. Existing recognized-temperature-fault inhibition/restart rules and ordinary charge-acceptance restrictions retain their distinct definitions; derive recognition boundaries, thermal margins and coverage.
- **Current and protection:** operating regulation must enforce the qualified pack envelope. The BMS is a protective backstop, not the commanded-current regulator. Validate configured thresholds, tolerances, delays, cell-group supervision and credible failure coverage; source defaults and automatic trip recovery do not satisfy vehicle fault policy. BMS recovery alone cannot clear a latched riding fault.
- **Power and UART:** assess switched-negative reference shifts, communication power/return paths and B+ exposure in riding, regeneration, shutdown, service and BMS-disconnect states. Resolve the manufacturer's UART warning through a qualified interface arrangement; do not prescribe an unverified isolation circuit. Assess generated energy when the BMS removes the charge path, and protection-limited HMI/light continuity.
- **Energy, mass and fit:** initial fit is owner-confirmed. For current planning, [PD DV-012](../../README.md#dv-012--payload-and-vehicle-mass-budget) assigns 5 kg to the complete pack (3.50 kg cell bound plus 1.50 kg assumed ancillary allowance) under [DEC-MAS-001](../Requirements/DEC-001_Decisions_and_Open_Issues.md#dec-mas-001). Actual complete mass remains unmeasured; retention, enclosure/contact weather protection, thermal duty and measured interval energy remain open. For illustration only, constant nominal voltage gives `844.2 × 0.60 = 506.52 Wh`, or `7.236 Wh/km` over 70 km before allowances. Actual `E20–80` requires a qualified curve/measurement; this illustration proves neither range success nor failure. Use the fixed pack for feasibility assessment instead of reopening cell selection.
- **Motor compatibility:** the reported, unqualified `9.5 rpm/V` gives 478.8 rpm at 50.4 V and 558.6 rpm at 58.8 V. With a merely nominal 16-inch circumference these are approximately 36.7 and 42.8 km/h at no load. The [conditional motor/energy assessment](../Requirements/System_Requirements/Vehicle_Qualification.md#fixed-pack-energy-and-motor-feasibility) gives about 55.0 V equivalent no-load reference for 40 km/h, subject to the same unqualified voltage/control convention. Loaded 40 km/h at no more than 80% actual SOC remains unresolved; neither the reported 70 V motor rating nor pack operation demonstrates it. No boost or field-weakening solution is selected (`OI-014`, `OI-018`, `OI-043`, `OI-054`).

### Storage load estimate

The BMS family lists maximum running/sleep/shutdown currents of 10 mA / 1.5 mA / 50 µA. Multiplication by duration gives the following **BMS-only** charge consumption; actual firmware/mode, other loads, self-discharge and normal-full entry tolerance remain unverified.

| Continuous mode assumption | 168 h fitted duty | 672 h detached duty |
|---|---:|---:|
| Running | 1.680 Ah | 6.720 Ah |
| Sleeping | 0.252 Ah | 1.008 Ah |
| Shutdown | 0.0084 Ah | 0.0336 Ah |

Communication can prevent sleep. Documented shutdown entry involves undervoltage and is not selected as a normal storage strategy. The 672 h dry indoor 15–30°C requirement and fitted outdoor duty use [DEC-STO-002](../Requirements/DEC-001_Decisions_and_Open_Issues.md#dec-sto-002) normal-full 80% entry. [Storage acceptance](../Requirements/System_Requirements/Environment_and_Storage.md#storage-charge-budget-and-acceptance) combines all loads, self-discharge, uncertainty and independent protection limits. Polling strategy must be assessed in that budget.

Closure is assigned to existing `OI-012/040/041/043/045/046/048/053/054/057/061–063` and `WS-OI-005/018/019`. Record actual unit/configuration, compatible UART electrical arrangement, captured/readback evidence and coupled qualification results before their dependent integration/acceptance gates. Mass uses the owner-authorized planning assumptions until complete-vehicle mass acceptance / mass-dependent physical qualification; an immediate gutted-scooter measurement is not required. No duplicate selection exercise or detailed internal BMS design is required.
