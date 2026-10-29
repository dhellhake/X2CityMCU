# Traction

`LE-TRACTION` groups TractionControl and the sibling MotorPositionEstimation component. Its part composition, physical boundaries, and delegated signal flows are defined in [Traction.sysml](Traction.sysml).

TractionControl receives riding authority and wheel-torque demand, and connects to EnergyPath for traction electrical power. MotorPositionEstimation receives Hall signals and motor phase-electrical observations directly; its qualified position and phase-current outputs feed TractionControl. Traction also exposes the modeled qualified vehicle motion, actual traction output, electrical-braking state, temperature, fast DC-link voltage, and traction-condition evidence. The model keeps measurement ownership with MotorPositionEstimation even where physical hardware may be shared.
