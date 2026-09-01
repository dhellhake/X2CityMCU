# DRV8300DRGE-EVM Integration Reference

This directory contains only the vendor artifacts needed to develop and bring
up motor-control firmware for an FK743M2-IIT6 V1.1 connected to a fixed
DRV8300DRGE-EVM. It is not a PCB redesign or manufacturing package.

## Retained Vendor Artifacts

- [Electrical schematic](<Project Outputs/MD030A(001)_Sch.PDF>) covers the
  host interface, DRV8300 configuration, three half bridges, current and
  voltage sensing, temperature sensing, Hall interface and board power.
- [Assembly drawing](<Project Outputs/MD030A(001)_Assy.PDF>) identifies
  component, jumper, connector and test-point locations.
- [Variant-001 bill of materials](<Project Outputs/MD030A(001)_BOM.xls>)
  records the fitted/DNP configuration and exact component values.

The schematic and populated BOM describe the actual EVM implementation. Use
the assembly drawing when locating configuration parts and measurement points
during bring-up.

## Authoritative Device Documentation

- [DRV8300DRGE-EVM user's guide](https://www.ti.com/lit/pdf/slvubv6)
- [DRV8300 product page and datasheet](https://www.ti.com/product/DRV8300)

The TI documents remain authoritative for operating limits, startup behavior
and device-level electrical requirements. Project-specific signal assignments,
timing and safety behavior belong in this repository's hardware/software
interface specification.

## Deliberately Excluded

Editable Altium sources, caches, release jobs, duplicate archives, Gerber,
ODB++, drill, pick-and-place, PCB-layer and validation outputs are excluded.
They are not needed to write or test firmware against the assembled EVM. If
redesign or manufacture of the EVM enters scope, obtain the complete design
package from Texas Instruments rather than treating this reduced directory as
a fabrication release.
