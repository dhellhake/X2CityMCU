package X2CitySpecification_BatterySupervision_RequirementSet {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement batterySupervisionRequirements : AbstractSoftwareRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatterySupervision
            architectural occurrence.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsObservationIdentity;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::batteryCapabilityPolicy;
        require X2CitySpecification_BatterySupervision_StartupAndRestart::bmsStartupChecks;
        require X2CitySpecification_BatterySupervision_CommonCurrentCapabilities::operatingLimitQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::actualSocQualification;
        require X2CitySpecification_BatterySupervision_RegenerativeChargeCapability::chargePathCapability;
        require X2CitySpecification_BatterySupervision_DischargeCapability::dischargePathCapability;
        require X2CitySpecification_BatterySupervision_Reporting::bmsMosDisabledStatus;
        require X2CitySpecification_BatterySupervision_FaultHandling::batteryFaultRecognition;
        require X2CitySpecification_BatterySupervision_FaultHandling::batteryFaultRetainedEffect;
        require X2CitySpecification_BatterySupervision_Reporting::batteryStatusPublication;
        require X2CitySpecification_BatterySupervision_StartupAndRestart::batteryStatusRestart;
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
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsBasicScaleQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsGroupCountQualification;
        require X2CitySpecification_BatterySupervision_MeasurementQualification::bmsQualificationWithdrawal;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsOutstandingRequestLimit;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsReadRetrySchedule;
        require X2CitySpecification_BatterySupervision_Reporting::bmsOutputPublicationTiming;
        require X2CitySpecification_BatterySupervision_BmsCommunication::bmsIdentityRequestSchedule;
        require X2CitySpecification_BatterySupervision_Reporting::bmsPackCurrentPublication;
        require X2CitySpecification_BatterySupervision_StartupAndRestart::startupRequiredEvidenceDeadline;
        require X2CitySpecification_BatterySupervision_FaultHandling::cyclicRequiredEvidenceFault;
        require X2CitySpecification_BatterySupervision_StartupAndRestart::capacityReferenceRetention;
        require X2CitySpecification_BatterySupervision_Reporting::batteryFaultReportEvidence;
        require X2CitySpecification_BatterySupervision_Reporting::lowDischargeVoltageStatus;
        require X2CitySpecification_BatterySupervision_Reporting::batteryStatusNotFunctionalInput;
    }
    satisfy batterySupervisionRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
    doc /*
        Requirement status is Draft unless a record states its canonical historical approval. Named
        verification methods, source links and OI/WS dependencies are planning evidence; numerical
        acceptance criteria remain controlled qualification inputs.
    */

    doc /*
        Output responsibility and system integration retained from the capability-policy record:
        - Operating battery capability: Keep charge and discharge capabilities distinct, including qualified
        effective current limits and charge-path acceptance. The selected temperature and group-voltage
        curves determine ordinary operating ceilings; configured supplied-BMS protection remains separate.
        Unqualified required evidence leaves affected current at zero and dependent operation unavailable.
        - Operation-specific battery restrictions: Distinguish regenerative charge acceptance from discharge
        capability, including auxiliary discharge. BatterySupervision includes lowest-group discharge and
        highest-group regenerative voltage cutoffs in its respective effective current limits. A temperature
        where discharge current remains available but effective charge current is zero is an ordinary
        regeneration restriction under DEC-TMP-003.
        - Riding integration: BatterySupervision publishes qualified battery assessment and fault evidence.
        A newly available battery envelope alone does not determine RidingControl authority or its session
        state.
        - Physical protection: LE-EPCS and the supplied BMS/other derived protection contributors retain the
        system obligation for energized paths, residual/generated energy, faults, and host/UART loss. Vendor
        protection release is an observation, not automatic restoration of effective limits or a system
        session. Only the information-policy contribution is allocated here. Calibration, source accuracy,
        diagnostics, actual protection, and parent system acceptance remain open; no software unit, inverter
        algorithm, or circuit is selected.
    */
    doc /*
        Requirement status is Draft unless a record states its canonical historical approval. Named
        verification methods, source links and OI/WS dependencies are planning evidence; numerical
        acceptance criteria remain controlled qualification inputs.
    */

    doc /*
        Output responsibility and system integration retained from the capability-policy record:
        - Operating battery capability: Keep charge and discharge capabilities distinct, including qualified
        effective current limits and charge-path acceptance. The selected temperature and group-voltage
        curves determine ordinary operating ceilings; configured supplied-BMS protection remains separate.
        Unqualified required evidence leaves affected current at zero and dependent operation unavailable.
        - Operation-specific battery restrictions: Distinguish regenerative charge acceptance from discharge
        capability, including auxiliary discharge. BatterySupervision includes lowest-group discharge and
        highest-group regenerative voltage cutoffs in its respective effective current limits. A temperature
        where discharge current remains available but effective charge current is zero is an ordinary
        regeneration restriction under DEC-TMP-003.
        - Riding integration: BatterySupervision publishes qualified battery assessment and fault evidence.
        A newly available battery envelope alone does not determine RidingControl authority or its session
        state.
        - Physical protection: LE-EPCS and the supplied BMS/other derived protection contributors retain the
        system obligation for energized paths, residual/generated energy, faults, and host/UART loss. Vendor
        protection release is an observation, not automatic restoration of effective limits or a system
        session. Only the information-policy contribution is allocated here. Calibration, source accuracy,
        diagnostics, actual protection, and parent system acceptance remain open; no software unit, inverter
        algorithm, or circuit is selected.
    */
    doc /*
        Requirement status is Draft unless a record states its canonical historical approval. Named
        verification methods, source links and OI/WS dependencies are planning evidence; numerical
        acceptance criteria remain controlled qualification inputs.
    */

    doc /*
        Output responsibility and system integration retained from the capability-policy record:
        - Operating battery capability: Keep charge and discharge capabilities distinct, including qualified
        effective current limits and charge-path acceptance. The selected temperature and group-voltage
        curves determine ordinary operating ceilings; configured supplied-BMS protection remains separate.
        Unqualified required evidence leaves affected current at zero and dependent operation unavailable.
        - Operation-specific battery restrictions: Distinguish regenerative charge acceptance from discharge
        capability, including auxiliary discharge. BatterySupervision includes lowest-group discharge and
        highest-group regenerative voltage cutoffs in its respective effective current limits. A temperature
        where discharge current remains available but effective charge current is zero is an ordinary
        regeneration restriction under DEC-TMP-003.
        - Riding integration: BatterySupervision publishes qualified battery assessment and fault evidence.
        A newly available battery envelope alone does not determine RidingControl authority or its session
        state.
        - Physical protection: LE-EPCS and the supplied BMS/other derived protection contributors retain the
        system obligation for energized paths, residual/generated energy, faults, and host/UART loss. Vendor
        protection release is an observation, not automatic restoration of effective limits or a system
        session. Only the information-policy contribution is allocated here. Calibration, source accuracy,
        diagnostics, actual protection, and parent system acceptance remain open; no software unit, inverter
        algorithm, or circuit is selected.
    */
}
