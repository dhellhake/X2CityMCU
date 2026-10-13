package X2CitySoftwareArchitecture {
    public import X2CitySharedSoftwareTypes::*;
    public import X2CityContract_BatteryControl::*;
    public import X2CitySoftwareComponent_RidingControl::*;
    public import X2CitySoftwareContract_RidingControl::*;
    public import X2CitySoftwareComponent_HmiAdapter::*;
    public import X2CitySoftwareContract_HmiAdapter::*;
    public import X2CitySoftwareComponent_BmsLink::*;
    public import X2CitySoftwareContract_BmsLink::*;
    public import X2CitySoftwareComponent_BatteryProtection::*;
    public import X2CitySoftwareContract_BatteryProtection::*;
    public import X2CitySoftwareComponent_LightPolicy::*;
    public import X2CitySoftwareContract_LightPolicy::*;
    public import X2CitySoftwareComponent_AnalogAcquisition::*;
    public import X2CitySoftwareContract_AnalogAcquisition::*;
    public import X2CitySoftwareComponent_AcceleratorInterface::*;
    public import X2CitySoftwareContract_AcceleratorInterface::*;
    public import X2CitySoftwareComponent_BrakeInterface::*;
    public import X2CitySoftwareContract_BrakeInterface::*;
    public import X2CitySoftwareComponent_TemperatureInterface::*;
    public import X2CitySoftwareContract_TemperatureInterface::*;
    public import X2CitySoftwareComponent_SupplyInterface::*;
    public import X2CitySoftwareContract_SupplyInterface::*;
    public import X2CitySoftwareComponent_MotorPhaseInterface::*;
    public import X2CitySoftwareContract_MotorPhaseInterface::*;
    public import X2CitySoftwareComponent_HallInterface::*;
    public import X2CitySoftwareContract_HallInterface::*;
    public import X2CitySoftwareComponent_MotorPositionEstimator::*;
    public import X2CitySoftwareContract_MotorPositionEstimator::*;
    public import X2CitySoftwareComponent_TractionControl::*;
    public import X2CitySoftwareContract_TractionControl::*;
    public import X2CitySoftwareComponent_Platform::*;
    public import X2CitySoftwareContract_Platform::*;
    public import X2CitySoftwareComponent_SuppliedBms::*;
    public import X2CitySoftwareContract_SuppliedBms::*;
    public import X2CitySoftwareComponent_SuppliedVd18mt::*;

    // These are typed information endpoints at the software scope boundary, not hardware parts,
    // sensor/ADC producers, pin models, or selected implementation APIs.
    part def VehicleSoftwareBoundary {
        /* Defines the vehicle host's software-scope exchange boundary for selected light modes, traction
           information/actuation observation, and raw acquisition. It is a typed integration edge,
           not a hardware assembly or an acquisition producer. */
        port lightModes:~LightModesOutputPort;
        port tractionInformationIo:~TractionOutputStageExchangePort;
        port analogRawAcquisition:~RawAdcAcquisitionInputPort;
        port hallCapture:~HallCaptureInputPort;
        port appliedPhaseVoltageEvidence:~AppliedPhaseVoltageEvidenceInputPort;
    }
    part def CallingExecutionContextBoundary {
        doc /* Runtime boundary representing the caller's execution context. Immediately before
           invoking a component, its caller samples the live host-boot monotonic microsecond
           clock and supplies that fixed value. This is not an application peer, clock service,
           scheduler release-time promise, or queued stream. */
        port executionTimeOut:ExecutionTimeOutputPort;
    }

    // ARCH-003 vehicle (.V) instances share one local vehicle context only.
    part ridingControlVehicle:RidingControl;
    part hmiVehicle:HmiAdapter;
    part bmsLinkVehicle:BmsLink;
    part batteryProtectionVehicle:BatteryProtection;
    part lightPolicyVehicle:LightPolicy;
    part analogAcquisitionVehicle:AnalogAcquisition;
    part acceleratorInterfaceVehicle:AcceleratorInterface;
    part brakeInterfaceVehicle:BrakeInterface;
    part temperatureInterfaceVehicle:TemperatureInterface;
    part supplyInterfaceVehicle:SupplyInterface;
    part motorPhaseInterfaceVehicle:MotorPhaseInterface;
    part hallInterfaceVehicle:HallInterface;
    part motorPositionEstimatorVehicle:MotorPositionEstimator;
    ref part tractionControlVehicle:TractionControl;
    // Allocation-only wrapper for the expanded logical MotorControl leaf. It references the
    // existing core and sensor occurrences below; it is not another deployed component.
    ref part motorControlRealizationVehicle:MotorControlRealization;
    part platformVehicle:Platform;

    part suppliedBmsVehicle:SuppliedBms;
    part suppliedVd18mtVehicle:SuppliedVd18mt;
    part vehicleBoundary:VehicleSoftwareBoundary;
    part callingExecutionContext:CallingExecutionContextBoundary;

    // Every project-owned software component receives its invocation reference from the runtime
    // calling context. Each component may use it to evaluate its own timeouts; no component reads
    // a clock service directly.
    flow executionTimeToRidingControl from callingExecutionContext.executionTimeOut.payload to ridingControlVehicle.executionTimeIn.payload;
    flow executionTimeToHmiAdapter from callingExecutionContext.executionTimeOut.payload to hmiVehicle.executionTimeIn.payload;
    flow executionTimeToBmsLink from callingExecutionContext.executionTimeOut.payload to bmsLinkVehicle.executionTimeIn.payload;
    flow executionTimeToBatteryProtection from callingExecutionContext.executionTimeOut.payload to batteryProtectionVehicle.executionTimeIn.payload;
    flow executionTimeToLightPolicy from callingExecutionContext.executionTimeOut.payload to lightPolicyVehicle.executionTimeIn.payload;
    flow executionTimeToAnalogAcquisition from callingExecutionContext.executionTimeOut.payload to analogAcquisitionVehicle.executionTimeIn.payload;
    flow executionTimeToAcceleratorInterface from callingExecutionContext.executionTimeOut.payload to acceleratorInterfaceVehicle.executionTimeIn.payload;
    flow executionTimeToBrakeInterface from callingExecutionContext.executionTimeOut.payload to brakeInterfaceVehicle.executionTimeIn.payload;
    flow executionTimeToTemperatureInterface from callingExecutionContext.executionTimeOut.payload to temperatureInterfaceVehicle.executionTimeIn.payload;
    flow executionTimeToSupplyInterface from callingExecutionContext.executionTimeOut.payload to supplyInterfaceVehicle.executionTimeIn.payload;
    flow executionTimeToMotorPhaseInterface from callingExecutionContext.executionTimeOut.payload to motorPhaseInterfaceVehicle.executionTimeIn.payload;
    flow executionTimeToHallInterface from callingExecutionContext.executionTimeOut.payload to hallInterfaceVehicle.executionTimeIn.payload;
    flow executionTimeToMotorPositionEstimator from callingExecutionContext.executionTimeOut.payload to motorPositionEstimatorVehicle.executionTimeIn.payload;
    flow executionTimeToTractionControl from callingExecutionContext.executionTimeOut.payload to tractionControlVehicle.executionTimeIn.payload;
    flow executionTimeToPlatform from callingExecutionContext.executionTimeOut.payload to platformVehicle.executionTimeIn.payload;

    // SW-I-001/002: qualified rider/settings information and setting/session consumers.
    // Qualified physical motion is required for the explicit setting-application and Ready
    // standstill guards; neither guard reconstructs standstill from demand or Hall edge absence.

    // Single RidingControl boundary: every producer-owned input is delivered once.
    flow ridingSettingsToControl from hmiVehicle.ridingSettingsOut.payload to ridingControlVehicle.hmiRiderSettingsRequestIn.payload;
    flow vehicleOperationToControl from hmiVehicle.vehicleOperationRequestOut.request to ridingControlVehicle.vehicleOperationRequestIn.request;
    flow runtimeInitializationToControl from platformVehicle.runtimeInitializationOut.initialization to ridingControlVehicle.runtimeInitializationIn.initialization;
    flow acceleratorToControl from acceleratorInterfaceVehicle.acceleratorPositionOut.payload to ridingControlVehicle.acceleratorPositionIn.acceleratorPosition;
    flow brakeToControl from brakeInterfaceVehicle.brakeLeverStateOut.brakeLeverState to ridingControlVehicle.brakeLeverStateIn.brakeLeverState;
    flow motionToControl from tractionControlVehicle.qualifiedMotionOut.payload to ridingControlVehicle.qualifiedVehicleMotionIn.payload;
    flow motorPositionToControl from motorPositionEstimatorVehicle.motorPositionOut.payload to ridingControlVehicle.motorPositionIn.payload;
    flow temperatureToControl from tractionControlVehicle.qualifiedTemperatureOut.payload to ridingControlVehicle.qualifiedTemperatureIn.payload;
    flow tractionConditionToControl from tractionControlVehicle.tractionObservationOut.payload to ridingControlVehicle.tractionConditionEvidenceIn.payload;
    flow batteryReadinessToControl from batteryProtectionVehicle.batteryReadinessAndFaultOut.readinessAndFault to ridingControlVehicle.batteryReadinessAndFaultIn.readinessAndFault;
    flow batterySocToControl from batteryProtectionVehicle.stateOfChargeOut.stateOfCharge to ridingControlVehicle.stateOfChargeIn.stateOfCharge;
    flow batteryLimitsToControl from batteryProtectionVehicle.batteryOperatingLimitsOut.operatingLimits to ridingControlVehicle.batteryOperatingLimitsIn.operatingLimits;
    flow actualTractionToControl from tractionControlVehicle.appliedTractionStateOut.payload to ridingControlVehicle.actualTractionOutputIn.payload;
    flow platformContextToControl from platformVehicle.platformContextOut.payload to ridingControlVehicle.platformContextIn.payload;
    flow platformHealthToControl from platformVehicle.platformHealthOut.payload to ridingControlVehicle.platformHealthIn.payload;
    flow controlAuthorityToTraction from ridingControlVehicle.ridingAuthorityOut.payload to tractionControlVehicle.ridingAuthorityIn.payload;
    flow controlCommandToTraction from ridingControlVehicle.wheelTorqueCommandOut.payload to tractionControlVehicle.wheelTorqueRequestIn.payload;
    flow controlFaultToHmi from ridingControlVehicle.selectedFaultIndicationOut.selectedFaultIndication to hmiVehicle.selectedFaultIn.selectedFaultIndication;
    flow controlSleepToPlatform from ridingControlVehicle.sleepRequestOut.request to platformVehicle.sleepRequestIn.request;
    // SW-I-003/004/005/006: vehicle policy, dedicated demand inputs, signed command and observations.
    interface rV16BatteryMeasurements : IfA009BatteryMeasurements
        connect bmsLinkVehicle.batteryMeasurementsOut to batteryProtectionVehicle.batteryMeasurementsIn;
    flow rV19LowSocRetention from platformVehicle.retentionCandidateOut.payload to batteryProtectionVehicle.lowSocRetentionCandidateIn.payload;
    // LightModeSelection receives the three concrete System-contract facts. BrakeInterface
    // owns mechanical-lever qualification; Traction owns actual electrical-braking state.
    flow rV20BrakeLeverState from brakeInterfaceVehicle.brakeLeverStateOut.brakeLeverState to lightPolicyVehicle.brakeLeverStateIn.brakeLeverState;
    flow rV21NormalLightRequest from hmiVehicle.runningLightStateOut.normalLightRequest to lightPolicyVehicle.runningLightStateIn.normalLightRequest;
    flow rV22ElectricalBrakingState from tractionControlVehicle.electricalBrakingStateOut.payload to lightPolicyVehicle.electricalBrakingStateIn.payload;
    flow rV24StateOfCharge from batteryProtectionVehicle.stateOfChargeOut.stateOfCharge to hmiVehicle.stateOfChargeIn.stateOfCharge;
    flow rV24BatteryCurrent from batteryProtectionVehicle.batteryCurrentOut.batteryCurrent to hmiVehicle.batteryCurrentIn.batteryCurrent;
    flow rV24VehicleMotion from tractionControlVehicle.qualifiedMotionOut.payload to hmiVehicle.vehicleMotionIn.payload;

    // R-X01 realizes the logical LE-HMI-ELECTRICAL data boundary only. The separate fixed
    // VD18MT pin-5 wake path is conditioned in HMI electrical hardware before Compute Hardware;
    // a concrete UART driver/peripheral is a realization decision, not an SC-HMI protocol port.
    flow rX01ReceivedData from suppliedVd18mtVehicle.uartReceivedDataOut.receivedData to hmiVehicle.uartReceivedDataIn.receivedData;
    flow rX01TransmittedData from hmiVehicle.uartTransmittedDataOut.transmittedData to suppliedVd18mtVehicle.uartTransmittedDataIn.transmittedData;

    // R-V25 is the existing light boundary. R-V26 keeps one typed command direction and a
    // separate physical-stage/protection evidence direction at the existing traction boundary.
    flow rV25 from lightPolicyVehicle.lightModesOut.payload to vehicleBoundary.lightModes.payload;
    flow rV26Acquisition from vehicleBoundary.tractionInformationIo.evidence to tractionControlVehicle.tractionOutputStageExchange.evidence;
    flow rV26ActuationObservation from tractionControlVehicle.tractionOutputStageExchange.phaseExcitationCommand to vehicleBoundary.tractionInformationIo.phaseExcitationCommand;

    // R-V27 carries qualified Hall observation, including sector bounds and transition evidence,
    // to the sole final-angle owner. It is not vehicle-speed qualification.
    flow rV27HallObservation from hallInterfaceVehicle.hallObservationOut.payload to motorPositionEstimatorVehicle.hallObservationIn.payload;
    // Hall-only health preserves the existing motion
    // qualification input separately from the broader FOC sensor-health gate.
    flow rV27MotionHealth from hallInterfaceVehicle.hallHealthOut.payload to tractionControlVehicle.motionHealthIn.payload;
    flow rV28Phase from motorPhaseInterfaceVehicle.phaseCurrentEpochOut.payload to tractionControlVehicle.phaseCurrentEpochIn.payload;
    flow rV28PhaseToPositionEstimator from motorPhaseInterfaceVehicle.phaseCurrentEpochOut.payload to motorPositionEstimatorVehicle.phaseCurrentEpochIn.payload;
    flow rV28Supply from supplyInterfaceVehicle.fastDcLinkVoltageOut.payload to tractionControlVehicle.fastDcLinkVoltageIn.payload;
    // The existing traction condition publisher evaluates categorized local evidence from the
    // shared semantic producers. These routes add no sensor conversion or fault latch to Traction.
    flow rV28TemperatureCondition from temperatureInterfaceVehicle.qualifiedTemperatureOut.payload to tractionControlVehicle.qualifiedTemperatureIn.payload;
    flow rV28RegularSupplyCondition from supplyInterfaceVehicle.supplyVoltageOut.payload to tractionControlVehicle.regularSupplyVoltageIn.payload;
    // R-V29 is a distinct source-qualified observer-voltage chain. Regular phase diagnostics
    // have no route to it and it remains unavailable until the open HSI source is qualified.
    flow rV29AppliedVoltageBoundary from vehicleBoundary.appliedPhaseVoltageEvidence.payload to motorPhaseInterfaceVehicle.appliedPhaseVoltageEvidenceIn.payload;
    flow rV29AppliedVoltageToPositionEstimator from motorPhaseInterfaceVehicle.qualifiedAppliedPhaseVoltageOut.payload to motorPositionEstimatorVehicle.qualifiedAppliedPhaseVoltageIn.payload;
    // R-V30 delivers the one complete estimator record to each defined consumer. Qualification
    // remains delivered even when the Position member is unavailable; health-only updates retain
    // Position reference time and never travel through generic health fan-ins.
    flow rV30MotorPosition from motorPositionEstimatorVehicle.motorPositionOut.payload to tractionControlVehicle.motorPositionIn.payload;
    flow rV30MotorPositionPlatform from motorPositionEstimatorVehicle.motorPositionOut.payload to platformVehicle.motorPositionIn.payload;

    // R-V41..R-V44 carry one-way qualified sensor evidence. The accelerator composite carries
    // its SensorHealthCondition-compatible Qualification member with Position, avoiding a second
    // accelerator health publication to Session. Platform and Traction use exact derived health
    // payloads.
    // Platform may latch FastSafetyState from an explicit request. Its platformHealthOut is never a
    // route back into sensorHealthIn, so a platform result cannot become a sensor root cause.
    flow rV41AnalogHealthPlatform from analogAcquisitionVehicle.adcAcquisitionHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41AcceleratorHealthPlatform from acceleratorInterfaceVehicle.acceleratorPositionOut.payload.Qualification to platformVehicle.acceleratorQualificationIn.payload;
    flow rV41BrakeHealthPlatform from brakeInterfaceVehicle.brakeHealthOut.qualification to platformVehicle.brakeQualificationIn.qualification;
    flow rV41TemperatureHealthPlatform from temperatureInterfaceVehicle.temperatureHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41SupplyHealthPlatform from supplyInterfaceVehicle.supplyHealthOut.qualification to platformVehicle.sensorHealthIn.payload;
    flow rV41PhaseHealthPlatform from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41HallHealthPlatform from hallInterfaceVehicle.hallHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV43TemperatureHealthTraction from temperatureInterfaceVehicle.temperatureHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;
    flow rV43SupplyHealthTraction from supplyInterfaceVehicle.supplyHealthOut.qualification to tractionControlVehicle.supplyHealthIn.qualification;
    flow rV43PhaseHealthTraction from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;
    flow rV43HallHealthTraction from hallInterfaceVehicle.hallHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;

    // SW-I-009 / R-V31: exact vehicle-local context and health event family.
    flow rV31ContextHmi from platformVehicle.platformContextOut.payload to hmiVehicle.platformContextIn.payload;
    flow rV31HealthHmi from platformVehicle.platformHealthOut.payload to hmiVehicle.platformHealthIn.payload;
    flow rV31ContextBms from platformVehicle.platformContextOut.payload to bmsLinkVehicle.platformContextIn.payload;
    flow rV31HealthBms from platformVehicle.platformHealthOut.payload to bmsLinkVehicle.platformHealthIn.payload;
    flow rV31ContextBattery from platformVehicle.platformContextOut.payload to batteryProtectionVehicle.platformContextIn.payload;
    flow rV31HealthBattery from platformVehicle.platformHealthOut.payload to batteryProtectionVehicle.platformHealthIn.payload;
    flow rV31ContextLight from platformVehicle.platformContextOut.payload to lightPolicyVehicle.platformContextIn.payload;
    flow rV31HealthLight from platformVehicle.platformHealthOut.payload to lightPolicyVehicle.platformHealthIn.payload;
    flow rV31ContextAnalog from platformVehicle.platformContextOut.payload to analogAcquisitionVehicle.platformContextIn.payload;
    flow rV31HealthAnalog from platformVehicle.platformHealthOut.payload to analogAcquisitionVehicle.platformHealthIn.payload;
    flow rV31ContextAccelerator from platformVehicle.platformContextOut.payload to acceleratorInterfaceVehicle.platformContextIn.payload;
    flow rV31HealthAccelerator from platformVehicle.platformHealthOut.payload to acceleratorInterfaceVehicle.platformHealthIn.payload;
    flow rV31ContextBrake from platformVehicle.platformContextOut.payload to brakeInterfaceVehicle.platformContextIn.payload;
    flow rV31HealthBrake from platformVehicle.platformHealthOut.payload to brakeInterfaceVehicle.platformHealthIn.payload;
    flow rV31ContextTemperature from platformVehicle.platformContextOut.payload to temperatureInterfaceVehicle.platformContextIn.payload;
    flow rV31HealthTemperature from platformVehicle.platformHealthOut.payload to temperatureInterfaceVehicle.platformHealthIn.payload;
    flow rV31ContextSupply from platformVehicle.platformContextOut.payload to supplyInterfaceVehicle.platformContextIn.payload;
    flow rV31HealthSupply from platformVehicle.platformHealthOut.payload to supplyInterfaceVehicle.platformHealthIn.payload;
    flow rV31ContextPhase from platformVehicle.platformContextOut.payload to motorPhaseInterfaceVehicle.platformContextIn.payload;
    flow rV31HealthPhase from platformVehicle.platformHealthOut.payload to motorPhaseInterfaceVehicle.platformHealthIn.payload;
    flow rV31ContextHall from platformVehicle.platformContextOut.payload to hallInterfaceVehicle.platformContextIn.payload;
    flow rV31HealthHall from platformVehicle.platformHealthOut.payload to hallInterfaceVehicle.platformHealthIn.payload;
    flow rV31ContextMotorPositionEstimator from platformVehicle.platformContextOut.payload to motorPositionEstimatorVehicle.platformContextIn.payload;
    flow rV31HealthMotorPositionEstimator from platformVehicle.platformHealthOut.payload to motorPositionEstimatorVehicle.platformHealthIn.payload;
    flow rV31ContextTraction from platformVehicle.platformContextOut.payload to tractionControlVehicle.platformContextIn.payload;
    flow rV31HealthTraction from platformVehicle.platformHealthOut.payload to tractionControlVehicle.platformHealthIn.payload;
    flow rV31ContextPlatform from platformVehicle.platformContextOut.payload to platformVehicle.platformContextIn.payload;
    flow rV31HealthPlatform from platformVehicle.platformHealthOut.payload to platformVehicle.platformHealthIn.payload;

    // R-X02: opaque supplied BMS endpoint in the vehicle configuration.
    flow rX02VehicleReceive from suppliedBmsVehicle.bmsTransportIo.payload to bmsLinkVehicle.bmsTransportExchange.payload;
    flow rX02VehicleRequest from bmsLinkVehicle.bmsTransportExchange.payload to suppliedBmsVehicle.bmsTransportIo.payload;

    // R-X03 raw acquisition boundaries. SC-ANALOG-ACQ and SC-HALL-IF, not SC-PLATFORM, own
    // vehicle acquisition records.
    flow rX03VehicleAnalog from vehicleBoundary.analogRawAcquisition.payload to analogAcquisitionVehicle.rawAdcAcquisitionIn.payload;
    flow rX03VehicleHall from vehicleBoundary.hallCapture.payload to hallInterfaceVehicle.hallCaptureIn.payload;

    // The JEOS-to-output fast chain is Detailed Design-only: U-ANALOG-ACQ-FAST publishes the
    // injected epoch to the phase/supply contributors; TractionControl consumes their typed
    // evidence and U-TRACTION-OUTPUT receives PWMAndADCSamplingPlan.
    // R-V33..R-V38 below are direct owner-record handoffs: Analog regular scans are consumed by
    // semantic interfaces; Analog fast epochs go only to MotorPhase and Supply. No raw ADC route
    // reaches FOC. No public SC fast ports are created by this architecture.
    flow rV33AcceleratorRaw from analogAcquisitionVehicle.analogSampleOut.payload to acceleratorInterfaceVehicle.analogSampleIn.payload;
    flow rV34BrakeRaw from analogAcquisitionVehicle.analogSampleOut.payload to brakeInterfaceVehicle.analogSampleIn.payload;
    flow rV35TemperatureRaw from analogAcquisitionVehicle.analogSampleOut.payload to temperatureInterfaceVehicle.analogSampleIn.payload;
    flow rV36SupplyRegularRaw from analogAcquisitionVehicle.analogSampleOut.payload to supplyInterfaceVehicle.analogSampleIn.payload;
    flow rV37PhaseRegularRaw from analogAcquisitionVehicle.analogSampleOut.payload to motorPhaseInterfaceVehicle.analogSampleIn.payload;
    flow rV38PhaseFastRaw from analogAcquisitionVehicle.fastInjectedEpochOut.payload to motorPhaseInterfaceVehicle.fastInjectedEpochIn.payload;
    flow rV39SupplyFastRaw from analogAcquisitionVehicle.fastInjectedEpochOut.payload to supplyInterfaceVehicle.fastInjectedEpochIn.payload;
}
