# Cells

`LE-CELLS` is the fixed owner-built 14S5P Samsung INR18650-35E cell bank. It provides physical cell-bank power, taps for all fourteen series groups, and available pack thermal observations to the supplied BMS. [Cells.sysml](Cells.sysml) defines the modeled items and ports.

The model does not imply per-cell sensing, a specified number or placement of thermal probes, or project software implementation. The canonical fixed-bank composition requirement is declared in the SysML file.

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
| Ideal continuous current ceilings | Discharge `5 × 8 = 40 A`; regenerative acceptance `5 × 2 = 10 A`. These are ideal cell-bank design references, not vehicle-host current clamps; select conservative operating curves within actual cell/BMS/assembly capabilities and validate physical BMS protection |
| Charge reference currents | Standard `5 × 1.7 = 8.5 A`; cycle-life test `5 × 1.02 = 5.1 A`; neither is a selected operating command |
| Bare-cell mass bound | `70 × 50 g = 3.50 kg`; excludes BMS, conductors, insulation and connectors. Complete pack mass is unmeasured; enclosure and mechanical retention are outside project design scope. |

No 65 A pulse capability is established. Battery DC current is not motor phase current or wheel torque. The BMS's 50 A designation is not a 50 A regenerative allowance or evidence that its installed protection is configured or qualified. The 40/10 A ideal cell-bank figures remain design references; physical pack-current limits must be allocated to configured and validated BMS protection.

## Specification

- [CellBankComposition](Specification/CellBankComposition.sysml)
- [RequirementSet](Specification/RequirementSet.sysml)
