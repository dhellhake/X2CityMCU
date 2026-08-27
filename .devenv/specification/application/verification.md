# Application verification

[Application index](README.md) · [SoM production checklist](../som/fet1061-s.md#production-use-verification)

This is the application-level release checklist. Passing a software build or a debugger session does not close these hardware and system obligations.

## Hardware identity and power

- Record the fitted SoM PCB revision, MCU suffix/silicon revision, QSPI marking/capacity, and applicable errata.
- Freeze the controller reference domain and the meaning of every `BAT+`, `BAT-`, `12V`, and `GND` connector contact.
- Validate normal, BMS-disconnected, brownout, reverse/transient, and externally powered interface states.
- Prove that UARTs, the ESC 3.3 V output, debugger VTG, and other connectors cannot back-power an unpowered SoM/carrier.
- Verify isolation-side supplies, ground separation, creepage/clearance, and fault containment after the isolation architecture is selected.

## Clock and execution

- Measure the actual 600 MHz core, 600 MHz AHB, 150 MHz IPG, and 24 MHz LPUART roots from independent observables.
- Stress representative units at the selected 1.250 V DCDC target across intended supply, temperature, and workload corners.
- Confirm that every time base and baud calculation uses the programmed clock tree.
- Re-run the complete qualification if core voltage or any divider changes; retain the option to return production firmware to 528 MHz.
- Verify scheduler-only RTWDOG supervision, including the intentional interval from watchdog start to the first valid service and reset after a supervised task failure.

## Boot, programming, and debug

- Exercise cold power-on and `POR_B` reset into QSPI without a debugger attached.
- Read back/compare a programmed release image and prove the 4 MiB flash assumptions on the fitted part.
- Confirm `BOOT_MODE0/1` sampled levels and QSPI selection on production-intent boards.
- Exercise RAM debug, QSPI program-and-debug, and release attach independently.
- Verify the Atmel-ICE VTG pin is sense-only and that attaching the probe does not bridge an isolation boundary.

## Interfaces

- Confirm each UART pin mux and input daisy, direction, format, baud error, signal level, idle state, cable loading, and external-device behavior.
- Run sustained BMS traffic with error injection, framing faults, disconnect/reconnect, full queues, and scheduler load.
- Qualify the ESC and VD18MT routes after their transceiver/isolation hardware is fixed.
- Record connector part numbers, keying, contact numbering, harness-side mirrored view, and all currently undocumented contacts.

## Operator inputs and safety-relevant output

- Verify the paired ADC acquisition and all electrical tolerances/fault cases listed in [Throttle input](throttle-input.md).
- Verify all four brake-handle states and every hard open/short signature listed in [Brake-handle input](brake-input.md).
- Qualify the exact brake-switch contact at the selected minimum voltage/current load across life, contamination, vibration, and temperature before freezing the common resistance scale.
- Sweep brake-loop series resistance and parallel leakage through every code boundary; document any fault values that alias a valid handle state.
- Inject handle resistor opens/shorts, opens in every switch-bypass lead/trace/joint, ADC saturation, and intermittent harness faults; confirm the latent-path limitation, propulsion inhibition, the separately selected vehicle reaction, and every residual-fault claim.
- Validate that immediate propulsion inhibition is itself safe in every relevant vehicle state; do not assume torque removal and active braking are interchangeable reactions.
- Demonstrate that missing, late, stuck, or implausible cyclic-task results cannot leave the board through a communication path as a valid command.
- Confirm startup and boot stalls remain outside the claimed scheduler-only supervision scope and cannot emit safety-relevant commands.

## Evidence

Archive the tested commit, release ELF/binary hashes, module/board identities, tool versions, measurements, logs, and pass/fail criteria together. Open items in this checklist block production release even if the current development board appears functional.
