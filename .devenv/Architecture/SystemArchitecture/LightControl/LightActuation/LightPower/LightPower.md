# LightPower

`LE-LIGHT-POWER` receives distributed vehicle electrical power and the qualified lighting-availability constraint, then provides the modeled lighting-power boundary to its owning LightActuation component. See [LightPower.sysml](LightPower.sysml) for the ports and model description.

The model specifies no separate converter, circuit, sensing, or control-state implementation. Its power contract is subject to EnergyPath and the modeled lighting availability input.
