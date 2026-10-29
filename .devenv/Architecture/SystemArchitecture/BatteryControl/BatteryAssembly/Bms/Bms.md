# Bms

`LE-BMS` represents the supplied JBD BMS assembly, including opaque vendor firmware. The model assigns it cell-bank monitoring, balancing, and protective switching, with physical cell-power, pack-power, series-group-tap, and available thermal-observation connections. Read-only UART request and telemetry ports connect the BMS to BatterySupervision. See [Bms.sysml](Bms.sysml) for the boundary and native allocation requirements.

Project software reads selected information through the modeled UART interface; the interface has no modeled write, override, or charger command. Detailed protocol and qualification evidence is documented with BatterySupervision in [BatterySupervision.md](../../BatterySupervision/BatterySupervision.md).

## BMS interface and protection basis

The NMC family specification describes 7–14S, 20–50 A options, common-port negative-side switching, passive balancing, one internal and one external temperature channel. Heating, charge-current regulation and secondary protection are unsupported. Board operation is specified at −20…75°C; this does not widen the cell envelope.

### Owner-reported app temperature readings (2026-10-26)

| Selected `0x03` order | App label | Owner-confirmed mapping / observation |
|---|---|---|
| 1 | MOS | MOS-labelled temperature; the app reading is similar to T1. The physical sensor location/role is not confirmed. |
| 2 | T1 | T1-labelled temperature; the app reading is similar to MOS. The physical sensor location/role is not confirmed. |
| 3 | T2 | Cell-pack probe placed at the pack centre; use this selected reading as `Tcell` for both current curves after field qualification. |

The owner confirms this mapping for the selected BMS: exactly three temperature values in Basic (`0x03`), ordered MOS, T1, T2. T2 is the cell-pack probe placed at pack centre; BMSIF-008 owns decoding and qualification of this selected-unit mapping, which does not claim a universal JBD protocol layout. Physical meanings of MOS and T1 remain unconfirmed. Measurement accuracy, coverage, lag, calibration, applicable thermal-trip thresholds and installed wire/schema acceptance remain open evidence. The family reference's one internal and one external channel describes family capability and does not change the selected three-value mapping.

UART: **9600 baud, 8 data bits, no parity, one stop bit**. J5, HY2.0-4P: **1 GND; 2 RXD; 3 TXD; 4 B+**, directions at the BMS. B+ is pack potential. Connector orientation, logic levels and ground reference require actual-unit verification. The non-isolated UART carries a manufacturer warning against energy-source/load communication. Integration must resolve that restriction without bypassing protection; a direct controller connection is not qualified.

Family example temperature trips (charge −10/65°C; discharge −20/75°C) exceed cell permissions. They are not acceptable project operating limits or evidence of actual settings. Typical balancing starts at 3.9 V with 15 mV difference, about 40 mA pulsed. Verify effective balancing without exceeding the qualified cell envelope.

## BMS configuration derivation

The selected unit shall be configured and accepted as a **14-series lithium-ion/NMC 35E 5P pack**. This table derives constraints and the evidence needed to turn them into settings; it is a configuration derivation, with final programmable values dependent on the listed evidence and supported parameters.

