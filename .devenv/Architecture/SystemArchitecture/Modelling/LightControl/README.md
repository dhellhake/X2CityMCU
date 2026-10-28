# LightControl

`LE-LIGHT-CONTROL` composes software [LightModeSelection](Decomposition/LightModeSelection_Requirements.md) (`LE-LIGHT-POLICY`) and logical hardware [LightActuation](Decomposition/LightActuation_Requirements.md) (`LE-LAMP-HW`). `LightPower` (`LE-LIGHT-POWER`) is contained within LightActuation and owns its lighting supply. [Canonical system requirements](LightControl_Requirements.md) remain the end-to-end contract; vehicle electrical power is an external boundary supplied through LE-ENERGY-PATH.

```mermaid
flowchart TD
    EPCS[LE-EPCS] -->|contains| LC[LightControl]
    LC -->|software| S[LightModeSelection]
    LC -->|hardware| A[LightActuation]
    A -->|contains| P[LightPower]
    CCC[CurrentConsumptionCoordination] -->|lighting availability| RC[RidingControl]
    RC -->|lighting availability| LC
    LC -->|lighting availability| A
    A -->|lighting availability| P
```

EnergyPath → Energy → LightControl → LightActuation → LightPower; LightPower supplies LightActuation internally. CurrentConsumptionCoordination → RidingControl → LightControl → LightActuation → LightPower carries qualified lighting availability as a budget-derived operational constraint on physical supply, independently of LightModeSelection. Qualified available neither proves physical supply nor lamp output.

| Port | Meaning | Owner |
| --- | --- | --- |
| `runningLightStateIn` | Qualified HMI normal-light request; its retained request is internal selection state | LightModeSelection |
| `brakeLeverStateIn` | Qualified mechanical lever State/Qualification composite from MechanicalBrakeDetection | LightModeSelection |
| `electricalBrakingStateIn` | Actual motor-braking state from Traction | LightModeSelection |
| `lightModesOut` / `lightModesIn` | Front On/Off and rear Off/Dim/Full intent | LightModeSelection → LightActuation |
| `lightingAvailabilityIn` | Qualified budget-derived operational constraint; delegated through LightControl and LightActuation to LightPower | CurrentConsumptionCoordination → RidingControl → LightControl → LightActuation → LightPower |
| `vehicleElectricalPowerIn` | Distributed vehicle electrical energy at the LightControl boundary | LE-ENERGY-PATH → LightControl |
| `vehicleElectricalPowerOut` | Electrical energy delegated by LE-ENERGY-PATH toward lighting supply | LE-ENERGY-PATH |
| `lightingPowerOut` | Lighting power provided by LightPower to the owned actuation path | LightPower → LightActuation |
| `frontIlluminationOut` / `rearIlluminationOut` | Physical illumination results | LightActuation |

Qualified unavailable overrides all physical illumination, including rear Full and startup fallback. In the live powered actuation context a known restriction persists through loss of qualification until qualified available returns; then current selected modes apply subject to supply and protection. Without a known restriction, unqualified availability alone preserves existing fallback and fault continuity where power and protection permit.

Actual electrical braking includes rollback retardation and constant-speed descent motor braking; it is not merely negative torque or battery charging. Physical continuity remains conditional on protection under [AUX-001](../../../../Requirements/System_Requirements/Auxiliary_Continuity.md#req-veh-aux-001).
