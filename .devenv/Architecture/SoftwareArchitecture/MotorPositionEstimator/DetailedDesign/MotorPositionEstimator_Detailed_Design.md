# DD-001 — Software unit design: MotorPositionEstimator

`U-MOTOR-POSITION-ESTIMATOR` is the sole final electrical-angle owner. It accepts
qualified Hall code/sector/bounds and transition evidence from `U-HALL-POSITION`.
At rest, a qualified static sector may produce a bounded electrical position. Between
accepted edges it may interpolate within its immutable compiled error bounds. It never
treats static Hall, missing transitions, a command or PWM state as signed electrical
speed, vehicle motion or standstill.

The observer branch accepts same-operation qualified phase current and the separate
qualified applied-winding-voltage record. It can assist the Hall-based estimate only
when the motor model and voltage evidence are observable. Low back-EMF or an
unavailable observer-voltage source with otherwise acceptable Hall error produces a
Hall-only estimate, not a false fault. A contradiction, lost mandatory Hall evidence
or recognized required-source failure makes the affected position unavailable and
publishes health for the established common fault policy.

The caller supplies one fixed `ExecutionTime` immediately before the bounded
invocation. The unit evaluates its own contributor age and timeout rules against that
time while retaining source/transition times. Calibration is immutable, validated at
startup against build/static initialization, and any validation failure withholds the
dependent estimate. There is no sensorless fallback, forced alignment, start routine,
diagnostic/service output or PWM write.