| Configuration subject | Derived constraint and acceptance evidence |
|---|---|
| Series count and chemistry | Set/read back 14 series groups and the NMC/lithium-ion parameter family. Confirm cell-order readback against all 14 physical groups and prove the selected board/firmware accepts this chemistry/count; a generic 7–14S family label is insufficient. |
| Capacity parameter | `5 × 3.350 Ah = 16.75 Ah` is the initial configuration basis, explicitly provisional. Qualify the full-reference charge capacity corresponding to 100% actual SOC using a justified model/calibration procedure and recorded temperature/current conditions; update the parameter from that evidence. Do not configure the smaller usable operating interval as full BMS capacity. The 16.25 Ah 1C rating is a different test basis, not an interchangeable setting. |
| Cell-voltage protection | The cell data give 4.20 V charge-test upper reference and 2.65 V discharge-test cutoff per group (`58.8 V` and `37.1 V` for 14S). Derive over-voltage protection at or below the former and under-voltage protection at or above the latter after accounting for BMS measurement uncertainty, cell imbalance, response delay, release behavior and the selected operating reserve. Treat these as outer test-reference constraints; apply any stricter manufacturer pack-design/application limits and system qualification. They do not by themselves establish deployable protection settings, the 90% regeneration policy or a normal operating floor. Read back per-cell units/ranges, trip and release values/delays; test controlled approach and recovery without crossing qualified cell limits. |
| Current protection | The 5P cell basis gives ideal continuous ceilings of 10 A charging (including regeneration) and 40 A discharge. Select BMS charge/discharge over-current thresholds, delays and releases conservatively within the qualified cell-bank and assembled-pack capabilities, accounting for actual current, sensing/shunt error, imbalance, transient duration and protection response. Commission, read back and validate these settings before protection acceptance. This physical BMS trip is distinct from normal host regulation of BatterySupervision operating budgets; the 40/10 A ideal figures do not become software clamps. The family 50 A version's 70 A discharge-trip example does not meet this derivation; do not assert that the board can configure a 10 A charge trip or a 40 A discharge trip until its actual ranges, resolution and shunt scale are read back and tested. |
| Temperature protection | Permit charging only within 0…45°C and discharge only within −10…60°C at the applicable cell surface. Derive early prohibit/trip and release thresholds, hysteresis and delays inside those envelopes using sensor placement, measurement uncertainty, thermal lag and response time. The family examples of charge −10/65°C and discharge −20/75°C are rejected for this pack. Verify each enabled probe's identity, range and fault behavior; unobserved cell conditions remain an independent coverage limitation. |
| Required functions | Enable and verify available cell-voltage, charge-current, discharge-current, temperature and charge/discharge-path monitoring/protection required by the derived configuration. Capture parameter readback and provoke bounded representative conditions to verify indication, path action, release and no bypass. Unsupported, disabled or unobservable protection cannot be credited and requires separate system coverage. |
| Balancing | Configure and verify balancing across all 14 groups within the qualified cell envelope. Derive balance start, differential, stop and any temperature/current inhibit from a qualified cell-voltage/SOC relation and supported parameter units; do not copy the family 3.9 V/15 mV example without that evidence. |
| SOC calibration | Establish full and empty anchors by controlled, qualified actual-charge/capacity evidence consistent with the cell-voltage and protection derivation. Record the calibration method, capacity value, reference conditions and resulting uncertainty. SOC supports display/reporting and 10–80% range qualification; it does not gate normal current capability. The qualified temperature/group-voltage capability curves provide the longevity protection intent; use canonical `V_l`/`V_h` assignments in [BatterySupervision.voltageDeratingCalibration](../../BatterySupervision/BatterySupervision.sysml), subject to product validation. Validate voltage/SOC correspondence without treating 10%/90% as exact control endpoints. |
| Configuration acceptance | Before final configuration qualification, identify the installed board/firmware/configuration, commission and read back every available parameter with its unit, scale, range, resolution and write/read persistence, and compare it with this table. Physically validate over-current and other protection thresholds, delays and releases, count, capacity, balancing and enabled protections against independent references. No setting has yet been qualified by this document. |

The unresolved engineering inputs are actual BMS parameter availability/ranges/resolution and shunt scale; voltage/current/temperature measurement error; sensor placement and response; cell imbalance; switching and protection delays/releases; supported balancing behavior; and controlled calibration evidence. They determine final margins and delays; neither the owner nor this family datasheet supplies deployable values for them.

## Specification

- [BmsIdentityAndConfiguration](Specification/BmsIdentityAndConfiguration.sysml)
- [BmsMeasurementSources](Specification/BmsMeasurementSources.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)
