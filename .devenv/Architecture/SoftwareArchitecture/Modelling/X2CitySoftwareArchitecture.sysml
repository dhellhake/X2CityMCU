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
        port lightIntent:~PLgtIntentO;
        port tractionInformationIo:~PTrOutputIo;
        port analogRawAcquisition:~PAArawI;
        port hallCapture:~PHallCaptureI;
    }
    part def MaintainerServiceBoundary {
        /* Exposes a read-only service snapshot to a maintainer or service consumer. This boundary
           carries presentation data only and has no control path back into the software architecture. */
        port snapshot:~PSvcSnapshotO;
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
    flow rV01 from acceleratorInterfaceVehicle.pAccelPositionO.payload to setVehicle.pSetRequestI.payload;
    flow rV02 from hmiVehicle.pHmiSettingsO.payload to setVehicle.pSetRequestI.payload;
    flow rV03Accelerator from acceleratorInterfaceVehicle.pAccelPositionO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV03Brake from brakeInterfaceVehicle.pBrakeStateO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV03Temperature from temperatureInterfaceVehicle.pTempQualifiedO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV03Supply from supplyInterfaceVehicle.pSupplyRegularO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV04 from hmiVehicle.pHmiSettingsO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV05 from setVehicle.pSetStateO.payload to sessionVehicle.pSesReadyI.payload;
    // Qualified physical motion is required for the explicit setting-application and Ready
    // standstill guards; neither guard reconstructs standstill from demand or Hall edge absence.
    flow rV05QualifiedMotionSet from tractionControlVehicle.pTrQualifiedMotionO.payload to setVehicle.pSetMotionI.payload;
    flow rV05QualifiedMotionSession from tractionControlVehicle.pTrQualifiedMotionO.payload to sessionVehicle.pSesMotionI.payload;

    // SW-I-003/004/005/006: vehicle policy, dedicated demand inputs, signed command and observations.
    flow rV06 from batteryProtectionVehicle.pBatEnvelopeO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV07 from tractionControlVehicle.pTrObsO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV08 from platformVehicle.pPltContextO.payload to sessionVehicle.startupContextRequired.payload;
    flow rV09Authority from sessionVehicle.pSesAuthO.payload to demandVehicle.pDemAuthorityI.payload;
    flow rV10Accelerator from acceleratorInterfaceVehicle.pAccelPositionO.payload to demandVehicle.pDemAcceleratorI.payload;
    flow rV10Brake from brakeInterfaceVehicle.pBrakeStateO.payload to demandVehicle.pDemBrakeI.payload;
    flow rV11ActiveSettings from setVehicle.pSetActiveDemandO.payload to demandVehicle.pDemActiveSettingsI.payload;
    flow rV12BatteryCapability from batteryProtectionVehicle.pBatEnvelopeO.payload to demandVehicle.pDemBatteryCapabilityI.payload;
    flow rV13QualifiedMotion from tractionControlVehicle.pTrQualifiedMotionO.payload to demandVehicle.pDemMotionI.payload;
    flow rV13ActualOutput from tractionControlVehicle.pTrActualOutputO.payload to demandVehicle.pDemActualOutputI.payload;
    flow rV14 from demandVehicle.pDemCommandO.payload to tractionControlVehicle.pTrCommandI.payload;
    flow rV15 from sessionVehicle.pSesAuthO.payload to tractionControlVehicle.pTrAuthI.payload;
    flow rV16 from bmsLinkVehicle.pBmsObsO.payload to batteryProtectionVehicle.pBatObservationsAndContextI.payload;
    flow rV17Temperature from temperatureInterfaceVehicle.pTempQualifiedO.payload to batteryProtectionVehicle.pBatObservationsAndContextI.payload;
    flow rV17Supply from supplyInterfaceVehicle.pSupplyRegularO.payload to batteryProtectionVehicle.pBatObservationsAndContextI.payload;
    flow rV17PhaseDiagnostic from motorPhaseInterfaceVehicle.pPhaseVoltageDiagnosticO.payload to batteryProtectionVehicle.pBatObservationsAndContextI.payload;
    flow rV18 from tractionControlVehicle.pTrObsO.payload to batteryProtectionVehicle.pBatObservationsAndContextI.payload;
    flow rV19 from platformVehicle.pPltRetentionO.payload to batteryProtectionVehicle.pBatObservationsAndContextI.payload;
    flow rV20 from brakeInterfaceVehicle.pBrakeStateO.payload to lightPolicyVehicle.pLgtInputI.payload;
    flow rV21 from hmiVehicle.pHmiLightO.payload to lightPolicyVehicle.pLgtInputI.payload;
    flow rV22 from tractionControlVehicle.pTrObsO.payload to lightPolicyVehicle.pLgtInputI.payload;
    flow rV23 from sessionVehicle.pSesReportO.payload to hmiVehicle.pHmiReportI.payload;
    flow rV24 from batteryProtectionVehicle.pBatEnvelopeO.payload to hmiVehicle.pHmiReportI.payload;

    // R-V25/R-V26 are opaque software boundary information exchanges.
    flow rV25 from lightPolicyVehicle.pLgtIntentO.payload to vehicleBoundary.lightIntent.payload;
    flow rV26Acquisition from vehicleBoundary.tractionInformationIo.payload to tractionControlVehicle.pTrOutputIo.payload;
    flow rV26ActuationObservation from tractionControlVehicle.pTrOutputIo.payload to vehicleBoundary.tractionInformationIo.payload;

    // R-V27 is complete qualified electrical position; it is not vehicle-speed qualification.
    flow rV27 from hallInterfaceVehicle.pHallPositionO.payload to tractionControlVehicle.pTrHallI.payload;
    flow rV28Phase from motorPhaseInterfaceVehicle.pPhaseCurrentO.payload to tractionControlVehicle.pTrPhaseCurrentI.payload;
    flow rV28Supply from supplyInterfaceVehicle.pSupplyFastVdcO.payload to tractionControlVehicle.pTrFastVdcI.payload;

    // R-V41..R-V44 carry one-way qualified sensor evidence. SensorHealthConditionV1 derives
    // ContextualSoftwareInformation, so the Session and Service record-collection inputs accept
    // it as a typed base-record handoff; Platform and Traction use the exact derived payload.
    // Platform may latch FastSafetyState from an explicit request. Its pPltHealthO is never a
    // route back into pPltSensorHealthI, so a platform result cannot become a sensor root cause.
    flow rV41AnalogHealthPlatform from analogAcquisitionVehicle.pAaHealthO.payload to platformVehicle.pPltSensorHealthI.payload;
    flow rV41AcceleratorHealthPlatform from acceleratorInterfaceVehicle.pAccelHealthO.payload to platformVehicle.pPltSensorHealthI.payload;
    flow rV41BrakeHealthPlatform from brakeInterfaceVehicle.pBrakeHealthO.payload to platformVehicle.pPltSensorHealthI.payload;
    flow rV41TemperatureHealthPlatform from temperatureInterfaceVehicle.pTempHealthO.payload to platformVehicle.pPltSensorHealthI.payload;
    flow rV41SupplyHealthPlatform from supplyInterfaceVehicle.pSupplyHealthO.payload to platformVehicle.pPltSensorHealthI.payload;
    flow rV41PhaseHealthPlatform from motorPhaseInterfaceVehicle.pPhaseHealthO.payload to platformVehicle.pPltSensorHealthI.payload;
    flow rV41HallHealthPlatform from hallInterfaceVehicle.pHallHealthO.payload to platformVehicle.pPltSensorHealthI.payload;
    flow rV42AnalogHealthSession from analogAcquisitionVehicle.pAaHealthO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV42AcceleratorHealthSession from acceleratorInterfaceVehicle.pAccelHealthO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV42BrakeHealthSession from brakeInterfaceVehicle.pBrakeHealthO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV42TemperatureHealthSession from temperatureInterfaceVehicle.pTempHealthO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV42SupplyHealthSession from supplyInterfaceVehicle.pSupplyHealthO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV42PhaseHealthSession from motorPhaseInterfaceVehicle.pPhaseHealthO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV42HallHealthSession from hallInterfaceVehicle.pHallHealthO.payload to sessionVehicle.pSesReadyI.payload;
    flow rV43TemperatureHealthTraction from temperatureInterfaceVehicle.pTempHealthO.payload to tractionControlVehicle.pTrSensorHealthI.payload;
    flow rV43SupplyHealthTraction from supplyInterfaceVehicle.pSupplyHealthO.payload to tractionControlVehicle.pTrSensorHealthI.payload;
    flow rV43PhaseHealthTraction from motorPhaseInterfaceVehicle.pPhaseHealthO.payload to tractionControlVehicle.pTrSensorHealthI.payload;
    flow rV43HallHealthTraction from hallInterfaceVehicle.pHallHealthO.payload to tractionControlVehicle.pTrSensorHealthI.payload;

    // SW-I-009 / R-V31: exact vehicle-local context and health service/event family.
    flow rV31ContextSet from platformVehicle.pPltContextO.payload to setVehicle.platformContextRequired.payload;
    flow rV31HealthSet from platformVehicle.pPltHealthO.payload to setVehicle.platformHealthRequired.payload;
    flow rV31ContextSession from platformVehicle.pPltContextO.payload to sessionVehicle.platformContextRequired.payload;
    flow rV31HealthSession from platformVehicle.pPltHealthO.payload to sessionVehicle.platformHealthRequired.payload;
    flow rV31ContextDemand from platformVehicle.pPltContextO.payload to demandVehicle.platformContextRequired.payload;
    flow rV31HealthDemand from platformVehicle.pPltHealthO.payload to demandVehicle.platformHealthRequired.payload;
    flow rV31CalibrationDemand from platformVehicle.pPltCalibrationO.payload to demandVehicle.calibrationRequired.payload;
    flow rV31ContextHmi from platformVehicle.pPltContextO.payload to hmiVehicle.platformContextRequired.payload;
    flow rV31HealthHmi from platformVehicle.pPltHealthO.payload to hmiVehicle.platformHealthRequired.payload;
    flow rV31ContextBms from platformVehicle.pPltContextO.payload to bmsLinkVehicle.platformContextRequired.payload;
    flow rV31HealthBms from platformVehicle.pPltHealthO.payload to bmsLinkVehicle.platformHealthRequired.payload;
    flow rV31ContextBattery from platformVehicle.pPltContextO.payload to batteryProtectionVehicle.platformContextRequired.payload;
    flow rV31HealthBattery from platformVehicle.pPltHealthO.payload to batteryProtectionVehicle.platformHealthRequired.payload;
    flow rV31ContextLight from platformVehicle.pPltContextO.payload to lightPolicyVehicle.platformContextRequired.payload;
    flow rV31HealthLight from platformVehicle.pPltHealthO.payload to lightPolicyVehicle.platformHealthRequired.payload;
    flow rV31ContextService from platformVehicle.pPltContextO.payload to serviceInformationVehicle.platformContextRequired.payload;
    flow rV31HealthService from platformVehicle.pPltHealthO.payload to serviceInformationVehicle.platformHealthRequired.payload;
    flow rV31ContextAnalog from platformVehicle.pPltContextO.payload to analogAcquisitionVehicle.platformContextRequired.payload;
    flow rV31HealthAnalog from platformVehicle.pPltHealthO.payload to analogAcquisitionVehicle.platformHealthRequired.payload;
    flow rV31ContextAccelerator from platformVehicle.pPltContextO.payload to acceleratorInterfaceVehicle.platformContextRequired.payload;
    flow rV31HealthAccelerator from platformVehicle.pPltHealthO.payload to acceleratorInterfaceVehicle.platformHealthRequired.payload;
    flow rV31ContextBrake from platformVehicle.pPltContextO.payload to brakeInterfaceVehicle.platformContextRequired.payload;
    flow rV31HealthBrake from platformVehicle.pPltHealthO.payload to brakeInterfaceVehicle.platformHealthRequired.payload;
    flow rV31ContextTemperature from platformVehicle.pPltContextO.payload to temperatureInterfaceVehicle.platformContextRequired.payload;
    flow rV31HealthTemperature from platformVehicle.pPltHealthO.payload to temperatureInterfaceVehicle.platformHealthRequired.payload;
    flow rV31ContextSupply from platformVehicle.pPltContextO.payload to supplyInterfaceVehicle.platformContextRequired.payload;
    flow rV31HealthSupply from platformVehicle.pPltHealthO.payload to supplyInterfaceVehicle.platformHealthRequired.payload;
    flow rV31ContextPhase from platformVehicle.pPltContextO.payload to motorPhaseInterfaceVehicle.platformContextRequired.payload;
    flow rV31HealthPhase from platformVehicle.pPltHealthO.payload to motorPhaseInterfaceVehicle.platformHealthRequired.payload;
    flow rV31ContextHall from platformVehicle.pPltContextO.payload to hallInterfaceVehicle.platformContextRequired.payload;
    flow rV31HealthHall from platformVehicle.pPltHealthO.payload to hallInterfaceVehicle.platformHealthRequired.payload;
    flow rV31ContextTraction from platformVehicle.pPltContextO.payload to tractionControlVehicle.platformContextRequired.payload;
    flow rV31HealthTraction from platformVehicle.pPltHealthO.payload to tractionControlVehicle.platformHealthRequired.payload;
    flow rV31CalibrationTraction from platformVehicle.pPltCalibrationO.payload to tractionControlVehicle.calibrationRequired.payload;
    flow rV31ContextPlatform from platformVehicle.pPltContextO.payload to platformVehicle.platformContextRequired.payload;
    flow rV31HealthPlatform from platformVehicle.pPltHealthO.payload to platformVehicle.platformHealthRequired.payload;

    // SW-I-008 / R-V32: all explicit vehicle producer ports retain their owner types.
    flow rV32AnalogRegular from analogAcquisitionVehicle.pAaRegularO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32AnalogFast from analogAcquisitionVehicle.pAaFastO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Accelerator from acceleratorInterfaceVehicle.pAccelPositionO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Brake from brakeInterfaceVehicle.pBrakeStateO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Temperature from temperatureInterfaceVehicle.pTempQualifiedO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32SupplyFast from supplyInterfaceVehicle.pSupplyFastVdcO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32SupplyRegular from supplyInterfaceVehicle.pSupplyRegularO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32PhaseCurrent from motorPhaseInterfaceVehicle.pPhaseCurrentO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32PhaseDiagnostic from motorPhaseInterfaceVehicle.pPhaseVoltageDiagnosticO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Hall from hallInterfaceVehicle.pHallPositionO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32HmiSettings from hmiVehicle.pHmiSettingsO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32HmiLight from hmiVehicle.pHmiLightO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Settings from setVehicle.pSetStateO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Authority from sessionVehicle.pSesAuthO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32SessionReport from sessionVehicle.pSesReportO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32DemandDiagnostic from demandVehicle.pDemDiagnosticO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Bms from bmsLinkVehicle.pBmsObsO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Battery from batteryProtectionVehicle.pBatEnvelopeO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Light from lightPolicyVehicle.pLgtIntentO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32QualifiedMotion from tractionControlVehicle.pTrQualifiedMotionO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32ActualOutput from tractionControlVehicle.pTrActualOutputO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32Traction from tractionControlVehicle.pTrObsO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32PlatformContext from platformVehicle.pPltContextO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32PlatformRetention from platformVehicle.pPltRetentionO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32PlatformHealth from platformVehicle.pPltHealthO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV32PlatformCalibration from platformVehicle.pPltCalibrationO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV44AnalogHealthService from analogAcquisitionVehicle.pAaHealthO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV44AcceleratorHealthService from acceleratorInterfaceVehicle.pAccelHealthO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV44BrakeHealthService from brakeInterfaceVehicle.pBrakeHealthO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV44TemperatureHealthService from temperatureInterfaceVehicle.pTempHealthO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV44SupplyHealthService from supplyInterfaceVehicle.pSupplyHealthO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV44PhaseHealthService from motorPhaseInterfaceVehicle.pPhaseHealthO.payload to serviceInformationVehicle.pSvcRecordI.payload;
    flow rV44HallHealthService from hallInterfaceVehicle.pHallHealthO.payload to serviceInformationVehicle.pSvcRecordI.payload;

    // R-X01: opaque supplied VD18MT transport, both byte/report directions.
    flow rX01Receive from suppliedVd18mtVehicle.hmiTransportIo.payload to hmiVehicle.pHmiTransportIo.payload;
    flow rX01Transmit from hmiVehicle.pHmiTransportIo.payload to suppliedVd18mtVehicle.hmiTransportIo.payload;

    // R-X02: opaque supplied BMS endpoint in the vehicle configuration.
    flow rX02VehicleReceive from suppliedBmsVehicle.bmsTransportIo.payload to bmsLinkVehicle.pBmsTransportIo.payload;
    flow rX02VehicleRequest from bmsLinkVehicle.pBmsTransportIo.payload to suppliedBmsVehicle.bmsTransportIo.payload;

    // R-X03 raw acquisition boundaries. SC-ANALOG-ACQ and SC-HALL-IF, not SC-PLATFORM, own
    // vehicle acquisition records.
    flow rX03VehicleAnalog from vehicleBoundary.analogRawAcquisition.payload to analogAcquisitionVehicle.pAaRawI.payload;
    flow rX03VehicleHall from vehicleBoundary.hallCapture.payload to hallInterfaceVehicle.pHallCaptureI.payload;

    // R-X04 read-only service presentation; there is deliberately no return/control flow.
    flow rX04Vehicle from serviceInformationVehicle.pSvcSnapshotO.payload to vehicleMaintainerBoundary.snapshot.payload;

    // The JEOS-to-output fast chain is Detailed Design-only: U-TRACTION-ACQUISITION directly
    // hands its FastEpochV1 to U-TRACTION-CONTROL, then U-TRACTION-OUTPUT receives FastCommandV1.
    // R-V33..R-V38 below are direct owner-record handoffs: Analog regular scans are consumed by
    // semantic interfaces; Analog fast epochs go only to MotorPhase and Supply. No raw ADC route
    // reaches FOC. No public SC fast ports are created by this architecture.
    flow rV33AcceleratorRaw from analogAcquisitionVehicle.pAaRegularO.payload to acceleratorInterfaceVehicle.pAccelRawI.payload;
    flow rV34BrakeRaw from analogAcquisitionVehicle.pAaRegularO.payload to brakeInterfaceVehicle.pBrakeRawI.payload;
    flow rV35TemperatureRaw from analogAcquisitionVehicle.pAaRegularO.payload to temperatureInterfaceVehicle.pTempRawI.payload;
    flow rV36SupplyRegularRaw from analogAcquisitionVehicle.pAaRegularO.payload to supplyInterfaceVehicle.pSupplyRegularRawI.payload;
    flow rV37PhaseRegularRaw from analogAcquisitionVehicle.pAaRegularO.payload to motorPhaseInterfaceVehicle.pPhaseRegularRawI.payload;
    flow rV38PhaseFastRaw from analogAcquisitionVehicle.pAaFastO.payload to motorPhaseInterfaceVehicle.pPhaseFastRawI.payload;
    flow rV39SupplyFastRaw from analogAcquisitionVehicle.pAaFastO.payload to supplyInterfaceVehicle.pSupplyFastRawI.payload;
    flow rV40CalibrationAnalog from platformVehicle.pPltCalibrationO.payload to analogAcquisitionVehicle.calibrationRequired.payload;
    flow rV40CalibrationAccelerator from platformVehicle.pPltCalibrationO.payload to acceleratorInterfaceVehicle.calibrationRequired.payload;
    flow rV40CalibrationBrake from platformVehicle.pPltCalibrationO.payload to brakeInterfaceVehicle.calibrationRequired.payload;
    flow rV40CalibrationTemperature from platformVehicle.pPltCalibrationO.payload to temperatureInterfaceVehicle.calibrationRequired.payload;
    flow rV40CalibrationSupply from platformVehicle.pPltCalibrationO.payload to supplyInterfaceVehicle.calibrationRequired.payload;
    flow rV40CalibrationPhase from platformVehicle.pPltCalibrationO.payload to motorPhaseInterfaceVehicle.calibrationRequired.payload;
    flow rV40CalibrationHall from platformVehicle.pPltCalibrationO.payload to hallInterfaceVehicle.calibrationRequired.payload;
}
