# CurrentConsumptionCoordination

`LE-CURRENT-CONSUMPTION-COORDINATION` is the shared battery-current budget authority composed within RidingControl. It consumes qualified battery operating limits and signed pack current, and publishes directional traction current budgets and lighting availability. Its ports and auxiliary-reserve calibration are defined in [CurrentConsumptionCoordination.sysml](CurrentConsumptionCoordination.sysml).

The SysML file contains the native requirement declarations for shared budgeting, reserve-based allocation, and budget supervision. Numerical reserve calibration and validation remain governed by those declarations; this overview does not add values or acceptance claims.
