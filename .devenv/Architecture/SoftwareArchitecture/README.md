# Vehicle Software Architecture

`ARCH-003_Software_Architecture.md` is the vehicle static architecture and `Runtime_Integration_Contract.md` is its selected vehicle runtime allocation. Load `../SystemArchitecture/Modelling` for logical supertypes, then `Modelling` for shared software types and root composition, and each component folder for its component model and recursive `DetailedDesign` resources. The entry package is `X2CitySoftwareArchitecture`.

The model contains only vehicle V instances. `SharedSoftwareTypes.sysml` holds common context/qualification records. `DetailedDesign/Modelling` holds shared detailed contracts and the detailed-design composition root; component `DetailedDesign` folders hold their owned unit models and Markdown design. `SC-HMI` realizes the System `HmiInformationProcessing` allocation while retaining its established component name; it transports qualified UART data at the logical electrical boundary and uses concrete qualified settings, selected-fault, battery and motion records. Supplied BMS and VD18MT components remain opaque and therefore have no vendor-internal detailed design.

`MotorPositionEstimator` jointly realizes `LE-MOTOR-POSITION-PROC` with HallInterface
and MotorPhaseInterface. HallInterface publishes observations; the estimator owns one
final `MotorPositionRecord(Position, Qualification)` publication to TractionControl,
RidingControl and Platform. Qualification remains delivered even if Position is
unavailable. The observer-voltage branch is a
separate explicit HSI boundary and remains unavailable until qualified; it is never
fed from the regular phase-voltage diagnostic path.

`MotorControlRealization` specializes the expanded logical `MotorControl` allocation. It contains the one `TractionControl` FOC/output core and references the existing AnalogAcquisition, TemperatureInterface and SupplyInterface instances. Physical logical temperature/supply measurements are allocated to those existing acquisition/conversion chains, not connected as a second SC input. The core evaluates qualified temperature, regular GVDD, fast PVDD, stage/protection and conversion-health evidence into local categorized condition evidence independently of authority; RidingControl owns session fault latching and reporting. The wrapper adds no deployed component, sensor conversion, task or PWM/JSQR writer.

The sole `SC-RIDING-CONTROL.V` instance and its four contained units are defined in [RidingControl](RidingControl/README.md); detailed unit contracts are consolidated in that component folder.
