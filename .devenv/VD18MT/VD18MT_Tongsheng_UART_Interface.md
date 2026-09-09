# VD18MT Tongsheng UART Interface

**Device:** APT/Varstrom VD18MT (MiniTouch), Tongsheng UART variant

**Status:** Released unofficial technical reference based on tested interface definitions and manufacturer documentation

**Revision:** 1.0, 2026-09-09

## Scope and Applicability

This reference describes the connector, serial frames and encoded values of the documented five-pin VD18MT variant. The exact hardware and firmware revision associated with the tested definitions has not been identified. Compatibility with other VD18MT variants is not established.

The wire definitions below come from a tested communication implementation. Manufacturer documentation supplies the displayed error descriptions compared in §5. Electrical limits and behaviors not established by these sources are identified in §6.

## 1. Physical Interface and Timing

| Parameter | Value / characterization |
|---|---|
| Interface | Asynchronous UART, separate TX and RX |
| Baud rate | 9600 bit/s |
| Format | 8 data bits, no parity, 1 stop bit (8N1) |
| UART logic class | 5 V; exact input/output thresholds are unspecified |
| Controller → Display update interval | 100 ms (10 frames/s) is a known working operating point; the permitted interval range is not characterized |
| Display → Controller update interval | Not characterized for the documented variant |

### Five-pin display connector

Directions are from the display perspective. This pinout applies to the documented five-pin variant.

| Pin | Wire colour | Function | Direction / interface |
|---:|---|---|---|
| 1 | Black | Ground | Common reference / return |
| 2 | Green | Display RX | Into display; 5 V UART |
| 3 | Yellow | Battery positive `P+` | Into display; battery-voltage supply |
| 4 | White | Display TX | Out of display; 5 V UART |
| 5 | Red | Power lock / switched `P+` | Display power-control function; switched battery-voltage interface |

Supply and power-lock conductors carry battery-voltage-class signals. UART conductors use the 5 V logic class. Exact continuous supply limits, power-lock voltage/drop and switching characteristics, unpowered UART behavior and connector identity are not characterized for the documented variant.

### Manufacturer specifications

