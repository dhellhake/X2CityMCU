# RidingPolicy

`LE-RIDING-POLICY` is the policy component inside RidingControl. It consumes qualified operation requests, runtime readiness, rider inputs, motion and motor-position information, battery status and operating limits, traction condition and output evidence, and rider-settings requests. It also consumes the independently qualified traction current budgets from CurrentConsumptionCoordination. See [RidingPolicy.sysml](RidingPolicy.sysml) for the complete modeled boundary.

The modeled outputs include riding authority, signed wheel-torque demand, selected fault indication, and compute sleep request. The component boundary is defined in [RidingPolicy.sysml](RidingPolicy.sysml); its canonical abstract software requirement allocation is maintained in [Settings and control policy](../../../../Requirements/Abstract_Software_Requirements/Settings_and_Control_Policy.md).
