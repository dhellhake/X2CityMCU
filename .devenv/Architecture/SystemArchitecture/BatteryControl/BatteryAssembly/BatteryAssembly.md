# BatteryAssembly
## Battery assembly

`LE-BATTERY-ASSEMBLY` is the removable pack composite containing the fixed Cells bank and supplied Bms. [BatteryAssembly.sysml](BatteryAssembly.sysml) defines their power, fourteen-series-group tap, thermal-observation, and protected pack-power connections.

The modeled boundary provides battery power to BatteryControl. The assembly integration and child composition requirements are held in the Specification packages of BatteryAssembly, Cells and Bms. BatteryControl and BatterySupervision own their respective additional integration and protocol documentation.

The former **BAT-001 — Selected pack and BMS** (Draft 0.1, 2026-09-10) is integrated here and in the linked [Cells](Cells/Cells.md), [Bms](Bms/Bms.md), and [BatterySupervision](../BatterySupervision/BatterySupervision.md) documents. [PD §10.8](../../../../../README.md#108-built-battery-and-selected-bms) and [DEC-BAT-002](../../../DEC-001_Decisions_and_Open_Issues.md#dec-bat-002) establish selection. Manufacturer ratings, calculations and owner observations have different evidence status. No qualification test was performed for that reference.

## Fixed inputs and provenance

The owner reports an already fabricated, working pack, initially fitted to the supplied BMW bay: **14 series groups of five parallel Samsung INR18650-35E cells, 70 cells total**. The owner explicitly confirmed the cell model, revised minimum riding ambient to −10°C, and selected **JBD SP14S004P14S50A**, using its **UART** for system interaction. The owner confirms the installed BMS is JBD SP14S004 hardware V1.0 with firmware 3.2. It is connected to the working pack, but its configuration remains incomplete and programmed values have not been recorded. The earlier SP14S004P14S50A designation records the selected 14S50A variant provenance; exact installed hardware and firmware are now known. Cell/topology/BMS selection and the reported initial bay fit are supplied facts; this report supplies no measured pack mass, E/E thermal or electrical protection acceptance and does not qualify mechanical bay fit or retention. Configuration values are engineering derivations to qualify, not owner-supplied decisions.

| Source | Scope and qualification |
|---|---|
| [Samsung SDI INR18650-35E specification, V1.1, 2015-07-09](https://www.nkon.nl/novat/amfile/file/download/file/495/product/5627/) | Manufacturer-authored document hosted by NKON; §3 supplies the cell ratings below. Pack-design guidance and test conditions also apply. |
| [JBD SP14S004 NMC family specification, A03, 2024-09-19](https://cdn-files.myshopline.com/file/store/1777805905342/jbd-SP14S004-7s-14s-20a-50a-nmc-smart-bms-datasheet.pdf) | Manufacturer-hosted family reference for the installed SP14S004 hardware V1.0; it does not establish firmware-specific support or configuration. Use this lithium-ion version, not the different LiFePO4 parameter table. |
| [JBD universal UART protocol, V12](https://cdn-files.myshopline.com/file/store/1777805905342/jbd-bms-universal-protocol-rs485-rs232-uart-communication-specification-pdf.pdf) | Manufacturer protocol reference; commands, extensions and scaling need selected-unit qualification. Generic protocol support does not prove board support. |

## Consequences and remaining acceptance

- **SOC and regenerative acceptance:** use qualified temperature/group-voltage capability curves for normal current limits, including zero discharge at/below canonical `V_l` and zero charge at/above canonical `V_h` (see linked BatterySupervision calibration; subject to product validation). The 10%/90% values are longevity contexts, not SOC comparisons or independent ceilings. Low-charge 0x01 follows the qualified `V_l` boundary; actual SOC alone does not set it. Qualify BMS capacity configuration, RSOC calibration and uncertainty against actual charge evidence; a vendor full-voltage calibration procedure does not authorize vehicle operation beyond the qualified envelope.
- **Temperature:** The owner revised riding ambient to −10…+40°C, resolving the prior −15°C cell-discharge conflict. Outdoor storage retains −15…+40°C. Qualify actual cell temperatures and margins under `OI-040`/`WS-OI-019`; ambient permission alone does not grant torque after cold-soaked storage. Regeneration is cell charging and requires the charging envelope even when propulsion discharge is permissible. Existing recognized-temperature-fault inhibition/restart rules and ordinary charge-acceptance restrictions retain their distinct definitions; derive recognition boundaries, thermal margins and coverage.
- **Current and protection:** operating regulation must enforce the qualified pack envelope. The BMS is a protective backstop, not the commanded-current regulator. Validate configured thresholds, tolerances, delays, cell-group supervision and credible failure coverage; source defaults and automatic trip recovery do not satisfy vehicle fault policy. BMS recovery alone cannot clear a latched riding fault.
- **Power and UART:** assess switched-negative reference shifts, communication power/return paths and B+ exposure in riding, regeneration, shutdown, service and BMS-disconnect states. Resolve the manufacturer's UART warning through a qualified interface arrangement; do not prescribe an unverified isolation circuit. Assess generated energy when the BMS removes the charge path, and protection-limited HMI/light continuity.
- **Energy and supplied mass context:** initial bay fit is owner-confirmed as a supplied platform fact, without project mechanical fit or retention acceptance. The 3.50 kg cell mass is a calculated constituent bound; total pack mass remains unmeasured. Use the supplied 130 kg duty input for system energy/performance analysis, not as a project vehicle mass design target. Electrical contact/weather exposure and E/E thermal duty remain open. For illustration only, constant nominal voltage gives `844.2 × 0.70 = 590.94 Wh`, or `8.442 Wh/km` over 70 km before allowances. Actual `E10–80` requires a qualified curve/measurement; this illustration proves neither range success nor failure. Use the fixed pack for feasibility assessment instead of reopening cell selection.
- **Motor compatibility:** the reported, unqualified `9.5 rpm/V` gives 478.8 rpm at 50.4 V and 558.6 rpm at 58.8 V. With a merely nominal 16-inch circumference these are approximately 36.7 and 42.8 km/h at no load. The [conditional motor/energy assessment](../../X2CityMCU.md#context-vehicle-qualification-fixed-pack-energy-and-motor-feasibility) gives about 55.0 V equivalent no-load reference for 40 km/h, subject to the same unqualified voltage/control convention. Loaded 40 km/h at no more than 80% actual SOC remains unresolved; neither the reported 70 V motor rating nor pack operation demonstrates it. No boost or field-weakening solution is selected (`OI-014`, `OI-018`, `OI-043`, `OI-054`).

### Storage load estimate

The BMS family lists maximum running/sleep/shutdown currents of 10 mA / 1.5 mA / 50 µA. Multiplication by duration gives the following **BMS-only** charge consumption; actual firmware/mode, other loads, self-discharge and normal-full entry tolerance remain unverified.

| Continuous mode assumption | 168 h fitted duty | 672 h detached duty |
|---|---:|---:|
| Running | 1.680 Ah | 6.720 Ah |
| Sleeping | 0.252 Ah | 1.008 Ah |
| Shutdown | 0.0084 Ah | 0.0336 Ah |

Communication can prevent sleep. Documented shutdown entry involves undervoltage and is not selected as a normal storage strategy. The 672 h dry indoor 15–30°C requirement and fitted outdoor duty use [DEC-STO-002](../../../DEC-001_Decisions_and_Open_Issues.md#dec-sto-002) normal-full 80% entry. [Storage acceptance](../../X2CityMCU.md#context-environment-and-storage-storage-charge-budget-and-acceptance) combines all loads, self-discharge, uncertainty and independent protection limits. Polling strategy must be assessed in that budget.

Closure is assigned to existing `OI-040/041/043/045/046/048/053/054/057/061–063` and `WS-OI-005/018/019`. Record actual unit/configuration, compatible UART electrical arrangement, captured/readback evidence and coupled qualification results before their dependent integration/acceptance gates. Use supplied vehicle mass/load context for E/E performance and energy assessment; this pack record assigns no vehicle mass ceiling or mechanical mass/retention qualification. No duplicate selection exercise or detailed internal BMS design is required.

## Specification

- [AssemblyIntegration](Specification/AssemblyIntegration.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)
