// SysML v2 textual model: vehicle detailed-design unit composition.
// External equipment is outside this vehicle model.
package X2CityDetailedDesign {
    public import X2CitySystemArchitecture::*;
    public import X2CitySoftwareArchitecture::*;
    public import X2CityDetailedSharedContracts::*;
    public import X2CityDetailedComponent_RidingControlDetailedDesign::*;
    public import X2CityDetailedUnit_SetState::*;
    public import X2CityDetailedUnit_SessionEligibility::*;
    public import X2CityDetailedUnit_SessionReport::*;
    public import X2CityDetailedUnit_DemandArbiter::*;
    public import X2CityDetailedUnit_HmiAdapter::*;
    public import X2CityDetailedUnit_LightMode::*;
    public import X2CityDetailedUnit_AnalogAcquisition::*;
    public import X2CityDetailedUnit_HallInterface::*;
    public import X2CityDetailedUnit_MotorPhaseInterface::*;
    public import X2CityDetailedUnit_MotorPositionEstimator::*;
    public import X2CityDetailedUnit_RegularSensorQualification::*;
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
        part hallPosition:HallObservationProcessor;
        part motorPhaseFast:FastPhaseCurrentProcessor;
        part motorPhaseDiag:PhaseVoltageDiagnosticProcessor;
        // This source-bound unit publishes unavailable until its direct-sensing or calibrated
        // PWM/bridge evidence boundary is qualified; regular diagnostics are not connected here.
        part motorPhaseObserverVoltage:ObserverAppliedVoltageProcessor;
        part motorPositionEstimator:ElectricalMotorPositionEstimator;
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
        part bmsPublish:BatteryMeasurementsPublisher;
        part batteryEvaluate:BatteryCapabilityEvaluator;
        part batteryRestriction:BatteryCapabilityRestrictor;
    }
    part def SelectedTractionControl :> X2CityComponent_TractionControl::TractionControl {
        part motorControl:MotorControlRealizationImplementation :>> X2CityComponent_TractionControl::TractionControl::motorControl;
    }
    part def SelectedTraction :> X2CitySystemArchitecture::Traction {
        part tractionControl:SelectedTractionControl :>> X2CitySystemArchitecture::Traction::tractionControl;
    }
    part def SelectedEpcs :> X2CitySystemArchitecture::ElectricalPropulsionControlSystem {
        part traction:SelectedTraction :>> X2CitySystemArchitecture::ElectricalPropulsionControlSystem::traction;
        part ridingControl:RidingControlDetailedDesign :>> X2CitySystemArchitecture::ElectricalPropulsionControlSystem::ridingControl;
    }
    part def VehicleDetailedDesign :> X2CitySystemArchitecture::ProjectVehicleModel {
        part epcs:SelectedEpcs :>> X2CitySystemArchitecture::ProjectVehicleModel::epcs;
        part riding:RidingUnits;
        part sensors:SensorInterfaceUnits;
        // Alias the one selected System→Software→Detailed motor-control occurrence; this
        // detailed view owns no parallel TractionUnits or MotorControl instance.
        ref part traction:TractionControlImplementation = epcs.traction.tractionControl.motorControl.controlCore;
        part platform:PlatformUnits;
        part energy:EnergyUnits;
        // References the one software-architecture runtime boundary rather than creating an
        // application clock producer in the detailed design.
        ref part callingExecutionContext:CallingExecutionContextBoundary = X2CitySoftwareArchitecture::callingExecutionContext;
        // Explicit source boundary for observer voltage. Its source remains a qualified HSI
        // gate, not an implemented ADC/PWM reconstruction claim.
        ref part vehicleBoundary:VehicleSoftwareBoundary = X2CitySoftwareArchitecture::vehicleBoundary;
    }
    part vehicle:VehicleDetailedDesign;
    bind X2CitySystemArchitecture::x2CityVehicle = vehicle;
    bind X2CitySoftwareArchitecture::tractionControlVehicle = vehicle.traction;
    bind X2CitySoftwareArchitecture::ridingControlVehicle = vehicle.epcs.ridingControl;
    bind X2CitySoftwareArchitecture::motorControlRealizationVehicle = vehicle.epcs.traction.tractionControl.motorControl;
    bind vehicle.epcs.traction.tractionControl.motorControl.analogAcquisition = X2CitySoftwareArchitecture::analogAcquisitionVehicle;
    bind vehicle.epcs.traction.tractionControl.motorControl.temperatureInterface = X2CitySoftwareArchitecture::temperatureInterfaceVehicle;
    bind vehicle.epcs.traction.tractionControl.motorControl.supplyInterface = X2CitySoftwareArchitecture::supplyInterfaceVehicle;
    // Identify the software boundary representation with the selected logical command/evidence
    // features. This makes each feature one source across views; it does not claim that the
    // unresolved physical observation/protection mechanisms have been selected or qualified.
    bind vehicle.vehicleBoundary.tractionInformationIo.evidence.tractionStageEvidence = vehicle.epcs.traction.tractionControl.motorControl.tractionStageEvidenceIn.payload;
    bind vehicle.vehicleBoundary.tractionInformationIo.evidence.tractionHardwareProtectionEvidence = vehicle.epcs.traction.tractionControl.motorControl.tractionHardwareProtectionEvidenceIn.payload;
    bind vehicle.vehicleBoundary.tractionInformationIo.phaseExcitationCommand = vehicle.epcs.traction.tractionControl.motorControl.phaseExcitationCommandOut.payload;
    // The selected System Traction occurrence inherits MotorPositionEstimation. Bind its
    // logical position/current publications to the detailed units that produce the same
    // feedback, so this refinement introduces no second estimator or current source.
    bind vehicle.epcs.traction.motorPositionEstimation.motorPositionOut.motorPosition = vehicle.sensors.motorPositionEstimator.motorPositionOut.payload;
    bind vehicle.epcs.traction.motorPositionEstimation.phaseCurrentOut.phaseCurrentMeasurements = vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload;
    // This binding identifies the SoftwareComponent publication with its detailed-unit
    // realization. There is no separate estimator-health projection or publication.
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.phaseCurrentEpochOut.payload = vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload;
    bind X2CitySoftwareArchitecture::motorPositionEstimatorVehicle.motorPositionOut.payload = vehicle.sensors.motorPositionEstimator.motorPositionOut.payload;
    // The detailed LightModePolicy realizes the owning SC-LIGHT-POLICY.V publication. Identifying
    // these payloads leaves the existing software-architecture R-V25 route as the sole publisher
    // to the vehicle boundary; this detailed composition creates no parallel boundary route.
    bind X2CitySoftwareArchitecture::lightPolicyVehicle.lightModesOut.payload = vehicle.riding.lightMode.lightModesOut.payload;
    // U-HMI-ADAPTER realizes SC-HMI's information ports only. The supplied five-pin electrical
    // interface and conditioned pin-5 wake path remain outside this detailed software composition.
    bind X2CitySoftwareArchitecture::hmiVehicle.uartReceivedDataIn.receivedData = vehicle.riding.hmiAdapter.uartReceivedDataIn.receivedData;
    bind X2CitySoftwareArchitecture::hmiVehicle.uartTransmittedDataOut.transmittedData = vehicle.riding.hmiAdapter.uartTransmittedDataOut.transmittedData;
    bind X2CitySoftwareArchitecture::hmiVehicle.ridingSettingsOut.payload = vehicle.riding.hmiAdapter.ridingSettingsOut.payload;
    bind X2CitySoftwareArchitecture::hmiVehicle.vehicleOperationRequestOut.request = vehicle.riding.hmiAdapter.vehicleOperationRequestOut.request;
    bind X2CitySoftwareArchitecture::hmiVehicle.runningLightStateOut.normalLightRequest = vehicle.riding.hmiAdapter.runningLightStateOut.normalLightRequest;
    bind X2CitySoftwareArchitecture::hmiVehicle.selectedFaultIn.selectedFaultIndication = vehicle.riding.hmiAdapter.selectedFaultIn.selectedFaultIndication;
    bind X2CitySoftwareArchitecture::hmiVehicle.stateOfChargeIn.stateOfCharge = vehicle.riding.hmiAdapter.stateOfChargeIn.payload;
    bind X2CitySoftwareArchitecture::hmiVehicle.batteryCurrentIn.batteryCurrent = vehicle.riding.hmiAdapter.batteryCurrentIn.payload;
    bind X2CitySoftwareArchitecture::hmiVehicle.vehicleMotionIn.payload = vehicle.riding.hmiAdapter.vehicleMotionIn.payload;
    bind X2CitySoftwareArchitecture::platformVehicle.runtimeInitializationOut.initialization = vehicle.platform.context.runtimeInitializationOut.initialization;

    // Direct callers provide a freshly sampled host-boot monotonic reference to each detailed
    // unit invocation. Fast IRQ/direct chains remain direct on this same domain; no cyclic
    // scheduler route or queued FOC handoff is introduced.
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
    flow vExecutionTimeToMotorPhaseObserverVoltage from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.motorPhaseObserverVoltage.executionTimeIn.payload;
    flow vExecutionTimeToMotorPositionEstimator from vehicle.callingExecutionContext.executionTimeOut.payload to vehicle.sensors.motorPositionEstimator.executionTimeIn.payload;
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
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCalibrationId = vehicle.sensors.motorPhaseObserverVoltage.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.motorPhaseFast.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.motorPhaseDiag.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::motorPhaseInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.motorPhaseObserverVoltage.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::motorPositionEstimatorVehicle.compiledMotorPositionEstimatorCalibration = vehicle.sensors.motorPositionEstimator.compiledMotorPositionEstimatorCalibration;
    bind X2CitySoftwareArchitecture::motorPositionEstimatorVehicle.compiledCalibrationId = vehicle.sensors.motorPositionEstimator.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::motorPositionEstimatorVehicle.compiledCalibrationValid = vehicle.sensors.motorPositionEstimator.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledSupplyCalibration = vehicle.sensors.supplyFast.compiledSupplyCalibration;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledSupplyCalibration = vehicle.sensors.supplyRegular.compiledSupplyCalibration;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledCalibrationId = vehicle.sensors.supplyFast.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledCalibrationId = vehicle.sensors.supplyRegular.compiledCalibrationId;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.supplyFast.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.compiledCalibrationValid = vehicle.sensors.supplyRegular.compiledCalibrationValid;
    bind X2CitySoftwareArchitecture::supplyInterfaceVehicle.supplyVoltageOut.payload = vehicle.sensors.supplyRegular.regularSupplyOut.payload;
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
    flow vHallObservationToMotorPositionEstimator from vehicle.sensors.hallPosition.hallObservationOut.payload to vehicle.sensors.motorPositionEstimator.hallObservationIn.payload;
    flow vMotorPhaseFastToMotorPositionEstimator from vehicle.sensors.motorPhaseFast.phaseFeedbackOut.payload to vehicle.sensors.motorPositionEstimator.phaseCurrentEpochIn.payload;
    // No regular-DMA path feeds observer voltage. This explicit physical/HSI boundary remains
    // unavailable until direct sensing or calibrated PWM/bridge reconstruction is qualified.
    flow vAppliedVoltageBoundaryToObserverVoltage from vehicle.vehicleBoundary.appliedPhaseVoltageEvidence.payload to vehicle.sensors.motorPhaseObserverVoltage.appliedPhaseVoltageEvidenceIn.payload;
    flow vObserverVoltageToMotorPositionEstimator from vehicle.sensors.motorPhaseObserverVoltage.qualifiedAppliedPhaseVoltageOut.payload to vehicle.sensors.motorPositionEstimator.qualifiedAppliedPhaseVoltageIn.payload;
    flow vMotorPositionToTraction from vehicle.sensors.motorPositionEstimator.motorPositionOut.payload to vehicle.traction.motorPositionIn.payload;
    flow vMotorPositionToPlatform from vehicle.sensors.motorPositionEstimator.motorPositionOut.payload to vehicle.platform.health.motorPositionIn.payload;
    flow vPlatformContextToMotorPositionEstimator from vehicle.platform.context.contextOut.payload to vehicle.sensors.motorPositionEstimator.platformContextIn.payload;
    flow vPlatformHealthToMotorPositionEstimator from vehicle.platform.health.healthOut.payload to vehicle.sensors.motorPositionEstimator.platformHealthIn.payload;
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
    flow vBrakeHealthToPlatform from vehicle.sensors.brakeQualify.brakeHealthOut.qualification to vehicle.platform.health.brakeQualificationIn.qualification;
    flow vTemperatureHealthToPlatform from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vHallCaptureHealthToPlatform from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vHallPositionHealthToPlatform from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vMotorPhaseFastHealthToPlatform from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vMotorPhaseDiagHealthToPlatform from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    // An unavailable/unobservable observer-voltage source is a qualified unavailable branch,
    // not a fault. This conveys only recognized source/qualification health.
    flow vMotorPhaseObserverVoltageHealthToPlatform from vehicle.sensors.motorPhaseObserverVoltage.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vSupplyFastHealthToPlatform from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;
    flow vSupplyRegularHealthToPlatform from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.platform.health.sensorHealthIn.payload;

    // RidingControl receives each concrete source once at its component boundary. Platform
    // performs source aggregation; private unit fan-out occurs only inside this owner.
    // Nine safety-relevant direct health inputs independently inhibit traction control. Observer
    // voltage availability is branch-independent: only recognized failure contributes; weak
    // back-EMF/unavailable assistance with accepted Hall position is not a fault.
    flow vSupplyRegularHealthToTraction from vehicle.sensors.supplyRegular.sensorHealthOut.payload to vehicle.traction.supplyHealthIn.qualification;
    flow vHallCaptureHealthToTraction from vehicle.sensors.hallCapture.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vHallPositionHealthToTraction from vehicle.sensors.hallPosition.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vMotorPhaseFastHealthToTraction from vehicle.sensors.motorPhaseFast.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vMotorPhaseDiagHealthToTraction from vehicle.sensors.motorPhaseDiag.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vMotorPhaseObserverVoltageHealthToTraction from vehicle.sensors.motorPhaseObserverVoltage.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;
    flow vSupplyFastHealthToTraction from vehicle.sensors.supplyFast.sensorHealthOut.payload to vehicle.traction.supplyHealthIn.qualification;
    flow vTemperatureHealthToTraction from vehicle.sensors.temperatureQualify.sensorHealthOut.payload to vehicle.traction.sensorHealthIn.payload;

    // Internal fan-out from the one component snapshot to its separate state/decision units.
    flow vBrakeToLight from vehicle.sensors.brakeQualify.brakeLeverStateOut.brakeLeverState to vehicle.riding.lightMode.brakeLeverStateIn.brakeLeverState;
    flow vElectricalBrakingStateToLight from vehicle.traction.electricalBrakingStateOut.payload to vehicle.riding.lightMode.electricalBrakingStateIn.payload;
    flow vBatterySocToHmi from vehicle.energy.batteryRestriction.stateOfChargeOut.payload to vehicle.riding.hmiAdapter.stateOfChargeIn.payload;
    flow vBatteryCurrentToHmi from vehicle.energy.batteryRestriction.batteryCurrentOut.payload to vehicle.riding.hmiAdapter.batteryCurrentIn.payload;
    flow vTractionMotionToHmi from vehicle.traction.qualifiedMotionOut.payload to vehicle.riding.hmiAdapter.vehicleMotionIn.payload;

    flow vBmsTransactionToDecode from vehicle.energy.bmsTransaction.acceptedPayloadOut.payload to vehicle.energy.bmsDecode.acceptedPayloadIn.payload;
    flow vBmsDecodeToPublish from vehicle.energy.bmsDecode.decodedOut.payload to vehicle.energy.bmsPublish.decodedIn.payload;
    flow vBmsPublishToBatteryEvaluate from vehicle.energy.bmsPublish.batteryMeasurementsOut.payload to vehicle.energy.batteryEvaluate.batteryMeasurementsIn.payload;
    flow vBatteryEvaluateToRestriction from vehicle.energy.batteryEvaluate.candidateOut.payload to vehicle.energy.batteryRestriction.candidateIn.payload;
    flow vRetentionToBatteryRestriction from vehicle.platform.retention.candidateOut.payload to vehicle.energy.batteryRestriction.retentionCandidateIn.payload;

}
