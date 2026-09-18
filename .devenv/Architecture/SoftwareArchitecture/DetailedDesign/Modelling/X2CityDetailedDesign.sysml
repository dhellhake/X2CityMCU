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
    public import X2CityDetailedUnit_PlatformRetention::*;
    public import X2CityDetailedUnit_PlatformHealth::*;
    public import X2CityDetailedUnit_BmsLinkTransaction::*;
    public import X2CityDetailedUnit_BmsLinkDecode::*;
    public import X2CityDetailedUnit_BmsLinkPublish::*;
    public import X2CityDetailedUnit_BatteryProtectionEvaluate::*;
    public import X2CityDetailedUnit_BatteryProtectionRestriction::*;

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
        // References the one software-architecture runtime boundary rather than creating an
        // application clock producer in the detailed design.
        ref part callingExecutionContext:CallingExecutionContextBoundary = X2CitySoftwareArchitecture::callingExecutionContext;
    }
    part vehicle:VehicleDetailedDesign;
    bind X2CitySystemArchitecture::x2CityVehicle = vehicle;
    bind X2CitySoftwareArchitecture::tractionControlVehicle = vehicle.epcs.traction.motorControl;

    // Direct callers provide a freshly sampled host-boot monotonic reference to each detailed
    // unit invocation. Fast IRQ/direct chains remain direct on this same domain; no cyclic
    // scheduler route or queued FOC handoff is introduced.
    flow vExecutionTimeToSetState from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.riding.setState.executionTimeIn.payload;
    flow vExecutionTimeToSessionEligibility from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.riding.sessionEligibility.executionTimeIn.payload;
    flow vExecutionTimeToSessionReport from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.riding.sessionReport.executionTimeIn.payload;
    flow vExecutionTimeToDemandArbiter from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.riding.demandArbiter.executionTimeIn.payload;
    flow vExecutionTimeToHmiAdapter from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.riding.hmiAdapter.executionTimeIn.payload;
    flow vExecutionTimeToLightMode from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.riding.lightMode.executionTimeIn.payload;
    flow vExecutionTimeToAnalogRegular from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.analogRegular.executionTimeIn.payload;
    flow vExecutionTimeToAnalogFast from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.analogFast.executionTimeIn.payload;
    flow vExecutionTimeToAcceleratorQualifier from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.acceleratorQualify.executionTimeIn.payload;
    flow vExecutionTimeToBrakeQualifier from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.brakeQualify.executionTimeIn.payload;
    flow vExecutionTimeToTemperatureQualifier from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.temperatureQualify.executionTimeIn.payload;
    flow vExecutionTimeToHallCapture from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.hallCapture.executionTimeIn.payload;
    flow vExecutionTimeToHallPosition from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.hallPosition.executionTimeIn.payload;
    flow vExecutionTimeToMotorPhaseFast from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.motorPhaseFast.executionTimeIn.payload;
    flow vExecutionTimeToMotorPhaseDiagnostic from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.motorPhaseDiag.executionTimeIn.payload;
    flow vExecutionTimeToSupplyFast from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.supplyFast.executionTimeIn.payload;
    flow vExecutionTimeToSupplyRegular from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.supplyRegular.executionTimeIn.payload;
    flow vExecutionTimeToPlatformContext from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.platform.context.executionTimeIn.payload;
    flow vExecutionTimeToPlatformBinding from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.platform.binding.executionTimeIn.payload;
    flow vExecutionTimeToPlatformRetention from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.platform.retention.executionTimeIn.payload;
    flow vExecutionTimeToPlatformHealth from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.platform.health.executionTimeIn.payload;
    flow vExecutionTimeToBmsTransaction from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.energy.bmsTransaction.executionTimeIn.payload;
    flow vExecutionTimeToBmsDecode from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.energy.bmsDecode.executionTimeIn.payload;
    flow vExecutionTimeToBmsPublish from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.energy.bmsPublish.executionTimeIn.payload;
    flow vExecutionTimeToBatteryEvaluate from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.energy.batteryEvaluate.executionTimeIn.payload;
    flow vExecutionTimeToBatteryRestriction from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.energy.batteryRestriction.executionTimeIn.payload;
    // vehicle.traction is the sole selected occurrence bound to tractionControlVehicle, so its
    // inherited executionTimeIn is supplied by executionTimeToTractionControl at software scope.
    // TractionControlImplementation forwards that one bounded invocation reference to its units.

    // Platform context and deterministic acquisition dispatch. Configuration is compiled into
    // its owning component and is therefore not a runtime route.
    // These are static build/startup consistency bindings: PlatformBinding's peripheral/rank/
    // trigger setup must match AnalogAcquisition's compiled interpretation configuration.
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledAcquisitionBinding = vehicle.platform.binding.compiledAcquisitionBinding;
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledConfigurationId = vehicle.platform.binding.compiledConfigurationId;
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledConfigurationValid = vehicle.platform.binding.compiledConfigurationValid;
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledAcquisitionBinding = vehicle.sensors.analogRegular.compiledAcquisitionBinding;
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledAcquisitionBinding = vehicle.sensors.analogFast.compiledAcquisitionBinding;
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledConfigurationId = vehicle.sensors.analogRegular.compiledAcquisitionConfigurationId;
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledConfigurationId = vehicle.sensors.analogFast.compiledAcquisitionConfigurationId;
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledConfigurationValid = vehicle.sensors.analogRegular.compiledConfigurationValid;
    bind X2CitySoftwareArchitecture::analogAcquisitionVehicle.compiledConfigurationValid = vehicle.sensors.analogFast.compiledConfigurationValid;
    bind vehicle.platform.binding.compiledAcquisitionBinding = vehicle.sensors.analogRegular.compiledAcquisitionBinding;
    bind vehicle.platform.binding.compiledAcquisitionBinding = vehicle.sensors.analogFast.compiledAcquisitionBinding;
    // Each qualifier consumes exactly its owning SoftwareComponent's fixed compiled set. These
    // structural bindings are deployment/build consistency constraints, never runtime flows.
    bind X2CitySoftwareArchitecture::acceleratorInterfaceVehicle.compiledCalibration = vehicle.sensors.acceleratorQualify.compiledCalibration;
    bind X2CitySoftwareArchitecture::acceleratorInterfaceVehicle.compiledCalibrationId = vehicle.sensors.acceleratorQualify.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::acceleratorInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.acceleratorQualify.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::brakeInterfaceVehicle.compiledCalibration = vehicle.sensors.brakeQualify.compiledCalibration;
    bind X2CitySoftwareArchitecture::brakeInterfaceVehicle.compiledCalibrationId = vehicle.sensors.brakeQualify.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::brakeInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.brakeQualify.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::temperatureInterfaceVehicle.compiledCalibration = vehicle.sensors.temperatureQualify.compiledCalibration;
    bind X2CitySoftwareArchitecture::temperatureInterfaceVehicle.compiledCalibrationId = vehicle.sensors.temperatureQualify.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::temperatureInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.temperatureQualify.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::hallInterfaceVehicle.compiledHallCalibration = vehicle.sensors.hallPosition.compiledHallCalibration;
    bind X2CitySoftwareArchitecture::hallInterfaceVehicle.compiledCalibrationId = vehicle.sensors.hallPosition.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::hallInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.hallPosition.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCurrentPhaseCalibration = vehicle.sensors.motorPhaseFast.compiledCurrentPhaseCalibration;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCurrentPhaseCalibration = vehicle.sensors.motorPhaseDiag.compiledCurrentPhaseCalibration;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCalibrationId = vehicle.sensors.motorPhaseFast.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCalibrationId = vehicle.sensors.motorPhaseDiag.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.motorPhaseFast.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.motorPhaseDiag.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledSupplyCalibration = vehicle.sensors.supplyFast.compiledSupplyCalibration;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledSupplyCalibration = vehicle.sensors.supplyRegular.compiledSupplyCalibration;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledCalibrationId = vehicle.sensors.supplyFast.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledCalibrationId = vehicle.sensors.supplyRegular.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.supplyFast.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.supplyRegular.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::demandVehicle.compiledDemandPolicyCalibration = vehicle.riding.demandArbiter.compiledDemandPolicyCalibration;
    bind X2CitySoftwareArchitecture::demandVehicle.compiledCalibrationId = vehicle.riding.demandArbiter.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::demandVehicle.compiledCalibrationValid = vehicle.riding.demandArbiter.compiledCalibrationValid;
    flow vBindingDispatchToAnalogFast from vehicle.platform.binding.fastIrqDispatchOut.payload to vehicle.sensors.analogFast.irqDispatchIn.payload;

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
    flow vPlatformContextToTractionMotion from vehicle.platform.context.contextOut.payload to vehicle.traction.platformContextIn.payload;
    flow vPlatformHealthToTractionMotion from vehicle.platform.health.healthOut.payload to vehicle.traction.platformHealthIn.payload;
    flow vHallCaptureHealthToTractionMotion from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.traction.motionHealthIn.payload;
    flow vHallPositionHealthToTractionMotion from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.traction.motionHealthIn.payload;
    flow vMotorPhaseToTraction from vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload to vehicle.traction.phaseCurrentEpochIn.payload;
    flow vSupplyFastToTraction from vehicle.sensors.supplyFast.fastDcLinkVoltageOut.payload to vehicle.traction.fastDcLinkVoltageIn.payload;

    // Every sensing unit publishes health to platform aggregation and session eligibility.
    // Accelerator's one composite conveys its Qualification to Platform and reaches Session
    // through the same composite position route below.
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

    // Seven safety-relevant direct health inputs independently inhibit traction control.
    flow vSupplyRegularHealthToTraction from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vHallCaptureHealthToTraction from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vHallPositionHealthToTraction from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vMotorPhaseFastHealthToTraction from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vMotorPhaseDiagHealthToTraction from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vSupplyFastHealthToTraction from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vTemperatureHealthToTraction from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;

    // Riding, energy and platform routes retained from the complete vehicle design.
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

}
