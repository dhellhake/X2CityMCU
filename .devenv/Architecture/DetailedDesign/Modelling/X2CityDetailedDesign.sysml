// SysML v2 textual model: vehicle detailed-design unit composition.
// External equipment is outside this vehicle model.
package X2CityDetailedDesign {
    public import X2CityDetailedSharedContracts::*;
    public import X2CityDetailedUnit_SetState::*;
    public import X2CityDetailedUnit_SessionEligibility::*;
    public import X2CityDetailedUnit_SessionReport::*;
    public import X2CityDetailedUnit_DemandArbiter::*;
    public import X2CityDetailedUnit_HmiAdapter::*;
    public import X2CityDetailedUnit_LightMode::*;
    public import X2CityDetailedUnit_AnalogAcquisition::*;
    public import X2CityDetailedUnit_HallInterface::*;
    public import X2CityDetailedUnit_MotorPhaseInterface::*;
    public import X2CityDetailedUnit_RiderTemperatureInterfaces::*;
    public import X2CityDetailedUnit_SupplyInterface::*;
    public import X2CityDetailedUnit_TractionAccept::*;
    public import X2CityDetailedUnit_TractionActualOutput::*;
    public import X2CityDetailedUnit_TractionMotion::*;
    public import X2CityDetailedUnit_TractionControl::*;
    public import X2CityDetailedUnit_TractionOutput::*;
    public import X2CityDetailedUnit_PlatformContext::*;
    public import X2CityDetailedUnit_PlatformBinding::*;
    public import X2CityDetailedUnit_PlatformCalibration::*;
    public import X2CityDetailedUnit_PlatformRetention::*;
    public import X2CityDetailedUnit_PlatformHealth::*;
    public import X2CityDetailedUnit_BmsLinkTransaction::*;
    public import X2CityDetailedUnit_BmsLinkDecode::*;
    public import X2CityDetailedUnit_BmsLinkPublish::*;
    public import X2CityDetailedUnit_BatteryProtectionEvaluate::*;
    public import X2CityDetailedUnit_BatteryProtectionRestriction::*;
    public import X2CityDetailedUnit_ServiceInfoCollect::*;
    public import X2CityDetailedUnit_ServiceInfoSnapshot::*;

    part def RidingUnits {
        part setState:USetState;
        part sessionEligibility:USessionEligibility;
        part sessionReport:USessionReport;
        part demandArbiter:UDemandArbiter;
        part hmiAdapter:UHmiAdapter;
        part lightMode:ULightMode;
    }
    part def SensorInterfaceUnits {
        part analogRegular:UAnalogAcqRegular;
        part analogFast:UAnalogAcqFast;
        part acceleratorQualify:UAcceleratorQualify;
        part brakeQualify:UBrakeQualify;
        part temperatureQualify:UTemperatureQualify;
        part hallCapture:UHallCapture;
        part hallPosition:UHallPosition;
        part motorPhaseFast:UMotorPhaseFast;
        part motorPhaseDiag:UMotorPhaseDiag;
        part supplyFast:USupplyFast;
        part supplyRegular:USupplyRegular;
    }
    part def TractionUnits {
        part accept:UTractionAccept;
        part actualOutput:UTractionActualOutput;
        part motion:UTractionMotion;
        part control:UTractionControl;
        part output:UTractionOutput;
    }
    part def PlatformUnits {
        part context:UPlatformContext;
        part binding:UPlatformBinding;
        part calibration:UPlatformCalibration;
        part retention:UPlatformRetention;
        part health:UPlatformHealth;
    }
    part def EnergyUnits {
        part bmsTransaction:UBmsLinkTransaction;
        part bmsDecode:UBmsLinkDecode;
        part bmsPublish:UBmsLinkPublish;
        part batteryEvaluate:UBatteryProtectionEvaluate;
        part batteryRestriction:UBatteryProtectionRestriction;
    }
    part def ServiceUnits {
        part collect:UServiceInfoCollect;
        part snapshot:UServiceInfoSnapshot;
    }
    part def VehicleDetailedDesign {
        part riding:RidingUnits;
        part sensors:SensorInterfaceUnits;
        part traction:TractionUnits;
        part platform:PlatformUnits;
        part energy:EnergyUnits;
        part service:ServiceUnits;
    }
    part vehicle:VehicleDetailedDesign;

    // Platform context, calibration and deterministic acquisition dispatch.
    flow vPlatformContextToCalibration from vehicle.platform.context.contextOut.payload to vehicle.platform.calibration.contextIn.payload;
    flow vCalibrationToBinding from vehicle.platform.calibration.calibrationOut.payload to vehicle.platform.binding.calibrationIn.payload;
    flow vBindingDispatchToAnalogFast from vehicle.platform.binding.fastIrqDispatchOut.payload to vehicle.sensors.analogFast.irqDispatchIn.payload;
    flow vCalibrationToAnalogRegular from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.analogRegular.calibrationIn.payload;
    flow vCalibrationToAnalogFast from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.analogFast.calibrationIn.payload;
    flow vCalibrationToAccelerator from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.acceleratorQualify.calibrationIn.payload;
    flow vCalibrationToBrake from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.brakeQualify.calibrationIn.payload;
    flow vCalibrationToTemperature from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.temperatureQualify.calibrationIn.payload;
    flow vCalibrationToHallPosition from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.hallPosition.calibrationIn.payload;
    flow vCalibrationToMotorPhaseFast from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.motorPhaseFast.calibrationIn.payload;
    flow vCalibrationToMotorPhaseDiag from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.motorPhaseDiag.calibrationIn.payload;
    flow vCalibrationToSupplyFast from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.supplyFast.calibrationIn.payload;
    flow vCalibrationToSupplyRegular from vehicle.platform.calibration.calibrationOut.payload to vehicle.sensors.supplyRegular.calibrationIn.payload;

    // Five regular consumers and two fast consumers preserve the acquisition split.
    flow vRegularScanToAccelerator from vehicle.sensors.analogRegular.regularScanOut.payload to vehicle.sensors.acceleratorQualify.scanIn.payload;
    flow vRegularScanToBrake from vehicle.sensors.analogRegular.regularScanOut.payload to vehicle.sensors.brakeQualify.scanIn.payload;
    flow vRegularScanToTemperature from vehicle.sensors.analogRegular.regularScanOut.payload to vehicle.sensors.temperatureQualify.scanIn.payload;
    flow vRegularScanToMotorPhaseDiag from vehicle.sensors.analogRegular.regularScanOut.payload to vehicle.sensors.motorPhaseDiag.regularScanIn.payload;
    flow vRegularScanToSupplyRegular from vehicle.sensors.analogRegular.regularScanOut.payload to vehicle.sensors.supplyRegular.regularScanIn.payload;
    flow vFastEpochToMotorPhase from vehicle.sensors.analogFast.injectedEpochOut.payload to vehicle.sensors.motorPhaseFast.injectedEpochIn.payload;
    flow vFastEpochToSupply from vehicle.sensors.analogFast.injectedEpochOut.payload to vehicle.sensors.supplyFast.injectedEpochIn.payload;
    flow vHallCaptureToPosition from vehicle.sensors.hallCapture.hallCaptureOut.payload to vehicle.sensors.hallPosition.hallCaptureIn.payload;
    flow vHallPositionToTraction from vehicle.sensors.hallPosition.electricalPositionOut.payload to vehicle.traction.control.electricalPositionIn.payload;
    flow vHallPositionToTractionMotion from vehicle.sensors.hallPosition.electricalPositionOut.payload to vehicle.traction.motion.electricalPositionIn.payload;
    flow vCalibrationToTractionMotion from vehicle.platform.calibration.calibrationOut.payload to vehicle.traction.motion.calibrationIn.payload;
    flow vPlatformContextToTractionMotion from vehicle.platform.context.contextOut.payload to vehicle.traction.motion.platformContextIn.payload;
    flow vPlatformHealthToTractionMotion from vehicle.platform.health.healthOut.payload to vehicle.traction.motion.platformHealthIn.payload;
    flow vHallCaptureHealthToTractionMotion from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.traction.motion.motionHealthIn.payload;
    flow vHallPositionHealthToTractionMotion from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.traction.motion.motionHealthIn.payload;
    flow vMotorPhaseToTraction from vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload to vehicle.traction.control.phaseFeedbackIn.payload;
    flow vSupplyFastToTraction from vehicle.sensors.supplyFast.fastVdcOut.payload to vehicle.traction.control.fastVdcIn.payload;
    flow vFastCommandToOutput from vehicle.traction.control.fastCommandOut.payload to vehicle.traction.output.fastCommandIn.payload;
    flow vOutputObservationToActualOutput from vehicle.traction.output.outputObservationOut.payload to vehicle.traction.actualOutput.outputStageEvidenceIn.payload;
    flow vPhaseFeedbackToActualOutput from vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload to vehicle.traction.actualOutput.phaseFeedbackIn.payload;
    flow vHallPositionToActualOutput from vehicle.sensors.hallPosition.electricalPositionOut.payload to vehicle.traction.actualOutput.electricalPositionIn.payload;
    flow vTractionMotionToActualOutput from vehicle.traction.motion.qualifiedMotionOut.payload to vehicle.traction.actualOutput.qualifiedMotionIn.payload;
    flow vCalibrationToActualOutput from vehicle.platform.calibration.calibrationOut.payload to vehicle.traction.actualOutput.calibrationIn.payload;
    flow vPlatformContextToActualOutput from vehicle.platform.context.contextOut.payload to vehicle.traction.actualOutput.platformContextIn.payload;
    flow vPlatformHealthToActualOutput from vehicle.platform.health.healthOut.payload to vehicle.traction.actualOutput.platformHealthIn.payload;
    flow vActualOutputEstimateToAccept from vehicle.traction.actualOutput.actualOutputOut.payload to vehicle.traction.accept.actualOutputIn.payload;

    // Every sensing unit publishes health to platform aggregation, session eligibility and service evidence.
    flow vAnalogRegularHealthToPlatform from vehicle.sensors.analogRegular.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vAnalogFastHealthToPlatform from vehicle.sensors.analogFast.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vAcceleratorHealthToPlatform from vehicle.sensors.acceleratorQualify.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vBrakeHealthToPlatform from vehicle.sensors.brakeQualify.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vTemperatureHealthToPlatform from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vHallCaptureHealthToPlatform from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vHallPositionHealthToPlatform from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vMotorPhaseFastHealthToPlatform from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vMotorPhaseDiagHealthToPlatform from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vSupplyFastHealthToPlatform from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vSupplyRegularHealthToPlatform from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;

    flow vAnalogRegularHealthToSession from vehicle.sensors.analogRegular.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vAnalogFastHealthToSession from vehicle.sensors.analogFast.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vAcceleratorHealthToSession from vehicle.sensors.acceleratorQualify.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vBrakeHealthToSession from vehicle.sensors.brakeQualify.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vTemperatureHealthToSession from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vHallCaptureHealthToSession from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vHallPositionHealthToSession from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vMotorPhaseFastHealthToSession from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vMotorPhaseDiagHealthToSession from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vSupplyFastHealthToSession from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vSupplyRegularHealthToSession from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vPlatformHealthToSession from vehicle.platform.health.healthOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;

    flow vAnalogRegularHealthToService from vehicle.sensors.analogRegular.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vAnalogFastHealthToService from vehicle.sensors.analogFast.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vAcceleratorHealthToService from vehicle.sensors.acceleratorQualify.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vBrakeHealthToService from vehicle.sensors.brakeQualify.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vTemperatureHealthToService from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vHallCaptureHealthToService from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vHallPositionHealthToService from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vMotorPhaseFastHealthToService from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vMotorPhaseDiagHealthToService from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSupplyFastHealthToService from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSupplyRegularHealthToService from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;

    // Seven safety-relevant direct health inputs independently inhibit traction control.
    flow vSupplyRegularHealthToTraction from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.traction.control.sensorHealthIn.payload;
    flow vHallCaptureHealthToTraction from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.traction.control.sensorHealthIn.payload;
    flow vHallPositionHealthToTraction from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.traction.control.sensorHealthIn.payload;
    flow vMotorPhaseFastHealthToTraction from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.traction.control.sensorHealthIn.payload;
    flow vMotorPhaseDiagHealthToTraction from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.traction.control.sensorHealthIn.payload;
    flow vSupplyFastHealthToTraction from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.traction.control.sensorHealthIn.payload;
    flow vTemperatureHealthToTraction from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.traction.control.sensorHealthIn.payload;

    // Riding, energy, service and platform routes retained from the complete vehicle design.
    flow vHmiSettingsToSet from vehicle.riding.hmiAdapter.settingsOut.payload to vehicle.riding.setState.requestedSettingsIn.payload;
    flow vHmiSettingsToSession from vehicle.riding.hmiAdapter.settingsOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vSetToSession from vehicle.riding.setState.stateOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vTractionMotionToSet from vehicle.traction.motion.qualifiedMotionOut.payload to vehicle.riding.setState.motionIn.payload;
    flow vTractionMotionToSession from vehicle.traction.motion.qualifiedMotionOut.payload to vehicle.riding.sessionEligibility.motionIn.payload;
    flow vSessionEligibilityToReport from vehicle.riding.sessionEligibility.eligibilityObservationOut.payload to vehicle.riding.sessionReport.eligibilityIn.payload;
    flow vSessionEligibilityToDemand from vehicle.riding.sessionEligibility.authorityOut.payload to vehicle.riding.demandArbiter.authorityIn.payload;
    flow vSetToDemand from vehicle.riding.setState.activeSettingsOut.payload to vehicle.riding.demandArbiter.activeSettingsIn.payload;
    flow vDemandToTractionAccept from vehicle.riding.demandArbiter.commandOut.payload to vehicle.traction.accept.commandIn.payload;
    flow vAcceptedDemandToTractionControl from vehicle.traction.accept.acceptedCommandOut.payload to vehicle.traction.control.acceptedDemandIn.payload;
    flow vSessionAuthorityToTractionAccept from vehicle.riding.sessionEligibility.authorityOut.payload to vehicle.traction.accept.authorityIn.payload;
    flow vHmiLightToLight from vehicle.riding.hmiAdapter.lightOut.payload to vehicle.riding.lightMode.inputsIn.payload;
    flow vAcceleratorToSet from vehicle.sensors.acceleratorQualify.positionOut.payload to vehicle.riding.setState.requestedSettingsIn.payload;
    flow vAcceleratorToSession from vehicle.sensors.acceleratorQualify.positionOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vBrakeToSession from vehicle.sensors.brakeQualify.stateOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vTemperatureToSession from vehicle.sensors.temperatureQualify.temperatureOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vAcceleratorToDemand from vehicle.sensors.acceleratorQualify.positionOut.payload to vehicle.riding.demandArbiter.acceleratorIn.payload;
    flow vBrakeToDemand from vehicle.sensors.brakeQualify.stateOut.payload to vehicle.riding.demandArbiter.brakeIn.payload;
    flow vSupplyRegularToSession from vehicle.sensors.supplyRegular.regularSupplyOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vPhaseDiagnosticToSession from vehicle.sensors.motorPhaseDiag.phaseVoltageDiagnosticOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vBrakeToLight from vehicle.sensors.brakeQualify.stateOut.payload to vehicle.riding.lightMode.inputsIn.payload;
    flow vPlatformContextToSession from vehicle.platform.context.contextOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vBatteryRestrictionToSession from vehicle.energy.batteryRestriction.envelopeOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vTractionObservationToSession from vehicle.traction.accept.observationOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vTractionActualOutputToDemand from vehicle.traction.accept.actualOutputOut.payload to vehicle.riding.demandArbiter.actualOutputIn.payload;
    flow vTractionMotionToDemand from vehicle.traction.motion.qualifiedMotionOut.payload to vehicle.riding.demandArbiter.motionIn.payload;
    flow vTractionObservationToLight from vehicle.traction.accept.observationOut.payload to vehicle.riding.lightMode.inputsIn.payload;
    flow vSessionReportToHmi from vehicle.riding.sessionReport.reportOut.payload to vehicle.riding.hmiAdapter.reportIn.payload;
    flow vBatteryToHmi from vehicle.energy.batteryRestriction.presentationOut.payload to vehicle.riding.hmiAdapter.reportIn.payload;

    flow vBmsTransactionToDecode from vehicle.energy.bmsTransaction.acceptedPayloadOut.payload to vehicle.energy.bmsDecode.acceptedPayloadIn.payload;
    flow vBmsDecodeToPublish from vehicle.energy.bmsDecode.decodedOut.payload to vehicle.energy.bmsPublish.decodedIn.payload;
    flow vBmsPublishToBatteryEvaluate from vehicle.energy.bmsPublish.observationOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vTemperatureToBatteryEvaluate from vehicle.sensors.temperatureQualify.temperatureOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vSupplyRegularToBatteryEvaluate from vehicle.sensors.supplyRegular.regularSupplyOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vPhaseDiagnosticToBatteryEvaluate from vehicle.sensors.motorPhaseDiag.phaseVoltageDiagnosticOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vTractionObservationToBatteryEvaluate from vehicle.traction.accept.observationOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vBatteryEvaluateToRestriction from vehicle.energy.batteryEvaluate.candidateOut.payload to vehicle.energy.batteryRestriction.candidateIn.payload;
    flow vRetentionToBatteryRestriction from vehicle.platform.retention.candidateOut.payload to vehicle.energy.batteryRestriction.retentionCandidateIn.payload;
    flow vBatteryRestrictionToDemand from vehicle.energy.batteryRestriction.envelopeOut.payload to vehicle.riding.demandArbiter.batteryCapabilityIn.payload;
    flow vPlatformContextToDemand from vehicle.platform.context.contextOut.payload to vehicle.riding.demandArbiter.platformContextIn.payload;
    flow vPlatformHealthToDemand from vehicle.platform.health.healthOut.payload to vehicle.riding.demandArbiter.platformHealthIn.payload;
    flow vCalibrationToDemand from vehicle.platform.calibration.calibrationOut.payload to vehicle.riding.demandArbiter.calibrationIn.payload;

    flow vServiceCollectToSnapshot from vehicle.service.collect.collectedOut.payload to vehicle.service.snapshot.collectedIn.payload;
    flow vHmiSettingsToService from vehicle.riding.hmiAdapter.settingsOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vHmiLightToService from vehicle.riding.hmiAdapter.lightOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSettingsToService from vehicle.riding.setState.stateOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSessionAuthorityToService from vehicle.riding.sessionEligibility.authorityOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSessionReportToService from vehicle.riding.sessionReport.reportOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vDemandDiagnosticToService from vehicle.riding.demandArbiter.diagnosticOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vBmsToService from vehicle.energy.bmsPublish.observationOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vBatteryToService from vehicle.energy.batteryRestriction.envelopeOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vLightToService from vehicle.riding.lightMode.intentOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vTractionToService from vehicle.traction.accept.observationOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vPlatformContextToService from vehicle.platform.context.contextOut.payload to vehicle.service.collect.contextIn.payload;
    flow vPlatformRetentionToService from vehicle.platform.retention.candidateOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vPlatformHealthToService from vehicle.platform.health.healthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vPlatformCalibrationToService from vehicle.platform.calibration.calibrationOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vAnalogRegularToService from vehicle.sensors.analogRegular.regularScanOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vAnalogFastToService from vehicle.sensors.analogFast.injectedEpochOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vAcceleratorToService from vehicle.sensors.acceleratorQualify.positionOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vBrakeToService from vehicle.sensors.brakeQualify.stateOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vTemperatureToService from vehicle.sensors.temperatureQualify.temperatureOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSupplyFastToService from vehicle.sensors.supplyFast.fastVdcOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSupplyRegularToService from vehicle.sensors.supplyRegular.regularSupplyOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vMotorPhaseFastToService from vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vMotorPhaseDiagToService from vehicle.sensors.motorPhaseDiag.phaseVoltageDiagnosticOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vHallPositionToService from vehicle.sensors.hallPosition.electricalPositionOut.payload to vehicle.service.collect.producerRecordIn.payload;
}
