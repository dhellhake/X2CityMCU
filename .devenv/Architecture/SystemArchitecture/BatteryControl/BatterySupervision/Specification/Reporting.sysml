package X2CitySpecification_BatterySupervision_Reporting {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BATSUP-006'> bmsMosDisabledStatus : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-010](../../Specification/Reporting.sysml).
            Sources: qualified BMS charge/discharge path observation; BMSIF-009–011.
            Verify: T-SW/T-SYS all enabled, disabled and unqualified path combinations and recovery.
            Evidence / open: Display-code selection remains RidingControl responsibility; status does not
            establish isolation or a fault.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish the independent BatteryStatus MOS-disabled warning as
                qualified present when both path states are qualified and either is disabled, qualified
                absent when both are qualified enabled, and unqualified when either state is unqualified.
            */
        }
    }
    satisfy bmsMosDisabledStatus by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-020'> batteryStatusPublication : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-010](../../Specification/Reporting.sysml).
            Sources: FLT-005/006, BMS-007, TMP-001/002 and BATSUP-001.
            Verify: T-SW/T-SYS concurrent conditions and BMSIF-020 component publication. Evidence / open:
            Physical delivery, recognition thresholds and source mapping remain subject to validation.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish the battery-fault condition, MOS-disabled warning and
                lowDischargeVoltageWarning concurrently as independent BatteryStatus conditions, without
                battery-local priority or HMI-code selection, within the BMSIF-020 component output budget.
            */
        }
    }
    satisfy batteryStatusPublication by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-020'> bmsOutputPublicationTiming : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall recompute and publish affected component outputs within 10 ms of
                relevant accepted information or timer expiry, including fault recognition and status
                publication.
            */
        }
    }
    satisfy bmsOutputPublicationTiming by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-022'> bmsPackCurrentPublication : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources: original BMS-003 and
            [consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance); owner
            decision 2026-10-28 on pack-current consumption. Verify: T-SW/T-SYS signed current publication
            and independent qualification; field-only loss affects only current, preserves other qualified
            outputs, and does not alone establish a battery fault under BMSIF-009 and BATSUP-017. Installed
            schema and physical accuracy remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish signed pack current with its independent qualification on
                batteryCurrentOut, using the sign convention in REQ-SYS-BMSIF-005.
            */
        }
    }
    satisfy bmsPackCurrentPublication by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-025'> batteryFaultReportEvidence : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-010](../../Specification/Reporting.sysml). Sources: FLT-005/006, BMS-007 and
            TMP-001/002.
            Verify: T-SW/T-SYS brief, cleared, simultaneous and overlapping faults. Open: OI-041/061 and
            WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall capture and make each recognized fault and its common recognition
                order available to RidingControl for reporting, including brief, cleared and simultaneous
                events even while operating assessments are unqualified.
            */
        }
    }
    satisfy batteryFaultReportEvidence by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-026'> lowDischargeVoltageStatus : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-010](../../Specification/Reporting.sysml). Sources: BMS-007 and owner-authorized
            discharge pack capability decision.
            Verify: T-SW/T-SYS voltage boundaries and missing evidence. Open: OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish lowDischargeVoltageWarning as qualified true when all
                fourteen group voltages and discharge cutoff calibration are qualified and Vl ≤ Dcut,
                qualified false when that evidence is qualified and Vl > Dcut, and unknown when any of that
                evidence is unqualified.
            */
        }
    }
    satisfy lowDischargeVoltageStatus by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-027'> batteryStatusNotFunctionalInput : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml). Source: AG-001 operational and reporting
            interfaces.
            Verify: T-SW/T-SYS independently vary reporting status and qualified functional evidence.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine operating capability without using BatteryStatus as a
                functional input.
            */
        }
    }
    satisfy batteryStatusNotFunctionalInput by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
}
