package X2CitySystemArchitecture {

    attribute def Validity;
    attribute def Freshness;
    attribute def SourceContext;
    attribute def Expiry;

    item def ContextualInformation {
        attribute validity:Validity;
        attribute freshness:Freshness;
        attribute sourceContext:SourceContext;
    }

    item def QualifiedRiderMotionInformation:>ContextualInformation;
    item def SettingsInformation:>ContextualInformation;
    item def ActiveSettingsInformation:>SettingsInformation;
    item def BatteryObservationInformation:>ContextualInformation;
    item def BatteryEnvelopeInformation:>ContextualInformation;
    item def RidingAuthorityInformation:>ContextualInformation {
        attribute expiry:Expiry;
    }
    item def SignedWheelTorqueCommand:>ContextualInformation {
        attribute expiry:Expiry;
    }
    item def ActualOutputInformation:>ContextualInformation;
    item def QualifiedMotionInformation:>ContextualInformation;
    item def RiderInformation:>ContextualInformation;
    item def LightInputInformation:>ContextualInformation;
    item def LightIntentInformation:>ContextualInformation;
    item def ServiceConfigurationInformation:>ContextualInformation;
    item def DemandPolicyDiagnosticInformation:>ServiceConfigurationInformation;
    item def BmsTelemetryInformation:>ContextualInformation;
    item def BmsReadRequestInformation:>ContextualInformation;

    port def QualifiedRiderMotionOut {
        doc /* Carries input-qualified accelerator/rest and coded-brake facts to SettingsPolicy, SessionPolicy, DemandPolicy and LightPolicy. These are rider control observations; Traction separately publishes vehicle speed, direction and standstill qualification. */
        out item payload:QualifiedRiderMotionInformation;
    }
    port def QualifiedRiderMotionIn {
        doc /* Carries input-qualified accelerator/rest and coded-brake facts to SettingsPolicy, SessionPolicy, DemandPolicy and LightPolicy. These are rider control observations; Traction separately publishes vehicle speed, direction and standstill qualification. */
        in item payload:QualifiedRiderMotionInformation;
    }
    port def SettingsOut {
        doc /* Carries owner-qualified rider settings requests from HMI or Input to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        out item payload:SettingsInformation;
    }
    port def SettingsIn {
        doc /* Carries owner-qualified rider settings requests from HMI or Input to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        in item payload:SettingsInformation;
    }
    port def ActiveSettingsOut {
        doc /* Carries SettingsPolicy's resolved active riding level and speed projection to DemandPolicy. Only applied active state crosses this contract; requested or pending values cannot drive demand. */
        out item payload:ActiveSettingsInformation;
    }
    port def ActiveSettingsIn {
        doc /* Carries SettingsPolicy's resolved active riding level and speed projection to DemandPolicy. Only applied active state crosses this contract; requested or pending values cannot drive demand. */
        in item payload:ActiveSettingsInformation;
    }
    port def BatteryObservationOut {
        doc /* Carries battery and traction condition observations assembled by Input from the BMS/energy and traction paths to BatteryProtection. These records remain qualified observations; they do not contain the resulting charge or discharge envelope. */
        out item payload:BatteryObservationInformation;
    }
    port def BatteryObservationIn {
        doc /* Carries battery and traction condition observations assembled by Input from the BMS/energy and traction paths to BatteryProtection. These records remain qualified observations; they do not contain the resulting charge or discharge envelope. */
        in item payload:BatteryObservationInformation;
    }
    port def BatteryEnvelopeOut {
        doc /* Carries BatteryProtection's separate positive-discharge and negative-charge capability envelope and protection status to SessionPolicy and DemandPolicy. Each policy applies the relevant qualified sign branch as a constraint on its decision. */
        out item payload:BatteryEnvelopeInformation;
    }
    port def BatteryEnvelopeIn {
        doc /* Carries BatteryProtection's separate positive-discharge and negative-charge capability envelope and protection status to SessionPolicy and DemandPolicy. Each policy applies the relevant qualified sign branch as a constraint on its decision. */
        in item payload:BatteryEnvelopeInformation;
    }
    port def RidingAuthorityOut {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        out item payload:RidingAuthorityInformation;
    }
    port def RidingAuthorityIn {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        in item payload:RidingAuthorityInformation;
    }
    port def TorqueCommandOut {
        doc /* Carries DemandPolicy's signed wheel-torque request and expiry to Traction. It is a demand boundary only; SessionPolicy authority remains an independent authorization input. */
        out item payload:SignedWheelTorqueCommand;
    }
    port def TorqueCommandIn {
        doc /* Carries DemandPolicy's signed wheel-torque request and expiry to Traction. It is a demand boundary only; SessionPolicy authority remains an independent authorization input. */
        in item payload:SignedWheelTorqueCommand;
    }
    port def ActualOutputOut {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy, DemandPolicy and LightPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command. */
        out item payload:ActualOutputInformation;
    }
    port def ActualOutputIn {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy, DemandPolicy and LightPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command. */
        in item payload:ActualOutputInformation;
    }
    port def QualifiedMotionOut {
        doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy and DemandPolicy. This physical-motion qualification is separate from Input's accelerator/rest and coded-brake facts. */
        out item payload:QualifiedMotionInformation;
    }
    port def QualifiedMotionIn {
        doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy and DemandPolicy. This physical-motion qualification is separate from Input's accelerator/rest and coded-brake facts. */
        in item payload:QualifiedMotionInformation;
    }
    port def RiderInformationOut {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        out item payload:RiderInformation;
    }
    port def RiderInformationIn {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        in item payload:RiderInformation;
    }
    port def LightInputOut {
        doc /* Carries the HMI normal-light request or Input-qualified rider and brake lighting facts to LightPolicy. LightPolicy combines these context inputs with traction observations before producing logical light intent. */
        out item payload:LightInputInformation;
    }
    port def LightInputIn {
        doc /* Carries the HMI normal-light request or Input-qualified rider and brake lighting facts to LightPolicy. LightPolicy combines these context inputs with traction observations before producing logical light intent. */
        in item payload:LightInputInformation;
    }
    port def LightIntentOut {
        doc /* Carries LightPolicy's selected front and rear logical lamp modes to the Auxiliary actuation boundary. Auxiliary applies the intent to lamp hardware; this contract does not define the physical drive implementation. */
        out item payload:LightIntentInformation;
    }
    port def LightIntentIn {
        doc /* Carries LightPolicy's selected front and rear logical lamp modes to the Auxiliary actuation boundary. Auxiliary applies the intent to lamp hardware; this contract does not define the physical drive implementation. */
        in item payload:LightIntentInformation;
    }
    port def ServiceConfigurationOut {
        doc /* Carries producer status, configuration and diagnostic observations from logical components to ServiceInformation and then service access. The records support read-only service presentation and do not configure or command their producers. */
        out item payload:ServiceConfigurationInformation;
    }
    port def ServiceConfigurationIn {
        doc /* Carries producer status, configuration and diagnostic observations from logical components to ServiceInformation and then service access. The records support read-only service presentation and do not configure or command their producers. */
        in item payload:ServiceConfigurationInformation;
    }
    port def DemandPolicyDiagnosticOut {
        doc /* Carries DemandPolicy's read-only policy status and diagnostic observations to ServiceInformation. It supports service reporting only and cannot authorize, refresh or command traction. */
        out item payload:DemandPolicyDiagnosticInformation;
    }
    port def BmsTelemetryOut {
        doc /* Carries battery data and protection-state observations from the supplied BMS assembly to BmsLink. BmsLink validates and qualifies this telemetry before using it as battery evidence; the path carries no software control decision. */
        out item payload:BmsTelemetryInformation;
    }
    port def BmsTelemetryIn {
        doc /* Carries battery data and protection-state observations from the supplied BMS assembly to BmsLink. BmsLink validates and qualifies this telemetry before using it as battery evidence; the path carries no software control decision. */
        in item payload:BmsTelemetryInformation;
    }
    port def BmsReadRequestOut {
        doc /* Carries a read-only battery-information request from BmsLink to the supplied BMS assembly. The request selects observation retrieval and does not write or command the BMS protection function. */
        out item payload:BmsReadRequestInformation;
    }
    port def BmsReadRequestIn {
        doc /* Carries a read-only battery-information request from BmsLink to the supplied BMS assembly. The request selects observation retrieval and does not write or command the BMS protection function. */
        in item payload:BmsReadRequestInformation;
    }

    interface def IfA001QualifiedRiderMotion {
        end producer:QualifiedRiderMotionOut;
        end consumer:QualifiedRiderMotionIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA002Settings {
        end producer:SettingsOut;
        end consumer:SettingsIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA002ActiveSettings {
        end producer:ActiveSettingsOut;
        end consumer:ActiveSettingsIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA003BatteryObservation {
        end producer:BatteryObservationOut;
        end consumer:BatteryObservationIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA003BatteryEnvelope {
        end producer:BatteryEnvelopeOut;
        end consumer:BatteryEnvelopeIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA004RidingAuthority {
        end producer:RidingAuthorityOut;
        end consumer:RidingAuthorityIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA004TorqueCommand {
        end producer:TorqueCommandOut;
        end consumer:TorqueCommandIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA005ActualOutput {
        end producer:ActualOutputOut;
        end consumer:ActualOutputIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA005QualifiedMotion {
        end producer:QualifiedMotionOut;
        end consumer:QualifiedMotionIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA006RiderInformation {
        end producer:RiderInformationOut;
        end consumer:RiderInformationIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA006LightInput {
        end producer:LightInputOut;
        end consumer:LightInputIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA006LightIntent {
        end producer:LightIntentOut;
        end consumer:LightIntentIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA008ServiceConfiguration {
        end producer:ServiceConfigurationOut;
        end consumer:ServiceConfigurationIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA008DemandPolicyDiagnostic {
        end producer:DemandPolicyDiagnosticOut;
        end consumer:ServiceConfigurationIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA009BmsReadRequest {
        end producer:BmsReadRequestOut;
        end consumer:BmsReadRequestIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA009BmsTelemetry {
        end producer:BmsTelemetryOut;
        end consumer:BmsTelemetryIn;
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
        port riderMotionIn:QualifiedRiderMotionIn;
        port qualifiedMotionIn:QualifiedMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port activeSettingsOut:ActiveSettingsOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def SessionPolicy { // LE-SESSION
        port riderMotionIn:QualifiedRiderMotionIn;
        port qualifiedMotionIn:QualifiedMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port batteryEnvelopeIn:BatteryEnvelopeIn;
        port tractionOutputIn:ActualOutputIn;
        port authorityOut:RidingAuthorityOut;
        port riderInformationOut:RiderInformationOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def DemandPolicy { // LE-DEMAND
        port qualifiedRiderMotionIn:QualifiedRiderMotionIn;
        port qualifiedMotionIn:QualifiedMotionIn;
        port activeSettingsIn:ActiveSettingsIn;
        port ridingAuthorityIn:RidingAuthorityIn;
        port batteryEnvelopeIn:BatteryEnvelopeIn;
        port actualOutputIn:ActualOutputIn;
        port torqueCommandOut:TorqueCommandOut;
        port demandPolicyDiagnosticOut:DemandPolicyDiagnosticOut;
    }

    part def HmiAdapter { // LE-HMI
        port settingsOut:SettingsOut;
        port lightInputOut:LightInputOut;
        port riderInformationIn:RiderInformationIn;
        port riderInformationOut:RiderInformationOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def Input { // LE-INPUT
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part bmsLink:BmsLink;
        port riderMotionOut:QualifiedRiderMotionOut;
        port settingsOut:SettingsOut;
        port energyObservationIn:BatteryObservationIn;
        port tractionObservationIn:BatteryObservationIn;
        port batteryObservationOut:BatteryObservationOut;
        port lightInputOut:LightInputOut;
    }

    part def RiderDevices { // LE-RIDER-DEVICES
        port riderInformationIn:RiderInformationIn;
    }

    part def InputHardware; // LE-INPUT-HW
    part def InputQualification { // LE-INPUT-QUAL
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def BmsLink { // LE-BMS-LINK
        port telemetryIn:BmsTelemetryIn;
        port readRequestOut:BmsReadRequestOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def Traction { // LE-TRACTION
        part motorControl:MotorControl;
        part tractionHardware:TractionHardware;
        port authorityIn:RidingAuthorityIn;
        port torqueCommandIn:TorqueCommandIn;
        port batteryObservationOut:BatteryObservationOut;
        port qualifiedMotionOut:QualifiedMotionOut;
        port actualOutputOut:ActualOutputOut;
    }

    part def MotorControl { // LE-MOTOR-CTRL
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
    part def TractionHardware; // LE-TRACTION-HW

    part def Energy { // LE-ENERGY
        part cells:Cells;
        part bms:Bms;
        part batteryPolicy:BatteryPolicy;
        part energyPath:EnergyPath;
        port batteryObservationOut:BatteryObservationOut;
    }

    part def Cells; // LE-CELLS

    part def Bms { // LE-BMS, supplied assembly
        port telemetryOut:BmsTelemetryOut;
        port readRequestIn:BmsReadRequestIn;
    }

    part def BatteryPolicy { // LE-BAT-POLICY
        port batteryObservationIn:BatteryObservationIn;
        port batteryEnvelopeOut:BatteryEnvelopeOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def EnergyPath; // LE-ENERGY-PATH

    part def Auxiliary { // LE-AUX
        part lightPolicy:LightPolicy;
        part auxiliaryPower:AuxiliaryPower;
        part lampHardware:LampHardware;
        port lightIntentIn:LightIntentIn;
    }

    part def LightPolicy { // LE-LIGHT-POLICY
        port riderMotionIn:QualifiedRiderMotionIn;
        port tractionOutputIn:ActualOutputIn;
        port hmiLightInputIn:LightInputIn;
        port inputLightInputIn:LightInputIn;
        port lightIntentOut:LightIntentOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def AuxiliaryPower; // LE-AUX-POWER
    part def LampHardware; // LE-LAMP-HW




    part def Compute { // LE-COMPUTE
        part computeHardware:ComputeHardware;
        part platform:Platform;
    }

    part def ComputeHardware; // LE-COMPUTE-HW
    part def Platform { // LE-PLATFORM
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def Service { // LE-SERVICE
        part serviceInformation:ServiceInformation;
        part serviceAccess:ServiceAccess;
    }

    part def ServiceInformation { // LE-SERVICE-INFO
        port serviceConfigurationIn:ServiceConfigurationIn;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def ServiceAccess { // LE-SERVICE-ACCESS
        port serviceConfigurationIn:ServiceConfigurationIn;
    }

    part def MechanicalControl; // LE-MECH; physical mechanical control boundary

    part def Integration { // LE-INTEGRATION
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

    part def ProjectEquipmentModel {
        part epcs:ElectricalPropulsionControlSystem;
        part mechanical:MechanicalControl;
        part integration:Integration;
        part installedVehicle:InstalledVehicleScope;
    }

    // applicable instances have independent state; no flow denotes a live bridge.
    part x2City:ProjectEquipmentModel;

    // IF-A-001: LE-INPUT owns qualified rider facts; LE-TRACTION owns qualified motion.
    flow ifA001ToSettings from x2City.epcs.input.riderMotionOut.payload to x2City.epcs.riding.settings.riderMotionIn.payload;
    flow ifA001ToSession from x2City.epcs.input.riderMotionOut.payload to x2City.epcs.riding.session.riderMotionIn.payload;
    flow ifA001ToDemand from x2City.epcs.input.riderMotionOut.payload to x2City.epcs.riding.demand.qualifiedRiderMotionIn.payload;
    flow ifA001ToLightPolicy from x2City.epcs.input.riderMotionOut.payload to x2City.epcs.auxiliary.lightPolicy.riderMotionIn.payload;
    flow ifA001MotionToSettings from x2City.epcs.traction.qualifiedMotionOut.payload to x2City.epcs.riding.settings.qualifiedMotionIn.payload;
    flow ifA001MotionToSession from x2City.epcs.traction.qualifiedMotionOut.payload to x2City.epcs.riding.session.qualifiedMotionIn.payload;

    // IF-A-002: raw requests feed LE-SET and startup receipt reaches LE-SESSION; demand receives only active settings.
    flow ifA002HmiToSettings from x2City.epcs.riding.hmi.settingsOut.payload to x2City.epcs.riding.settings.hmiSettingsIn.payload;
    flow ifA002HmiToSession from x2City.epcs.riding.hmi.settingsOut.payload to x2City.epcs.riding.session.hmiSettingsIn.payload;
    flow ifA002InputToSettings from x2City.epcs.input.settingsOut.payload to x2City.epcs.riding.settings.inputSettingsIn.payload;
    flow ifA002InputToSession from x2City.epcs.input.settingsOut.payload to x2City.epcs.riding.session.inputSettingsIn.payload;
    flow ifA002ActiveSettingsToDemand from x2City.epcs.riding.settings.activeSettingsOut.payload to x2City.epcs.riding.demand.activeSettingsIn.payload;

    // IF-A-003: energy and traction observations, then the battery envelope/status.
    flow ifA003EnergyToInput from x2City.epcs.energy.batteryObservationOut.payload to x2City.epcs.input.energyObservationIn.payload;
    flow ifA003TractionToInput from x2City.epcs.traction.batteryObservationOut.payload to x2City.epcs.input.tractionObservationIn.payload;
    flow ifA003InputToBatteryPolicy from x2City.epcs.input.batteryObservationOut.payload to x2City.epcs.energy.batteryPolicy.batteryObservationIn.payload;
    flow ifA003ToSession from x2City.epcs.energy.batteryPolicy.batteryEnvelopeOut.payload to x2City.epcs.riding.session.batteryEnvelopeIn.payload;
    flow ifA003ToDemand from x2City.epcs.energy.batteryPolicy.batteryEnvelopeOut.payload to x2City.epcs.riding.demand.batteryEnvelopeIn.payload;

    // IF-A-004: authority informs demand and traction; demand alone provides the signed command.
    flow ifA004AuthorityToDemand from x2City.epcs.riding.session.authorityOut.payload to x2City.epcs.riding.demand.ridingAuthorityIn.payload;
    flow ifA004Authority from x2City.epcs.riding.session.authorityOut.payload to x2City.epcs.traction.authorityIn.payload;
    flow ifA004TorqueCommand from x2City.epcs.riding.demand.torqueCommandOut.payload to x2City.epcs.traction.torqueCommandIn.payload;

    // IF-A-005: LE-TRACTION owns qualified motion and actual-output feedback.
    flow ifA005TractionToSession from x2City.epcs.traction.actualOutputOut.payload to x2City.epcs.riding.session.tractionOutputIn.payload;
    flow ifA005MotionToDemand from x2City.epcs.traction.qualifiedMotionOut.payload to x2City.epcs.riding.demand.qualifiedMotionIn.payload;
    flow ifA005TractionToDemand from x2City.epcs.traction.actualOutputOut.payload to x2City.epcs.riding.demand.actualOutputIn.payload;
    flow ifA005TractionToLightPolicy from x2City.epcs.traction.actualOutputOut.payload to x2City.epcs.auxiliary.lightPolicy.tractionOutputIn.payload;

    // IF-A-006: rider presentation and logical lighting information.
    flow ifA006SessionToHmi from x2City.epcs.riding.session.riderInformationOut.payload to x2City.epcs.riding.hmi.riderInformationIn.payload;
    flow ifA006HmiToRiderDevices from x2City.epcs.riding.hmi.riderInformationOut.payload to x2City.epcs.input.riderDevices.riderInformationIn.payload;
    flow ifA006HmiToLightPolicy from x2City.epcs.riding.hmi.lightInputOut.payload to x2City.epcs.auxiliary.lightPolicy.hmiLightInputIn.payload;
    flow ifA006InputToLightPolicy from x2City.epcs.input.lightInputOut.payload to x2City.epcs.auxiliary.lightPolicy.inputLightInputIn.payload;
    flow ifA006LightPolicyToAuxiliary from x2City.epcs.auxiliary.lightPolicy.lightIntentOut.payload to x2City.epcs.auxiliary.lightIntentIn.payload;


    // IF-A-008: applicable producer information to LE-SERVICE-INFO.
    flow ifA008SettingsToService from x2City.epcs.riding.settings.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008SessionToService from x2City.epcs.riding.session.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008DemandDiagnosticToService from x2City.epcs.riding.demand.demandPolicyDiagnosticOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008HmiToService from x2City.epcs.riding.hmi.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008InputQualificationToService from x2City.epcs.input.inputQualification.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008BmsLinkToService from x2City.epcs.input.bmsLink.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008MotorControlToService from x2City.epcs.traction.motorControl.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008BatteryPolicyToService from x2City.epcs.energy.batteryPolicy.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008LightPolicyToService from x2City.epcs.auxiliary.lightPolicy.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008PlatformToService from x2City.epcs.compute.platform.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    // IF-A-008: current service/configuration information to the service access boundary.
    flow ifA008ServiceInformation from x2City.epcs.service.serviceInformation.serviceConfigurationOut.payload to x2City.epcs.service.serviceAccess.serviceConfigurationIn.payload;

    // IF-A-009: the selected BMS read information endpoint.
    flow ifA009BmsReadRequest from x2City.epcs.input.bmsLink.readRequestOut.payload to x2City.epcs.energy.bms.readRequestIn.payload;
    flow ifA009BmsTelemetry from x2City.epcs.energy.bms.telemetryOut.payload to x2City.epcs.input.bmsLink.telemetryIn.payload;
}
