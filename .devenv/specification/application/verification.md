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
- Record and qualify the fitted VD18MT 3.3 V/5 V level-interface circuit, including display-TX voltage, margins, loading, power-off behavior, and back-powering; the successful development HIL test alone does not close this item.
- Run sustained simultaneous BMS and VD18MT traffic under scheduler load. For VD18MT, verify 9600 8N1 framing, both directions, checksum rejection, parser resynchronization, partial-frame timeout, UART errors, queue overflow, disconnect/reconnect, and the 100 ms transmit period.
- Capture the level-shifted VD18MT RX and TX waveforms externally to close signal amplitude, baud timing, and far-end reception; debugger counters alone do not prove the complete physical TX path.
- Verify that a VD18MT consumer rejects stale display requests after a defined timeout before any request can affect safety-relevant behavior.
- Capture `ESC PWR` and both UART directions externally. Verify the selected 1,000,000-bit/s 8N1 timing, levels, directions, idle state, level-shifter/isolation behavior, cable loading, and powered/unpowered back-powering.
- Qualify sustained 1 ms current-command and 10 ms telemetry operation at 1,000,000 bit/s. Measure response latency and loss under the final scheduler and motor load without weakening the 20 ms response timeout or 30 ms telemetry-freshness bound.
- Qualify only the explicit firmware 6.02 / `75_300_R2` profile. Exercise unsupported firmware versions and hardware names, invalid CRC/framing, partial frames, stale telemetry, response timeout, unexpected or late replies, queue pressure, disconnect/reconnect, and simultaneous scheduler load; every failure must remain fail-closed.
- On a mechanically safe unloaded rig, verify the 1 ms zero fallback, 5 ms current-request lease, firmware/telemetry/fault gating, request clearing across faults and power cycles, the selected application current ceiling, and that nonzero current is impossible until that ceiling is explicitly configured.
- Measure worst-case task completion, watchdog-service margin, UART queue loading, and every task stack watermark while real ESC replies are active. The 57.569 s zero-current development run established loss-free 1,000,000-bit/s communication on the current bench setup, but did not establish production margins across motor load, supply, temperature, harness, or unit variation.
- Record connector part numbers, keying, contact numbering, harness-side mirrored view, and all currently undocumented contacts.

## Operator inputs and safety-relevant output

- Verify the implemented shared four-channel ADC2 frame, accelerator endpoint calibration, all throttle positions, and every electrical tolerance/fault case listed in [Throttle input](throttle-input.md).
- Verify all four brake-handle states and every hard open/short signature listed in [Brake-handle input](brake-input.md).
- Qualify the exact brake-switch contact at the selected minimum voltage/current load across life, contamination, vibration, and temperature before freezing the common resistance scale.
- Sweep brake-loop series resistance and parallel leakage through every code boundary; document any fault values that alias a valid handle state.
- Inject handle resistor opens/shorts, opens in every switch-bypass lead/trace/joint, ADC saturation, and intermittent harness faults; confirm the latent-path limitation, propulsion inhibition, the separately selected vehicle reaction, and every residual-fault claim.
- Validate that immediate propulsion inhibition is itself safe in every relevant vehicle state; do not assume torque removal and active braking are interchangeable reactions.
- Demonstrate that missing, late, stuck, or implausible cyclic-task results cannot leave the board through a communication path as a valid command.
- Confirm startup and boot stalls remain outside the claimed scheduler-only supervision scope and cannot emit safety-relevant commands.

## Evidence

Archive the tested commit, release ELF/binary hashes, module/board identities, tool versions, measurements, logs, and pass/fail criteria together. Open items in this checklist block production release even if the current development board appears functional.
