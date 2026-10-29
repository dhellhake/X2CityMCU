package X2CitySpecification_EnergyPath_Requirements {
    private import X2CitySystemArchitecture::EnergyPath;
    private import RequirementTypes::*;

    requirement <'REQ-AHW-ENEPATH-001'> totalDischargeCurrentCeiling : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/EnergyPath/EnergyPath.md#req-ahw-enepath-001 (line 8).
            Original target: LE-ENERGY-PATH.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-ahw-enepath-001"></a>`REQ-AHW-ENEPATH-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`: verify finite positive and
            qualified zero bounds with simultaneous loads and transitions, using independently measured
            signed battery current. Distinguish unqualified branch from qualified zero; electrical current
            direction is distinct from wheel torque.
            Open dependencies: Derive and physically verify actuation, bootstrap and qualification
            sequencing, retention or hold-up, loss of host power, residual/parasitic and self-discharge
            behavior, tolerances and timing. Do not assume control power survives cutoff or promise charging
            when control is unpowered. The UART is read-only; no vendor BMS MOS override or
            current-sensing/switch topology is selected.
        */
        subject owner:EnergyPath =
            X2CitySystemArchitecture::x2CityVehicle.epcs.energyPath;
        require constraint {
            doc /*
                EnergyPath shall enforce the qualified BatterySupervision discharge-current ceiling,
                including zero, on total net battery discharge supplying all operating loads, including
                traction, display, lighting and control.
            */
        }
    }
    satisfy totalDischargeCurrentCeiling by X2CitySystemArchitecture::x2CityVehicle.epcs.energyPath;

}
