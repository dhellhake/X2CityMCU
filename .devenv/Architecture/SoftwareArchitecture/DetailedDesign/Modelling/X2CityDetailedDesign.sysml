// SysML v2 textual model: vehicle detailed-design unit composition.
// External equipment is outside this vehicle model.
package X2CityDetailedDesign {
    public import X2CitySystemArchitecture::*;
    public import X2CitySoftwareArchitecture::*;
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
    public import X2CityDetailedComponent_TractionControlImplementation::*;
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
        part setState:RidingSettingsStateManager;
        part sessionEligibility:SessionEligibilityEvaluator;
        part sessionReport:SessionReportPublisher;
        part demandArbiter:DemandArbiter;
        part hmiAdapter:HmiAdapterUnit;
        part lightMode:LightModePolicy;
    }
    part def SensorInterfaceUnits {
        part analogRegular:RegularAnalogAcquisition;
        part analogFast:FastAnalogAcquisition;
        part acceleratorQualify:AcceleratorQualifier;
        part brakeQualify:BrakeQualifier;
        part temperatureQualify:TemperatureQualifier;
        part hallCapture:HallCaptureProcessor;
        part hallPosition:ElectricalPositionEstimator;
        part motorPhaseFast:FastPhaseCurrentProcessor;
        part motorPhaseDiag:PhaseVoltageDiagnosticProcessor;
        part supplyFast:FastSupplyVoltageProcessor;
        part supplyRegular:RegularSupplyVoltageProcessor;
    }
    part def PlatformUnits {
        part context:PlatformContextManager;
        part binding:PlatformBinding;
        part calibration:CalibrationLifecycleManager;
        part retention:RetentionCandidateManager;
        part health:PlatformHealthManager;
    }
    part def EnergyUnits {
        part bmsTransaction:BmsTransaction;
        part bmsDecode:BmsResponseDecoder;
        part bmsPublish:BmsObservationPublisher;
        part batteryEvaluate:BatteryCapabilityEvaluator;
        part batteryRestriction:BatteryCapabilityRestrictor;
    }
    part def ServiceUnits {
        part collect:ServiceRecordCollector;
        part snapshot:ServiceSnapshotPublisher;
    }
    part def SelectedTraction :> X2CitySystemArchitecture::Traction {
        part motorControl:TractionControlImplementation :>> X2CitySystemArchitecture::Traction::motorControl;
    }
    part def SelectedEpcs :> X2CitySystemArchitecture::ElectricalPropulsionControlSystem {
        part traction:SelectedTraction :>> X2CitySystemArchitecture::ElectricalPropulsionControlSystem::traction;
    }
    part def VehicleDetailedDesign :> X2CitySystemArchitecture::ProjectVehicleModel {
        part epcs:SelectedEpcs :>> X2CitySystemArchitecture::ProjectVehicleModel::epcs;
        part riding:RidingUnits;
        part sensors:SensorInterfaceUnits;
        // Alias the one selected System→Software→Detailed motor-control occurrence; this
        // detailed view owns no parallel TractionUnits or MotorControl instance.
        ref part traction:TractionControlImplementation = epcs.traction.motorControl;
        part platform:PlatformUnits;
        part energy:EnergyUnits;
        part service:ServiceUnits;
    }
    part vehicle:VehicleDetailedDesign;
    bind X2CitySystemArchitecture::x2CityVehicle = vehicle;
    bind X2CitySoftwareArchitecture::tractionControlVehicle = vehicle.epcs.traction.motorControl;

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
    flow vRegularScanToAccelerator from vehicle.sensors.analogRegular.analogSampleOut.payload to vehicle.sensors.acceleratorQualify.analogSampleIn.payload;
    flow vRegularScanToBrake from vehicle.sensors.analogRegular.analogSampleOut.payload to vehicle.sensors.brakeQualify.analogSampleIn.payload;
    flow vRegularScanToTemperature from vehicle.sensors.analogRegular.analogSampleOut.payload to vehicle.sensors.temperatureQualify.analogSampleIn.payload;
    flow vRegularScanToMotorPhaseDiag from vehicle.sensors.analogRegular.analogSampleOut.payload to vehicle.sensors.motorPhaseDiag.analogSampleIn.payload;
    flow vRegularScanToSupplyRegular from vehicle.sensors.analogRegular.analogSampleOut.payload to vehicle.sensors.supplyRegular.analogSampleIn.payload;
    flow vFastEpochToMotorPhase from vehicle.sensors.analogFast.injectedEpochOut.payload to vehicle.sensors.motorPhaseFast.injectedEpochIn.payload;
    flow vFastEpochToSupply from vehicle.sensors.analogFast.injectedEpochOut.payload to vehicle.sensors.supplyFast.injectedEpochIn.payload;
    flow vHallCaptureToPosition from vehicle.sensors.hallCapture.hallCaptureOut.payload to vehicle.sensors.hallPosition.hallCaptureIn.payload;
    flow vHallPositionToTraction from vehicle.sensors.hallPosition.electricalPositionOut.payload to vehicle.traction.hallElectricalPositionIn.payload;
    flow vCalibrationToTractionMotion from vehicle.platform.calibration.calibrationOut.payload to vehicle.traction.calibrationIn.payload;
    flow vPlatformContextToTractionMotion from vehicle.platform.context.contextOut.payload to vehicle.traction.platformContextIn.payload;
    flow vPlatformHealthToTractionMotion from vehicle.platform.health.healthOut.payload to vehicle.traction.platformHealthIn.payload;
    flow vHallCaptureHealthToTractionMotion from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.traction.motionHealthIn.payload;
    flow vHallPositionHealthToTractionMotion from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.traction.motionHealthIn.payload;
    flow vMotorPhaseToTraction from vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload to vehicle.traction.phaseCurrentEpochIn.payload;
    flow vSupplyFastToTraction from vehicle.sensors.supplyFast.fastDcLinkVoltageOut.payload to vehicle.traction.fastDcLinkVoltageIn.payload;

    // Every sensing unit publishes health to platform aggregation, session eligibility and service evidence.
    // Accelerator's one composite conveys its Qualification to Platform and reaches Session and
    // Service through the same composite position route below.
    flow vAnalogRegularHealthToPlatform from vehicle.sensors.analogRegular.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vAnalogFastHealthToPlatform from vehicle.sensors.analogFast.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vAcceleratorHealthToPlatform from vehicle.sensors.acceleratorQualify.acceleratorPositionOut.payload.Qualification to vehicle.platform.health.acceleratorQualificationIn.payload;
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
    flow vBrakeHealthToService from vehicle.sensors.brakeQualify.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vTemperatureHealthToService from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vHallCaptureHealthToService from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vHallPositionHealthToService from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vMotorPhaseFastHealthToService from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vMotorPhaseDiagHealthToService from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSupplyFastHealthToService from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSupplyRegularHealthToService from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.service.collect.producerRecordIn.payload;

    // Seven safety-relevant direct health inputs independently inhibit traction control.
    flow vSupplyRegularHealthToTraction from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vHallCaptureHealthToTraction from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vHallPositionHealthToTraction from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vMotorPhaseFastHealthToTraction from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vMotorPhaseDiagHealthToTraction from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vSupplyFastHealthToTraction from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vTemperatureHealthToTraction from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;

    // Riding, energy, service and platform routes retained from the complete vehicle design.
    flow vHmiSettingsToSet from vehicle.riding.hmiAdapter.settingsOut.payload to vehicle.riding.setState.requestedSettingsIn.payload;
    flow vHmiSettingsToSession from vehicle.riding.hmiAdapter.settingsOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vSetToSession from vehicle.riding.setState.stateOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vTractionMotionToSet from vehicle.traction.qualifiedMotionOut.payload to vehicle.riding.setState.motionIn.payload;
    flow vTractionMotionToSession from vehicle.traction.qualifiedMotionOut.payload to vehicle.riding.sessionEligibility.motionIn.payload;
    flow vSessionEligibilityToReport from vehicle.riding.sessionEligibility.eligibilityObservationOut.payload to vehicle.riding.sessionReport.eligibilityIn.payload;
    flow vSessionEligibilityToDemand from vehicle.riding.sessionEligibility.authorityOut.payload to vehicle.riding.demandArbiter.authorityIn.payload;
    flow vSetToDemand from vehicle.riding.setState.activeSettingsOut.payload to vehicle.riding.demandArbiter.activeSettingsIn.payload;
    flow vDemandToTractionAccept from vehicle.riding.demandArbiter.commandOut.payload to vehicle.traction.wheelTorqueRequestIn.payload;
    flow vSessionAuthorityToTractionAccept from vehicle.riding.sessionEligibility.authorityOut.payload to vehicle.traction.ridingAuthorityIn.payload;
    flow vHmiLightToLight from vehicle.riding.hmiAdapter.lightOut.payload to vehicle.riding.lightMode.lightingContextIn.payload;
    flow vAcceleratorToSet from vehicle.sensors.acceleratorQualify.acceleratorPositionOut.payload to vehicle.riding.setState.acceleratorPositionIn.payload;
    flow vAcceleratorToSession from vehicle.sensors.acceleratorQualify.acceleratorPositionOut.payload to vehicle.riding.sessionEligibility.acceleratorPositionIn.payload;
    flow vBrakeToSession from vehicle.sensors.brakeQualify.stateOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vTemperatureToSession from vehicle.sensors.temperatureQualify.temperatureOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vAcceleratorToDemand from vehicle.sensors.acceleratorQualify.acceleratorPositionOut.payload to vehicle.riding.demandArbiter.acceleratorIn.payload;
    flow vBrakeToDemand from vehicle.sensors.brakeQualify.stateOut.payload to vehicle.riding.demandArbiter.brakeIn.payload;
    flow vSupplyRegularToSession from vehicle.sensors.supplyRegular.regularSupplyOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vPhaseDiagnosticToSession from vehicle.sensors.motorPhaseDiag.phaseVoltageDiagnosticOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vBrakeToLight from vehicle.sensors.brakeQualify.stateOut.payload to vehicle.riding.lightMode.lightingContextIn.payload;
    flow vPlatformContextToSession from vehicle.platform.context.contextOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vBatteryRestrictionToSession from vehicle.energy.batteryRestriction.envelopeOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vTractionObservationToSession from vehicle.traction.tractionObservationOut.payload to vehicle.riding.sessionEligibility.prerequisitesIn.payload;
    flow vAppliedTractionStateToDemand from vehicle.traction.appliedTractionStateOut.payload to vehicle.riding.demandArbiter.actualOutputIn.payload;
    flow vTractionMotionToDemand from vehicle.traction.qualifiedMotionOut.payload to vehicle.riding.demandArbiter.motionIn.payload;
    flow vTractionObservationToLight from vehicle.traction.tractionObservationOut.payload to vehicle.riding.lightMode.lightingContextIn.payload;
    flow vSessionReportToHmi from vehicle.riding.sessionReport.reportOut.payload to vehicle.riding.hmiAdapter.reportIn.payload;
    flow vBatteryToHmi from vehicle.energy.batteryRestriction.presentationOut.payload to vehicle.riding.hmiAdapter.reportIn.payload;

    flow vBmsTransactionToDecode from vehicle.energy.bmsTransaction.acceptedPayloadOut.payload to vehicle.energy.bmsDecode.acceptedPayloadIn.payload;
    flow vBmsDecodeToPublish from vehicle.energy.bmsDecode.decodedOut.payload to vehicle.energy.bmsPublish.decodedIn.payload;
    flow vBmsPublishToBatteryEvaluate from vehicle.energy.bmsPublish.observationOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vTemperatureToBatteryEvaluate from vehicle.sensors.temperatureQualify.temperatureOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vSupplyRegularToBatteryEvaluate from vehicle.sensors.supplyRegular.regularSupplyOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vPhaseDiagnosticToBatteryEvaluate from vehicle.sensors.motorPhaseDiag.phaseVoltageDiagnosticOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
    flow vTractionObservationToBatteryEvaluate from vehicle.traction.tractionObservationOut.payload to vehicle.energy.batteryEvaluate.observationsAndContextIn.payload;
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
    flow vTractionToService from vehicle.traction.tractionObservationOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vPlatformContextToService from vehicle.platform.context.contextOut.payload to vehicle.service.collect.contextIn.payload;
    flow vPlatformRetentionToService from vehicle.platform.retention.candidateOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vPlatformHealthToService from vehicle.platform.health.healthOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vPlatformCalibrationToService from vehicle.platform.calibration.calibrationOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vAnalogRegularToService from vehicle.sensors.analogRegular.analogSampleOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vAnalogFastToService from vehicle.sensors.analogFast.injectedEpochOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vAcceleratorToService from vehicle.sensors.acceleratorQualify.acceleratorPositionOut.payload to vehicle.service.collect.acceleratorPositionIn.payload;
    flow vBrakeToService from vehicle.sensors.brakeQualify.stateOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vTemperatureToService from vehicle.sensors.temperatureQualify.temperatureOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSupplyFastToService from vehicle.sensors.supplyFast.fastDcLinkVoltageOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vSupplyRegularToService from vehicle.sensors.supplyRegular.regularSupplyOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vMotorPhaseFastToService from vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vMotorPhaseDiagToService from vehicle.sensors.motorPhaseDiag.phaseVoltageDiagnosticOut.payload to vehicle.service.collect.producerRecordIn.payload;
    flow vHallPositionToService from vehicle.sensors.hallPosition.electricalPositionOut.payload to vehicle.service.collect.producerRecordIn.payload;
}
