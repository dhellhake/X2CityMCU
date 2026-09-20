package X2CitySystemArchitecture {
    private import X2CitySharedContracts::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityComponent_MotorControl::*;
    private import X2CityComponent_AcceleratorPositionIdentification::*;
    private import X2CityComponent_AcceleratorSignalMeasurement::*;
    private import X2CityComponent_AcceleratorPositionProcessing::*;
    private import X2CityContract_LightControl::*;
    private import X2CityComponent_LightControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_LightPower::*;
    private import X2CityComponent_LightPower::*;

    alias ValidityStatus for X2CitySharedContracts::ValidityStatus;
    alias SourceContext for X2CitySharedContracts::SourceContext;
    alias Expiry for X2CitySharedContracts::Expiry;
    alias QualifiedInformationRecord for X2CitySharedContracts::QualifiedInformationRecord;

    alias QualifiedBrakeInput for X2CityContract_Input::QualifiedBrakeInput;
    alias BrakeStateOutputPort for X2CityContract_Input::BrakeStateOutputPort;
    alias BrakeStateInputPort for X2CityContract_Input::BrakeStateInputPort;
    alias AcceleratorElectricalSignal for X2CityContract_AcceleratorSignalMeasurement::AcceleratorElectricalSignal;
    alias AcceleratorElectricalSignalOutputPort for X2CityContract_AcceleratorSignalMeasurement::AcceleratorElectricalSignalOutputPort;
    alias AcceleratorElectricalSignalInputPort for X2CityContract_AcceleratorSignalMeasurement::AcceleratorElectricalSignalInputPort;
    alias AcceleratorMeasurement for X2CityContract_AcceleratorSignalMeasurement::AcceleratorMeasurement;
    alias AcceleratorMeasurementOutputPort for X2CityContract_AcceleratorSignalMeasurement::AcceleratorMeasurementOutputPort;
    alias AcceleratorMeasurementInputPort for X2CityContract_AcceleratorSignalMeasurement::AcceleratorMeasurementInputPort;
    alias AcceleratorPosition for X2CityContract_AcceleratorPositionProcessing::AcceleratorPosition;
    alias AcceleratorPositionOutputPort for X2CityContract_AcceleratorPositionProcessing::AcceleratorPositionOutputPort;
    alias AcceleratorPositionInputPort for X2CityContract_AcceleratorPositionProcessing::AcceleratorPositionInputPort;
    alias AcceleratorHealthOutputPort for X2CityContract_AcceleratorPositionProcessing::AcceleratorHealthOutputPort;
    alias AcceleratorHealthInputPort for X2CityContract_AcceleratorPositionProcessing::AcceleratorHealthInputPort;
    alias AcceleratorSignalMeasurement for X2CityComponent_AcceleratorSignalMeasurement::AcceleratorSignalMeasurement;
    alias AcceleratorPositionProcessing for X2CityComponent_AcceleratorPositionProcessing::AcceleratorPositionProcessing;
    alias AcceleratorPositionIdentification for X2CityComponent_AcceleratorPositionIdentification::AcceleratorPositionIdentification;
    item def RiderSettingsRequest:>QualifiedInformationRecord;
    item def ActiveRidingSettings:>RiderSettingsRequest;
    item def BatteryConditionObservation:>QualifiedInformationRecord;
    item def BatteryCapabilityEnvelope:>QualifiedInformationRecord;
    alias RidingAuthority for X2CityContract_SessionPolicy::RidingAuthority;
    alias SignedWheelTorqueRequest for X2CityContract_DemandPolicy::SignedWheelTorqueRequest;
    alias ActualTractionOutput for X2CityContract_MotorControl::ActualTractionOutput;
    alias ElectricalBrakingState for X2CityContract_MotorControl::ElectricalBrakingState;
    alias QualifiedVehicleMotion for X2CityContract_MotorControl::QualifiedVehicleMotion;
    item def RiderStatusInformation:>QualifiedInformationRecord;
    alias NormalLightRequest for X2CityContract_LightControl::NormalLightRequest;
    alias FrontLightMode for X2CityContract_LightControl::FrontLightMode;
    alias RearLightMode for X2CityContract_LightControl::RearLightMode;
    alias LightModes for X2CityContract_LightControl::LightModes;
    alias VehicleElectricalPower for X2CityContract_EnergyPath::VehicleElectricalPower;
    alias LightingPower for X2CityContract_LightPower::LightingPower;
    alias FrontIllumination for X2CityContract_LightControl::FrontIllumination;
    alias RearIllumination for X2CityContract_LightControl::RearIllumination;
    item def BmsTelemetry:>QualifiedInformationRecord;
    item def BmsReadRequest:>QualifiedInformationRecord;

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
    alias RidingAuthorityOutputPort for X2CityContract_SessionPolicy::RidingAuthorityOutputPort;
    alias RidingAuthorityInputPort for X2CityContract_SessionPolicy::RidingAuthorityInputPort;
    alias WheelTorqueCommandOutputPort for X2CityContract_DemandPolicy::WheelTorqueCommandOutputPort;
    alias WheelTorqueCommandInputPort for X2CityContract_DemandPolicy::WheelTorqueCommandInputPort;
    alias ActualTractionOutputPort for X2CityContract_MotorControl::ActualTractionOutputPort;
    alias ActualTractionInputPort for X2CityContract_MotorControl::ActualTractionInputPort;
    alias ElectricalBrakingStateOutputPort for X2CityContract_MotorControl::ElectricalBrakingStateOutputPort;
    alias ElectricalBrakingStateInputPort for X2CityContract_MotorControl::ElectricalBrakingStateInputPort;
    alias QualifiedVehicleMotionOutputPort for X2CityContract_MotorControl::QualifiedVehicleMotionOutputPort;
    alias QualifiedVehicleMotionInputPort for X2CityContract_MotorControl::QualifiedVehicleMotionInputPort;
    alias NormalLightRequestOutputPort for X2CityContract_LightControl::NormalLightRequestOutputPort;
    alias NormalLightRequestInputPort for X2CityContract_LightControl::NormalLightRequestInputPort;
    alias LightModesOutputPort for X2CityContract_LightControl::LightModesOutputPort;
    alias LightModesInputPort for X2CityContract_LightControl::LightModesInputPort;
    alias VehicleElectricalPowerOutputPort for X2CityContract_EnergyPath::VehicleElectricalPowerOutputPort;
    alias VehicleElectricalPowerInputPort for X2CityContract_EnergyPath::VehicleElectricalPowerInputPort;
    alias LightingPowerOutputPort for X2CityContract_LightPower::LightingPowerOutputPort;
    alias LightingPowerInputPort for X2CityContract_LightPower::LightingPowerInputPort;
    alias FrontIlluminationOutputPort for X2CityContract_LightControl::FrontIlluminationOutputPort;
    alias RearIlluminationOutputPort for X2CityContract_LightControl::RearIlluminationOutputPort;
    alias LightControl for X2CityComponent_LightControl::LightControl;
    alias LightPower for X2CityComponent_LightPower::LightPower;
    port def RiderStatusInformationOutputPort {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        out item payload:RiderStatusInformation;
    }
    port def RiderStatusInformationInputPort {
        doc /* Carries rider-facing session and status information through HmiAdapter to presentation devices. It supports display/device interaction and remains informational, without adding riding control authority. */
        in item payload:RiderStatusInformation;
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
        port qualifiedBrakeInputIn:BrakeStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port inputRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port activeRidingSettingsOut:ActiveRidingSettingsOutputPort;
    }

    part def SessionPolicy { // LE-SESSION
        port qualifiedBrakeInputIn:BrakeStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port inputRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port batteryCapabilityEnvelopeIn:BatteryCapabilityEnvelopeInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port ridingAuthorityOut:RidingAuthorityOutputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
    }

    part def DemandPolicy { // LE-DEMAND
        port qualifiedBrakeInputIn:BrakeStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port activeRidingSettingsIn:ActiveRidingSettingsInputPort;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port batteryCapabilityEnvelopeIn:BatteryCapabilityEnvelopeInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port wheelTorqueCommandOut:WheelTorqueCommandOutputPort;
    }

    part def HmiAdapter { // LE-HMI
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port normalLightRequestOut:NormalLightRequestOutputPort;
        port riderStatusInformationIn:RiderStatusInformationInputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
    }

    part def Input { // LE-INPUT
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part accelerator:AcceleratorPositionIdentification;
        part bmsLink:BmsLink;
        port qualifiedBrakeInputOut:BrakeStateOutputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
        port acceleratorHealthOut:AcceleratorHealthOutputPort;
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port energyBatteryObservationIn:BatteryConditionObservationInputPort;
        port tractionBatteryObservationIn:BatteryConditionObservationInputPort;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
        flow qualifiedBrakeFromInputQualification from inputQualification.brakeLeverStateOut.payload to qualifiedBrakeInputOut.payload;
        flow acceleratorPositionFromFunction from accelerator.acceleratorPositionOut.acceleratorPosition to acceleratorPositionOut.acceleratorPosition;
        flow acceleratorHealthFromFunction from accelerator.acceleratorHealthOut.qualification to acceleratorHealthOut.qualification;
        flow riderElectricalToAccelerator from riderDevices.acceleratorElectricalSignalOut.signal to accelerator.electricalSignalIn.signal;
    }

    part def RiderDevices { // LE-RIDER-DEVICES
        port riderStatusInformationIn:RiderStatusInformationInputPort;
        port acceleratorElectricalSignalOut:AcceleratorElectricalSignalOutputPort;
    }

    part def InputHardware; // LE-INPUT-HW
    part def InputQualification { // LE-INPUT-QUAL
        port brakeLeverStateOut:BrakeStateOutputPort;
    }

    part def BmsLink { // LE-BMS-LINK
        port bmsTelemetryIn:BmsTelemetryInputPort;
        port bmsReadRequestOut:BmsReadRequestOutputPort;
    }

    part def Traction { // LE-TRACTION
        part motorControl:X2CityComponent_MotorControl::MotorControl;
        part tractionHardware:TractionHardware;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort;
        port actualTractionOutputOut:ActualTractionOutputPort;
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort;
        flow ridingAuthorityToMotorControl from ridingAuthorityIn.payload to motorControl.ridingAuthorityIn.payload;
        flow wheelTorqueCommandToMotorControl from wheelTorqueCommandIn.payload to motorControl.wheelTorqueCommandIn.payload;
        flow qualifiedMotionFromMotorControl from motorControl.qualifiedVehicleMotionOut.payload to qualifiedVehicleMotionOut.payload;
        flow actualOutputFromMotorControl from motorControl.actualTractionOutputOut.payload to actualTractionOutputOut.payload;
        flow electricalBrakingFromMotorControl from motorControl.electricalBrakingStateOut.payload to electricalBrakingStateOut.payload;
    }
    part def TractionHardware; // LE-TRACTION-HW

    part def Energy { // LE-ENERGY
        part cells:Cells;
        part bms:Bms;
        part batteryProtection:BatteryProtection;
        part energyPath:EnergyPath;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
        port vehicleElectricalPowerOut:VehicleElectricalPowerOutputPort { doc /* Delegates EnergyPath's distributed vehicle electrical energy to an EPCS vehicle load. */ }
        flow vehicleElectricalPowerFromPath from energyPath.vehicleElectricalPowerOut.vehicleElectricalPower to vehicleElectricalPowerOut.vehicleElectricalPower;
    }

    part def Cells; // LE-CELLS

    part def Bms { // LE-BMS, supplied assembly
        port bmsTelemetryOut:BmsTelemetryOutputPort;
        port bmsReadRequestIn:BmsReadRequestInputPort;
    }

    part def BatteryProtection { // LE-BAT-POLICY
        port batteryConditionObservationIn:BatteryConditionObservationInputPort;
        port batteryCapabilityEnvelopeOut:BatteryCapabilityEnvelopeOutputPort;
    }

    part def EnergyPath { // LE-ENERGY-PATH
        port vehicleElectricalPowerOut:VehicleElectricalPowerOutputPort { doc /* Supplies distributed vehicle electrical energy to Energy's vehicle-load boundary. */ }
    }




    part def Compute { // LE-COMPUTE
        part computeHardware:ComputeHardware;
        part platform:Platform;
    }

    part def ComputeHardware; // LE-COMPUTE-HW
    part def Platform { // LE-PLATFORM
        port acceleratorHealthIn:AcceleratorHealthInputPort;
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
        part lightControl:LightControl;
        part compute:Compute;
        interface vehicleElectricalPowerToLightControl : IfA010VehicleElectricalPower
            connect energy.vehicleElectricalPowerOut to lightControl.vehicleElectricalPowerIn;
    }

    // LE-VEH is an installed-vehicle scope view, not a parent of the whole EPCS.
    part def InstalledVehicleScope;

    part def ProjectVehicleModel {
        part epcs:ElectricalPropulsionControlSystem;
        part mechanicalControl:MechanicalControl;
        part vehicleIntegration:VehicleIntegration;
        part installedVehicle:InstalledVehicleScope;
    }

    // The selected detailed vehicle binds this System reference to the one MotorControl pilot
    // occurrence; System flows retain their logical IF ownership and do not add a live bridge.
    ref part x2CityVehicle:ProjectVehicleModel;

    // IF-A-001: LE-ACCELERATOR owns qualified Position/Qualification; LE-INPUT's retained generic route carries coded brake only. LE-TRACTION owns qualified vehicle motion.
    flow ifA001BrakeToSettings from x2CityVehicle.epcs.input.qualifiedBrakeInputOut.payload to x2CityVehicle.epcs.riding.settings.qualifiedBrakeInputIn.payload;
    flow ifA001BrakeToSession from x2CityVehicle.epcs.input.qualifiedBrakeInputOut.payload to x2CityVehicle.epcs.riding.session.qualifiedBrakeInputIn.payload;
    flow ifA001BrakeToDemand from x2CityVehicle.epcs.input.qualifiedBrakeInputOut.payload to x2CityVehicle.epcs.riding.demand.qualifiedBrakeInputIn.payload;
    flow ifA001BrakeToLightControl from x2CityVehicle.epcs.input.qualifiedBrakeInputOut.payload to x2CityVehicle.epcs.lightControl.brakeLeverStateIn.payload;
    flow ifA001AcceleratorToSettings from x2CityVehicle.epcs.input.acceleratorPositionOut.acceleratorPosition to x2CityVehicle.epcs.riding.settings.acceleratorPositionIn.acceleratorPosition;
    flow ifA001AcceleratorToSession from x2CityVehicle.epcs.input.acceleratorPositionOut.acceleratorPosition to x2CityVehicle.epcs.riding.session.acceleratorPositionIn.acceleratorPosition;
    flow ifA001AcceleratorToDemand from x2CityVehicle.epcs.input.acceleratorPositionOut.acceleratorPosition to x2CityVehicle.epcs.riding.demand.acceleratorPositionIn.acceleratorPosition;
    flow ifA001AcceleratorToPlatform from x2CityVehicle.epcs.input.acceleratorHealthOut.qualification to x2CityVehicle.epcs.compute.platform.acceleratorHealthIn.qualification;
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
    interface ifA005ElectricalBrakingToLightControl : IfA005ElectricalBrakingState
        connect x2CityVehicle.epcs.traction.electricalBrakingStateOut to x2CityVehicle.epcs.lightControl.electricalBrakingStateIn;

    // IF-A-006: rider presentation and HMI's accepted normal-light request.
    flow ifA006SessionToHmi from x2CityVehicle.epcs.riding.session.riderStatusInformationOut.payload to x2CityVehicle.epcs.riding.hmi.riderStatusInformationIn.payload;
    flow ifA006HmiToRiderDevices from x2CityVehicle.epcs.riding.hmi.riderStatusInformationOut.payload to x2CityVehicle.epcs.input.riderDevices.riderStatusInformationIn.payload;
    interface ifA006HmiToLightControl : IfA006NormalLightRequest
        connect x2CityVehicle.epcs.riding.hmi.normalLightRequestOut to x2CityVehicle.epcs.lightControl.runningLightStateIn;


    // IF-A-009: the selected BMS read information endpoint.
    flow ifA009BmsReadRequest from x2CityVehicle.epcs.input.bmsLink.bmsReadRequestOut.payload to x2CityVehicle.epcs.energy.bms.bmsReadRequestIn.payload;
    flow ifA009BmsTelemetry from x2CityVehicle.epcs.energy.bms.bmsTelemetryOut.payload to x2CityVehicle.epcs.input.bmsLink.bmsTelemetryIn.payload;
}
