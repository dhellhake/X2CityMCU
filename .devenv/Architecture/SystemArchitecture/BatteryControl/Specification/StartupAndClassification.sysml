package X2CitySpecification_BatteryControl_StartupAndClassification {
    private import X2CityComponent_BatteryControl::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMS-006'> batteryStartupQualification : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources:
            [REQ-SYS-STA-006](../../Specification/PowerStartupAndFaults.sysml);
            BATSUP-001/002; BMSIF-005; BAT-001.
            Planned verification: T-SYS, T-FI. At normal and unexpected restart, withhold or invalidate
            startup and branch input evidence; verify branch qualification and effective current outputs
            before and after required evidence passes.
            Open: per-consumer source and protection qualification remain under OI-041/049/061 and
            WS-OI-007/018/019.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_StartupAndRestart::bmsStartupChecks;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::operatingLimitQualification;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicInformationDecoding;
        require constraint {
            doc /*
                Following each controller startup or restart, BatteryControl shall keep each discharge or
                regenerative-charge assessment unqualified, with zero effective current, until that
                assessment’s required startup checks and input qualification have passed.
            */
        }
        require X2CitySpecification_BatterySupervision_StartupAndRestart::startupRequiredEvidenceDeadline;
    }
    satisfy batteryStartupQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-007'> batteryOperatingClassification : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: REQ-SYS-BMS-005; BAT-001; DEC-FLT-005–009 and DEC-TMP-001–003.
            Planned verification: A, T-SYS, T-FI. Exercise qualified and unqualified branch inputs and
            ordinary restrictions; compare each published effective current limit with its applicable
            assessment.
            Open: recognition coverage, timing, physical protection correspondence and
            configuration-specific acceptance remain under OI-041/049/061.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::chargePathCapability;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargePathCapability;
        require X2CitySpecification_BatterySupervision_FaultHandling::batteryFaultRecognition;
        require X2CitySpecification_BatterySupervision_FaultHandling::batteryFaultRetainedEffect;
        require X2CitySpecification_BatterySupervision_StartupAndRestart::startupCapacityReference;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeBaseCurrent;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeTemperatureCeiling;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeVoltageCeiling;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativePackCeiling;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargeBaseCurrent;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargeTemperatureCeiling;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargeVoltageCeiling;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargePackCeiling;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::voltageDeratingCalibrationQualification;
        require constraint {
            doc /*
                BatteryControl shall publish independently qualified effective current limits for
                regenerative charge and discharge based on their applicable battery operating assessments.
            */
        }
        require X2CitySpecification_BatterySupervision_FaultHandling::cyclicRequiredEvidenceFault;
        require X2CitySpecification_BatterySupervision_StartupAndRestart::capacityReferenceRetention;
        require X2CitySpecification_BatterySupervision_Reporting::batteryStatusNotFunctionalInput;
    }
    satisfy batteryOperatingClassification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
}
