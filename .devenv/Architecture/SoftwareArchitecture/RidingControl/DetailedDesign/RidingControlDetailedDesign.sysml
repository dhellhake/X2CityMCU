package X2CityDetailedComponent_RidingControlDetailedDesign {
    public import X2CityDetailedUnit_SetState::*;
    public import X2CityDetailedUnit_SessionEligibility::*;
    public import X2CityDetailedUnit_SessionReport::*;
    public import X2CityDetailedUnit_DemandArbiter::*;
    public import X2CitySoftwareComponent_RidingControl::*;
    part def RidingControlDetailedDesign :> X2CitySoftwareComponent_RidingControl::RidingControl {
        /* Realizes the single RidingControl runtime component through setting state, session
           eligibility, report publication and demand arbitration. The enclosing component
           remains the sole vehicle boundary for authority, torque, fault and sleep outputs. */
        part setState:RidingSettingsStateManager;
        part sessionEligibility:SessionEligibilityEvaluator;
        part sessionReport:SessionReportPublisher;
        part demandArbiter:DemandArbiter;
        flow vExecutionTimeToSetState from executionTimeIn.payload to setState.executionTimeIn.payload;
        flow vExecutionTimeToSessionEligibility from executionTimeIn.payload to sessionEligibility.executionTimeIn.payload;
        flow vExecutionTimeToSessionReport from executionTimeIn.payload to sessionReport.executionTimeIn.payload;
        flow vExecutionTimeToDemandArbiter from executionTimeIn.payload to demandArbiter.executionTimeIn.payload;
        bind compiledDemandPolicyCalibration = demandArbiter.compiledDemandPolicyCalibration;
        bind compiledCalibrationId = demandArbiter.compiledCalibrationId;
        bind compiledCalibrationValid = demandArbiter.compiledCalibrationValid;
        bind ridingAuthorityOut.payload = sessionEligibility.authorityOut.payload;
        bind wheelTorqueCommandOut.payload = demandArbiter.commandOut.payload;
        bind selectedFaultIndicationOut.selectedFaultIndication = sessionReport.selectedFaultOut.selectedFaultIndication;
        bind sleepRequestOut.request = sessionEligibility.sleepRequestOut.request;
        flow vRidingRequestToSet from hmiRiderSettingsRequestIn.payload to setState.requestedSettingsIn.payload;
        flow vRidingRequestToEligibility from hmiRiderSettingsRequestIn.payload to sessionEligibility.ridingSettingsIn.payload;
        flow vRidingAcceleratorToSet from acceleratorPositionIn.acceleratorPosition to setState.acceleratorPositionIn.acceleratorPosition;
        flow vRidingAcceleratorToEligibility from acceleratorPositionIn.acceleratorPosition to sessionEligibility.acceleratorPositionIn.acceleratorPosition;
        flow vRidingAcceleratorToDemand from acceleratorPositionIn.acceleratorPosition to demandArbiter.acceleratorIn.payload;
        flow vRidingBrakeToEligibility from brakeLeverStateIn.brakeLeverState to sessionEligibility.brakeLeverStateIn.brakeLeverState;
        flow vRidingBrakeToDemand from brakeLeverStateIn.brakeLeverState to demandArbiter.brakeLeverStateIn.brakeLeverState;
        flow vRidingMotionToSet from qualifiedVehicleMotionIn.payload to setState.motionIn.payload;
        flow vRidingMotionToEligibility from qualifiedVehicleMotionIn.payload to sessionEligibility.motionIn.payload;
        flow vRidingMotionToDemand from qualifiedVehicleMotionIn.payload to demandArbiter.motionIn.payload;
        flow vRidingMotorPositionToEligibility from motorPositionIn.payload to sessionEligibility.motorPositionIn.payload;
        flow vRidingTemperatureToEligibility from qualifiedTemperatureIn.payload to sessionEligibility.qualifiedTemperatureIn.payload;
        flow vRidingTractionConditionToEligibility from tractionConditionEvidenceIn.payload to sessionEligibility.tractionConditionEvidenceIn.payload;
        flow vRidingOperationToEligibility from vehicleOperationRequestIn.request to sessionEligibility.vehicleOperationRequestIn.request;
        flow vRidingInitializationToEligibility from runtimeInitializationIn.initialization to sessionEligibility.runtimeInitializationIn.initialization;
        flow vRidingBatteryFaultStatusToEligibility from batteryFaultStatusIn.faultStatus to sessionEligibility.batteryFaultStatusIn.payload;
        flow vRidingBatteryLimitsToEligibility from batteryOperatingLimitsIn.operatingLimits to sessionEligibility.batteryOperatingLimitsIn.payload;
        flow vRidingSocToEligibility from stateOfChargeIn.stateOfCharge to sessionEligibility.stateOfChargeIn.payload;
        flow vRidingSocToDemand from stateOfChargeIn.stateOfCharge to demandArbiter.stateOfChargeIn.payload;
        flow vRidingActiveSettingsToDemand from setState.activeSettingsOut.payload to demandArbiter.activeSettingsIn.payload;
        flow vRidingSettingsStateToEligibility from setState.stateOut.payload to sessionEligibility.settingsStateIn.payload;
        flow vRidingEligibilityToReport from sessionEligibility.eligibilityObservationOut.payload to sessionReport.eligibilityIn.payload;
        flow vRidingBatteryLimitsToReport from batteryOperatingLimitsIn.operatingLimits to sessionReport.batteryOperatingLimitsIn.payload;
        flow vRidingSocToReport from stateOfChargeIn.stateOfCharge to sessionReport.stateOfChargeIn.payload;
        flow vRidingAuthorityToDemand from sessionEligibility.authorityOut.payload to demandArbiter.authorityIn.payload;
        flow vRidingBatteryLimitsToDemand from batteryOperatingLimitsIn.operatingLimits to demandArbiter.batteryOperatingLimitsIn.payload;
        flow vRidingActualOutputToDemand from actualTractionOutputIn.payload to demandArbiter.actualOutputIn.payload;
        flow vRidingContextToEligibility from platformContextIn.payload to sessionEligibility.platformContextIn.payload;
        flow vRidingHealthToEligibility from platformHealthIn.payload to sessionEligibility.platformHealthIn.payload;
        flow vRidingContextToSettings from platformContextIn.payload to setState.platformContextIn.payload;
        flow vRidingHealthToSettings from platformHealthIn.payload to setState.platformHealthIn.payload;
        flow vRidingContextToDemand from platformContextIn.payload to demandArbiter.platformContextIn.payload;
        flow vRidingHealthToDemand from platformHealthIn.payload to demandArbiter.platformHealthIn.payload;
    }
}
