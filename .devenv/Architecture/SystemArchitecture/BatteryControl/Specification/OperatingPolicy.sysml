package X2CitySpecification_BatteryControl_OperatingPolicy {
    private import X2CityComponent_BatteryControl::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMS-008'> dischargePermissiveChargeRestriction : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: REQ-SYS-BMS-001; REQ-SYS-REG-001; DEC-TMP-003.
            Planned verification: A, T-SYS. With qualified cell temperatures that permit discharge but
            exclude charge, verify charge capability is zero and otherwise eligible discharge capability
            remains available, subject to other restrictions.
            Open: integrated thermal margins and coverage remain under WS-OI-005/019.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require constraint {
            doc /*
                When qualified cell temperature permits discharge but not charging, BatteryControl shall
                report zero qualified regenerative-charge current capability while preserving any otherwise
                qualified discharge capability, subject to other applicable restrictions.
            */
        }
    }
    satisfy dischargePermissiveChargeRestriction by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-003'> dischargeVoltageCutoff : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: DEC-SOC-001; PD CON-048; OI-061.
            Planned verification: T-SYS with propulsion demand and auxiliary loads at and around the
            validated discharge-voltage endpoint.
            Open: endpoint and measurement acceptance remain controlled by the discharge-voltage calibration
            and OI-061.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargeVoltageCeiling;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargePackCeiling;
        require constraint {
            doc /*
                At or below the validated discharge cutoff voltage of the lowest qualified series group,
                BatteryControl shall set total battery discharge current capability to zero, including
                auxiliary loads. Abrupt withdrawal is permitted.
            */
        }
    }
    satisfy dischargeVoltageCutoff by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-004'> currentBranchIndependence : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: DEC-SOC-001; DEC-REG-001/006; DEC-SPD-001.
            Planned verification: A, T-SYS. Vary required charge-only and discharge-only evidence
            independently and verify the unaffected branch retains its own qualified outcome, subject to
            shared constraints and recognized common faults.
            Open: branch input acceptance remains under the applicable BatterySupervision requirements.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require constraint {
            doc /*
                BatteryControl shall assess regenerative-charge and discharge capability independently
                against their respective qualified operating evidence, subject to shared constraints and
                recognized common faults.
            */
        }
    }
    satisfy currentBranchIndependence by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-005'> dischargeVoltageRecovery : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Source: DEC-SOC-001.
            Planned verification: T-SYS at and just above the validated lowest-group discharge cutoff,
            including startup and concurrent restrictions.
            Open: positive response acceptance follows REQ-SYS-SOC-008 and the validated discharge-voltage
            calibration.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargeVoltageCeiling;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargePackCeiling;
        require constraint {
            doc /*
                When the lowest qualified series-group voltage rises strictly above the validated discharge
                cutoff, BatteryControl shall allow the discharge-voltage restriction to recover
                automatically, subject to other applicable limits.
            */
        }
    }
    satisfy dischargeVoltageRecovery by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-REG-002'> regenerativeVoltageCutoff : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: DEC-REG-001/004; PD CON-048; OI-061.
            Planned verification: A, T-SYS at and around the calibrated highest-group charge cutoff in each
            regenerative level, with other limits varied independently.
            Open: endpoint and measurement acceptance remain subject to product validation under OI-061;
            4.10 V is a provisional endpoint, not an accepted fixed value.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeVoltageCeiling;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativePackCeiling;
        require constraint {
            doc /*
                At or above the calibrated charge cutoff voltage of the highest qualified series group,
                BatteryControl shall set regenerative-charge current capability to zero. Abrupt withdrawal
                is permitted.
            */
        }
    }
    satisfy regenerativeVoltageCutoff by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-REG-012'> regenerativeVoltageRecovery : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: DEC-REG-001/004; OI-061. This top-level System Requirement has no System Requirement
            parent.
            Planned verification: A, T-SYS. Approach the calibrated highest-group charge cutoff from above
            and below with qualified voltage, temperature and path evidence; verify battery capability
            follows the voltage curve without requiring restart or an extra enable action.
            Open: endpoint, measurement accuracy and accepted response remain subject to product validation.
            RidingControl's separate regenerative re-entry guards continue to govern application of torque.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeVoltageCeiling;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativePackCeiling;
        require constraint {
            doc /*
                When the highest qualified series-group voltage falls below the calibrated charge cutoff,
                BatteryControl shall allow the regenerative-voltage restriction to recover automatically,
                subject to other applicable limits.
            */
        }
    }
    satisfy regenerativeVoltageRecovery by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
}
