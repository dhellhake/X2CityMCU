# X2CityMCU specification

This directory separates reusable System-on-Module facts from decisions that belong to this application and its carrier board.

## Navigation

| Area | Purpose |
|---|---|
| [FET1061-S SoM reference](som/fet1061-s.md) | Reusable module mechanics, power limits, pad map, mux options, reset behavior, and vendor-source reconciliation. |
| [Application specification](application/README.md) | Project-board wiring, peripheral assignments, clock choice, debug/boot workflow, power domains, and verification obligations. |

## Document boundary

- A fact about the FET1061-S itself belongs in the SoM reference.
- A choice made for this carrier, firmware, connector, or external system belongs under `application/`.
- A proposed or unresolved design choice is labelled as such. It must not be treated as established hardware merely because it appears in this specification.
- Each design fact should have one canonical description. Other pages link to it instead of copying it.

The historical top-level SoM filename remains as a short compatibility link for existing bookmarks.
