package X2CitySpecification_BatterySupervision_FaultHandling {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BATSUP-017'> batteryFaultRecognition : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml);
            [REQ-SYS-BMS-010](../../Specification/Reporting.sysml).
            Sources: FLT-005/006, BMS-007 and startup mismatch.
            Verify: T-SW/T-SYS actual BMS thermal and other faults and accepted mismatch without added
            debounce. Evidence / open: Fault retention follows BATSUP-019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall recognize a battery fault immediately upon an accepted actual
                BMS-reported fault, including a BMS thermal fault, or an accepted startup version or
                group-count mismatch.
            */
        }
    }
    satisfy batteryFaultRecognition by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-019'> batteryFaultRetainedEffect : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: FLT-005/006, BMS-007 and TMP-001/002.
            Verify: T-SW/T-SYS source and path recovery, valid unrelated measurements, normal and unexpected
            restart. Evidence / open: Independent valid measurement qualification follows BMSIF.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                Upon recognition of a restart-required battery-side fault, BatterySupervision shall retain
                both operating branches unqualified with effective current limits zero until the next normal
                or unexpected controller restart, regardless of source or path recovery, live condition
                clearing or requalification.
            */
        }
    }
    satisfy batteryFaultRetainedEffect by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-023'> cyclicRequiredEvidenceFault : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml). Sources: FLT-005/006 and BMSIF-010 field
            expiry.
            Verify: T-SW/T-SYS qualified field expiry, rejected frames and optional-field loss. Open:
            OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                After a required cyclic field has qualified, BatterySupervision shall recognize a
                battery-information fault when that field expires under BMSIF-010.
            */
        }
    }
    satisfy cyclicRequiredEvidenceFault by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
}
