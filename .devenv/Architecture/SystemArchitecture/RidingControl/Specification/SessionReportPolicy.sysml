package X2CitySpecification_RidingControl_SessionReportPolicy {
    private import X2CityComponent_RidingControl::RidingControl;
    private import RequirementTypes::*;

    requirement <'REQ-VEH-HMI-006'> sessionFaultReportRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Session_Report_Policy.md#req-veh-hmi-006 (line 7).
            Original target: LE-RIDING.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-hmi-006"></a>`REQ-VEH-HMI-006`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. H: accelerator first, brake
            later, accelerator repaired, restart with only brake faulty → new 0x0D. Cover converse and each
            grouped category persisting alone.
            Sources:
            [DEC-FLT-003](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-003),
            [DEC-FLT-004](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-004),
            [DEC-FLT-006](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-006),
            [DEC-FLT-008](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-008),
            [DEC-FLT-002](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-002),
            [DEC-STA-001](../../../DEC-001_Decisions_and_Open_Issues.md#dec-sta-001)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-009`, `WS-OI-010`,
            `WS-OI-012`, `WS-OI-018`, `WS-OI-019`: Report reset does not enable torque; ordinary startup
            qualification alone is not a recognized fault.
        */
        subject owner:RidingControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require constraint {
            doc /*
                A selected indication of a problem requiring fixing shall remain for the session despite
                condition clearance and report whenever communication permits. Every restart shall discard
                old selection and report newly recognized faults independently of Ready.
            */
        }
    }
    satisfy sessionFaultReportRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;

    requirement <'REQ-VEH-HMI-007'> firstDetectedFaultReportSelection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Session_Report_Policy.md#req-veh-hmi-007 (line 8).
            Original target: LE-RIDING.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-hmi-007"></a>`REQ-VEH-HMI-007`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. H: ordered combinations of
            all seven categories, first condition clearing before/after later faults, and indistinguishable
            order under [REQ-VEH-HMI-018](SessionReportPolicy.sysml).
            Sources:
            [DEC-FLT-003](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-003),
            [DEC-FLT-004](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-004),
            [DEC-FLT-006](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-006),
            [DEC-FLT-008](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-008)
            Open dependencies / qualifications: `WS-OI-001`, `WS-OI-008`, `WS-OI-009`, `WS-OI-010`,
            `WS-OI-012`, `WS-OI-015`, `WS-OI-018`, `WS-OI-019`: All seven outrank 0x01; approved
            [REQ-SYS-CTL-004](../RidingPolicy/Specification/SettingsAndControlPolicy.sysml) specifies the
            lowest code only for indistinguishable earliest ties; recognition timing remains open.
        */
        subject owner:RidingControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require constraint {
            doc /*
                Within a session, the first detected accelerator 0x0A, brake 0x0D, speed 0x03, battery 0x07,
                temperature-limit 0x06, blocked-motor 0x04 or generic 0x05 fault shall remain the selected
                report from that group, without replacement/alternation by later group faults.
            */
        }
    }
    satisfy firstDetectedFaultReportSelection by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;

    requirement <'REQ-VEH-HMI-009'> batteryWarningReportComposition : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Session_Report_Policy.md#req-veh-hmi-009 (line 9).
            Original target: LE-RIDING.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-hmi-009"></a>`REQ-VEH-HMI-009` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`: exercise each cause alone and
            together, voltage at and above cutoff, unknown/stale evidence, independent MOS clearance,
            unknown voltage evidence while MOS warning remains true, fault masking and restart; the active
            MOS cause keeps `0x01` despite unknown voltage evidence. SOC loss, cold zero capability and
            path-off zero capability alone do not establish low-voltage warning.
            Sources:
            [DEC-SOC-001](../../../DEC-001_Decisions_and_Open_Issues.md#dec-soc-001)
            Open dependencies / qualifications: `WS-OI-005/008/009/010/017`: Voltage warning uses qualified
            lowest group voltage and discharge cutoff, independent of SOC and aggregate current capability.
        */
        subject owner:RidingControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require constraint {
            doc /*
                When no retained group fault has priority, report `0x01` while BatteryStatus indicates known
                true `lowDischargeVoltageWarning` or known true MOS-disabled warning. Clear each cause
                independently when qualified false; absent, stale or unknown evidence withdraws that cause
                without establishing a healthy state. Neither cause requires restart.
            */
        }
    }
    satisfy batteryWarningReportComposition by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;

    requirement <'REQ-VEH-HMI-010'> retainedFaultReportPriority : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Session_Report_Policy.md#req-veh-hmi-010 (line 10).
            Original target: LE-RIDING.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-hmi-010"></a>`REQ-VEH-HMI-010` **Draft successor — 2026-10-26**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. H: both orders for every
            grouped category with each/both 0x01 causes; clearing either warning cause cannot clear retained
            fault. After restart, current qualified low-voltage and MOS warning states determine 0x01 if no
            higher report.
            Sources:
            [DEC-SOC-001](../../../DEC-001_Decisions_and_Open_Issues.md#dec-soc-001),
            [DEC-FLT-003](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-003),
            [DEC-FLT-006](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-006),
            [DEC-FLT-008](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-008)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-009`, `WS-OI-010`,
            `WS-OI-017`, `WS-OI-018`, `WS-OI-019`: All seven categories, including 0x04/0x05, use the same
            priority over 0x01.
        */
        subject owner:RidingControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require constraint {
            doc /*
                Any selected [REQ-VEH-HMI-007](SessionReportPolicy.sysml) retained fault-group report shall
                outrank the composed low-priority `0x01` warning regardless of detection order, preserving
                its restart-based lifetime.
            */
        }
    }
    satisfy retainedFaultReportPriority by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;

    requirement <'REQ-VEH-HMI-014'> temperatureFaultReportRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Session_Report_Policy.md#req-veh-hmi-014 (line 11).
            Original target: LE-RIDING.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-hmi-014"></a>`REQ-VEH-HMI-014`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. H/F: normalize without
            restart; normal/unexpected restart with temperature normal versus persistent/new violation.
            Sources:
            [DEC-TMP-001](../../../DEC-001_Decisions_and_Open_Issues.md#dec-tmp-001)
            Open dependencies / qualifications: `WS-OI-007`, `WS-OI-008`, `WS-OI-009`, `WS-OI-010`,
            `WS-OI-019`: Retained report does not itself force auxiliary shutdown.
        */
        subject owner:RidingControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require constraint {
            doc /*
                Temperature indication shall remain for the session after normalization, reporting `0x06`
                when selected/communicable; every restart shall assess it afresh.
            */
        }
    }
    satisfy temperatureFaultReportRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;

    requirement <'REQ-VEH-HMI-018'> tiedFaultReportSelection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Session_Report_Policy.md#req-veh-hmi-018 (line 12).
            Original target: LE-RIDING.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-hmi-018"></a>`REQ-VEH-HMI-018`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `T-SYS`, `T-FI`. Repeat equivalent ties;
            compare distinguishably ordered faults, subsequent faults and condition clearance.
            Sources:
            [DEC-FLT-008](../../../DEC-001_Decisions_and_Open_Issues.md#dec-flt-008)
            Open dependencies / qualifications: `WS-OI-008`, `WS-OI-009`, `WS-OI-010`, `WS-OI-019`: approved
            [REQ-SYS-CTL-004](../RidingPolicy/Specification/SettingsAndControlPolicy.sysml) specifies the
            tie rule; detection-order resolution remains open; a tie rule does not override priority between
            categories; independent low-voltage and MOS warnings are not group faults.
        */
        subject owner:RidingControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require constraint {
            doc /*
                Indistinguishably ordered reportable group faults shall select one tied fault by a
                consistent rule and retain selection until restart under the applicable reporting rules.
            */
        }
    }
    satisfy tiedFaultReportSelection by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;

}
