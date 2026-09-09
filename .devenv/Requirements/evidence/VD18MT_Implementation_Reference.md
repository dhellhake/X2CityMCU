# VD18MT Historical Implementation Reference

**Status:** Approved and released evidence reference, Revision 1.0. Historical observations retain their stated limits; this document is not implementation or vehicle qualification.

**Revision:** 1.0, 2026-09-09

**Purpose:** Preserve historical implementation details, source provenance and qualification limits supporting the Item Definition & Requirements workstream. The [project-independent VD18MT interface reference](../../VD18MT/VD18MT_Tongsheng_UART_Interface.md) describes the device interface. Current vehicle behavior is recorded in the [decisions and open issues](../DEC-001_Decisions_and_Open_Issues.md), [requirements](../REQ-001_Requirements.md) and [item definition](../ID-001_Item_Definition.md). This reference does not create requirements or allocate their implementation.

## Project reference and source authority

The [frozen Project Definition PD-001 Rev1.0](../../../PD-001_Project_Definition_Rev1.0.md), released 2026-09-05, preserves the historical source authority. [PD-001 Rev1.1](../../../PD-001_Project_Definition_Rev1.1.md), reviewed and released 2026-09-09, is now the current upstream baseline, also reproduced in the [root README](../../../README.md); its release does not alter this historical VD18MT evidence. [PD-001 Rev1.0 §10.4](../../../PD-001_Project_Definition_Rev1.0.md#104-existing-vd18mt-test-implementation) establishes the prior successful VD18MT implementation as a confirmed project input. The owner identified **`30fcc91f2066eb2d2e554e1c2776fe32549a0752`**, dated 2026-08-31, subject “Implemented Brake and Accelerator Input,” and directed that its tested and proven behavior be adopted into the interface documentation. This source-authority decision is traced as **DEC-REF-001** in the working decision record.

The source is in historical Git path **`src/vd18mt`**. All source paths and line anchors below refer to that commit, not to files necessarily present in the current working tree. The independently maintained interface reference describes the device interface; this note records how the project uses that reference and the qualifications on its evidence.

The source uses `VD18MT*` names for display-to-controller data and `VT8MT*` names for controller-to-display data. These are historical Rust names for the two directions of the same VD18MT interface. They do not identify different selected devices.

The implementation replaced earlier generic Tongsheng/TSDZ2 assumptions for assist selection, battery indication, current, wheel-speed encoding, error mapping and controller transmission scheduling. Basic protocol discovery is not reopened. Further work concerns missing capabilities, the identified manual discrepancy, selected-unit correlation and final verification under PD-001 §10.4.

## Relationship to decisions and open issues

Owner behavior decisions formerly held in `VD18MT_Project_Notes.md` are consolidated in the [working decision record](../DEC-001_Decisions_and_Open_Issues.md) and expressed as [requirements](../REQ-001_Requirements.md). Relevant decision traces are **DEC-LVL-001** (profiles 0–5), **DEC-LVL-002** (requested and active levels), **DEC-LVL-003** (VD18MT authority and retention), **DEC-BRK-002** (brake-release resumption) and **DEC-HMI-001** (no indication of reduced or unavailable regeneration). These are vehicle choices, not inherent display behavior or evidence that the historical UART module implements them.

The [working open-issue register](../DEC-001_Decisions_and_Open_Issues.md) holds the remaining integration scope, with links to **PD-001 OI-026–OI-032**. It covers selected-unit and manual correlation, electrical characterization, connector qualification, vehicle HMI functions and settings, battery presentation, level and power integration, timing, message freshness and communication-fault response. The error-presentation correlation below is retained as evidence for **OI-026 / WS-OI-008**.

No error value has been assigned to normal regenerative-braking limitation. The interface reference defines no arbitrary-text command. A historical enum name alone does not establish an available or required vehicle indication. The decoder's initial `Level0` value, before any valid received request, is local initialization rather than a received display request or evidence of a permitted vehicle default.

### Selected connector and electrical provenance

The selected **five-pin display connector** and its verified pinout come from [PD-001 Rev1.0 §11.4](../../../PD-001_Project_Definition_Rev1.0.md#114-vd18mt-hmi-interface), not from the historical parser. The independent interface reference carries the pinout table. The generic six-pin Tongsheng motor-side connector is a different interface location: its wire colors and brake-cutoff conductor must not be substituted for the selected five-pin display connection.

PD-001 §11.4 and the historical communication record establish the display-side 5 V UART logic class. The historical controller used a 3.3 V/5 V level interface, with MCU allocation and circuit details belonging to that implementation. Those details do not allocate the final vehicle hardware or establish final electrical qualification. The historical record leaves circuit ratings, margins, loading, power-off behavior and back-powering qualification open.

### Error-mapping discrepancy

At the reference commit, `src/vd18mt/frame.rs:51` defines `VT8MTErrorCode`, and `src/vd18mt/mod.rs:296` serializes its numeric value directly into controller-to-display byte 5. The adopted reference has no enum value for `0x08` or communication fault `0x30`.

The [VD18MT TS-UART manual, p. 20](https://device.report/m/8eadeca26f13eecf8b0f56e22f02b41615385c72a112dff4c1755f3e408e53fd.pdf) gives **displayed** error descriptions that differ from those Rust labels. It does not establish their raw UART encoding. The independent interface reference preserves both sets without equating them. Correlation of manual variant, historical meanings and actual selected-unit display behavior remains associated with **OI-026**.

The earlier claims that displayed code 30 establishes raw UART byte `0x30`, or proves that the display generates that byte locally, are unsupported by the implementation and manual. Communication-loss timing and undefined-code presentation remain unresolved.

## Historical implementation choices

This section preserves host-software behavior separately from device encoding. These choices are evidence about the tested implementation, not requirements imposed by the VD18MT or a selection of the final firmware design.

### Initialization, field validation and numeric helpers

| Historical source at the reference commit | Implementation behavior and its boundary |
|---|---|
| `src/vd18mt/frame.rs:103` | Initial transmit data is empty battery indication, no status flags, zero current, no error and zero speed. Its encoded frame is `43 00 00 00 00 00 07 07 51`. These initial values do not declare actual battery state or vehicle readiness. |
| `src/vd18mt/frame.rs:165` | Initial receive data is Level 0, headlight false, wheel-size setting zero and speed-limit setting zero. This is local initialization, not a received display selection. |
| `src/vd18mt/mod.rs:187` | A complete frame must pass checksum, exact assist-value matching after removal of headlight bit `0x01`, and wheel-size range validation before replacing decoded data. Accepted wheel settings are 4–35 inclusive. |
| `src/vd18mt/mod.rs:218` | Bytes 2 and 4 are ignored without a zero check. The speed-limit byte is passed through without a range check or a legacy fallback. This describes parser behavior rather than an accepted vehicle speed requirement. |
| `src/vd18mt/frame.rs:142` | All assist values or combinations outside the six adopted mappings are rejected after masking the headlight bit. In particular, `0x20` alone or combined with an otherwise valid selection is rejected. This limits parser coverage; it does not prove that the device cannot issue walk requests. |
| `src/vd18mt/frame.rs:70` | The current helper accepts 0–51 A, asserts on inputs outside that range, and quantizes using `floor(current_A × 5 + 0.5)`. For example, 12.3 A becomes raw 62 (`0x3E`), representing 12.4 A. API assertions and rounding are software choices. The representable field range is not a vehicle current limit, and the reference defines no negative-current encoding for regeneration. |
| `src/vd18mt/mod.rs:296` | The encoder transmits byte 3 as zero and current in byte 4. This replaces the earlier generic torque-tare/torque-actual interpretation for the established reference. |
| `src/vd18mt/mod.rs:322` | The speed helper takes unsigned 16-bit integer (`u16`) `SpeedKmh` and the latest accepted setting named `WheelDiameterInches`. The source comment assigns 0.04 m circumference per setting unit. It rounds the computed millisecond period to the nearest integer, clamps it to 1–65535 and changes a moving value equal to `0x0707` to `0x0706` to avoid the stationary sentinel. Zero speed or an invalid/uninitialized wheel setting produces `0x0707`. Validation, fallback, rounding, clamping and the sentinel-collision guard are software choices. |

The historical wheel-speed helper computes `numerator = wheel_setting × 4 × 3600`, `denominator = speed_kmh × 100`, then `floor((numerator + floor(denominator / 2)) / denominator)` before the guard behavior above. Wheel setting 26 at 25 km/h produces period 150 (`0x0096`). The Rust name `WheelDiameterInches` does not override the source's display-setting conversion or establish the scooter's physical dimensions. The earlier generic 0.00204 seconds-per-unit conversion and legacy LCD cutoff are not used by this reference.

The battery symbols `Empty`, `OneSixth` through `FiveSixths`, and `Full`, plus the named status/error symbols, are implementation labels retained for traceability. Their wire definitions are in the independent interface reference; assigning vehicle conditions to them remains project work.

### Receive handling and scheduling

- `src/vd18mt/mod.rs:102`: `0x59` starts a seven-byte candidate frame. An embedded `0x59` in an otherwise valid frame remains data.
- `src/vd18mt/mod.rs:229`: after a rejected complete frame, the parser searches backward for the last embedded `0x59` and retains that suffix as a possible next frame.
- `src/vd18mt/mod.rs:155`: UART parity, framing, noise or overrun errors discard the partial frame and the associated error-marked byte. The step processes at most 16 queued receive bytes, using the step timestamp for processed bytes.
- `src/vd18mt/mod.rs:127`: receive processing occurs before expiry checking. A remaining partial frame is discarded when more than 20,000 microseconds have elapsed since its last processed byte. Invalid traffic or partial-frame expiry leaves the latest accepted data and timestamp unchanged.
- The 20 ms threshold is a parser timeout based on processing timestamps. It is not an on-wire inter-byte tolerance, display transmission period, complete-message freshness limit or vehicle communication-loss policy. The historical communication record at `.devenv/specification/application/communication-interfaces.md:44` leaves a consumer freshness limit to application requirements.
- `src/vd18mt/mod.rs:25`, `:262` and `:360`: nominal controller transmission period is 100 ms (10 frames/s). The first protocol step can initiate the first frame; missed periods are skipped. This is host scheduling behavior, not a measured device timing tolerance or mandatory hardware constraint. The code does not specify a fixed display-to-controller transmission period.
- Completion of UART transmit-queue acceptance increments the implementation's transmitted-frame count. It is not an acknowledgement that the display received the frame. The frame format provides no acknowledgement or sequence counter.
- `src/mcu/vd18mtcommunication/mod.rs:13` and `:146` provide the historical 9600 bit/s, 8N1 communication binding. `.devenv/specification/application/communication-interfaces.md:33` records the historical 10 ms shared protocol task and interrupt-driven receive/transmit servicing; that task allocation is not part of the device specification.

## Historical evidence and qualification limits

The owner's confirmation and PD-001 establish the implementation as tested and proven in use. The available artifacts provide the narrower evidence described here. This transfer is not a new test execution, proof of every indication/error presentation, or final vehicle qualification.

### Host-test artifacts

The historical `.devenv/vd18mt-host-tests.rs` contains six tests:

| Source line | Coverage |
|---:|---|
| 129 | Valid Level 2/headlight request decoding. |
| 151 | Bad checksum rejection and resynchronization at an embedded start byte. |
| 171 | UART error discarding a partial protocol frame. |
| 201 | Partial-frame expiry after more than 20 ms. |
| 213 | Periodic initial/default transmission at 100 ms. |
| 233 | Application-data encoding, current quantization and speed encoding. |

`.devenv/test-vd18mt.ps1` is the historical host-test runner. Test source and a runner identify coverage; they do not by themselves establish execution on the selected physical display. The encoded application-data example from the test is `43 08 0C 00 3E 00 96 00 2B`; the valid Level 2/headlight request example is `59 41 00 1A 00 19 CD`.

### Recorded HIL observation

`.devenv/specification/application/communication-interfaces.md:46` records a 2026-08-27 Atmel-ICE RAM-debug HIL run with one uninterrupted scheduler interval containing **332 valid received display frames** and **419 controller frames accepted and drained by LPUART2**, with zero reported invalid frames, checksum failures, parser errors, UART errors or overruns.

The recorded latest received frame was `59 10 00 10 00 1E 97`. The intentionally neutral transmitted frame was `43 00 00 00 00 00 07 07 51`. That run **did not include external TX waveform capture or far-end reception proof**. The source's counts must not be described as proof that 419 frames were received by the display.

### Remaining qualification

The historical `.devenv/specification/application/verification.md:33` identifies physical UART configuration, timing, level, loading and device-behavior checks. Lines 35–38 retain qualification of the VD18MT level-interface circuit and power-off/back-powering behavior; sustained traffic, parser/error/overflow and disconnect/reconnect behavior; external capture of both physical directions; and consumer freshness rejection before requests affect safety-relevant behavior. The successful development HIL run alone does not close that scope.

The confirmed five-pin interface still requires the selected-unit electrical and environmental characterization tracked by PD-001 OI-027–OI-031. None of the historical board allocation, nominal software timing, available host-test source or recorded HIL counters establishes final vehicle hardware or system qualification.

## Source and transfer history

The independent interface reference retains device frame definitions and their technical comparison sources. Project provenance retained here is:

- [PD-001 Rev1.0](../../../PD-001_Project_Definition_Rev1.0.md): §10.4, §11.4 and OI-026–OI-032.
- Owner direction to adopt the implementation at `30fcc91f2066eb2d2e554e1c2776fe32549a0752` as tested and proven in use.
- Historical source, test and verification artifacts at that commit, with exact paths and line anchors above.
- [APT / Varstrom VD18MT TS-UART manual](https://device.report/m/8eadeca26f13eecf8b0f56e22f02b41615385c72a112dff4c1755f3e408e53fd.pdf), used for the displayed-error comparison; [generic TSDZ2 serial communication](https://github.com/hurzhurz/tsdz2/blob/master/serial-communication.md) and [motor-side connector pinout](https://github.com/hurzhurz/tsdz2/blob/master/pinout.md), retained as the origins of earlier generic assumptions.

All entries below occurred on **2026-09-06** in the Item Definition & Requirements workstream, in the order shown:

1. Adopted the owner-confirmed implementation as the project interface reference; corrected assist, battery, current, speed, timing and error definitions; adopted the PD-001 five-pin connector; retained parser coverage, evidence and the manual discrepancy.
2. Revised HMI indication, profile numbering, level authority and brake-release decisions. Their current disposition and superseded choices are preserved in the working decision record under **DEC-HMI-001**, **DEC-LVL-001**, **DEC-LVL-003** and **DEC-BRK-002**.
3. At the owner's direction, separated project-specific material into root `VD18MT_Project_Notes.md` so that the existing VD18MT interface document could serve as a project-independent datasheet-like reference.
4. At the owner's direction, consolidated workstream material in `.devenv/Requirements/`. Relocated the historical evidence to this reference and replaced the transfer note's duplicated behavior and issue lists with links to the working item definition, requirements and decision register. The released Project Definition is unchanged by this transfer; no tests were executed as part of the relocation.
