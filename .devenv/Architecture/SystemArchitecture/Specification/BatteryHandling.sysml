package X2CitySpecification_X2CityMCU_BatteryHandling {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BAT-001'> propulsionInhibitionDuringBatteryHandling : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Battery_Handling.md#req-sys-bat-001
            (line 13).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-bat-001"></a>`REQ-SYS-BAT-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `T-SYS`. Observe the connected intervals and
            confirm no propulsion command during the supplied procedure.
            Sources: [DEC-BAT-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-bat-001),
            `VS-011`
            Open dependencies / qualifications: `WS-OI-007`: Connection or lock sensing, interlock and
            mechanical retention are outside project scope. Abnormal energized handling remains relevant to
            electrical protection.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The EPCS shall command no propulsion during the supplied normal battery removal/refitting
                procedure (`VS-011`), including electrically connected but unseated/unlocked intervals.
            */
        }
    }
    satisfy propulsionInhibitionDuringBatteryHandling by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-BAT-003'> batteryInterfaceSafetyDuringHandling : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Battery_Handling.md#req-sys-bat-003
            (line 14).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-bat-003"></a>`REQ-SYS-BAT-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`, `T-FI`. Observe prescribed
            electrical states, detached contacts and exposed bay; verify accessible
            voltage/current/temperature/energy against configuration-specific limits, including
            powered/unpowered, wheel-generation and unavailable-controller/link cases.
            Sources: `OBJ-005`, `CON-019`, `CON-021`, `IU-018`, `IF-EPCS-008`, `IF-EXT-007`,
            [PD §11.8](../../../../README.md#118-battery-removal-and-service-interfaces);
            [energy protection](EnergyAndProtection.sysml)
            Open dependencies / qualifications: `OI-045/046/049/056`, `WS-OI-011/018`: Target
            [LE-EPCS](../X2CityMCU.md#le-epcs). Derive electrical exposure limits, fault coverage and
            inspection/recovery criteria. Mechanical access, retention, connection/lock sensing and
            interlock are outside project scope.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Throughout the supplied battery removal/refitting procedure and defined exposed-empty-bay
                duty, accessible battery/vehicle interfaces shall remain within qualified electrical,
                thermal and residual/generated-energy limits, including connected-but-unseated/unlocked
                intermediates. Required electrical protection shall remain effective within the defined
                fault envelope when vehicle control or BMS UART is unavailable.
            */
        }
    }
    satisfy batteryInterfaceSafetyDuringHandling by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
