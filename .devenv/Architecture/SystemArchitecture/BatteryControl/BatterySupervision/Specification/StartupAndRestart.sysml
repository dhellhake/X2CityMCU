package X2CitySpecification_BatterySupervision_StartupAndRestart {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BATSUP-001'> bmsStartupChecks : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-006](../../Specification/StartupAndClassification.sysml).
            Sources: selected-unit UART acceptance (BatterySupervision.md).
            Verify: T-SW/T-SYS accepted, missing, invalid and mismatched startup evidence at normal and
            unexpected startup. Evidence / open: OI-041/061 version interpretation.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller startup, BatterySupervision shall pass exactly two
                compatibility checks only when the same current accepted Basic (0x03) response reports
                decoded software version 3.2 and 14 series groups, using the selected-unit protocol
                reference for version interpretation.
            */
        }
    }
    satisfy bmsStartupChecks by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-007'> startupCapacityReference : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: REQ-SYS-BMS-001 (../BatteryControl.md); owner-authorized pack capability
            decisions.
            Verify: T-SW/T-SYS positive, zero, negative, nonfinite, missing and unqualified capacity and
            restart. Evidence / open: Installed-unit scaling and profile calibration; standard nominal
            capacity excludes remaining capacity and learned FCC.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller startup, BatterySupervision shall capture as C_Ah
                the first finite, positive, qualified standard nominal full-pack capacity in ampere-hours
                from a current accepted Basic (0x03) response.
            */
        }
    }
    satisfy startupCapacityReference by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-021'> batteryStatusRestart : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml);
            [REQ-SYS-BMS-010](../../Specification/Reporting.sysml).
            Sources: FLT-005/006 restart handling.
            Verify: T-SW/T-SYS normal and unexpected restart with cleared and still-present faults. Evidence
            / open: Startup qualification and current-fault recognition apply anew.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller restart BatterySupervision shall discard prior-cycle
                retained battery fault effects and diagnostic evidence.
            */
        }
    }
    satisfy batteryStatusRestart by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-022'> startupRequiredEvidenceDeadline : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-006](../../Specification/StartupAndClassification.sysml). Sources: selected-unit UART acceptance and
            BATSUP-001 startup qualification.
            Verify: T-SW/T-SYS initial waiting and deadline boundaries. Open: OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller startup, BatterySupervision shall recognize a
                battery-information fault if either startup check or required startup data, including the
                capacity reference before capture, remains unavailable or unqualified 1 s after polling
                begins.
            */
        }
    }
    satisfy startupRequiredEvidenceDeadline by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-024'> capacityReferenceRetention : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml). Sources: owner-authorized regenerative and
            discharge pack capability decisions.
            Verify: T-SW/T-SYS later field changes, expiry and controller restart. Open: OI-041/061 and
            WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall retain the captured C_Ah unchanged for the controller cycle until
                the next normal or unexpected controller restart, irrespective of subsequent capacity
                updates, expiry or return.
            */
        }
    }
    satisfy capacityReferenceRetention by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
}
