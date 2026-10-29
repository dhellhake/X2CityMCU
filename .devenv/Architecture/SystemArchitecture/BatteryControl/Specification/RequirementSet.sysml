package X2CitySpecification_BatteryControl_RequirementSet {
    private import X2CityComponent_BatteryControl::*;
    private import RequirementTypes::*;

    requirement batteryControlRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryControl architectural
            occurrence.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatteryControl_AssemblySelection::removableBatteryAssemblySelection;
        require X2CitySpecification_BatteryControl_BmsIntegration::integratedBmsConfiguration;
        require X2CitySpecification_BatteryControl_BmsIntegration::batteryInterfaceProvision;
        require X2CitySpecification_BatteryControl_StartupAndClassification::batteryStartupQualification;
        require X2CitySpecification_BatteryControl_StartupAndClassification::batteryOperatingClassification;
        require X2CitySpecification_BatteryControl_OperatingPolicy::dischargePermissiveChargeRestriction;
        require X2CitySpecification_BatteryControl_OperatingPolicy::dischargeVoltageCutoff;
        require X2CitySpecification_BatteryControl_OperatingPolicy::currentBranchIndependence;
        require X2CitySpecification_BatteryControl_OperatingPolicy::dischargeVoltageRecovery;
        require X2CitySpecification_BatteryControl_OperatingPolicy::regenerativeVoltageCutoff;
        require X2CitySpecification_BatteryAssembly_RequirementSet::batteryAssemblyRequirements;
        require X2CitySpecification_BatterySupervision_RequirementSet::batterySupervisionRequirements;
        require X2CitySpecification_BatteryControl_Reporting::batteryStatusReporting;
        require X2CitySpecification_BatteryControl_OperatingPolicy::regenerativeVoltageRecovery;
    }
    satisfy batteryControlRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    // Historical source note, retained from the pre-migration model.
    doc /*
        Native requirement derivations connect only requirement usages modeled in SysML. Parent records
        maintained in Markdown remain source links in the owning requirement documentation; this model does
        not create proxy requirements for those records.
    */

    #derivation connection def DischargeVoltageCutoffDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive dischargeVoltageCeiling : Requirements::RequirementCheck;
        end #derive dischargePackCeiling : Requirements::RequirementCheck;
    }

    #derivation connection dischargeVoltageCutoffDerivation : DischargeVoltageCutoffDerivation {
        end original ::> X2CitySpecification_BatteryControl_OperatingPolicy::dischargeVoltageCutoff;
        end batteryCapabilityPolicy ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        end dischargeVoltageCeiling ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargeVoltageCeiling;
        end dischargePackCeiling ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargePackCeiling;
    }

    #derivation connection def CurrentBranchIndependenceDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
    }

    #derivation connection currentBranchIndependenceDerivation : CurrentBranchIndependenceDerivation {
        end original ::> X2CitySpecification_BatteryControl_OperatingPolicy::currentBranchIndependence;
        end batteryCapabilityPolicy ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
    }

    #derivation connection def DischargeVoltageRecoveryDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive dischargeVoltageCeiling : Requirements::RequirementCheck;
        end #derive dischargePackCeiling : Requirements::RequirementCheck;
    }

    #derivation connection dischargeVoltageRecoveryDerivation : DischargeVoltageRecoveryDerivation {
        end original ::> X2CitySpecification_BatteryControl_OperatingPolicy::dischargeVoltageRecovery;
        end batteryCapabilityPolicy ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        end dischargeVoltageCeiling ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargeVoltageCeiling;
        end dischargePackCeiling ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargePackCeiling;
    }

    #derivation connection def RegenerativeVoltageCutoffDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive regenerativeVoltageCeiling : Requirements::RequirementCheck;
        end #derive regenerativePackCeiling : Requirements::RequirementCheck;
    }

    #derivation connection regenerativeVoltageCutoffDerivation : RegenerativeVoltageCutoffDerivation {
        end original ::> X2CitySpecification_BatteryControl_OperatingPolicy::regenerativeVoltageCutoff;
        end batteryCapabilityPolicy ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        end regenerativeVoltageCeiling ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeVoltageCeiling;
        end regenerativePackCeiling ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativePackCeiling;
    }

    #derivation connection def RegenerativeVoltageRecoveryDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive regenerativeVoltageCeiling : Requirements::RequirementCheck;
        end #derive regenerativePackCeiling : Requirements::RequirementCheck;
    }

    #derivation connection regenerativeVoltageRecoveryDerivation : RegenerativeVoltageRecoveryDerivation {
        end original ::> X2CitySpecification_BatteryControl_OperatingPolicy::regenerativeVoltageRecovery;
        end batteryCapabilityPolicy ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        end regenerativeVoltageCeiling ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeVoltageCeiling;
        end regenerativePackCeiling ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativePackCeiling;
    }

    #derivation connection def BatteryAssemblySelectionDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive cellBankComposition : Requirements::RequirementCheck;
        end #derive packIntegration : Requirements::RequirementCheck;
        end #derive bmsIdentity : Requirements::RequirementCheck;
    }

    #derivation connection batteryAssemblySelectionDerivation : BatteryAssemblySelectionDerivation {
        end original ::> X2CitySpecification_BatteryControl_AssemblySelection::removableBatteryAssemblySelection;
        end cellBankComposition ::> X2CitySpecification_Cells_CellBankComposition::fixedCellBankComposition;
        end packIntegration ::> X2CitySpecification_BatteryAssembly_AssemblyIntegration::removablePackIntegration;
        end bmsIdentity ::> X2CitySpecification_Bms_BmsIdentityAndConfiguration::selectedBmsIdentity;
    }

    #derivation connection def BmsConfigurationDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive effectiveConfiguration : Requirements::RequirementCheck;
        end #derive bmsBasicInformationDecoding : Requirements::RequirementCheck;
        end #derive startupAssessment : Requirements::RequirementCheck;
        end #derive bmsGroupCountQualification : Requirements::RequirementCheck;
        end #derive effectiveBmsCurrentProtection : Requirements::RequirementCheck;
        end #derive effectiveBmsTemperatureProtection : Requirements::RequirementCheck;
    }

    #derivation connection bmsConfigurationDerivation : BmsConfigurationDerivation {
        end original ::> X2CitySpecification_BatteryControl_BmsIntegration::integratedBmsConfiguration;
        end effectiveConfiguration ::> X2CitySpecification_Bms_BmsIdentityAndConfiguration::effectiveBmsConfiguration;
        end bmsBasicInformationDecoding ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicInformationDecoding;
        end startupAssessment ::> X2CitySpecification_BatteryControl_StartupAndClassification::batteryStartupQualification;
        end bmsGroupCountQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsGroupCountQualification;
        end effectiveBmsCurrentProtection ::> X2CitySpecification_Bms_BmsIdentityAndConfiguration::effectiveBmsCurrentProtection;
        end effectiveBmsTemperatureProtection ::> X2CitySpecification_Bms_BmsIdentityAndConfiguration::effectiveBmsTemperatureProtection;
    }

    #derivation connection def BmsInterfaceDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive measurementSources : Requirements::RequirementCheck;
        end #derive informationQualification : Requirements::RequirementCheck;
        end #derive actualSocQualification : Requirements::RequirementCheck;
        end #derive startupAssessment : Requirements::RequirementCheck;
        end #derive operatingClassification : Requirements::RequirementCheck;
        end #derive bmsReadCommandRestriction : Requirements::RequirementCheck;
        end #derive bmsResponseValidation : Requirements::RequirementCheck;
        end #derive bmsTransactionAcceptance : Requirements::RequirementCheck;
        end #derive bmsBasicInformationDecoding : Requirements::RequirementCheck;
        end #derive bmsGroupVoltageQualification : Requirements::RequirementCheck;
        end #derive bmsIdentityInformationDecoding : Requirements::RequirementCheck;
        end #derive bmsTemperatureQualification : Requirements::RequirementCheck;
        end #derive bmsFieldQualification : Requirements::RequirementCheck;
        end #derive bmsObservationAgeQualification : Requirements::RequirementCheck;
        end #derive bmsObservationRetention : Requirements::RequirementCheck;
        end #derive bmsSourceRequalification : Requirements::RequirementCheck;
        end #derive bmsReadServiceTiming : Requirements::RequirementCheck;
        end #derive bmsBasicScaleQualification : Requirements::RequirementCheck;
        end #derive bmsGroupCountQualification : Requirements::RequirementCheck;
        end #derive bmsQualificationWithdrawal : Requirements::RequirementCheck;
        end #derive bmsOutstandingRequestLimit : Requirements::RequirementCheck;
        end #derive bmsReadRetrySchedule : Requirements::RequirementCheck;
        end #derive bmsOutputPublicationTiming : Requirements::RequirementCheck;
        end #derive bmsIdentityRequestSchedule : Requirements::RequirementCheck;
        end #derive bmsPackCurrentPublication : Requirements::RequirementCheck;
        end #derive statusReporting : Requirements::RequirementCheck;
    }

    #derivation connection bmsInterfaceDerivation : BmsInterfaceDerivation {
        end original ::> X2CitySpecification_BatteryControl_BmsIntegration::batteryInterfaceProvision;
        end measurementSources ::> X2CitySpecification_Bms_BmsMeasurementSources::bmsMeasurementSources;
        end informationQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsObservationIdentity;
        end actualSocQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::actualSocQualification;
        end startupAssessment ::> X2CitySpecification_BatteryControl_StartupAndClassification::batteryStartupQualification;
        end operatingClassification ::> X2CitySpecification_BatteryControl_StartupAndClassification::batteryOperatingClassification;
        end bmsReadCommandRestriction ::> X2CitySpecification_BatterySupervision_BmsCommunication::bmsReadCommandRestriction;
        end bmsResponseValidation ::> X2CitySpecification_BatterySupervision_BmsCommunication::bmsResponseValidation;
        end bmsTransactionAcceptance ::> X2CitySpecification_BatterySupervision_BmsCommunication::bmsTransactionAcceptance;
        end bmsBasicInformationDecoding ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicInformationDecoding;
        end bmsGroupVoltageQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsGroupVoltageQualification;
        end bmsIdentityInformationDecoding ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsIdentityInformationDecoding;
        end bmsTemperatureQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsTemperatureQualification;
        end bmsFieldQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsFieldQualification;
        end bmsObservationAgeQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsObservationAgeQualification;
        end bmsObservationRetention ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsObservationRetention;
        end bmsSourceRequalification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsSourceRequalification;
        end bmsReadServiceTiming ::> X2CitySpecification_BatterySupervision_BmsCommunication::bmsReadServiceTiming;
        end bmsBasicScaleQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicScaleQualification;
        end bmsGroupCountQualification ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsGroupCountQualification;
        end bmsQualificationWithdrawal ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsQualificationWithdrawal;
        end bmsOutstandingRequestLimit ::> X2CitySpecification_BatterySupervision_BmsCommunication::bmsOutstandingRequestLimit;
        end bmsReadRetrySchedule ::> X2CitySpecification_BatterySupervision_BmsCommunication::bmsReadRetrySchedule;
        end bmsOutputPublicationTiming ::> X2CitySpecification_BatterySupervision_Reporting::bmsOutputPublicationTiming;
        end bmsIdentityRequestSchedule ::> X2CitySpecification_BatterySupervision_BmsCommunication::bmsIdentityRequestSchedule;
        end bmsPackCurrentPublication ::> X2CitySpecification_BatterySupervision_Reporting::bmsPackCurrentPublication;
        end statusReporting ::> X2CitySpecification_BatteryControl_Reporting::batteryStatusReporting;
    }

    #derivation connection def StartupQualificationDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive bmsStartupChecks : Requirements::RequirementCheck;
        end #derive operatingLimitQualification : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive bmsBasicInformationDecoding : Requirements::RequirementCheck;
        end #derive startupRequiredEvidenceDeadline : Requirements::RequirementCheck;
    }

    #derivation connection startupQualificationDerivation : StartupQualificationDerivation {
        end original ::> X2CitySpecification_BatteryControl_StartupAndClassification::batteryStartupQualification;
        end bmsStartupChecks ::> X2CitySpecification_BatterySupervision_StartupAndRestart::bmsStartupChecks;
        end operatingLimitQualification ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::operatingLimitQualification;
        end batteryCapabilityPolicy ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        end bmsBasicInformationDecoding ::> X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicInformationDecoding;
        end startupRequiredEvidenceDeadline ::> X2CitySpecification_BatterySupervision_StartupAndRestart::startupRequiredEvidenceDeadline;
    }

    #derivation connection def OperatingClassificationDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive chargePathCapability : Requirements::RequirementCheck;
        end #derive dischargePathCapability : Requirements::RequirementCheck;

        end #derive batteryFaultRecognition : Requirements::RequirementCheck;
        end #derive batteryFaultRetainedEffect : Requirements::RequirementCheck;

        end #derive batteryStatusRestart : Requirements::RequirementCheck;
        end #derive startupCapacityReference : Requirements::RequirementCheck;
        end #derive regenerativeBaseCurrent : Requirements::RequirementCheck;
        end #derive regenerativeTemperatureCeiling : Requirements::RequirementCheck;
        end #derive regenerativeVoltageCeiling : Requirements::RequirementCheck;
        end #derive regenerativePackCeiling : Requirements::RequirementCheck;
        end #derive dischargeBaseCurrent : Requirements::RequirementCheck;
        end #derive dischargeTemperatureCeiling : Requirements::RequirementCheck;
        end #derive dischargeVoltageCeiling : Requirements::RequirementCheck;
        end #derive dischargePackCeiling : Requirements::RequirementCheck;
        end #derive voltageDeratingCalibrationQualification : Requirements::RequirementCheck;
        end #derive cyclicRequiredEvidenceFault : Requirements::RequirementCheck;
        end #derive capacityReferenceRetention : Requirements::RequirementCheck;
        end #derive batteryStatusNotFunctionalInput : Requirements::RequirementCheck;
    }

    #derivation connection operatingClassificationDerivation : OperatingClassificationDerivation {
        end original ::> X2CitySpecification_BatteryControl_StartupAndClassification::batteryOperatingClassification;
        end batteryCapabilityPolicy ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        end chargePathCapability ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::chargePathCapability;
        end dischargePathCapability ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargePathCapability;

        end batteryFaultRecognition ::> X2CitySpecification_BatterySupervision_FaultHandling::batteryFaultRecognition;
        end batteryFaultRetainedEffect ::> X2CitySpecification_BatterySupervision_FaultHandling::batteryFaultRetainedEffect;

        end batteryStatusRestart ::> X2CitySpecification_BatterySupervision_StartupAndRestart::batteryStatusRestart;
        end startupCapacityReference ::> X2CitySpecification_BatterySupervision_StartupAndRestart::startupCapacityReference;
        end regenerativeBaseCurrent ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeBaseCurrent;
        end regenerativeTemperatureCeiling ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeTemperatureCeiling;
        end regenerativeVoltageCeiling ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativeVoltageCeiling;
        end regenerativePackCeiling ::> X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::regenerativePackCeiling;
        end dischargeBaseCurrent ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargeBaseCurrent;
        end dischargeTemperatureCeiling ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargeTemperatureCeiling;
        end dischargeVoltageCeiling ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargeVoltageCeiling;
        end dischargePackCeiling ::> X2CitySpecification_BatterySupervision_DischargeCapability::dischargePackCeiling;
        end voltageDeratingCalibrationQualification ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::voltageDeratingCalibrationQualification;
        end cyclicRequiredEvidenceFault ::> X2CitySpecification_BatterySupervision_FaultHandling::cyclicRequiredEvidenceFault;
        end capacityReferenceRetention ::> X2CitySpecification_BatterySupervision_StartupAndRestart::capacityReferenceRetention;
        end batteryStatusNotFunctionalInput ::> X2CitySpecification_BatterySupervision_Reporting::batteryStatusNotFunctionalInput;
    }

    #derivation connection def BatteryStatusReportingDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive bmsMosDisabledStatus : Requirements::RequirementCheck;
        end #derive batteryFaultRecognition : Requirements::RequirementCheck;
        end #derive batteryStatusPublication : Requirements::RequirementCheck;
        end #derive batteryStatusRestart : Requirements::RequirementCheck;
        end #derive batteryFaultReportEvidence : Requirements::RequirementCheck;
        end #derive lowDischargeVoltageStatus : Requirements::RequirementCheck;
    }

    #derivation connection batteryStatusReportingDerivation : BatteryStatusReportingDerivation {
        end original ::> X2CitySpecification_BatteryControl_Reporting::batteryStatusReporting;
        end bmsMosDisabledStatus ::> X2CitySpecification_BatterySupervision_Reporting::bmsMosDisabledStatus;
        end batteryFaultRecognition ::> X2CitySpecification_BatterySupervision_FaultHandling::batteryFaultRecognition;
        end batteryStatusPublication ::> X2CitySpecification_BatterySupervision_Reporting::batteryStatusPublication;
        end batteryStatusRestart ::> X2CitySpecification_BatterySupervision_StartupAndRestart::batteryStatusRestart;
        end batteryFaultReportEvidence ::> X2CitySpecification_BatterySupervision_Reporting::batteryFaultReportEvidence;
        end lowDischargeVoltageStatus ::> X2CitySpecification_BatterySupervision_Reporting::lowDischargeVoltageStatus;
    }

    #derivation connection def ChargeRestrictionDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
    }

    #derivation connection chargeRestrictionDerivation : ChargeRestrictionDerivation {
        end original ::> X2CitySpecification_BatteryControl_OperatingPolicy::dischargePermissiveChargeRestriction;
        end batteryCapabilityPolicy ::> X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
    }
}
