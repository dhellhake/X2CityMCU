package X2CitySoftwareArchitecture {
    public import X2CitySharedSoftwareTypes::*;
    public import X2CityContract_BatteryControl::*;
    public import X2CitySoftwareComponent_SettingsPolicy::*;
    public import X2CitySoftwareContract_SettingsPolicy::*;
    public import X2CitySoftwareComponent_SessionPolicy::*;
    public import X2CitySoftwareContract_SessionPolicy::*;
    public import X2CitySoftwareComponent_DemandPolicy::*;
    public import X2CitySoftwareContract_DemandPolicy::*;
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
    public import X2CitySoftwareComponent_TractionControl::*;
    public import X2CitySoftwareContract_TractionControl::*;
    public import X2CitySoftwareComponent_Platform::*;
    public import X2CitySoftwareContract_Platform::*;
    public import X2CitySoftwareComponent_SuppliedBms::*;
    public import X2CitySoftwareContract_SuppliedBms::*;
    public import X2CitySoftwareComponent_SuppliedVd18mt::*;
    public import X2CitySoftwareContract_SuppliedVd18mt::*;

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
    }
    part def CallingExecutionContextBoundary {
        doc /* Runtime boundary representing the caller's execution context. Immediately before
           invoking a component, its caller samples the live host-boot monotonic microsecond
           clock and supplies that fixed value. This is not an application peer, clock service,
           scheduler release-time promise, or queued stream. */
        port executionTimeOut:ExecutionTimeOutputPort;
    }

    // ARCH-003 vehicle (.V) instances share one local vehicle context only.
    part setVehicle:SettingsPolicy;
    part sessionVehicle:SessionPolicy;
    part demandVehicle:DemandPolicy;
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
    ref part tractionControlVehicle:TractionControl;
    part platformVehicle:Platform;

    part suppliedBmsVehicle:SuppliedBms;
    part suppliedVd18mtVehicle:SuppliedVd18mt;
    part vehicleBoundary:VehicleSoftwareBoundary;
    part callingExecutionContext:CallingExecutionContextBoundary;

    // Every project-owned software component receives its invocation reference from the runtime
    // calling context. Each component may use it to evaluate its own timeouts; no component reads
    // a clock service directly.
    flow executionTimeToSettingsPolicy from callingExecutionContext.executionTimeOut.payload to setVehicle.executionTimeIn.payload;
    flow executionTimeToSessionPolicy from callingExecutionContext.executionTimeOut.payload to sessionVehicle.executionTimeIn.payload;
    flow executionTimeToDemandPolicy from callingExecutionContext.executionTimeOut.payload to demandVehicle.executionTimeIn.payload;
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
    flow executionTimeToTractionControl from callingExecutionContext.executionTimeOut.payload to tractionControlVehicle.executionTimeIn.payload;
    flow executionTimeToPlatform from callingExecutionContext.executionTimeOut.payload to platformVehicle.executionTimeIn.payload;

    // SW-I-001/002: qualified rider/settings information and setting/session consumers.
    flow rV01 from acceleratorInterfaceVehicle.acceleratorPositionOut.payload to setVehicle.acceleratorPositionIn.payload;
    flow rV02 from hmiVehicle.hmiSettingsRequestOut.payload to setVehicle.settingsRequestIn.payload;
    flow rV03Accelerator from acceleratorInterfaceVehicle.acceleratorPositionOut.payload to sessionVehicle.acceleratorPositionIn.payload;
    flow rV03Brake from brakeInterfaceVehicle.brakeStateOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV03Temperature from temperatureInterfaceVehicle.qualifiedTemperatureOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV03Supply from supplyInterfaceVehicle.supplyVoltageOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV04 from hmiVehicle.hmiSettingsRequestOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV05 from setVehicle.ridingSettingsStateOut.payload to sessionVehicle.ridingReadinessIn.payload;
    // Qualified physical motion is required for the explicit setting-application and Ready
    // standstill guards; neither guard reconstructs standstill from demand or Hall edge absence.
    flow rV05QualifiedMotionSet from tractionControlVehicle.qualifiedMotionOut.payload to setVehicle.qualifiedMotionIn.payload;
    flow rV05QualifiedMotionSession from tractionControlVehicle.qualifiedMotionOut.payload to sessionVehicle.qualifiedMotionIn.payload;

    // SW-I-003/004/005/006: vehicle policy, dedicated demand inputs, signed command and observations.
    flow rV06BatteryReadiness from batteryProtectionVehicle.batteryReadinessAndFaultOut.readinessAndFault to sessionVehicle.batteryReadinessAndFaultIn.readinessAndFault;
    flow rV06StateOfChargeSession from batteryProtectionVehicle.stateOfChargeOut.stateOfCharge to sessionVehicle.stateOfChargeIn.stateOfCharge;
    flow rV07 from tractionControlVehicle.tractionObservationOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV08 from platformVehicle.platformContextOut.payload to sessionVehicle.startupContextIn.payload;
    flow rV09Authority from sessionVehicle.ridingAuthorityOut.payload to demandVehicle.ridingAuthorityIn.payload;
    flow rV10Accelerator from acceleratorInterfaceVehicle.acceleratorPositionOut.payload to demandVehicle.acceleratorPositionIn.payload;
    flow rV10Brake from brakeInterfaceVehicle.brakeStateOut.payload to demandVehicle.brakeStateIn.payload;
    flow rV11ActiveSettings from setVehicle.activeRidingSettingsOut.payload to demandVehicle.activeRidingSettingsIn.payload;
    flow rV12BatteryOperatingLimits from batteryProtectionVehicle.batteryOperatingLimitsOut.operatingLimits to demandVehicle.batteryOperatingLimitsIn.payload;
    flow rV13QualifiedMotion from tractionControlVehicle.qualifiedMotionOut.payload to demandVehicle.qualifiedMotionIn.payload;
    flow rV13ActualOutput from tractionControlVehicle.appliedTractionStateOut.payload to demandVehicle.actualTractionOutputIn.payload;
    flow rV14 from demandVehicle.wheelTorqueRequestOut.payload to tractionControlVehicle.wheelTorqueRequestIn.payload;
    flow rV15 from sessionVehicle.ridingAuthorityOut.payload to tractionControlVehicle.ridingAuthorityIn.payload;
    interface rV16BatteryMeasurements : IfA009BatteryMeasurements
        connect bmsLinkVehicle.batteryMeasurementsOut to batteryProtectionVehicle.batteryMeasurementsIn;
    flow rV19LowSocRetention from platformVehicle.retentionCandidateOut.payload to batteryProtectionVehicle.lowSocRetentionCandidateIn.payload;
    // LightModeSelection receives the three concrete System-contract facts. InputQualification
    // owns the mechanical-lever qualification; Traction owns actual electrical-braking state.
    flow rV20BrakeLeverState from brakeInterfaceVehicle.brakeStateOut.payload to lightPolicyVehicle.brakeLeverStateIn.payload;
    flow rV21NormalLightRequest from hmiVehicle.hmiLightRequestOut.payload to lightPolicyVehicle.runningLightStateIn.payload;
    flow rV22ElectricalBrakingState from tractionControlVehicle.electricalBrakingStateOut.payload to lightPolicyVehicle.electricalBrakingStateIn.payload;
    flow rV23 from sessionVehicle.sessionReportOut.payload to hmiVehicle.hmiReportIn.payload;
    flow rV24StateOfCharge from batteryProtectionVehicle.stateOfChargeOut.stateOfCharge to hmiVehicle.stateOfChargeIn.stateOfCharge;
    flow rV24BatteryCurrent from batteryProtectionVehicle.batteryCurrentOut.batteryCurrent to hmiVehicle.batteryCurrentIn.batteryCurrent;

    // R-V25/R-V26 are opaque software boundary information exchanges.
    flow rV25 from lightPolicyVehicle.lightModesOut.payload to vehicleBoundary.lightModes.payload;
    flow rV26Acquisition from vehicleBoundary.tractionInformationIo.payload to tractionControlVehicle.tractionOutputStageExchange.payload;
    flow rV26ActuationObservation from tractionControlVehicle.tractionOutputStageExchange.payload to vehicleBoundary.tractionInformationIo.payload;

    // R-V27 is complete qualified electrical position; it is not vehicle-speed qualification.
    flow rV27 from hallInterfaceVehicle.hallElectricalPositionOut.payload to tractionControlVehicle.hallElectricalPositionIn.payload;
    // R-V27 / P-TR-MOTION-HEALTH-I: Hall-only health preserves the existing motion
    // qualification input separately from the broader FOC sensor-health gate.
    flow rV27MotionHealth from hallInterfaceVehicle.hallHealthOut.payload to tractionControlVehicle.motionHealthIn.payload;
    flow rV28Phase from motorPhaseInterfaceVehicle.phaseCurrentEpochOut.payload to tractionControlVehicle.phaseCurrentEpochIn.payload;
    flow rV28Supply from supplyInterfaceVehicle.fastDcLinkVoltageOut.payload to tractionControlVehicle.fastDcLinkVoltageIn.payload;

    // R-V41..R-V44 carry one-way qualified sensor evidence. The accelerator composite carries
    // its SensorHealthCondition-compatible Qualification member with Position, avoiding a second
    // accelerator health publication to Session. Platform and Traction use exact derived health
    // payloads.
    // Platform may latch FastSafetyState from an explicit request. Its platformHealthOut is never a
    // route back into sensorHealthIn, so a platform result cannot become a sensor root cause.
    flow rV41AnalogHealthPlatform from analogAcquisitionVehicle.adcAcquisitionHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41AcceleratorHealthPlatform from acceleratorInterfaceVehicle.acceleratorPositionOut.payload.Qualification to platformVehicle.acceleratorQualificationIn.payload;
    flow rV41BrakeHealthPlatform from brakeInterfaceVehicle.brakeHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41TemperatureHealthPlatform from temperatureInterfaceVehicle.temperatureHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41SupplyHealthPlatform from supplyInterfaceVehicle.supplyHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41PhaseHealthPlatform from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41HallHealthPlatform from hallInterfaceVehicle.hallHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV42AnalogHealthSession from analogAcquisitionVehicle.adcAcquisitionHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42BrakeHealthSession from brakeInterfaceVehicle.brakeHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42TemperatureHealthSession from temperatureInterfaceVehicle.temperatureHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42SupplyHealthSession from supplyInterfaceVehicle.supplyHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42PhaseHealthSession from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42HallHealthSession from hallInterfaceVehicle.hallHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV43TemperatureHealthTraction from temperatureInterfaceVehicle.temperatureHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;
    flow rV43SupplyHealthTraction from supplyInterfaceVehicle.supplyHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;
    flow rV43PhaseHealthTraction from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;
    flow rV43HallHealthTraction from hallInterfaceVehicle.hallHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;

    // SW-I-009 / R-V31: exact vehicle-local context and health event family.
    flow rV31ContextSet from platformVehicle.platformContextOut.payload to setVehicle.platformContextIn.payload;
    flow rV31HealthSet from platformVehicle.platformHealthOut.payload to setVehicle.platformHealthIn.payload;
    flow rV31ContextSession from platformVehicle.platformContextOut.payload to sessionVehicle.platformContextIn.payload;
    flow rV31HealthSession from platformVehicle.platformHealthOut.payload to sessionVehicle.platformHealthIn.payload;
    flow rV31ContextDemand from platformVehicle.platformContextOut.payload to demandVehicle.platformContextIn.payload;
    flow rV31HealthDemand from platformVehicle.platformHealthOut.payload to demandVehicle.platformHealthIn.payload;
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
    flow rV31ContextTraction from platformVehicle.platformContextOut.payload to tractionControlVehicle.platformContextIn.payload;
    flow rV31HealthTraction from platformVehicle.platformHealthOut.payload to tractionControlVehicle.platformHealthIn.payload;
    flow rV31ContextPlatform from platformVehicle.platformContextOut.payload to platformVehicle.platformContextIn.payload;
    flow rV31HealthPlatform from platformVehicle.platformHealthOut.payload to platformVehicle.platformHealthIn.payload;

    // R-X01: opaque supplied VD18MT transport, both byte/report directions.
    flow rX01Receive from suppliedVd18mtVehicle.hmiTransportIo.payload to hmiVehicle.hmiTransportExchange.payload;
    flow rX01Transmit from hmiVehicle.hmiTransportExchange.payload to suppliedVd18mtVehicle.hmiTransportIo.payload;

    // R-X02: opaque supplied BMS endpoint in the vehicle configuration.
    flow rX02VehicleReceive from suppliedBmsVehicle.bmsTransportIo.payload to bmsLinkVehicle.bmsTransportExchange.payload;
    flow rX02VehicleRequest from bmsLinkVehicle.bmsTransportExchange.payload to suppliedBmsVehicle.bmsTransportIo.payload;

    // R-X03 raw acquisition boundaries. SC-ANALOG-ACQ and SC-HALL-IF, not SC-PLATFORM, own
    // vehicle acquisition records.
    flow rX03VehicleAnalog from vehicleBoundary.analogRawAcquisition.payload to analogAcquisitionVehicle.rawAdcAcquisitionIn.payload;
    flow rX03VehicleHall from vehicleBoundary.hallCapture.payload to hallInterfaceVehicle.hallCaptureIn.payload;

    // The JEOS-to-output fast chain is Detailed Design-only: U-TRACTION-ACQUISITION directly
    // hands its FastEpoch to U-TRACTION-CONTROL, then U-TRACTION-OUTPUT receives PWMAndADCSamplingPlan.
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
