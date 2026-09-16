// SysML v2 textual model: static logical system architecture only.
// Canonical source: ARCH-001 logical composition and IF-A-001..009.
// IF-A-010..013 are physical energy, protection, mechanical, and handling boundaries,
// not information flows in this model.
package X2CitySystemArchitecture {

    // Information items summarize the canonical IF-A contracts. Fields, protocols,
    // numerical bounds, timing, behavior, and software-unit routes are intentionally absent.
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
    item def BatteryObservationInformation:>ContextualInformation;
    item def BatteryCapabilityStatus:>ContextualInformation;
    item def RidingAuthorityInformation:>ContextualInformation {
        attribute expiry:Expiry;
    }
    item def SignedWheelTorqueCommand:>ContextualInformation {
        attribute expiry:Expiry;
    }
    item def ActualOutputInformation:>ContextualInformation;
    item def RiderInformation:>ContextualInformation;
    item def LightInputInformation:>ContextualInformation;
    item def LightIntentInformation:>ContextualInformation;
    item def ServiceConfigurationInformation:>ContextualInformation;
    item def BmsTelemetryInformation:>ContextualInformation;
    item def BmsReadRequestInformation:>ContextualInformation;

    port def QualifiedRiderMotionOut { out item payload:QualifiedRiderMotionInformation; }
    port def QualifiedRiderMotionIn { in item payload:QualifiedRiderMotionInformation; }
    port def SettingsOut { out item payload:SettingsInformation; }
    port def SettingsIn { in item payload:SettingsInformation; }
    port def BatteryObservationOut { out item payload:BatteryObservationInformation; }
    port def BatteryObservationIn { in item payload:BatteryObservationInformation; }
    port def BatteryCapabilityOut { out item payload:BatteryCapabilityStatus; }
    port def BatteryCapabilityIn { in item payload:BatteryCapabilityStatus; }
    port def RidingAuthorityOut { out item payload:RidingAuthorityInformation; }
    port def RidingAuthorityIn { in item payload:RidingAuthorityInformation; }
    port def TorqueCommandOut { out item payload:SignedWheelTorqueCommand; }
    port def TorqueCommandIn { in item payload:SignedWheelTorqueCommand; }
    port def ActualOutputOut { out item payload:ActualOutputInformation; }
    port def ActualOutputIn { in item payload:ActualOutputInformation; }
    port def RiderInformationOut { out item payload:RiderInformation; }
    port def RiderInformationIn { in item payload:RiderInformation; }
    port def LightInputOut { out item payload:LightInputInformation; }
    port def LightInputIn { in item payload:LightInputInformation; }
    port def LightIntentOut { out item payload:LightIntentInformation; }
    port def LightIntentIn { in item payload:LightIntentInformation; }
    port def ServiceConfigurationOut { out item payload:ServiceConfigurationInformation; }
    port def ServiceConfigurationIn { in item payload:ServiceConfigurationInformation; }
    port def BmsTelemetryOut { out item payload:BmsTelemetryInformation; }
    port def BmsTelemetryIn { in item payload:BmsTelemetryInformation; }
    port def BmsReadRequestOut { out item payload:BmsReadRequestInformation; }
    port def BmsReadRequestIn { in item payload:BmsReadRequestInformation; }

    // Interface definitions establish the reusable producer and consumer roles.
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
    interface def IfA003BatteryObservation {
        end producer:BatteryObservationOut;
        end consumer:BatteryObservationIn;
        flow producer.payload to consumer.payload;
    }
    interface def IfA003BatteryCapability {
        end producer:BatteryCapabilityOut;
        end consumer:BatteryCapabilityIn;
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
    // ARCH-001 logical component catalogue. LE identifiers remain authoritative.
    part def RidingSupervisor { // LE-RIDING
        part settings:SettingsPolicy;
        part session:SessionPolicy;
        part demand:DemandPolicy;
        part hmi:HmiAdapter;
    }

    part def SettingsPolicy { // LE-SET
        port riderMotionIn:QualifiedRiderMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def SessionPolicy { // LE-SESSION
        port riderMotionIn:QualifiedRiderMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port capabilityIn:BatteryCapabilityIn;
        port tractionOutputIn:ActualOutputIn;
        port inputOutputIn:ActualOutputIn;
        port authorityOut:RidingAuthorityOut;
        port riderInformationOut:RiderInformationOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }

    part def DemandPolicy { // LE-DEMAND
        port riderMotionIn:QualifiedRiderMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port capabilityIn:BatteryCapabilityIn;
        port tractionOutputIn:ActualOutputIn;
        port inputOutputIn:ActualOutputIn;
        port torqueCommandOut:TorqueCommandOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
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
        port actualOutputOut:ActualOutputOut;
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
        port capabilityOut:BatteryCapabilityOut;
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
        port inputOutputIn:ActualOutputIn;
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

    // IF-A-001: LE-INPUT to riding and light policy.
    flow ifA001ToSettings from x2City.epcs.input.riderMotionOut.payload to x2City.epcs.riding.settings.riderMotionIn.payload;
    flow ifA001ToSession from x2City.epcs.input.riderMotionOut.payload to x2City.epcs.riding.session.riderMotionIn.payload;
    flow ifA001ToDemand from x2City.epcs.input.riderMotionOut.payload to x2City.epcs.riding.demand.riderMotionIn.payload;
    flow ifA001ToLightPolicy from x2City.epcs.input.riderMotionOut.payload to x2City.epcs.auxiliary.lightPolicy.riderMotionIn.payload;

    // IF-A-002: LE-HMI and LE-INPUT to riding policy components.
    flow ifA002HmiToSettings from x2City.epcs.riding.hmi.settingsOut.payload to x2City.epcs.riding.settings.hmiSettingsIn.payload;
    flow ifA002HmiToSession from x2City.epcs.riding.hmi.settingsOut.payload to x2City.epcs.riding.session.hmiSettingsIn.payload;
    flow ifA002HmiToDemand from x2City.epcs.riding.hmi.settingsOut.payload to x2City.epcs.riding.demand.hmiSettingsIn.payload;
    flow ifA002InputToSettings from x2City.epcs.input.settingsOut.payload to x2City.epcs.riding.settings.inputSettingsIn.payload;
    flow ifA002InputToSession from x2City.epcs.input.settingsOut.payload to x2City.epcs.riding.session.inputSettingsIn.payload;
    flow ifA002InputToDemand from x2City.epcs.input.settingsOut.payload to x2City.epcs.riding.demand.inputSettingsIn.payload;

    // IF-A-003: energy and traction observations, then battery capability/status.
    flow ifA003EnergyToInput from x2City.epcs.energy.batteryObservationOut.payload to x2City.epcs.input.energyObservationIn.payload;
    flow ifA003TractionToInput from x2City.epcs.traction.batteryObservationOut.payload to x2City.epcs.input.tractionObservationIn.payload;
    flow ifA003InputToBatteryPolicy from x2City.epcs.input.batteryObservationOut.payload to x2City.epcs.energy.batteryPolicy.batteryObservationIn.payload;
    flow ifA003ToSession from x2City.epcs.energy.batteryPolicy.capabilityOut.payload to x2City.epcs.riding.session.capabilityIn.payload;
    flow ifA003ToDemand from x2City.epcs.energy.batteryPolicy.capabilityOut.payload to x2City.epcs.riding.demand.capabilityIn.payload;

    // IF-A-004: LE-SESSION and LE-DEMAND to LE-TRACTION.
    flow ifA004Authority from x2City.epcs.riding.session.authorityOut.payload to x2City.epcs.traction.authorityIn.payload;
    flow ifA004TorqueCommand from x2City.epcs.riding.demand.torqueCommandOut.payload to x2City.epcs.traction.torqueCommandIn.payload;

    // IF-A-005: LE-TRACTION and LE-INPUT actual-output information.
    flow ifA005TractionToSession from x2City.epcs.traction.actualOutputOut.payload to x2City.epcs.riding.session.tractionOutputIn.payload;
    flow ifA005TractionToDemand from x2City.epcs.traction.actualOutputOut.payload to x2City.epcs.riding.demand.tractionOutputIn.payload;
    flow ifA005TractionToLightPolicy from x2City.epcs.traction.actualOutputOut.payload to x2City.epcs.auxiliary.lightPolicy.tractionOutputIn.payload;
    flow ifA005InputToSession from x2City.epcs.input.actualOutputOut.payload to x2City.epcs.riding.session.inputOutputIn.payload;
    flow ifA005InputToDemand from x2City.epcs.input.actualOutputOut.payload to x2City.epcs.riding.demand.inputOutputIn.payload;
    flow ifA005InputToLightPolicy from x2City.epcs.input.actualOutputOut.payload to x2City.epcs.auxiliary.lightPolicy.inputOutputIn.payload;

    // IF-A-006: rider presentation and logical lighting information.
    flow ifA006SessionToHmi from x2City.epcs.riding.session.riderInformationOut.payload to x2City.epcs.riding.hmi.riderInformationIn.payload;
    flow ifA006HmiToRiderDevices from x2City.epcs.riding.hmi.riderInformationOut.payload to x2City.epcs.input.riderDevices.riderInformationIn.payload;
    flow ifA006HmiToLightPolicy from x2City.epcs.riding.hmi.lightInputOut.payload to x2City.epcs.auxiliary.lightPolicy.hmiLightInputIn.payload;
    flow ifA006InputToLightPolicy from x2City.epcs.input.lightInputOut.payload to x2City.epcs.auxiliary.lightPolicy.inputLightInputIn.payload;
    flow ifA006LightPolicyToAuxiliary from x2City.epcs.auxiliary.lightPolicy.lightIntentOut.payload to x2City.epcs.auxiliary.lightIntentIn.payload;


    // IF-A-008: applicable producer information to LE-SERVICE-INFO.
    flow ifA008SettingsToService from x2City.epcs.riding.settings.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008SessionToService from x2City.epcs.riding.session.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
    flow ifA008DemandToService from x2City.epcs.riding.demand.serviceConfigurationOut.payload to x2City.epcs.service.serviceInformation.serviceConfigurationIn.payload;
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
