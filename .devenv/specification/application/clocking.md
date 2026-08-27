# Clocking

[Application index](README.md) · [SoM reference](../som/fet1061-s.md)

**Status:** implemented as an intentional, unsupported overclock.

## Qualified hardware limit

The documented FET1061-S carries an industrial speed-grade-5 `MIMXRT1061CVL5A`; later public BSP material names `...CVL5B`. Both are qualified for a maximum 528 MHz core/AHB clock (`F_SYS`) and 132 MHz IPG clock (`F_BUS`). The complete FET1061-S is also advertised at 528 MHz.

NXP's supported 600 MHz operating point applies to the separate consumer `DVL6` speed grade. A programmable 600 MHz clock and a numerically overlapping core voltage do not qualify a `CVL5` device at that frequency.

## Current application operating point

The current [clock-tree implementation](../../../src/mcu/clocktree/mod.rs) programs:

| Quantity | Configuration | Result |
|---|---|---:|
| Crystal | Fixed SoM crystal | 24 MHz |
| ARM PLL | `DIV_SELECT = 100` | 1.2 GHz |
| ARM divider | encoded `ARM_PODF = 1` | 600 MHz core |
| AHB divider | encoded `AHB_PODF = 0` | 600 MHz AHB |
| IPG divider | encoded `IPG_PODF = 3` | 150 MHz IPG |
| LPUART root | 24 MHz crystal, divide by one | 24 MHz |
| DCDC target | `DCDC_REG3.TRG = 0x12` | nominal 1.250 V |

The 1.250 V target is deliberately the lowest target currently selected for the experimental operating point. It stays below the `CVL5` data sheet's 1.26 V recommended operating ceiling, but it does not make 600 MHz a supported `CVL5` condition. Do not raise it merely to mask a software, memory-layout, or MPU fault. Any increase requires evidence of voltage-related instability, thermal review, and renewed target testing.

## Transition requirements

Initialization must keep the ordering implemented by `McuClockTree_Init()`:

1. Move the live core/bus tree to the 24 MHz crystal and keep interrupts disabled.
2. Set the LPUART root to the crystal so UART timing is independent of the PLL transition.
3. Program the DCDC target and wait for `STS_DC_OK`.
4. Reconfigure and lock the ARM PLL while it is bypassed.
5. Program the bus dividers and switch the live tree to the PLL.
6. Execute data/instruction synchronization barriers before continuing.

Frequency must be reduced before lowering the core voltage. Voltage must settle before increasing the frequency.

## Qualification boundary

This setting is suitable only for the explicitly accepted experimental deployment. Before a production release, either return to 528 MHz or qualify representative units across voltage, workload, temperature, reset, and lifetime margins. Timing calculations must use the values derived from the same divider constants that program the hardware.

References: [NXP industrial data sheet](https://www.nxp.com/docs/en/nxp/data-sheets/IMXRT1060IEC.pdf), [NXP consumer data sheet](https://www.nxp.com/docs/en/nxp/data-sheets/IMXRT1060CEC.pdf), and [NXP AN12245](https://www.nxp.com/docs/en/application-note/AN12245.pdf).

## Related documents

- [Communication interfaces](communication-interfaces.md)
- [Verification](verification.md)
