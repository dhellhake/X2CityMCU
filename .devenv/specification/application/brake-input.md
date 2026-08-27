# Brake-handle input

[Application index](README.md) · [SoM ADC pin map](../som/fet1061-s.md#complete-100-pad-pinout) · [Application verification](verification.md)

**Status:** proposed passive two-wire encoding and diagnostic concept. The nominal state code is complete, but the absolute resistance/current scale, production thresholds, external-fault protection, and the system safety argument remain open. The exact switch contact specification and vehicle fault envelope are blocking inputs.

The state-encoding and nominal measurement network contains only switches, resistors, capacitors, and optional protection diodes. It needs no op-amp, comparator, current source, or handle-side electronics; the MCU uses two ADC inputs. This does **not** yet prove that a passive protection network can survive every required vehicle-harness fault. Production protection must be selected after that electrical fault envelope is defined.

## Design summary

Each handle is converted into a polarity-independent two-terminal network containing a permanent series resistor followed by the parallel combination of the normally-open switch and a release-state resistor.

Closing a switch adds conductance rather than shorting the loop. Since parallel conductances add, the four handle states become distinct. The PCB applies a symmetric source/return bias across the loop and measures both conductor voltages, giving additional common-mode diagnostics.

## Refined requirements

| ID | Proposed requirement | Verification intent |
|---|---|---|
| `BRK-F-01` | In a fault-free circuit, distinguish `released`, `left pressed`, `right pressed`, and `both pressed`. | Exercise all four combinations across tolerance and temperature. |
| `BRK-F-02` | Preserve the existing two-wire trunk and passive Y connection. Handle networks must be polarity independent. | Reverse either handle branch and repeat the state test. |
| `BRK-D-01` | Detect a hard open in either trunk conductor and loss of either complete handle branch, independent of the remaining handle's state. | Open each conductor before and after the Y junction. |
| `BRK-D-02` | Detect a hard short between the two brake conductors. | Short the connector and each branch in turn. |
| `BRK-D-03` | Detect each conductor shorted to local ground or the local 3.3 V excitation rail, provided the fault remains within the qualified protection envelope. | Inject each fault through a current-limited fixture. |
| `BRK-D-04` | Treat every sample outside a validated state window, stale acquisition, and excessive paired-channel disagreement as an immediate invalid input. Record all events; latch a service fault only after a validated persistence/repetition criterion. | Sweep resistance continuously and inject intermittent connections and contact bounce. |
| `BRK-S-01` | A valid pressed code or any invalid/stale input must remove propulsion permission. Only a valid pressed code may establish brake-handle actuation and identity; a fault leaves both unknown. | Fault-injection test at every application operating state. |
| `BRK-S-02` | Do not grant propulsion permission until the input has completed startup plausibility checks. | Boot with each state and each hard fault applied. |
| `BRK-S-03` | The vehicle hazard analysis must validate that immediate propulsion inhibition is safe in every relevant vehicle state and select whether an input fault additionally commands active/regenerative braking, passive coast, or another reaction. The decoder must not silently equate `fault` with a physical handle press. | Verify the selected reaction for each vehicle operating state. |
| `BRK-T-01` | Initial design target: remove propulsion permission on the first credible pressed or invalid sample and confirm a valid pressed identity within 10 ms. Re-enabling propulsion may be debounced for at least 20 ms. | Measure end-to-end timing with the production scheduler and filters. |
| `BRK-E-01` | The final design must define allowable cable resistance, insulation resistance, switch contact resistance, the switch's minimum applicable voltage/current load, EMC transients, and shorts to every adjacent vehicle supply. | Derive limits from the switch, harness, and vehicle electrical specifications. |
| `BRK-V-01` | Production state windows must include component tolerance, temperature drift, ADC error, reference mismatch, leakage, cable/contact resistance, and aging with explicit guard bands. | Worst-case calculation, Monte Carlo analysis, and hardware characterization. |

`BRK-D-01` through `BRK-D-03` deliberately describe hard opens and shorts. An arbitrary partial resistance can equal another valid two-terminal code; the [architectural limits](#architectural-limits) explain why unrestricted “detect any damaged cable” is not achievable with this passive two-wire interface.

## Handle modification

### Electrical topology

Modify both handles according to this topology. The normally-open contact is part of the finite-resistance coded network and must not directly bridge the two harness wires.

```text
HANDLE_A o---- R_SER ----+---- SW_NO ----+----o HANDLE_B
                         |               |
                         +---- R_REL ----+

SW_NO open:    R_HANDLE = R_SER + R_REL
SW_NO closed:  R_HANDLE = R_SER
```

`R_SER` gives the pressed handle its finite code resistance. `R_REL` provides end-of-line continuity while the switch is released. An open `R_SER` removes the branch; an open `R_REL` removes the released branch but still permits the pressed path; and resistor shorts move the result toward an apparent press or hard-short signature. Continuity of the switch-only bypass path requires the proof test described below.

### Resistance ratios and unresolved current scale

Define a common positive scale factor `S` and multiply **every loop resistor**, including the PCB excitation/return pair, by it:

| Location | Base value multiplied by `S` | Released branch | Pressed branch |
|---|---:|---:|---:|
| PCB `R_EXC`, `R_RET` | 1.96 kΩ each | — | — |
| Left `R_SER`, `R_REL` | 6.65 kΩ, 13.3 kΩ | 19.950 kΩ × `S` | 6.650 kΩ × `S` |
| Right `R_SER`, `R_REL` | 2.49 kΩ, 2.49 kΩ | 4.980 kΩ × `S` | 2.490 kΩ × `S` |

The ratios form an approximately equal-step conductance code after the Y connection. The state voltages and normalized code are independent of `S`; loop current, contact current, fault energy, leakage sensitivity, and settling are not.

Use 0.1% thin-film parts with no worse than 25 ppm/°C **individual** TCR as the calculation baseline. Parts in separate handles cannot be assumed to track as a matched network, so production limits must use independent temperature drift. Do not substitute values or exchange left/right networks without recalculating the code and component FMEA.

`S = 1` is used in the calculation tables below, but is not a frozen production choice. It produces only 0.16–0.21 mA through the left closed contact. A lower-impedance prototype candidate is `S = 0.10`: 196 Ω for each PCB bias resistor, 665 Ω/1.33 kΩ in the left handle, and 249 Ω/249 Ω in the right handle. This raises the fault-free loop current to approximately 4.2–5.8 mA and closed-contact currents to approximately 1.57–2.09 mA left and 4.19–4.78 mA right while preserving the tabled voltages.

Neither scale is production-qualified without the exact switch data. The open-contact voltage is only approximately 0.69–1.11 V, independent of `S`, and a mechanical contact's minimum applicable load is normally specified as a voltage/current pair. Select or replace the switch for qualified low-level/dry-circuit service, then choose `S` jointly with the sustained-fault and protection design. Under a fixed applied voltage, loop current and resistor fault power scale approximately as `1 / S`.

### Mechanical implementation

- Rewire the contact path with `R_SER` in series and fit `R_REL` across the switch only. Verify with an ohmmeter that neither pressed handle can directly short its connector pins.
- Place both resistors inside the handle, electrically beyond as much of the branch cable and connector as practical. Resistors placed on the PCB cannot supervise the external branch cable.
- Minimize and mechanically secure joints in the switch-only bypass path. That path is latent while released: an open contact, lead, trace, or new solder joint leaves `R_REL` reporting a plausible released branch but prevents the press from being observed.
- Provide strain relief, insulation, moisture protection, and mechanically secured solder joints suitable for handlebar vibration.
- Permanently mark the left and right modified handles; exchanging them swaps the reported identity but still removes propulsion permission when either is pressed.
- Treat the modified pair as a coded sensor loop. It is no longer a conventional zero-ohm dry-contact input and must not also feed equipment that expects one.
- Measure and record each completed handle's released and pressed resistance before installing the Y harness.

## Two-wire system topology

```text
PCB BRAKE_A o==========+======================+
                       |                      |
                [ LEFT NETWORK ]       [ RIGHT NETWORK ]
                       |                      |
PCB BRAKE_B o==========+======================+
                       \______ Y harness _____/

The two handle networks are connected in parallel between BRAKE_A and BRAKE_B.
```

The handle networks are resistor-only and therefore do not depend on connector polarity. `BRAKE_A` and `BRAKE_B` acquire their names only at the PCB measurement circuit.

## PCB measurement circuit

### Proposed circuit

```text
               R_EXC 1.96 kΩ × S                    R_RET 1.96 kΩ × S
3V3_BRAKE o---------/\/\/\--o BRAKE_A ===[ Y + handles ]=== BRAKE_B o--/\/\/\--o ANALOG_GND
                              |                                      |
                           1.00 kΩ                                1.00 kΩ
                              |                                      |
                           o ADC_A                                o ADC_B
                              |                                      |
                           100 nF                                100 nF
                              |                                      |
ANALOG_GND o------------------+--------------------------------------+

Add low-leakage external clamps at ADC_A and ADC_B and connector-side ESD/
overvoltage protection after the vehicle fault-voltage envelope is defined.
Do not rely on the MCU's internal protection structures for harness faults.
```

| PCB component/function | Proposed value or allocation | Purpose |
|---|---|---|
| `R_EXC`, `R_RET` | 1.96 kΩ × `S`, 0.1%; use a matched pair/network where practical | Symmetric excitation and return; matching makes `ADC_A + ADC_B` a useful plausibility invariant. |
| `R_ADC_A`, `R_ADC_B` | 1.00 kΩ | Isolate the ADC sampling/filter capacitors and limit clamp current. |
| `C_ADC_A`, `C_ADC_B` | 100 nF, X7R, placed at the SoM pins | Matched low-pass filtering; nominal settling is well below the proposed 5 ms sample interval. |
| `D_PROT_A`, `D_PROT_B` | Low-leakage external clamps; exact network pending electrical-environment definition | Keep ADC inputs within their qualified range during ESD and bounded cable faults. |
| `ADC_A` | Proposed SoM pad 93, `ADC2_IN1` | Samples the excited harness conductor. Confirm the pad is unused in the carrier schematic. |
| `ADC_B` | Proposed SoM pad 94, `ADC2_IN4` | Samples the return harness conductor. Confirm the pad is unused in the carrier schematic. |

The ADC input pins must remain between `VSS` and `VDDA_ADC_3P3`. Feed `R_EXC` from the ADC-reference-related 3.3 V rail or measure the excitation separately; otherwise the voltage-sum plausibility check has no accurate reference. Configure ADC calibration, hardware averaging, and a sample time validated for the actual source/filter network. NXP's data sheet makes allowable analog-source resistance dependent on the ADC sample-time and power-mode settings; the 100 nF capacitors do not remove the need to verify settling.

At `S = 1`, total loop current is approximately 0.42 mA released and 0.58 mA with both handles pressed. Current scales as `1 / S`. The [resistance-scale decision](#resistance-ratios-and-unresolved-current-scale) must be closed against the switch's complete minimum-load specification and the protection design, not by checking current alone.

## State calculation

For a fault-free series loop:

```text
I_LOOP = V_EXC / (R_EXC + R_BUS + R_RET)
V_A    = V_EXC - I_LOOP × R_EXC
V_B    = I_LOOP × R_RET

R_BUS  = R_RET × (V_A - V_B) / V_B
K      = V_B / (V_A - V_B) = R_RET / R_BUS
```

`K` is useful because excitation voltage and ADC reference gain cancel to first order when the two channels are sampled close together. Classification can avoid division by comparing `V_B` with fixed multiples of `V_A - V_B`.

With `V_EXC = 3.300 V` and `S = 1`, the results are as follows. Every resistance in the `R_BUS` column scales with `S`; the voltages, `K`, and ideal ADC codes remain unchanged when all loop resistors use the same scale.

| Handle state | `R_BUS` at `S = 1` | `V_A` | `V_B` | `V_A - V_B` | `K` | Illustrative 12-bit codes `A / B` |
|---|---:|---:|---:|---:|---:|---:|
| Neither pressed | 3.985 kΩ | 2.482 V | 0.818 V | 1.664 V | 0.4918 | 3080 / 1015 |
| Left pressed | 2.848 kΩ | 2.344 V | 0.956 V | 1.389 V | 0.6883 | 2909 / 1186 |
| Right pressed | 2.214 kΩ | 2.246 V | 1.055 V | 1.191 V | 0.8854 | 2786 / 1309 |
| Both pressed | 1.812 kΩ | 2.172 V | 1.128 V | 1.043 V | 1.0819 | 2695 / 1400 |

The ADC codes assume an ADC reference exactly equal to the 3.3 V excitation and are shown only for orientation. Use the measured ratio and validated windows in firmware.

```text
increasing total conductance / decreasing R_BUS  ─────────────────────────────────>

branch-loss codes               released     left     branch-loss     right     both
K = 0.098 / 0.295 / 0.394         0.492       0.688       0.787         0.885     1.082

hard wire short: V_A ≈ V_B, so the differential approaches zero and K is not used
```

Illustrative bring-up windows could be `0.47–0.52`, `0.66–0.72`, `0.86–0.92`, and `1.05–1.11`. These are **not production thresholds**. Their purpose is to demonstrate that guard bands exist; replace them with limits derived from worst-case analysis and measured production-intent hardware.

A preliminary exhaustive enumeration of the listed valid states and nearest complete-branch-open case, using 0.1% limits for all coding and return resistors followed by an independent ±4.28 LSB error on each 12-bit ADC result, gives these illustrative `K` ranges:

| State | Resistor corners only | Resistor plus ADC-error corners |
|---|---:|---:|
| Neither pressed | 0.4908–0.4928 | 0.4868–0.4969 |
| Left pressed | 0.6869–0.6897 | 0.6811–0.6956 |
| Right pressed | 0.8836–0.8872 | 0.8757–0.8953 |
| Both pressed | 1.0797–1.0841 | 1.0694–1.0946 |
| Closest complete branch-open fault | 0.7856–0.7887 | 0.7787–0.7957 |

The ADC term uses NXP's maximum total-unadjusted-error figure under its stated calibrated/averaged conditions. The closest preliminary complete-branch-open-to-valid separation remains approximately 0.080 in `K`. This is **not** a minimum separation for all faults: component shorts and arbitrary resistive damage can alias valid codes. The check confirms useful branch-open separation, but it is not the production error budget; it omits cable/contact resistance, protection leakage, reference/excitation mismatch during sequential samples, temperature tracking, noise, aging, and dynamic settling.

## Expected fault signatures

| Injected condition | Nominal observation | Required interpretation |
|---|---|---|
| Trunk open / connector disconnected | `V_A ≈ 3.3 V`, `V_B ≈ 0 V` | Fault; remove propulsion permission and report identity unknown. |
| One handle branch open | Surviving branch is 2.490, 4.980, 6.650, or 19.950 kΩ times `S`; `K` is 0.787, 0.394, 0.295, or 0.098 | Every value is outside the valid windows: fault; remove propulsion permission and report identity unknown. |
| Short between `BRAKE_A` and `BRAKE_B` | `V_A ≈ V_B ≈ 1.65 V`; differential approaches zero | Fault; remove propulsion permission and report identity unknown. |
| `BRAKE_A` short to local ground | Both measured nodes move abnormally low; voltage sum collapses | Fault; protection must limit current. |
| `BRAKE_B` short to local ground | `V_B ≈ 0 V`, while `V_A + V_B` is below the excitation invariant | Fault; protection must limit current. |
| `BRAKE_A` short to local 3.3 V | `V_A ≈ 3.3 V`, while the voltage sum is too high | Fault; protection must prevent rail backfeed. |
| `BRAKE_B` short to local 3.3 V | Both measured nodes move abnormally high | Fault; protection must prevent rail backfeed. |
| Intermittent/high-resistance connection | Samples cross a guard band or disagree in many—but not all—cases | Remove propulsion permission immediately while invalid; record every event and latch only by qualified persistence/repetition criteria. |
| `R_SER` open | Complete handle branch is lost | Branch-loss fault; remove propulsion permission and report identity unknown. |
| `R_REL` open | Released branch is lost; pressing the handle restores its finite `R_SER` path | Fault while released; pressed operation remains detectable. |
| `R_REL` short | Handle is permanently reduced to `R_SER` | Apparent persistent valid press; propulsion remains disabled, but this fault is not separately identified. |
| `R_SER` short | Released code becomes invalid or can resemble a press; pressing creates the hard-short signature | Fault or apparent valid press; propulsion remains disabled in either case. |
| Switch-only bypass path open | Released code remains valid through `R_REL`; pressing causes no code change | Latent undetected fault that can hide actuation; requires proof testing or an independent sensing path. |

For the symmetric bias network, `V_A + V_B` should remain near the known or separately measured excitation voltage during healthy operation. This invariant adds information that a single ADC measurement cannot provide. It detects several conductor-to-rail faults even when differential resistance alone looks plausible.

## Firmware classification behavior

1. Sample `ADC_A` and `ADC_B` back-to-back, initially every 5 ms or faster.
2. Reject rail saturation, `V_A ≤ V_B`, an invalid `V_A + V_B`, and a differential too close to zero before calculating a state code.
3. Compute or cross-multiply the normalized code `K` and accept only one validated state window. Guard-band values are faults, not nearest-state results.
4. For a valid left, right, or both code, publish the corresponding pressed state and remove propulsion permission immediately. Identity may be confirmed over two consecutive samples only if that does not delay propulsion inhibition.
5. For an invalid or stale input, publish `fault`, set identity to `unknown`, and remove propulsion permission immediately. Do not fabricate a physical brake-handle state; a separate system-safety policy decides whether the vehicle actively brakes, coasts, or takes another action.
6. Re-enable propulsion permission only after a stable released code for the validated debounce interval and only if no qualified diagnostic blocks recovery.
7. Record isolated invalid samples. Latch a service fault only after validated persistence/repetition criteria that tolerate RC settling and contact bounce; there is no generally impossible logical transition because both handles can change within one sample interval.
8. Expose a mutually exclusive decoded state (`released`, `left`, `right`, `both`, or `fault`) separately from `propulsion_permit` and any downstream active-braking command.

Thresholds should be generated from component limits rather than scattered magic ADC counts. Store them as dimensionless ratio bounds or cross-multiplication constants so excitation/reference variation does not silently move the state windows.

```text
ADC_A + ADC_B
      |
      v
electrical validity + code windows
      |
      +-- valid released ------> identity: released ---> permission after debounce
      |
      +-- valid pressed -------> identity: L/R/both ---> propulsion permission OFF
      |
      +-- invalid or stale ----> identity: unknown ----> propulsion permission OFF
                                      |
                                      +---------------> system hazard-response policy
```

## Architectural limits

This passive design materially improves diagnostics, but a two-terminal resistor network exposes only one equivalent impedance at any instant. Different physical conditions that produce the same impedance are electrically indistinguishable.

In particular:

- Any open in the switch-only bypass path—including the normally-open contact, its leads, the interrupted trace, or either new solder joint—cannot be distinguished from an unpressed handle. The end-of-line path proves branch continuity through `R_REL`, not that the bypass will close on demand.
- An arbitrary partial series resistance can move a genuinely pressed code toward a less-pressed valid code. An arbitrary leakage resistance can move it toward a more-pressed code. Guard bands and persistent-fault monitoring detect many such events but cannot prove coverage of every possible resistance.
- A simultaneous/common fault in the Y junction or two-wire trunk affects both handles. The two handle indications are coded states, not independent safety channels.
- The two ADC channels still share the MCU, ADC2, reference, software, and much of the passive excitation path.
- Modifying a certified brake handle may invalidate its environmental, warranty, or regulatory status.

Therefore, if the system safety goal requires detection of every single fault that could hide brake actuation, the passive two-wire Y architecture is insufficient. The preferred architectural changes are separate conductors per handle, a normally-closed or changeover contact per handle, a second independent sensing principle, or qualified active handle electronics. The proposed circuit is acceptable only after the system safety analysis explicitly accepts its residual faults and defines another means of controlling them, such as periodic proof testing or an independent braking/torque-inhibit path.

## Protection and layout requirements

- Keep the two ADC filter networks symmetric and place their capacitors and clamps close to the SoM pads.
- Route `BRAKE_A` and `BRAKE_B` together, away from PWM, motor, and switching-regulator nodes. Provide a defined analog return rather than sharing high-current ground paths.
- Use connector-side ESD protection with leakage characterized across temperature; leakage is part of the state-code error budget.
- The scaled bias resistors are **not** by themselves a qualified protection solution for a sustained short to `BAT+`, 12 V, or another high-energy rail. Define the maximum fault voltage, source impedance, duration, and required survival before selecting resistor strings, PTC/fusible elements, TVS/clamps, and ratings.
- Ensure protection current cannot back-power the carrier 3.3 V rail or an unpowered SoM.
- Verify resistor pulse/voltage ratings, not only steady-state dissipation.
- Include accessible test points for `BRAKE_A`, `BRAKE_B`, `ADC_A`, and `ADC_B` without adding a path that bypasses harness supervision.

## Verification plan

Before accepting production thresholds:

1. Measure at least the four valid states, trunk open, each individual branch open, line-to-line short, and each line-to-qualified rail fault.
2. Substitute every handle resistor open and short one at a time and confirm the FMEA classification on released and pressed handles.
3. Open the switch contact, each bypass lead/trace segment, and each new solder joint in turn. Confirm that these faults remain latent while released, then validate the selected proof-test or independent mitigation.
4. Sweep added series resistance and parallel leakage to identify all alias regions; record them as residual faults rather than claiming universal cable-damage coverage.
5. Test switch bounce, slow actuation, connector fretting, intermittent opens, and hot-plugging while logging both raw ADC channels.
6. Characterize minimum/maximum component tolerances and ADC readings across supply and temperature, including clamp leakage and cable/contact resistance.
7. Validate ADC calibration, acquisition time, channel-to-channel settling, filter response, and scheduler latency under worst-case CPU/interrupt load.
8. Verify propulsion permission is removed at every safety-relevant output before startup classification and during a fault. Separately validate that propulsion inhibition and the hazard-analysis-selected active-brake/coast reaction are safe in every relevant vehicle state.
9. Repeat EMC, ESD, transient, moisture, vibration, and harness tests on production-intent assemblies.

## References and related documents

- [NXP i.MX RT1060 industrial data sheet](https://www.nxp.com/docs/en/nxp/data-sheets/IMXRT1060IEC.pdf) — ADC input range, source-resistance/sample-time relationship, calibration, and accuracy.
- Exact brake-handle switch data sheet — **open input**; minimum applicable voltage/current load and contact material are required before selecting `S`.
- Vehicle harness electrical-fault envelope — **open input**; adjacent-rail voltage, source impedance, duration, and required survival are required before selecting protection.
- [Throttle input](throttle-input.md) — adjacent ADC2 allocation and the existing analog-input documentation pattern.
- [Power domains and isolation](power-domains-and-isolation.md) — vehicle supply and ground-domain constraints.
- [Application verification](verification.md) — system-level release evidence.
