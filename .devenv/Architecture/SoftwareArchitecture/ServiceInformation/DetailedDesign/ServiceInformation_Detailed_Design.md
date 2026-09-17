# DD-002 — Battery protection and BMS software-unit design: ServiceInformation

## SC-SERVICE-INFO

### Units, interfaces and executable order

`U-SERVICE-INFO-COLLECT` receives producer-tagged publications through `SW-I-008` and reset/platform context through `SW-I-009`. It retains no source value across a producer-context change. It preserves source availability, validity, freshness and qualification; it does not replace unavailable battery current with the HMI's 0 A fallback or infer actual output from a command.

`U-SERVICE-INFO-SNAPSHOT` forms an atomic current readout keyed to service task and source contexts. It includes available identity/effective configuration, check state, current recognized conditions, restriction/inhibition reasons, selected indication, requested versus qualified actual output, relevant battery data and vehicle-session state. It labels incomplete/pass/fail separately and reports each unavailable part explicitly. The snapshot is read-only and has no control return path.

Execution is: receive producer publication/context event → withdraw affected old-context entries → update current source records → assemble on service request or publication boundary. A producer restart affects only that producer's old-context entries. A BMS reset/recovery may change BMS data freshness but cannot change riding latches. The service component's own restart clears only its cached snapshot and does not release an unaffected domain's inhibition.

### State, reset and invariants

State is a volatile cache indexed by producer and producer context. It contains no persistent fault history, calibration write staging or session state. Required operational retention remains owned by the originating policy and is reported as an observed state with its qualification.

Invariants: every record retains producer/context and qualification; selected report/mode cannot conceal other current observations supplied for service; unavailable remains unavailable; service reads cannot clear inhibition, establish a charging session, or grant torque or regenerative-charge permission; and a BMS path bit or zero command never establishes isolation.

### Acceptance scenarios

Use source stubs to cover unavailable/stale publications, incomplete/pass/fail checks, simultaneous faults, producer-context change, BMS-only reset/recovery, vehicle riding reset, and service-component-only reset. Verify source values against independent physical evidence at system level. Access transport, electrical/power conditions, source coverage, update bounds and service procedures remain acceptance gates.
