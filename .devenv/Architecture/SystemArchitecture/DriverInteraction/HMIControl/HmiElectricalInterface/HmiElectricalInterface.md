# HmiElectricalInterface
## HMI electrical interface requirements

**Type:** Abstract Hardware Requirement. **Target:** `LE-HMI-ELECTRICAL`. **Status:** Draft.

This leaf owns the vehicle-side VD18MT display-supply, UART compatibility and power-lock conditioning boundary. The fixed five-wire physical bundle comprises common ground, display supply, two UART signals and pin 5 switched power lock. Pin 5's asserted on/wake signal is conditioned to a level compatible with the selected MCU wake input and connected to `LE-COMPUTE-HW` under [REQ-SYS-HMIE-002](Specification/Requirements.sysml). While awake, this leaf publishes `HmiPowerLockObservation` state and integrity under [REQ-SYS-CMPH-002](Specification/Requirements.sysml); HMI information processing owns its qualified On/Off interpretation. The intended physical Inactive-to-Off mapping remains Draft pending selected-unit compatibility and qualification; it is not a measured pin-5 fact. Wake or Off recognition neither grants drive authorization nor substitutes for the common startup guard. HMI UART loss alone shall not create Off. This leaf does not implement an MCU-controlled UART on/off function or claim that an outgoing report was acknowledged by the display.


Exact electrical values, selected conditioning/protection circuit, MCU wake pin and sleep mode, finite wake/restore bounds, and the selected-unit deassertion qualification remain open derivation and qualification work. Inactive-to-Off recognition is Draft; selected-unit compatibility is not established by the raw pin-5 reference.

## Physical refinement

The [colocated physical connection model](HmiElectricalInterface.sysml) retains `X2CityHardware_Vd18mtElectricalConnection` as the physical refinement of the logical boundary: its five-wire endpoints, conductor types, flows and connection context describe the supplied display and vehicle harness. The logical contract and existing component allocations remain distinct. Device connector and electrical evidence is documented in the [project-independent VD18MT reference](../HMIControl.md#vd18mt-device-reference-vd18mt-tongsheng-uart-interface).

## Specification

- [Requirements](Specification/Requirements.sysml)
