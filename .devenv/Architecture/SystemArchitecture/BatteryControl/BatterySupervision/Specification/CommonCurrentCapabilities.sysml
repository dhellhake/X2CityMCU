package X2CitySpecification_BatterySupervision_CommonCurrentCapabilities {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMSPOL-001'> batteryCapabilityPolicy : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-006, REQ-SYS-BMS-007, REQ-SYS-BMS-008, REQ-SYS-SOC-003, REQ-SYS-SOC-004,
            REQ-SYS-SOC-005, REQ-SYS-REG-002 and REQ-SYS-REG-012 (../BatteryControl.sysml).
            Source: [REQ-SYS-BMS-001](../../../Specification/BatteryControl.sysml).
            Sources: Battery Integration qualification and response budget; event/recovery matrix.
            Verify: A, T-SW/T-SYS/T-FI independent branch outputs and restriction reasons. Evidence / open:
            IF-A-003/009; OI-041/045/048/049/061; physical protection remains separate.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish the independent charge and discharge branch qualifications,
                effective current limits and restriction reasons on BatteryOperatingLimits.
            */
        }
    }
    satisfy batteryCapabilityPolicy by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-002'> operatingLimitQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-006](../../Specification/StartupAndClassification.sysml).
            Sources: BAT-001; Battery Integration per-consumer acceptance; owner decision 2026-10-28.
            Verify: I/A/T-SW/T-SYS/T-FI startup and independent shared/branch loss, including immediate
            invalid-T2 withdrawal and BMSIF-020 publication. Evidence / open: OI-041/049/061;
            WS-OI-007/018/019 input subsets, temperature and measurement accuracy.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish a branch unqualified with a zero effective current limit
                whenever either startup check has not passed or any required evidence for that branch is
                unqualified, including an unknown path state. Required evidence comprises the captured
                capacity, qualified T2, all fourteen group voltages, the applicable voltage calibration and
                the applicable path state; charge-only evidence does not gate discharge and discharge-only
                evidence does not gate charge. Actual SOC and pack current are not required evidence.
            */
        }
    }
    satisfy operatingLimitQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-016'> voltageDeratingCalibrationQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: controlled compiled calibration and applicable pack/cell envelopes.
            Verify: T-SW/T-SYS missing, nonfinite, nonpositive, reversed or equal endpoints, configuration
            mismatch and independent branches. Evidence / open: Numerical pack/cell envelope validation and
            release evidence remain open.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify each voltage derating calibration pair independently only
                when both values are present, finite, positive, correspond to the controlled compiled
                configuration and lie within the applicable qualified pack and cell envelopes, with
                discharge cutoff less than discharge full-current voltage or regenerative full-current
                voltage less than regenerative cutoff voltage, respectively.
            */
        }
    }
    satisfy voltageDeratingCalibrationQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
}
