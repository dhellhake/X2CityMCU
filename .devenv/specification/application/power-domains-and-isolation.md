# Power domains and isolation

[Application index](README.md) · [External connector](external-connector.md)

**Status:** external interface facts are established, but the common-ground and UART-isolation architecture is still open. No single topology is approved by this document.

## Known external interfaces

| Device | Power/ground behavior | Communication |
|---|---|---|
| BMS | `BAT-` is permanently connected to battery negative. `BAT+` is permanently connected to battery positive and can reach 58.8 V. Its separate `GND` is tied to battery negative only while enabled by the BMS. | 9600 bit/s UART, TX and RX. The BMS provides no stated low-voltage rail for an isolator. |
| ESC | `BAT+` is the intended power input. A 3.3 V output is provided by the ESC; its current capacity and back-power behavior are not yet specified. | TX, RX, and common ground. |
| VD18MT | `BAT+` is the intended supply. Ground behavior beyond the interface label is not yet documented. | 9600 bit/s UART, TX and RX. |
| Controller/carrier | The external connector exposes `BAT+`, permanent `BAT-`, `12V`, and contacts labelled `GND`. | The carrier terminates the implemented BMS UART, is intended to terminate the proposed VD18MT UART, and connects to the ESC elsewhere on the board. |

Traction-battery voltage must never be connected to a 3.3 V logic-supply pin, UART pin, debugger reference, or the SoM's backup rail.

## Architectural options under consideration

### Permanent-BAT- controller domain

Power the controller and low-voltage peripherals with a return referenced to permanent `BAT-`. This keeps the controller alive independently of the BMS-switched `GND` but requires isolation wherever a separately grounded device would otherwise bridge domains. In the discussed arrangement, the ESC UART is the likely isolated boundary.

This option still requires proof that every external ground and supply is compatible with permanent battery negative and that no cable or programming connection bypasses the intended isolation.

### BMS-switched-ground controller domain

Reference the controller and ordinary peripherals to the BMS-switched `GND`. The controller then loses its reference/power when the BMS opens that path, and the BMS UART becomes the likely isolation boundary to permanent `BAT-`.

This is more involved because the BMS does not provide an independent 3.3 V supply for the BMS-side isolator. A complete solution needs an isolated DC/DC supply or another explicitly qualified isolated power source; a digital isolator does not create isolated power.

## Isolation requirements

- Select isolation only after defining the controller, BMS, ESC, VD18MT, debugger, USB, and charger ground domains on one schematic.
- Provide a separately referenced low-voltage supply on each powered side of a digital isolator.
- Maintain required creepage, clearance, transient, and fault ratings at board and connector level. An IC's isolation rating does not automatically qualify a breakout board or assembled path.
- Confirm UART idle levels, power-off behavior, default states, direction, propagation delay, and fault containment.
- Prevent the ESC 3.3 V output, debugger VTG, or any external UART from back-powering an unpowered controller.
- Treat `BAT+` as up to 58.8 V even though separate connector contacts provide `12V`.

An ADuM1201-class bidirectional-channel arrangement has been discussed, but it is only a component candidate until the architecture and isolated-side supply are approved. See the [ADuM1200/ADuM1201 data sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/ADuM1200_1201.pdf).

## Decision required

Before schematic release, choose the controller reference domain and record:

1. Which exact connector `GND` contacts are permanent `BAT-`, BMS-switched ground, chassis/shield, or isolated returns.
2. Which UART boundaries are isolated.
3. How each side of every isolator is powered during normal operation, shutdown, programming, and fault states.
4. Whether any auxiliary connection can defeat the isolation barrier.

## Related documents

- [Communication interfaces](communication-interfaces.md)
- [Debug and boot](debug-and-boot.md)
- [Verification](verification.md)
