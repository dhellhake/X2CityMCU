package X2CitySpecification_BatteryControl_BmsIntegration {
    private import X2CityComponent_BatteryControl::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMS-002'> integratedBmsConfiguration : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL. Acceptance criteria:
            [configuration baseline](../BatteryControl.md#configuration-acceptance-baseline) and
            [SOC source acceptance](../BatteryControl.md#soc-source-acceptance).
            Sources: PD OI-041/061 and CON-048–050;
            [BAT-001](../BatteryAssembly/BatteryAssembly.md#fixed-inputs-and-provenance); configuration and SOC
            acceptance criteria.
            Planned verification: I, A, T-SYS. Review accepted commissioning configuration and integration
            evidence against the referenced criteria for the fixed 14S5P35E pack.
            Open: effective settings, margins, calibration and acceptance evidence remain under
            OI-041/049/061.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatteryAssembly_RequirementSet::assemblyConfigurationRequirements;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicInformationDecoding;
        require constraint {
            doc /*
                BatteryControl shall integrate the selected BMS with an effective configuration accepted
                against the linked pack-configuration and SOC-source criteria for the fixed 14S5P35E
                assembly.
            */
        }
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsGroupCountQualification;
    }
    satisfy integratedBmsConfiguration by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-003'> batteryInterfaceProvision : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: PD OI-041/047/061;
            [BAT-001 UART information contract](../BatteryAssembly/BatteryAssembly.md#fixed-inputs-and-provenance);
            [selected-unit read acceptance](../BatterySupervision/BatterySupervision.md#selected-unit-uart-read-acceptance-contract)
            and [per-consumer acceptance](../BatteryControl.md#per-consumer-information-acceptance)
            criteria; SOC/fault integration policy.
            Planned verification: I, T-SYS. Check acquisition and internal qualification of required source
            fields against the cited contracts; separately observe actual SOC and signed pack current at
            their published interfaces and compare values and validity with independent references.
            Open: installed schema, accuracy, supported fields and source timing remain to be qualified
            under WS-OI-005/018/019 and OI-041/049. Signed current is positive when charging and negative
            when discharging; reported RSOC alone does not establish actual SOC.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatteryAssembly_RequirementSet::assemblySourceInformationRequirements;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsObservationIdentity;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::actualSocQualification;
        require X2CitySpecification_BatterySupervision_Reporting::bmsPackCurrentPublication;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsReadCommandRestriction;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsResponseValidation;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsTransactionAcceptance;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicInformationDecoding;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsGroupVoltageQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsIdentityInformationDecoding;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsTemperatureQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsFieldQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsObservationAgeQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsObservationRetention;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsSourceRequalification;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsReadServiceTiming;
        require constraint {
            doc /*
                BatteryControl shall acquire and internally qualify each selected BMS source observation
                required for battery supervision against its applicable source and consumer acceptance
                criteria.
            */
        }
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicScaleQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsGroupCountQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsQualificationWithdrawal;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsOutstandingRequestLimit;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsReadRetrySchedule;
        require X2CitySpecification_BatterySupervision_Reporting::bmsOutputPublicationTiming;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsIdentityRequestSchedule;
        require X2CitySpecification_BatterySupervision_Reporting::bmsPackCurrentPublication;
    }
    satisfy batteryInterfaceProvision by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
}
