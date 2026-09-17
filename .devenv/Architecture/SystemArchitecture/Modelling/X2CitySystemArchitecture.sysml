package X2CitySystemArchitecture {

    attribute def ValidityStatus;
    attribute def FreshnessStatus;
    attribute def SourceContext;
    attribute def Expiry;

    item def QualifiedInformationRecord {
        attribute validity:ValidityStatus;
        attribute freshness:FreshnessStatus;
        attribute sourceContext:SourceContext;
    }

    item def QualifiedRiderInput:>QualifiedInformationRecord;
    item def RiderSettingsRequest:>QualifiedInformationRecord;
    item def ActiveRidingSettings:>RiderSettingsRequest;
    item def BatteryConditionObservation:>QualifiedInformationRecord;
    item def BatteryCapabilityEnvelope:>QualifiedInformationRecord;
    item def RidingAuthority:>QualifiedInformationRecord {
        attribute expiry:Expiry;
    }
    item def SignedWheelTorqueRequest:>QualifiedInformationRecord {
        attribute expiry:Expiry;
    }
    item def ActualTractionOutput:>QualifiedInformationRecord;
    item def QualifiedVehicleMotion:>QualifiedInformationRecord;
    item def RiderStatusInformation:>QualifiedInformationRecord;
    item def LightingContext:>QualifiedInformationRecord;
    item def LightActuationIntent:>QualifiedInformationRecord;
    item def ServiceReportInformation:>QualifiedInformationRecord;
    item def DemandPolicyDiagnostics:>ServiceReportInformation;
    item def BmsTelemetry:>QualifiedInformationRecord;
    item def BmsReadRequest:>QualifiedInformationRecord;

    port def RiderControlOutputPort {
        doc /* Carries input-qualified accelerator/rest and coded-brake facts to SettingsPolicy, SessionPolicy, DemandPolicy and LightPolicy. These are rider control observations; Traction separately publishes vehicle speed, direction and standstill qualification. */
        out item payload:QualifiedRiderInput;
    }
    port def RiderControlInputPort {
        doc /* Carries input-qualified accelerator/rest and coded-brake facts to SettingsPolicy, SessionPolicy, DemandPolicy and LightPolicy. These are rider control observations; Traction separately publishes vehicle speed, direction and standstill qualification. */
        in item payload:QualifiedRiderInput;
    }
    port def RiderSettingsRequestOutputPort {
        doc /* Carries owner-qualified rider settings requests from HMI or Input to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        out item payload:RiderSettingsRequest;
    }
    port def RiderSettingsRequestInputPort {
        doc /* Carries owner-qualified rider settings requests from HMI or Input to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        in item payload:RiderSettingsRequest;
    }
    port def ActiveRidingSettingsOutputPort {
        doc /* Carries SettingsPolicy's resolved active riding level and speed projection to DemandPolicy. Only applied active state crosses this contract; requested or pending values cannot drive demand. */
        out item payload:ActiveRidingSettings;
    }
    port def ActiveRidingSettingsInputPort {
        doc /* Carries SettingsPolicy's resolved active riding level and speed projection to DemandPolicy. Only applied active state crosses this contract; requested or pending values cannot drive demand. */
        in item payload:ActiveRidingSettings;
    }
    port def BatteryConditionObservationOutputPort {
        doc /* Carries battery and traction condition observations assembled by Input from the BMS/energy and traction paths to BatteryProtection. These records remain qualified observations; they do not contain the resulting charge or discharge envelope. */
        out item payload:BatteryConditionObservation;
    }
    port def BatteryConditionObservationInputPort {
        doc /* Carries battery and traction condition observations assembled by Input from the BMS/energy and traction paths to BatteryProtection. These records remain qualified observations; they do not contain the resulting charge or discharge envelope. */
        in item payload:BatteryConditionObservation;
    }
    port def BatteryCapabilityEnvelopeOutputPort {
        doc /* Carries BatteryProtection's separate positive-discharge and negative-charge capability envelope and protection status to SessionPolicy and DemandPolicy. Each policy applies the relevant qualified sign branch as a constraint on its decision. */
        out item payload:BatteryCapabilityEnvelope;
    }
    port def BatteryCapabilityEnvelopeInputPort {
        doc /* Carries BatteryProtection's separate positive-discharge and negative-charge capability envelope and protection status to SessionPolicy and DemandPolicy. Each policy applies the relevant qualified sign branch as a constraint on its decision. */
        in item payload:BatteryCapabilityEnvelope;
    }
    port def RidingAuthorityOutputPort {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        out item payload:RidingAuthority;
    }
    port def RidingAuthorityInputPort {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        in item payload:RidingAuthority;
    }
    port def WheelTorqueCommandOutputPort {
        doc /* Carries DemandPolicy's signed wheel-torque request and expiry to Traction. It is a demand boundary only; SessionPolicy authority remains an independent authorization input. */
        out item payload:SignedWheelTorqueRequest;
    }
    port def WheelTorqueCommandInputPort {
        doc /* Carries DemandPolicy's signed wheel-torque request and expiry to Traction. It is a demand boundary only; SessionPolicy authority remains an independent authorization input. */
        in item payload:SignedWheelTorqueRequest;
    }
    port def ActualTractionOutputPort {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy, DemandPolicy and LightPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command. */
        out item payload:ActualTractionOutput;
    }
    port def ActualTractionInputPort {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy, DemandPolicy and LightPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command. */
        in item payload:ActualTractionOutput;
    }
    port def QualifiedVehicleMotionOutputPort {
        doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy and DemandPolicy. This physical-motion qualification is separate from Input's accelerator/rest and coded-brake facts. */
        out item payload:QualifiedVehicleMotion;
    }
    port def QualifiedVehicleMotionInputPort {
        doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy and DemandPolicy. This physical-motion qualification is separate from Input's accelerator/rest and coded-brake facts. */
        in item payload:QualifiedVehicleMotion;
    }
    port def RiderStatusInformationOutputPort {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        out item payload:RiderStatusInformation;
    }
    port def RiderStatusInformationInputPort {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        in item payload:RiderStatusInformation;
    }
    port def LightingContextOutputPort {
        doc /* Carries the HMI normal-light request or Input-qualified rider and brake lighting facts to LightPolicy. LightPolicy combines these context inputs with traction observations before producing logical light intent. */
        out item payload:LightingContext;
    }
    port def LightingContextInputPort {
        doc /* Carries the HMI normal-light request or Input-qualified rider and brake lighting facts to LightPolicy. LightPolicy combines these context inputs with traction observations before producing logical light intent. */
        in item payload:LightingContext;
    }
    port def LightActuationIntentOutputPort {
        doc /* Carries LightPolicy's selected front and rear logical lamp modes to the Auxiliary actuation boundary. Auxiliary applies the intent to lamp hardware; this contract does not define the physical drive implementation. */
        out item payload:LightActuationIntent;
    }
    port def LightActuationIntentInputPort {
        doc /* Carries LightPolicy's selected front and rear logical lamp modes to the Auxiliary actuation boundary. Auxiliary applies the intent to lamp hardware; this contract does not define the physical drive implementation. */
        in item payload:LightActuationIntent;
    }
    port def ServiceReportOutputPort {
        doc /* Carries producer status, configuration and diagnostic observations from logical components to ServiceInformation and then service access. The records support read-only service presentation and do not configure or command their producers. */
        out item payload:ServiceReportInformation;
    }
    port def ServiceReportInputPort {
        doc /* Carries producer status, configuration and diagnostic observations from logical components to ServiceInformation and then service access. The records support read-only service presentation and do not configure or command their producers. */
        in item payload:ServiceReportInformation;
    }
    port def DemandPolicyDiagnosticsOutputPort {
        doc /* Carries DemandPolicy's read-only policy status and diagnostic observations to ServiceInformation. It supports service reporting only and cannot authorize, refresh or command traction. */
        out item payload:DemandPolicyDiagnostics;
    }
    port def BmsTelemetryOutputPort {
        doc /* Carries battery data and protection-state observations from the supplied BMS assembly to BmsLink. BmsLink validates and qualifies this telemetry before using it as battery evidence; the path carries no software control decision. */
        out item payload:BmsTelemetry;
    }
    port def BmsTelemetryInputPort {
        doc /* Carries battery data and protection-state observations from the supplied BMS assembly to BmsLink. BmsLink validates and qualifies this telemetry before using it as battery evidence; the path carries no software control decision. */
        in item payload:BmsTelemetry;
    }
    port def BmsReadRequestOutputPort {
        doc /* Carries a read-only battery-information request from BmsLink to the supplied BMS assembly. The request selects observation retrieval and does not write or command the BMS protection function. */
        out item payload:BmsReadRequest;
    }
    port def BmsReadRequestInputPort {
        doc /* Carries a read-only battery-information request from BmsLink to the supplied BMS assembly. The request selects observation retrieval and does not write or command the BMS protection function. */
        in item payload:BmsReadRequest;
    }

    interface def IfA001QualifiedRiderInput {
        end producer:RiderControlOutputPort;
        end consumer:RiderControlInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA002RiderSettingsRequest {
        end producer:RiderSettingsRequestOutputPort;
        end consumer:RiderSettingsRequestInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA002ActiveRidingSettings {
        end producer:ActiveRidingSettingsOutputPort;
        end consumer:ActiveRidingSettingsInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA003BatteryConditionObservation {
        end producer:BatteryConditionObservationOutputPort;
        end consumer:BatteryConditionObservationInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA003BatteryCapabilityEnvelope {
        end producer:BatteryCapabilityEnvelopeOutputPort;
        end consumer:BatteryCapabilityEnvelopeInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA004RidingAuthority {
        end producer:RidingAuthorityOutputPort;
        end consumer:RidingAuthorityInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA004WheelTorqueCommand {
        end producer:WheelTorqueCommandOutputPort;
        end consumer:WheelTorqueCommandInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA005ActualTractionOutput {
        end producer:ActualTractionOutputPort;
        end consumer:ActualTractionInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA005QualifiedVehicleMotion {
        end producer:QualifiedVehicleMotionOutputPort;
        end consumer:QualifiedVehicleMotionInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA006RiderStatusInformation {
        end producer:RiderStatusInformationOutputPort;
        end consumer:RiderStatusInformationInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA006LightingContext {
        end producer:LightingContextOutputPort;
        end consumer:LightingContextInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA006LightActuationIntent {
        end producer:LightActuationIntentOutputPort;
        end consumer:LightActuationIntentInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA008ServiceReport {
        end producer:ServiceReportOutputPort;
        end consumer:ServiceReportInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA008DemandPolicyDiagnostics {
        end producer:DemandPolicyDiagnosticsOutputPort;
        end consumer:ServiceReportInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA009BmsReadRequest {
        end producer:BmsReadRequestOutputPort;
        end consumer:BmsReadRequestInputPort;
        flow producer.payload to consumer.payload;
    }
    interface def IfA009BmsTelemetry {
        end producer:BmsTelemetryOutputPort;
        end consumer:BmsTelemetryInputPort;
        flow producer.payload to consumer.payload;
    }
    // ARCH-001; LE identifiers remain authoritative.
    part def RidingSupervisor { // LE-RIDING
        part settings:SettingsPolicy;
        part session:SessionPolicy;
        part demand:DemandPolicy;
        part hmi:HmiAdapter;
    }

    part def SettingsPolicy { // LE-SET
        port qualifiedRiderInputIn:RiderControlInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port inputRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port activeRidingSettingsOut:ActiveRidingSettingsOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def SessionPolicy { // LE-SESSION
        port qualifiedRiderInputIn:RiderControlInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port inputRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port batteryCapabilityEnvelopeIn:BatteryCapabilityEnvelopeInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port ridingAuthorityOut:RidingAuthorityOutputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def DemandPolicy { // LE-DEMAND
        port qualifiedRiderInputIn:RiderControlInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port activeRidingSettingsIn:ActiveRidingSettingsInputPort;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port batteryCapabilityEnvelopeIn:BatteryCapabilityEnvelopeInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port wheelTorqueCommandOut:WheelTorqueCommandOutputPort;
        port demandPolicyDiagnosticsOut:DemandPolicyDiagnosticsOutputPort;
    }

    part def HmiAdapter { // LE-HMI
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port lightingContextOut:LightingContextOutputPort;
        port riderStatusInformationIn:RiderStatusInformationInputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def Input { // LE-INPUT
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part bmsLink:BmsLink;
        port qualifiedRiderInputOut:RiderControlOutputPort;
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port energyBatteryObservationIn:BatteryConditionObservationInputPort;
        port tractionBatteryObservationIn:BatteryConditionObservationInputPort;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
        port lightingContextOut:LightingContextOutputPort;
    }

    part def RiderDevices { // LE-RIDER-DEVICES
        port riderStatusInformationIn:RiderStatusInformationInputPort;
    }

    part def InputHardware; // LE-INPUT-HW
    part def InputQualification { // LE-INPUT-QUAL
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def BmsLink { // LE-BMS-LINK
        port bmsTelemetryIn:BmsTelemetryInputPort;
        port bmsReadRequestOut:BmsReadRequestOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def Traction { // LE-TRACTION
        part motorControl:MotorControl;
        part tractionHardware:TractionHardware;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort;
        port actualTractionOutputOut:ActualTractionOutputPort;
    }

    part def MotorControl { // LE-MOTOR-CTRL
        port serviceReportOut:ServiceReportOutputPort;
    }
    part def TractionHardware; // LE-TRACTION-HW

    part def Energy { // LE-ENERGY
        part cells:Cells;
        part bms:Bms;
        part batteryProtection:BatteryProtection;
        part energyPath:EnergyPath;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
    }

    part def Cells; // LE-CELLS

    part def Bms { // LE-BMS, supplied assembly
        port bmsTelemetryOut:BmsTelemetryOutputPort;
        port bmsReadRequestIn:BmsReadRequestInputPort;
    }

    part def BatteryProtection { // LE-BAT-POLICY
        port batteryConditionObservationIn:BatteryConditionObservationInputPort;
        port batteryCapabilityEnvelopeOut:BatteryCapabilityEnvelopeOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def EnergyPath; // LE-ENERGY-PATH

    part def Auxiliary { // LE-AUX
        part lightPolicy:LightPolicy;
        part auxiliaryPower:AuxiliaryPower;
        part lampHardware:LampHardware;
        port lightActuationIntentIn:LightActuationIntentInputPort;
    }

    part def LightPolicy { // LE-LIGHT-POLICY
        port qualifiedRiderInputIn:RiderControlInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port hmiLightingContextIn:LightingContextInputPort;
        port inputLightingContextIn:LightingContextInputPort;
        port lightActuationIntentOut:LightActuationIntentOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def AuxiliaryPower; // LE-AUX-POWER
    part def LampHardware; // LE-LAMP-HW




    part def Compute { // LE-COMPUTE
        part computeHardware:ComputeHardware;
        part platform:Platform;
    }

    part def ComputeHardware; // LE-COMPUTE-HW
    part def Platform { // LE-PLATFORM
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def Service { // LE-SERVICE
        part serviceInformation:ServiceInformation;
        part serviceAccess:ServiceAccess;
    }

    part def ServiceInformation { // LE-SERVICE-INFO
        port serviceReportIn:ServiceReportInputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }

    part def ServiceAccess { // LE-SERVICE-ACCESS
        port serviceReportIn:ServiceReportInputPort;
    }

    part def MechanicalControl; // LE-MECH; physical mechanical control boundary

    part def VehicleIntegration { // LE-INTEGRATION
        part carrierHardware:CarrierHardware;
        part enclosureHardware:EnclosureHardware;
        part harnessHardware:HarnessHardware;
    }

    part def CarrierHardware; // LE-CARRIER-HW
    part def EnclosureHardware; // LE-ENCLOSURE-HW
    part def HarnessHardware; // LE-HARNESS-HW

    part def ElectricalPropulsionControlSystem { // LE-EPCS
        part riding:RidingSupervisor;
        part input:Input;
        part traction:Traction;
        part energy:Energy;
        part auxiliary:Auxiliary;
        part compute:Compute;
        part service:Service;
    }

    // LE-VEH is an installed-vehicle scope view, not a parent of the whole EPCS.
    part def InstalledVehicleScope;

    part def ProjectVehicleModel {
        part epcs:ElectricalPropulsionControlSystem;
        part mechanicalControl:MechanicalControl;
        part vehicleIntegration:VehicleIntegration;
        part installedVehicle:InstalledVehicleScope;
    }

    // applicable instances have independent state; no flow denotes a live bridge.
    part x2CityVehicle:ProjectVehicleModel;

    // IF-A-001: LE-INPUT owns qualified accelerator/rest and coded-brake inputs; LE-TRACTION owns qualified vehicle motion.
    flow ifA001ToSettings from x2CityVehicle.epcs.input.qualifiedRiderInputOut.payload to x2CityVehicle.epcs.riding.settings.qualifiedRiderInputIn.payload;
    flow ifA001ToSession from x2CityVehicle.epcs.input.qualifiedRiderInputOut.payload to x2CityVehicle.epcs.riding.session.qualifiedRiderInputIn.payload;
    flow ifA001ToDemand from x2CityVehicle.epcs.input.qualifiedRiderInputOut.payload to x2CityVehicle.epcs.riding.demand.qualifiedRiderInputIn.payload;
    flow ifA001ToLightPolicy from x2CityVehicle.epcs.input.qualifiedRiderInputOut.payload to x2CityVehicle.epcs.auxiliary.lightPolicy.qualifiedRiderInputIn.payload;
    flow ifA001VehicleMotionToSettings from x2CityVehicle.epcs.traction.qualifiedVehicleMotionOut.payload to x2CityVehicle.epcs.riding.settings.qualifiedVehicleMotionIn.payload;
    flow ifA001VehicleMotionToSession from x2CityVehicle.epcs.traction.qualifiedVehicleMotionOut.payload to x2CityVehicle.epcs.riding.session.qualifiedVehicleMotionIn.payload;

    // IF-A-002: raw requests feed LE-SET and startup receipt reaches LE-SESSION; demand receives only active settings.
    flow ifA002HmiToSettings from x2CityVehicle.epcs.riding.hmi.riderSettingsRequestOut.payload to x2CityVehicle.epcs.riding.settings.hmiRiderSettingsRequestIn.payload;
    flow ifA002HmiToSession from x2CityVehicle.epcs.riding.hmi.riderSettingsRequestOut.payload to x2CityVehicle.epcs.riding.session.hmiRiderSettingsRequestIn.payload;
    flow ifA002InputToSettings from x2CityVehicle.epcs.input.riderSettingsRequestOut.payload to x2CityVehicle.epcs.riding.settings.inputRiderSettingsRequestIn.payload;
    flow ifA002InputToSession from x2CityVehicle.epcs.input.riderSettingsRequestOut.payload to x2CityVehicle.epcs.riding.session.inputRiderSettingsRequestIn.payload;
    flow ifA002ActiveRidingSettingsToDemand from x2CityVehicle.epcs.riding.settings.activeRidingSettingsOut.payload to x2CityVehicle.epcs.riding.demand.activeRidingSettingsIn.payload;

    // IF-A-003: energy and traction observations, then the battery envelope/status.
    flow ifA003EnergyToInput from x2CityVehicle.epcs.energy.batteryConditionObservationOut.payload to x2CityVehicle.epcs.input.energyBatteryObservationIn.payload;
    flow ifA003TractionToInput from x2CityVehicle.epcs.traction.batteryConditionObservationOut.payload to x2CityVehicle.epcs.input.tractionBatteryObservationIn.payload;
    flow ifA003InputToBatteryProtection from x2CityVehicle.epcs.input.batteryConditionObservationOut.payload to x2CityVehicle.epcs.energy.batteryProtection.batteryConditionObservationIn.payload;
    flow ifA003ToSession from x2CityVehicle.epcs.energy.batteryProtection.batteryCapabilityEnvelopeOut.payload to x2CityVehicle.epcs.riding.session.batteryCapabilityEnvelopeIn.payload;
    flow ifA003ToDemand from x2CityVehicle.epcs.energy.batteryProtection.batteryCapabilityEnvelopeOut.payload to x2CityVehicle.epcs.riding.demand.batteryCapabilityEnvelopeIn.payload;

    // IF-A-004: authority informs demand and traction; demand alone provides the signed command.
    flow ifA004AuthorityToDemand from x2CityVehicle.epcs.riding.session.ridingAuthorityOut.payload to x2CityVehicle.epcs.riding.demand.ridingAuthorityIn.payload;
    flow ifA004Authority from x2CityVehicle.epcs.riding.session.ridingAuthorityOut.payload to x2CityVehicle.epcs.traction.ridingAuthorityIn.payload;
    flow ifA004WheelTorqueCommand from x2CityVehicle.epcs.riding.demand.wheelTorqueCommandOut.payload to x2CityVehicle.epcs.traction.wheelTorqueCommandIn.payload;

    // IF-A-005: LE-TRACTION owns qualified vehicle motion and actual-output feedback.
    flow ifA005TractionToSession from x2CityVehicle.epcs.traction.actualTractionOutputOut.payload to x2CityVehicle.epcs.riding.session.actualTractionOutputIn.payload;
    flow ifA005VehicleMotionToDemand from x2CityVehicle.epcs.traction.qualifiedVehicleMotionOut.payload to x2CityVehicle.epcs.riding.demand.qualifiedVehicleMotionIn.payload;
    flow ifA005TractionToDemand from x2CityVehicle.epcs.traction.actualTractionOutputOut.payload to x2CityVehicle.epcs.riding.demand.actualTractionOutputIn.payload;
    flow ifA005TractionToLightPolicy from x2CityVehicle.epcs.traction.actualTractionOutputOut.payload to x2CityVehicle.epcs.auxiliary.lightPolicy.actualTractionOutputIn.payload;

    // IF-A-006: rider presentation and logical lighting information.
    flow ifA006SessionToHmi from x2CityVehicle.epcs.riding.session.riderStatusInformationOut.payload to x2CityVehicle.epcs.riding.hmi.riderStatusInformationIn.payload;
    flow ifA006HmiToRiderDevices from x2CityVehicle.epcs.riding.hmi.riderStatusInformationOut.payload to x2CityVehicle.epcs.input.riderDevices.riderStatusInformationIn.payload;
    flow ifA006HmiToLightPolicy from x2CityVehicle.epcs.riding.hmi.lightingContextOut.payload to x2CityVehicle.epcs.auxiliary.lightPolicy.hmiLightingContextIn.payload;
    flow ifA006InputToLightPolicy from x2CityVehicle.epcs.input.lightingContextOut.payload to x2CityVehicle.epcs.auxiliary.lightPolicy.inputLightingContextIn.payload;
    flow ifA006LightPolicyToAuxiliary from x2CityVehicle.epcs.auxiliary.lightPolicy.lightActuationIntentOut.payload to x2CityVehicle.epcs.auxiliary.lightActuationIntentIn.payload;


    // IF-A-008: applicable producer information to LE-SERVICE-INFO.
    flow ifA008SettingsToService from x2CityVehicle.epcs.riding.settings.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008SessionToService from x2CityVehicle.epcs.riding.session.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008DemandDiagnosticsToService from x2CityVehicle.epcs.riding.demand.demandPolicyDiagnosticsOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008HmiToService from x2CityVehicle.epcs.riding.hmi.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008InputQualificationToService from x2CityVehicle.epcs.input.inputQualification.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008BmsLinkToService from x2CityVehicle.epcs.input.bmsLink.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008MotorControlToService from x2CityVehicle.epcs.traction.motorControl.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008BatteryProtectionToService from x2CityVehicle.epcs.energy.batteryProtection.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008LightPolicyToService from x2CityVehicle.epcs.auxiliary.lightPolicy.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    flow ifA008PlatformToService from x2CityVehicle.epcs.compute.platform.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceInformation.serviceReportIn.payload;
    // IF-A-008: current service/configuration information to the service access boundary.
    flow ifA008ServiceReport from x2CityVehicle.epcs.service.serviceInformation.serviceReportOut.payload to x2CityVehicle.epcs.service.serviceAccess.serviceReportIn.payload;

    // IF-A-009: the selected BMS read information endpoint.
    flow ifA009BmsReadRequest from x2CityVehicle.epcs.input.bmsLink.bmsReadRequestOut.payload to x2CityVehicle.epcs.energy.bms.bmsReadRequestIn.payload;
    flow ifA009BmsTelemetry from x2CityVehicle.epcs.energy.bms.bmsTelemetryOut.payload to x2CityVehicle.epcs.input.bmsLink.bmsTelemetryIn.payload;
}
