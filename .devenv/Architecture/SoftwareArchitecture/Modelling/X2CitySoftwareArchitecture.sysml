package X2CitySoftwareArchitecture {
    public import X2CitySharedSoftwareTypes::*;
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
    public import X2CitySoftwareComponent_ServiceInformation::*;
    public import X2CitySoftwareContract_ServiceInformation::*;
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
        /* Defines the vehicle host's software-scope exchange boundary for light intent, traction
           information/actuation observation, and raw acquisition. It is a typed integration edge,
           not a hardware assembly or an acquisition producer. */
        port lightIntent:~LightIntentOutputPort;
        port tractionInformationIo:~TractionOutputStageExchangePort;
        port analogRawAcquisition:~RawAdcAcquisitionInputPort;
        port hallCapture:~HallCaptureInputPort;
    }
    part def MaintainerServiceBoundary {
        /* Exposes a read-only service snapshot to a maintainer or service consumer. This boundary
           carries presentation data only and has no control path back into the software architecture. */
        port snapshot:~ServiceSnapshotOutputPort;
    }

    // ARCH-003 vehicle (.V) instances share one local vehicle context only.
    part setVehicle:SettingsPolicy;
    part sessionVehicle:SessionPolicy;
    part demandVehicle:DemandPolicy;
    part hmiVehicle:HmiAdapter;
    part bmsLinkVehicle:BmsLink;
    part batteryProtectionVehicle:BatteryProtection;
    part lightPolicyVehicle:LightPolicy;
    part serviceInformationVehicle:ServiceInformation;
    part analogAcquisitionVehicle:AnalogAcquisition;
    part acceleratorInterfaceVehicle:AcceleratorInterface;
    part brakeInterfaceVehicle:BrakeInterface;
    part temperatureInterfaceVehicle:TemperatureInterface;
    part supplyInterfaceVehicle:SupplyInterface;
    part motorPhaseInterfaceVehicle:MotorPhaseInterface;
    part hallInterfaceVehicle:HallInterface;
    part tractionControlVehicle:TractionControl;
    part platformVehicle:Platform;

    part suppliedBmsVehicle:SuppliedBms;
    part suppliedVd18mtVehicle:SuppliedVd18mt;
    part vehicleBoundary:VehicleSoftwareBoundary;
    part vehicleMaintainerBoundary:MaintainerServiceBoundary;

    // SW-I-001/002: qualified rider/settings information and setting/session consumers.
    flow rV01 from acceleratorInterfaceVehicle.acceleratorPositionOut.payload to setVehicle.settingsRequestIn.payload;
    flow rV02 from hmiVehicle.hmiSettingsRequestOut.payload to setVehicle.settingsRequestIn.payload;
    flow rV03Accelerator from acceleratorInterfaceVehicle.acceleratorPositionOut.payload to sessionVehicle.ridingReadinessIn.payload;
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
    flow rV06 from batteryProtectionVehicle.batteryCapabilityEnvelopeOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV07 from tractionControlVehicle.tractionObservationOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV08 from platformVehicle.platformContextOut.payload to sessionVehicle.startupContextIn.payload;
    flow rV09Authority from sessionVehicle.ridingAuthorityOut.payload to demandVehicle.ridingAuthorityIn.payload;
    flow rV10Accelerator from acceleratorInterfaceVehicle.acceleratorPositionOut.payload to demandVehicle.acceleratorPositionIn.payload;
    flow rV10Brake from brakeInterfaceVehicle.brakeStateOut.payload to demandVehicle.brakeStateIn.payload;
    flow rV11ActiveSettings from setVehicle.activeRidingSettingsOut.payload to demandVehicle.activeRidingSettingsIn.payload;
    flow rV12BatteryCapability from batteryProtectionVehicle.batteryCapabilityEnvelopeOut.payload to demandVehicle.batteryCapabilityIn.payload;
    flow rV13QualifiedMotion from tractionControlVehicle.qualifiedMotionOut.payload to demandVehicle.qualifiedMotionIn.payload;
    flow rV13ActualOutput from tractionControlVehicle.appliedTractionStateOut.payload to demandVehicle.actualTractionOutputIn.payload;
    flow rV14 from demandVehicle.wheelTorqueRequestOut.payload to tractionControlVehicle.wheelTorqueRequestIn.payload;
    flow rV15 from sessionVehicle.ridingAuthorityOut.payload to tractionControlVehicle.ridingAuthorityIn.payload;
    flow rV16 from bmsLinkVehicle.bmsObservationOut.payload to batteryProtectionVehicle.batteryObservationsAndContextIn.payload;
    flow rV17Temperature from temperatureInterfaceVehicle.qualifiedTemperatureOut.payload to batteryProtectionVehicle.batteryObservationsAndContextIn.payload;
    flow rV17Supply from supplyInterfaceVehicle.supplyVoltageOut.payload to batteryProtectionVehicle.batteryObservationsAndContextIn.payload;
    flow rV17PhaseDiagnostic from motorPhaseInterfaceVehicle.phaseVoltageDiagnosticOut.payload to batteryProtectionVehicle.batteryObservationsAndContextIn.payload;
    flow rV18 from tractionControlVehicle.tractionObservationOut.payload to batteryProtectionVehicle.batteryObservationsAndContextIn.payload;
    flow rV19 from platformVehicle.retentionCandidateOut.payload to batteryProtectionVehicle.batteryObservationsAndContextIn.payload;
    flow rV20 from brakeInterfaceVehicle.brakeStateOut.payload to lightPolicyVehicle.lightPolicyInputIn.payload;
    flow rV21 from hmiVehicle.hmiLightRequestOut.payload to lightPolicyVehicle.lightPolicyInputIn.payload;
    flow rV22 from tractionControlVehicle.tractionObservationOut.payload to lightPolicyVehicle.lightPolicyInputIn.payload;
    flow rV23 from sessionVehicle.sessionReportOut.payload to hmiVehicle.hmiReportIn.payload;
    flow rV24 from batteryProtectionVehicle.batteryCapabilityEnvelopeOut.payload to hmiVehicle.hmiReportIn.payload;

    // R-V25/R-V26 are opaque software boundary information exchanges.
    flow rV25 from lightPolicyVehicle.lightIntentOut.payload to vehicleBoundary.lightIntent.payload;
    flow rV26Acquisition from vehicleBoundary.tractionInformationIo.payload to tractionControlVehicle.tractionOutputStageExchange.payload;
    flow rV26ActuationObservation from tractionControlVehicle.tractionOutputStageExchange.payload to vehicleBoundary.tractionInformationIo.payload;

    // R-V27 is complete qualified electrical position; it is not vehicle-speed qualification.
    flow rV27 from hallInterfaceVehicle.hallElectricalPositionOut.payload to tractionControlVehicle.hallElectricalPositionIn.payload;
    flow rV28Phase from motorPhaseInterfaceVehicle.phaseCurrentEpochOut.payload to tractionControlVehicle.phaseCurrentEpochIn.payload;
    flow rV28Supply from supplyInterfaceVehicle.fastDcLinkVoltageOut.payload to tractionControlVehicle.fastDcLinkVoltageIn.payload;

    // R-V41..R-V44 carry one-way qualified sensor evidence. SensorHealthConditionV1 derives
    // ContextualSoftwareInformation, so the Session and Service record-collection inputs accept
    // it as a typed base-record handoff; Platform and Traction use the exact derived payload.
    // Platform may latch FastSafetyState from an explicit request. Its platformHealthOut is never a
    // route back into sensorHealthIn, so a platform result cannot become a sensor root cause.
    flow rV41AnalogHealthPlatform from analogAcquisitionVehicle.adcAcquisitionHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41AcceleratorHealthPlatform from acceleratorInterfaceVehicle.acceleratorHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41BrakeHealthPlatform from brakeInterfaceVehicle.brakeHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41TemperatureHealthPlatform from temperatureInterfaceVehicle.temperatureHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41SupplyHealthPlatform from supplyInterfaceVehicle.supplyHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41PhaseHealthPlatform from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV41HallHealthPlatform from hallInterfaceVehicle.hallHealthOut.payload to platformVehicle.sensorHealthIn.payload;
    flow rV42AnalogHealthSession from analogAcquisitionVehicle.adcAcquisitionHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42AcceleratorHealthSession from acceleratorInterfaceVehicle.acceleratorHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42BrakeHealthSession from brakeInterfaceVehicle.brakeHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42TemperatureHealthSession from temperatureInterfaceVehicle.temperatureHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42SupplyHealthSession from supplyInterfaceVehicle.supplyHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42PhaseHealthSession from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV42HallHealthSession from hallInterfaceVehicle.hallHealthOut.payload to sessionVehicle.ridingReadinessIn.payload;
    flow rV43TemperatureHealthTraction from temperatureInterfaceVehicle.temperatureHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;
    flow rV43SupplyHealthTraction from supplyInterfaceVehicle.supplyHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;
    flow rV43PhaseHealthTraction from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;
    flow rV43HallHealthTraction from hallInterfaceVehicle.hallHealthOut.payload to tractionControlVehicle.sensorHealthIn.payload;

    // SW-I-009 / R-V31: exact vehicle-local context and health service/event family.
    flow rV31ContextSet from platformVehicle.platformContextOut.payload to setVehicle.platformContextIn.payload;
    flow rV31HealthSet from platformVehicle.platformHealthOut.payload to setVehicle.platformHealthIn.payload;
    flow rV31ContextSession from platformVehicle.platformContextOut.payload to sessionVehicle.platformContextIn.payload;
    flow rV31HealthSession from platformVehicle.platformHealthOut.payload to sessionVehicle.platformHealthIn.payload;
    flow rV31ContextDemand from platformVehicle.platformContextOut.payload to demandVehicle.platformContextIn.payload;
    flow rV31HealthDemand from platformVehicle.platformHealthOut.payload to demandVehicle.platformHealthIn.payload;
    flow rV31CalibrationDemand from platformVehicle.calibrationBundleOut.payload to demandVehicle.calibrationIn.payload;
    flow rV31ContextHmi from platformVehicle.platformContextOut.payload to hmiVehicle.platformContextIn.payload;
    flow rV31HealthHmi from platformVehicle.platformHealthOut.payload to hmiVehicle.platformHealthIn.payload;
    flow rV31ContextBms from platformVehicle.platformContextOut.payload to bmsLinkVehicle.platformContextIn.payload;
    flow rV31HealthBms from platformVehicle.platformHealthOut.payload to bmsLinkVehicle.platformHealthIn.payload;
    flow rV31ContextBattery from platformVehicle.platformContextOut.payload to batteryProtectionVehicle.platformContextIn.payload;
    flow rV31HealthBattery from platformVehicle.platformHealthOut.payload to batteryProtectionVehicle.platformHealthIn.payload;
    flow rV31ContextLight from platformVehicle.platformContextOut.payload to lightPolicyVehicle.platformContextIn.payload;
    flow rV31HealthLight from platformVehicle.platformHealthOut.payload to lightPolicyVehicle.platformHealthIn.payload;
    flow rV31ContextService from platformVehicle.platformContextOut.payload to serviceInformationVehicle.platformContextIn.payload;
    flow rV31HealthService from platformVehicle.platformHealthOut.payload to serviceInformationVehicle.platformHealthIn.payload;
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
    flow rV31CalibrationTraction from platformVehicle.calibrationBundleOut.payload to tractionControlVehicle.calibrationIn.payload;
    flow rV31ContextPlatform from platformVehicle.platformContextOut.payload to platformVehicle.platformContextIn.payload;
    flow rV31HealthPlatform from platformVehicle.platformHealthOut.payload to platformVehicle.platformHealthIn.payload;

    // SW-I-008 / R-V32: all explicit vehicle producer ports retain their owner types.
    flow rV32AnalogRegular from analogAcquisitionVehicle.regularAdcScanOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32AnalogFast from analogAcquisitionVehicle.fastInjectedEpochOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Accelerator from acceleratorInterfaceVehicle.acceleratorPositionOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Brake from brakeInterfaceVehicle.brakeStateOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Temperature from temperatureInterfaceVehicle.qualifiedTemperatureOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32SupplyFast from supplyInterfaceVehicle.fastDcLinkVoltageOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32SupplyRegular from supplyInterfaceVehicle.supplyVoltageOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32PhaseCurrent from motorPhaseInterfaceVehicle.phaseCurrentEpochOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32PhaseDiagnostic from motorPhaseInterfaceVehicle.phaseVoltageDiagnosticOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Hall from hallInterfaceVehicle.hallElectricalPositionOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32HmiSettings from hmiVehicle.hmiSettingsRequestOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32HmiLight from hmiVehicle.hmiLightRequestOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Settings from setVehicle.ridingSettingsStateOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Authority from sessionVehicle.ridingAuthorityOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32SessionReport from sessionVehicle.sessionReportOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32DemandDiagnostic from demandVehicle.demandPolicyDiagnosticOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Bms from bmsLinkVehicle.bmsObservationOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Battery from batteryProtectionVehicle.batteryCapabilityEnvelopeOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Light from lightPolicyVehicle.lightIntentOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32QualifiedMotion from tractionControlVehicle.qualifiedMotionOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32ActualOutput from tractionControlVehicle.appliedTractionStateOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32Traction from tractionControlVehicle.tractionObservationOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32PlatformContext from platformVehicle.platformContextOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32PlatformRetention from platformVehicle.retentionCandidateOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32PlatformHealth from platformVehicle.platformHealthOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV32PlatformCalibration from platformVehicle.calibrationBundleOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV44AnalogHealthService from analogAcquisitionVehicle.adcAcquisitionHealthOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV44AcceleratorHealthService from acceleratorInterfaceVehicle.acceleratorHealthOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV44BrakeHealthService from brakeInterfaceVehicle.brakeHealthOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV44TemperatureHealthService from temperatureInterfaceVehicle.temperatureHealthOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV44SupplyHealthService from supplyInterfaceVehicle.supplyHealthOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV44PhaseHealthService from motorPhaseInterfaceVehicle.motorPhaseHealthOut.payload to serviceInformationVehicle.serviceRecordIn.payload;
    flow rV44HallHealthService from hallInterfaceVehicle.hallHealthOut.payload to serviceInformationVehicle.serviceRecordIn.payload;

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

    // R-X04 read-only service presentation; there is deliberately no return/control flow.
    flow rX04Vehicle from serviceInformationVehicle.serviceSnapshotOut.payload to vehicleMaintainerBoundary.snapshot.payload;

    // The JEOS-to-output fast chain is Detailed Design-only: U-TRACTION-ACQUISITION directly
    // hands its FastEpochV1 to U-TRACTION-CONTROL, then U-TRACTION-OUTPUT receives PWMAndADCSamplingPlanV1.
    // R-V33..R-V38 below are direct owner-record handoffs: Analog regular scans are consumed by
    // semantic interfaces; Analog fast epochs go only to MotorPhase and Supply. No raw ADC route
    // reaches FOC. No public SC fast ports are created by this architecture.
    flow rV33AcceleratorRaw from analogAcquisitionVehicle.regularAdcScanOut.payload to acceleratorInterfaceVehicle.regularAdcScanIn.payload;
    flow rV34BrakeRaw from analogAcquisitionVehicle.regularAdcScanOut.payload to brakeInterfaceVehicle.regularAdcScanIn.payload;
    flow rV35TemperatureRaw from analogAcquisitionVehicle.regularAdcScanOut.payload to temperatureInterfaceVehicle.regularAdcScanIn.payload;
    flow rV36SupplyRegularRaw from analogAcquisitionVehicle.regularAdcScanOut.payload to supplyInterfaceVehicle.regularAdcScanIn.payload;
    flow rV37PhaseRegularRaw from analogAcquisitionVehicle.regularAdcScanOut.payload to motorPhaseInterfaceVehicle.regularAdcScanIn.payload;
    flow rV38PhaseFastRaw from analogAcquisitionVehicle.fastInjectedEpochOut.payload to motorPhaseInterfaceVehicle.fastInjectedEpochIn.payload;
    flow rV39SupplyFastRaw from analogAcquisitionVehicle.fastInjectedEpochOut.payload to supplyInterfaceVehicle.fastInjectedEpochIn.payload;
    flow rV40CalibrationAnalog from platformVehicle.calibrationBundleOut.payload to analogAcquisitionVehicle.calibrationIn.payload;
    flow rV40CalibrationAccelerator from platformVehicle.calibrationBundleOut.payload to acceleratorInterfaceVehicle.calibrationIn.payload;
    flow rV40CalibrationBrake from platformVehicle.calibrationBundleOut.payload to brakeInterfaceVehicle.calibrationIn.payload;
    flow rV40CalibrationTemperature from platformVehicle.calibrationBundleOut.payload to temperatureInterfaceVehicle.calibrationIn.payload;
    flow rV40CalibrationSupply from platformVehicle.calibrationBundleOut.payload to supplyInterfaceVehicle.calibrationIn.payload;
    flow rV40CalibrationPhase from platformVehicle.calibrationBundleOut.payload to motorPhaseInterfaceVehicle.calibrationIn.payload;
    flow rV40CalibrationHall from platformVehicle.calibrationBundleOut.payload to hallInterfaceVehicle.calibrationIn.payload;
}
