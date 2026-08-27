# Throttle analog input

[Application index](README.md) · [SoM pin map](../som/fet1061-s.md#complete-100-pad-pinout)

**Status:** proposed analog front end and sampling concept. It is not production-qualified hardware.

## Channel allocation

| Function | ADC route | SoM pad | Acquisition |
|---|---|---:|---|
| Hall-throttle output | `ADC2_IN2` | 91 | 16,000 samples/s, paired with the supply-sense sample |
| Hall-throttle 5 V sense | `ADC2_IN3` | 92 | 16,000 samples/s, immediately adjacent to the throttle sample |

The second channel permits a ratiometric result instead of assuming an exact 5 V excitation. Accumulate 16 sample pairs for each nominal 1 ms command update, then apply only a validated digital filter.

## Proposed per-channel network

Use the same passive network on both inputs:

```text
external signal ── 2.00 kΩ ──┬── ADC input
                             ├── 2.00 kΩ ── quiet GND
                             └── 1.0 µF ─── quiet GND
```

Nominal behavior:

- DC gain: 0.5.
- Thevenin resistance seen by the ADC: 1.0 kΩ.
- RC pole: approximately 159 Hz.
- A 5 V input becomes nominally 2.5 V at the ADC node.

Neither ADC input may be driven directly from a 5 V throttle signal. The final design still needs input fault protection whose leakage and capacitance do not invalidate accuracy or acquisition settling.

## Required diagnostics

The application must define and validate at least:

- Plausible throttle and excitation ranges, including startup and shutdown behavior.
- Ratiometric calculation and behavior when the excitation measurement is too small or invalid.
- Open circuit, short to ground, short to excitation, and channel cross-short detection.
- Maximum accepted mismatch and rate of change.
- ADC saturation, stale data, timing loss, and scheduler/program-flow failure response.
- A safe output behavior before a valid sample history exists and after any detected fault.

## Hardware verification

Measure divider tolerance, bias/error, source impedance, ADC acquisition settling, filter response, noise, protection leakage, and fault voltages on production-intent hardware across supply and temperature. Keep analog return currents away from high-current battery, ESC, LED, and digital switching paths.

## Related documents

- [Clocking](clocking.md)
- [Verification](verification.md)
