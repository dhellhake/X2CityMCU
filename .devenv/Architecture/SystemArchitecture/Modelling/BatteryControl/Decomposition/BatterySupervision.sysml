package X2CityComponent_BatterySupervision {
    private import X2CityContract_BatteryControl::*;

    requirement def AbstractSoftwareRequirement {
    }

    part def BatterySupervision { // LE-BATTERY-SUPERVISION
        doc /* Project software responsibility on the vehicle host. It logically owns the existing BmsLink read/qualification and BatteryProtection operating-policy responsibilities; their existing software components realize this part, while supplied BMS internals remain outside it. */
        port bmsTelemetryIn:BmsTelemetryInputPort { doc /* Read-only UART response input from the supplied BMS. */ }
        port bmsReadRequestOut:BmsReadRequestOutputPort { doc /* Read-only UART request output to the supplied BMS. */ }
        port batteryReadinessAndFaultOut:BatteryReadinessAndFaultOutputPort { doc /* Publishes one startup assessment and separate recognized thermal/battery fault evidence to RidingControl. */ }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort { doc /* Publishes independent discharge/regeneration branch limits and SOC-positive-propulsion limits to RidingControl. */ }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort { doc /* Publishes qualified actual SOC for HMI and RidingControl low-charge selection. */ }
        port batteryCurrentOut:BatteryCurrentOutputPort { doc /* Publishes qualified signed pack current in amperes for HMI. */ }
    }

    requirement <'REQ-SYS-BMSIF-001'> bmsInformationQualification : AbstractSoftwareRequirement {
        doc /*
        Abstract Software Requirement. Canonical historical record: REQ-001-R1.6, Approved.
        Draft successor allocation: LE-BATTERY-SUPERVISION, realized by existing BmsLink and BatteryProtection
        project software contributions on the owner-selected vehicle host. Deployment and integration acceptance remain open.
        Parent: [REQ-SYS-BMS-003](../Battery_Integration.md#req-sys-bms-003).
        Source: [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md); PD OI-041/061.
        Derive polling, timeout, plausibility, freshness and uncertainty contracts. No UART peripheral, parser implementation,
        or write/control-command support is selected. VD18MT current magnitude clamped to 51 A and invalid-current fallback
        0 A are presentation rules only.
        Planned verification: T-SW and T-SYS with captured selected-unit responses and independently constructed
        valid/invalid cases for framing, checksum, status, lengths/counts, signed/scaled boundaries, missing/late data,
        and sleep/restart. Verify consumers cannot mistake display fallback for qualified control data.
        Acceptance evidence: [Selected-unit UART read acceptance contract](BMS_Information.md#selected-unit-uart-read-acceptance-contract).
        Model and verification rules: [REQ-001 requirements](../../../../../Requirements/REQ-001_Requirements.md).
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
            BatterySupervision shall decode the selected-unit-qualified JBD UART read responses into value, validity
            and freshness information for the quantities in its parent. It shall reject unsuccessful, malformed,
            wrong-command, inconsistent or stale responses according to the qualified contract, and shall preserve current
            direction, scaling mode, 14-group identity and temperature units.
            */
        }
    }

    requirement <'REQ-SYS-BMSPOL-001'> batteryCapabilityPolicy : AbstractSoftwareRequirement {
        doc /*
        Abstract Software Requirement. Canonical historical record: REQ-001-R1.6, Approved.
        Draft successor allocation: LE-BATTERY-SUPERVISION, realized by existing BmsLink and BatteryProtection
        project software contributions on the owner-selected vehicle host. Configuration-specific deployment and acceptance remain open.
        Parents: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001),
        [REQ-SYS-BMS-006](../Battery_Integration.md#req-sys-bms-006),
        [REQ-SYS-BMS-007](../Battery_Integration.md#req-sys-bms-007),
        [REQ-SYS-BMS-008](../Battery_Integration.md#req-sys-bms-008).
        Planned verification: A, T-SW, T-SYS and T-FI. Exercise the
        [battery event and recovery matrix](../Battery_Integration.md#battery-event-and-recovery-matrix) with independently
        varied data quality, path/configuration states and overlapping current/SOC/temperature restrictions. Compare output
        permissions, limits and causes with the qualified envelope and owner policy; verify physical enforcement separately.
        Open dependencies and qualifications: IF-A-003/009; OI-041/045/048/049/061. Derive numerical bounds, error/age
        margins, output representation/update budget and classification evidence. Software outputs do not prove protection
        with the host unavailable.
        Model and verification rules: [REQ-001 requirements](../../../../../Requirements/REQ-001_Requirements.md).
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
            BatterySupervision shall produce qualified battery-side charge/discharge envelopes,
            operation-specific permission/restriction reasons and recognized battery-fault information from qualified
            battery observations, effective configuration and the current operating context. Outputs shall distinguish a
            normal restriction from a fault and shall not grant dependent permission from unavailable required information.
            */
        }
    }

    doc /* Output responsibility and system integration retained from the capability-policy record:
        - Physical battery capability: Keep charge and discharge capabilities distinct, including qualified current limits and charge-path acceptance. Limits account for the most restrictive applicable cell/group, temperature, configured protection and connected-component envelope. An unknown required limit cannot enlarge permission.
        - Operation-specific restrictions: Distinguish propulsion limits, regenerative charge acceptance and auxiliary discharge capability. The 10% propulsion cutoff does not automatically remove auxiliary discharge capability. A discharge-permissible/charge-forbidden temperature is an ordinary regeneration restriction under DEC-TMP-003.
        - Riding integration: LE-RIDING owns the common fault latch and Ready guard, rider/brake/speed/profile arbitration, and regeneration re-entry behavior. LE-TRACTION must enforce physical torque/current capability. A newly available battery envelope alone does not re-enable torque, clear a session fault, or increase regeneration while its recovery guard remains unmet.
        - Physical protection: LE-EPCS and the supplied BMS/other derived protection contributors retain the system obligation for energized paths, residual/generated energy, faults, and host/UART loss. Vendor protection release is an observation, not automatic permission to resume a system session.
        Only the information-policy contribution is allocated here. Calibration, source accuracy, diagnostics, actual protection, and parent system acceptance remain open; no software unit, inverter algorithm, or circuit is selected. */
}