The [manufacturer manual, p. 2](https://device.report/m/8eadeca26f13eecf8b0f56e22f02b41615385c72a112dff4c1755f3e408e53fd.pdf) lists these device-family specifications. Correlation with the exact hardware revision of the documented five-pin variant remains unresolved.

| Characteristic | Manufacturer specification |
|---|---|
| Low-voltage version | Nominal systems: 24, 36, 48 or 52 V |
| High-voltage version | Nominal systems: 48, 52, 60 or 72 V |
| Current output to controller | Maximum 1 A |
| Leakage when off | Less than 5 µA |
| Operating temperature | −15 to +40 °C |
| Storage temperature | −20 to +50 °C |
| Enclosure ingress rating | IP67 |

Nominal system voltages do not specify the exact permissible continuous input-voltage limits. The manual's enclosure rating does not identify a mating connector or its sealing conditions.

## 2. Controller → Display Frame

**Length:** 9 bytes

**Start byte:** `0x43`

| Byte | Field | Definition |
|---:|---|---|
| 0 | Start | `0x43` |
| 1 | Battery indication | Encoded indication state |
| 2 | Controller status | Status bitfield |
| 3 | Fixed field | `0x00` in the documented encoding; other meanings are unspecified |
| 4 | Battery current | Unsigned current in 0.2 A units |
| 5 | Error | Wire-code mapping in §5 |
| 6 | Wheel period L | Low byte of encoded period |
| 7 | Wheel period H | High byte of encoded period |
| 8 | Checksum | 8-bit additive checksum; see §4 |

### Status byte

| Mask | Meaning |
|---|---|
| `0x00` | No flags |
| `0x01` | Battery undervoltage |
| `0x02` | Unspecified |
| `0x04` | Controller working |
| `0x08` | Pedal activity |
| `0x10`, `0x20`, `0x40`, `0x80` | Unspecified |

Defined flags can be combined by bitwise OR.

### Battery indication

| Value | Indication state |
|---|---|
| `0x00` | Empty |
| `0x02` | One sixth |
| `0x04` | Two sixths |
| `0x06` | Three sixths |
| `0x08` | Four sixths |
| `0x0A` | Five sixths |
| `0x0C` | Full |

These values select indication states. No battery-voltage or state-of-charge thresholds are defined by this encoding table.

### Battery current

The one-byte unsigned field represents 0–51 A in 0.2 A increments:

```text
represented_current_A = current_raw × 0.2
```

For example, `0x3E` (62) represents 12.4 A. The documented field has no signed negative-current representation.

### Wheel speed

The period field is a little-endian unsigned 16-bit value:

```text
period_raw = SpdL | (SpdH << 8)
```

The documented conversion uses milliseconds and **0.04 m circumference per display wheel-size setting unit**:

```text
encoding_circumference_m = wheel_setting × 0.04
period_ms = period_raw

speed_kmh ≈ encoding_circumference_m × 3600 / period_ms
          = 144 × wheel_setting / period_raw
```

This relation applies to nonzero period values other than the stationary sentinel. The scaling describes the display encoding; the wheel-size field is labelled in inches in the display interface.

**Stationary sentinel:** `0x0707` (1799), transmitted as `07 07`. This value indicates stationary speed rather than a moving-wheel period. The meaning of period zero is unspecified.

As an encoding example, wheel setting 26 and speed 25 km/h give a calculated period of 149.76 ms. An integer period of 150 (`0x0096`) represents this value to the nearest millisecond.

### Encoded examples

Empty battery indication, no status flags, zero current, no error and stationary speed:

```text
43 00 00 00 00 00 07 07 51
```

Four-sixths battery indication, controller-working and pedal-activity flags, 12.4 A, no error and period 150 ms:

```text
43 08 0C 00 3E 00 96 00 2B
```

## 3. Display → Controller Frame

**Length:** 7 bytes

**Start byte:** `0x59`

| Byte | Field | Definition |
|---:|---|---|
| 0 | Start | `0x59` |
| 1 | Control | Assist selection and headlight bit |
| 2 | Unused | `0x00` in the documented examples; no meaning established |
| 3 | Wheel size | Display wheel-size setting, labelled in inches |
| 4 | Unused | `0x00` in the documented examples; no meaning established |
| 5 | Speed-limit setting | km/h; valid range and special values are unspecified |
| 6 | Checksum | 8-bit additive checksum |

### Assist selection and headlight

Bit `0x01` indicates a headlight request. Removing this bit leaves the assist-selection value:

| Assist value | Display selection |
|---|---|
| `0x10` | Level 0 |
| `0x80` | Level 1 |
| `0x40` | Level 2 |
| `0x02` | Level 3 |
| `0x04` | Level 4 |
| `0x08` | Level 5 |

The headlight bit can coexist with each listed selection. For example, `0x41` indicates Level 2 and headlight requested.

The level values communicate the display selection; this table does not define motor torque or braking behavior.

### Other control values

Generic [Tongsheng protocol observations](https://github.com/hurzhurz/tsdz2/blob/master/serial-communication.md) describe `0x20` as a walk-assist flag. Its wire behavior and combinations for the documented VD18MT variant are not established here. Unlisted control values have no definition in this reference.

### Wheel-size setting

The [VD18MT manual, p. 16](https://device.report/m/8eadeca26f13eecf8b0f56e22f02b41615385c72a112dff4c1755f3e408e53fd.pdf) describes a wheel-size setting range of 4–35 inches. The setting is carried in byte 3; the associated speed-encoding scale is given in §2.

### Encoded example

Level 2, headlight requested, wheel setting 26 and speed-limit setting 25 km/h:

```text
59 41 00 1A 00 19 CD
```

## 4. Checksum

For both frame types, the checksum includes the start byte and all subsequent bytes before the checksum:

```text
checksum = (sum of all bytes before checksum) & 0xFF
```

For example, with hexadecimal values:

```text
59 + 41 + 00 + 1A + 00 + 19 = CD
=> 59 41 00 1A 00 19 CD
```

These fixed-length frame formats contain no CRC, escaping, length field, acknowledgement or sequence counter. A start-byte value can also occur as data within a frame.

## 5. Error Codes

### Documented wire-code mapping

The following meanings are taken from the tested interface definitions for controller-to-display byte 5.

| Wire value | Meaning |
|---|---|
| `0x00` | No error |
| `0x01` | Under- or overvoltage |
| `0x02` | Torque sensor error |
| `0x03` | Speed sensor error |
| `0x04` | Motor blocked |
| `0x05` | Unspecified |
| `0x06` | Overtemperature |
| `0x07` | Battery overcurrent |
| `0x09` | EEPROM check error |
| `0x0A` | Throttle sensor error |
| `0x0B` | Unspecified |
| `0x0D` | Cadence sensor error |

Unlisted values, including `0x08` and `0x30`, have no established meaning in this wire-code mapping.

### Manufacturer's displayed error codes

The [VD18MT TS-UART manual, p. 20](https://device.report/m/8eadeca26f13eecf8b0f56e22f02b41615385c72a112dff4c1755f3e408e53fd.pdf) lists these **displayed codes**:

| Displayed code | Manual description |
|---|---|
| 01 | Controller temperature protection |
| 02 | Short-circuit protection |
| 04 | Throttle fault |
| 05 | Three-phase power fault |
| 06 | Torque sensor signal fault |
| 07 | Motor fault |
| 08 | Battery low |
| 09 | Overvoltage protection |
| 30 | Communication fault |

The manual does not specify UART values for these displayed codes. Its descriptions differ from the documented wire-code meanings. Correspondence between the two tables and applicability to specific hardware/firmware variants remain unresolved.

Displayed code 30 alone does not establish raw byte `0x30`, local error-generation behavior or a communication-loss timeout.

## 6. Unspecified Characteristics

| Area | Information not established for the documented variant |
|---|---|
| Identification | Exact hardware/firmware revision and compatibility across variants |
| Supply | Permissible continuous voltage range, brownout behavior and active/off-state current |
| Power lock | Output voltage/drop and switching behavior; applicability of the manual's output-current/leakage ratings to the exact hardware revision |
| UART electrical behavior | Input/output thresholds, loading limits and unpowered behavior |
| Connector | Exact connector family, mating details and sealing |
| Timing | Permitted message intervals, tolerances and display communication-loss timeout |
| Extended display data | Encoding of any additional power, brake, range, regeneration-status or arbitrary-text functions |
| Error presentation | Wire-code/display-code correspondence and response to undefined values |
| Settings | Assist-selection retention across power cycles and any controller-writable assist-selection mechanism |

## Sources

- [APT / Varstrom VD18MT TS-UART User Manual](https://device.report/m/8eadeca26f13eecf8b0f56e22f02b41615385c72a112dff4c1755f3e408e53fd.pdf): display functions, settings and displayed error descriptions.
- [hurzhurz — TSDZ2 serial communication](https://github.com/hurzhurz/tsdz2/blob/master/serial-communication.md): generic Tongsheng protocol observations; variant-specific mappings in this reference take precedence over the generic level and telemetry interpretations.
- [hurzhurz — TSDZ2 connector pinout](https://github.com/hurzhurz/tsdz2/blob/master/pinout.md): background on the separate motor-side connector; it is not the five-pin display pinout in §1.
