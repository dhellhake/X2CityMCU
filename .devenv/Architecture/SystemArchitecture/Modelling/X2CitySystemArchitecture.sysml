package X2CitySystemArchitecture {
    private import X2CitySharedContracts::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_BrakeSignalMeasurement::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_MotorSignalMeasurement::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityComponent_MotorControl::*;
    private import X2CityComponent_TractionHardware::*;
    private import X2CityComponent_TractionControl::*;
    private import X2CityComponent_MotorPositionEstimation::*;
    private import X2CityComponent_AcceleratorPositionIdentification::*;
    private import X2CityComponent_AcceleratorSignalMeasurement::*;
    private import X2CityComponent_AcceleratorPositionProcessing::*;
    private import X2CityComponent_MechanicalBrakeDetection::*;
    private import X2CityComponent_BrakeSignalMeasurement::*;
    private import X2CityComponent_BrakeStateIdentification::*;
    private import X2CityContract_LightControl::*;
    private import X2CityComponent_LightControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_LightPower::*;
    private import X2CityComponent_LightPower::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_BatteryControl::*;
    private import X2CityComponent_BatteryAssembly::*;
    private import X2CityComponent_BatterySupervision::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_HmiElectricalInterface::*;
    private import X2CityComponent_HmiControl::*;
    private import X2CityContract_ComputeHardware::*;
    private import X2CityContract_Compute::*;
    private import X2CityComponent_Compute::*;
    private import X2CityComponent_ComputeHardware::*;
    private import X2CityComponent_Platform::*;

    alias ValidityStatus for X2CitySharedContracts::ValidityStatus;
    alias SourceContext for X2CitySharedContracts::SourceContext;
    alias Expiry for X2CitySharedContracts::Expiry;
    alias QualifiedInformationRecord for X2CitySharedContracts::QualifiedInformationRecord;

    alias BrakeElectricalSignalInputPort for X2CityContract_BrakeSignalMeasurement::BrakeElectricalSignalInputPort;
    alias BrakeMeasurementOutputPort for X2CityContract_BrakeSignalMeasurement::BrakeMeasurementOutputPort;
    alias BrakeMeasurementInputPort for X2CityContract_BrakeSignalMeasurement::BrakeMeasurementInputPort;
    alias BrakeLeverStateOutputPort for X2CityContract_BrakeStateIdentification::BrakeLeverStateOutputPort;
    alias BrakeLeverStateInputPort for X2CityContract_BrakeStateIdentification::BrakeLeverStateInputPort;
    alias BrakeHealthOutputPort for X2CityContract_BrakeStateIdentification::BrakeHealthOutputPort;
    alias BrakeHealthInputPort for X2CityContract_BrakeStateIdentification::BrakeHealthInputPort;
    alias MechanicalBrakeDetection for X2CityComponent_MechanicalBrakeDetection::MechanicalBrakeDetection;
    alias BrakeSignalMeasurement for X2CityComponent_BrakeSignalMeasurement::BrakeSignalMeasurement;
    alias BrakeStateIdentification for X2CityComponent_BrakeStateIdentification::BrakeStateIdentification;
    alias TemperatureMeasurementOutputPort for X2CityContract_TractionControl::TemperatureMeasurementOutputPort;
    alias TemperatureMeasurementInputPort for X2CityContract_TractionControl::TemperatureMeasurementInputPort;
    alias QualifiedTemperatureOutputPort for X2CityContract_TractionControl::QualifiedTemperatureOutputPort;
    alias QualifiedTemperatureInputPort for X2CityContract_TractionControl::QualifiedTemperatureInputPort;
    alias SupplyVoltageMeasurementOutputPort for X2CityContract_TractionControl::SupplyVoltageMeasurementOutputPort;
    alias SupplyVoltageMeasurementInputPort for X2CityContract_TractionControl::SupplyVoltageMeasurementInputPort;
    alias FastDcLinkVoltageOutputPort for X2CityContract_TractionControl::FastDcLinkVoltageOutputPort;
    alias FastDcLinkVoltageInputPort for X2CityContract_TractionControl::FastDcLinkVoltageInputPort;
    alias AcceleratorElectricalSignal for X2CityContract_AcceleratorSignalMeasurement::AcceleratorElectricalSignal;
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
    alias HallSignalsOutputPort for X2CityContract_MotorSignalMeasurement::HallSignalsOutputPort;
    alias HallSignalsInputPort for X2CityContract_MotorSignalMeasurement::HallSignalsInputPort;
    alias MotorPhaseElectricalOutputPort for X2CityContract_MotorSignalMeasurement::MotorPhaseElectricalOutputPort;
    alias MotorPhaseElectricalInputPort for X2CityContract_MotorSignalMeasurement::MotorPhaseElectricalInputPort;
    alias MotorPositionEstimation for X2CityComponent_MotorPositionEstimation::MotorPositionEstimation;
    alias MotorControl for X2CityComponent_MotorControl::MotorControl;
    alias TractionHardware for X2CityComponent_TractionHardware::TractionHardware;
    alias TractionControl for X2CityComponent_TractionControl::TractionControl;
    alias RiderSettingsRequest for X2CityContract_SettingsPolicy::RiderSettingsRequest;
    alias ActiveRidingSettings for X2CityContract_SettingsPolicy::ActiveRidingSettings;
    alias RidingAuthority for X2CityContract_SessionPolicy::RidingAuthority;
    alias SignedWheelTorqueRequest for X2CityContract_DemandPolicy::SignedWheelTorqueRequest;
    alias ActualTractionOutput for X2CityContract_MotorControl::ActualTractionOutput;
    alias ElectricalBrakingState for X2CityContract_MotorControl::ElectricalBrakingState;
    alias QualifiedVehicleMotion for X2CityContract_MotorControl::QualifiedVehicleMotion;
    alias PhaseExcitationCommand for X2CityContract_MotorControl::PhaseExcitationCommand;
    alias RequestedPhaseVoltageVector for X2CityContract_MotorControl::RequestedPhaseVoltageVector;
    alias TractionStageEvidence for X2CityContract_MotorControl::TractionStageEvidence;
    alias TractionHardwareProtectionEvidence for X2CityContract_MotorControl::TractionHardwareProtectionEvidence;
    alias TractionConditionEvidence for X2CityContract_MotorControl::TractionConditionEvidence;
    alias TractionConditionCategory for X2CityContract_MotorControl::TractionConditionCategory;
    alias PhysicalMotorActuation for X2CityContract_MotorControl::PhysicalMotorActuation;
    alias SelectedFaultIndication for X2CityContract_SessionPolicy::SelectedFaultIndication;
    alias NormalLightRequest for X2CityContract_LightControl::NormalLightRequest;
    alias FrontLightMode for X2CityContract_LightControl::FrontLightMode;
    alias RearLightMode for X2CityContract_LightControl::RearLightMode;
    alias LightModes for X2CityContract_LightControl::LightModes;
    alias VehicleElectricalPower for X2CityContract_EnergyPath::VehicleElectricalPower;
    alias LightingPower for X2CityContract_LightPower::LightingPower;
    alias FrontIllumination for X2CityContract_LightControl::FrontIllumination;
    alias RearIllumination for X2CityContract_LightControl::RearIllumination;
    alias BatteryPower for X2CityContract_BatteryControl::BatteryPower;
    alias BatteryPowerPort for X2CityContract_BatteryControl::BatteryPowerPort;
    alias BmsReadRequest for X2CityContract_BatteryControl::BmsReadRequest;
    alias BmsTelemetry for X2CityContract_BatteryControl::BmsTelemetry;
    alias BmsReadRequestOutputPort for X2CityContract_BatteryControl::BmsReadRequestOutputPort;
    alias BmsReadRequestInputPort for X2CityContract_BatteryControl::BmsReadRequestInputPort;
    alias BmsTelemetryOutputPort for X2CityContract_BatteryControl::BmsTelemetryOutputPort;
    alias BmsTelemetryInputPort for X2CityContract_BatteryControl::BmsTelemetryInputPort;
    alias BatteryMeasurements for X2CityContract_BatteryControl::BatteryMeasurements;
    alias BatteryMeasurementsOutputPort for X2CityContract_BatteryControl::BatteryMeasurementsOutputPort;
    alias BatteryMeasurementsInputPort for X2CityContract_BatteryControl::BatteryMeasurementsInputPort;
    alias IfA009BatteryMeasurements for X2CityContract_BatteryControl::IfA009BatteryMeasurements;
    alias BatteryReadinessAndFault for X2CityContract_BatteryControl::BatteryReadinessAndFault;
    alias BatteryReadinessAndFaultOutputPort for X2CityContract_BatteryControl::BatteryReadinessAndFaultOutputPort;
    alias BatteryReadinessAndFaultInputPort for X2CityContract_BatteryControl::BatteryReadinessAndFaultInputPort;
    alias BatteryOperatingLimits for X2CityContract_BatteryControl::BatteryOperatingLimits;
    alias BatteryOperatingLimitsOutputPort for X2CityContract_BatteryControl::BatteryOperatingLimitsOutputPort;
    alias BatteryOperatingLimitsInputPort for X2CityContract_BatteryControl::BatteryOperatingLimitsInputPort;
    alias BatteryStateOfCharge for X2CityContract_BatteryControl::BatteryStateOfCharge;
    alias BatteryStateOfChargeOutputPort for X2CityContract_BatteryControl::BatteryStateOfChargeOutputPort;
    alias BatteryStateOfChargeInputPort for X2CityContract_BatteryControl::BatteryStateOfChargeInputPort;
    alias BatteryCurrent for X2CityContract_BatteryControl::BatteryCurrent;
    alias BatteryCurrentOutputPort for X2CityContract_BatteryControl::BatteryCurrentOutputPort;
    alias BatteryCurrentInputPort for X2CityContract_BatteryControl::BatteryCurrentInputPort;
    alias IfA003BatteryReadinessAndFault for X2CityContract_BatteryControl::IfA003BatteryReadinessAndFault;
    alias IfA003BatteryOperatingLimits for X2CityContract_BatteryControl::IfA003BatteryOperatingLimits;
    alias IfA003BatteryStateOfCharge for X2CityContract_BatteryControl::IfA003BatteryStateOfCharge;
    alias IfA003BatteryCurrent for X2CityContract_BatteryControl::IfA003BatteryCurrent;
    alias IfA010BatteryPower for X2CityContract_BatteryControl::IfA010BatteryPower;
    alias BatteryControl for X2CityComponent_BatteryControl::BatteryControl;
    alias BatteryAssembly for X2CityComponent_BatteryAssembly::BatteryAssembly;
    alias BatterySupervision for X2CityComponent_BatterySupervision::BatterySupervision;

    alias RiderSettingsRequestOutputPort for X2CityContract_SettingsPolicy::RiderSettingsRequestOutputPort;
    alias RiderSettingsRequestInputPort for X2CityContract_SettingsPolicy::RiderSettingsRequestInputPort;
    alias ActiveRidingSettingsOutputPort for X2CityContract_SettingsPolicy::ActiveRidingSettingsOutputPort;
    alias ActiveRidingSettingsInputPort for X2CityContract_SettingsPolicy::ActiveRidingSettingsInputPort;
    alias RidingAuthorityOutputPort for X2CityContract_SessionPolicy::RidingAuthorityOutputPort;
    alias RidingAuthorityInputPort for X2CityContract_SessionPolicy::RidingAuthorityInputPort;
    alias SelectedFaultIndicationOutputPort for X2CityContract_SessionPolicy::SelectedFaultIndicationOutputPort;
    alias WheelTorqueCommandOutputPort for X2CityContract_DemandPolicy::WheelTorqueCommandOutputPort;
    alias WheelTorqueCommandInputPort for X2CityContract_DemandPolicy::WheelTorqueCommandInputPort;
    alias ActualTractionOutputPort for X2CityContract_MotorControl::ActualTractionOutputPort;
    alias ActualTractionInputPort for X2CityContract_MotorControl::ActualTractionInputPort;
    alias ElectricalBrakingStateOutputPort for X2CityContract_MotorControl::ElectricalBrakingStateOutputPort;
    alias ElectricalBrakingStateInputPort for X2CityContract_MotorControl::ElectricalBrakingStateInputPort;
    alias QualifiedVehicleMotionOutputPort for X2CityContract_MotorControl::QualifiedVehicleMotionOutputPort;
    alias QualifiedVehicleMotionInputPort for X2CityContract_MotorControl::QualifiedVehicleMotionInputPort;
    alias PhaseExcitationCommandOutputPort for X2CityContract_MotorControl::PhaseExcitationCommandOutputPort;
    alias PhaseExcitationCommandInputPort for X2CityContract_MotorControl::PhaseExcitationCommandInputPort;
    alias TractionStageEvidenceOutputPort for X2CityContract_MotorControl::TractionStageEvidenceOutputPort;
    alias TractionStageEvidenceInputPort for X2CityContract_MotorControl::TractionStageEvidenceInputPort;
    alias TractionHardwareProtectionEvidenceOutputPort for X2CityContract_MotorControl::TractionHardwareProtectionEvidenceOutputPort;
    alias TractionHardwareProtectionEvidenceInputPort for X2CityContract_MotorControl::TractionHardwareProtectionEvidenceInputPort;
    alias TractionConditionEvidenceOutputPort for X2CityContract_MotorControl::TractionConditionEvidenceOutputPort;
    alias TractionConditionEvidenceInputPort for X2CityContract_MotorControl::TractionConditionEvidenceInputPort;
    alias PhysicalMotorActuationPort for X2CityContract_MotorControl::PhysicalMotorActuationPort;
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
    alias HMIControl for X2CityComponent_HmiControl::HMIControl;
    alias HmiDisplayRequestData for X2CityContract_HmiElectricalInterface::HmiDisplayRequestData;
    alias HmiControllerReportData for X2CityContract_HmiElectricalInterface::HmiControllerReportData;
    alias HmiDevicePort for X2CityContract_HmiElectricalInterface::HmiDevicePort;
    alias HmiPowerLockSignal for X2CityContract_HmiElectricalInterface::HmiPowerLockSignal;
    alias ControllerWakeSignal for X2CityContract_ComputeHardware::ControllerWakeSignal;
    alias ControllerWakeOutputPort for X2CityContract_ComputeHardware::ControllerWakeOutputPort;
    alias ControllerWakeInputPort for X2CityContract_ComputeHardware::ControllerWakeInputPort;
    alias IfA006ControllerWake for X2CityContract_ComputeHardware::IfA006ControllerWake;
    alias HmiPowerLockObservationState for X2CityContract_HmiControl::HmiPowerLockObservationState;
    alias HmiPowerLockObservation for X2CityContract_HmiControl::HmiPowerLockObservation;
    alias HmiPowerLockObservationOutputPort for X2CityContract_HmiControl::HmiPowerLockObservationOutputPort;
    alias HmiPowerLockObservationInputPort for X2CityContract_HmiControl::HmiPowerLockObservationInputPort;
    alias VehicleOperationRequestState for X2CityContract_HmiControl::VehicleOperationRequestState;
    alias VehicleOperationRequestQualification for X2CityContract_HmiControl::VehicleOperationRequestQualification;
    alias VehicleOperationRequest for X2CityContract_HmiControl::VehicleOperationRequest;
    alias VehicleOperationRequestOutputPort for X2CityContract_HmiControl::VehicleOperationRequestOutputPort;
    alias VehicleOperationRequestInputPort for X2CityContract_HmiControl::VehicleOperationRequestInputPort;
    alias IfA006HmiPowerLockObservation for X2CityContract_HmiControl::IfA006HmiPowerLockObservation;
    alias ComputeRuntimeInitialization for X2CityContract_Compute::ComputeRuntimeInitialization;
    alias ComputeRuntimeInitializationOutputPort for X2CityContract_Compute::ComputeRuntimeInitializationOutputPort;
    alias ComputeRuntimeInitializationInputPort for X2CityContract_Compute::ComputeRuntimeInitializationInputPort;
    alias ComputeSleepRequest for X2CityContract_Compute::ComputeSleepRequest;
    alias ComputeSleepRequestOutputPort for X2CityContract_Compute::ComputeSleepRequestOutputPort;
    alias ComputeSleepRequestInputPort for X2CityContract_Compute::ComputeSleepRequestInputPort;
    alias IfA006VehicleOperationRequest for X2CityContract_HmiControl::IfA006VehicleOperationRequest;
    alias IfA006ComputeRuntimeInitialization for X2CityContract_Compute::IfA006ComputeRuntimeInitialization;
    alias IfA006ComputeSleepRequest for X2CityContract_Compute::IfA006ComputeSleepRequest;

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
    // ARCH-001; LE identifiers remain authoritative.
    part def RidingSupervisor { // LE-RIDING
        part settings:SettingsPolicy;
        part session:SessionPolicy;
        part demand:DemandPolicy;
    }

    part def SettingsPolicy { // LE-SET
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port activeRidingSettingsOut:ActiveRidingSettingsOutputPort;
    }

    part def SessionPolicy { // LE-SESSION
        /* Owns operation lifecycle, Ready/authority, fault/restart policy and riding authority. A qualified explicit physical Off ends the current operation session immediately, regardless of vehicle motion; Unknown or unavailable is not Off, and HMI UART loss does not change the physical request. A later On, including before sleep entry, begins fresh session qualification. Session's sleep request follows traction output handoff and is not physical inhibition evidence. */
        port vehicleOperationRequestIn:VehicleOperationRequestInputPort;
        port runtimeInitializationIn:ComputeRuntimeInitializationInputPort;
        port sleepRequestOut:ComputeSleepRequestOutputPort;
        port brakeLeverStateIn:BrakeLeverStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port motorPositionIn:MotorPositionInputPort { doc /* Receives estimator Position and Qualification for existing fault supervision. QualifiedVehicleMotion remains the separate standstill/speed evidence. */ }
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port qualifiedTemperatureIn:QualifiedTemperatureInputPort;
        port tractionConditionEvidenceIn:TractionConditionEvidenceInputPort;
        port batteryReadinessAndFaultIn:BatteryReadinessAndFaultInputPort { doc /* Receives BatteryControl startup assessment and separate recognized thermal/battery faults. */ }
        port stateOfChargeIn:BatteryStateOfChargeInputPort { doc /* Receives qualified actual SOC for low-charge selection. */ }
        port actualTractionOutputIn:ActualTractionInputPort;
        port ridingAuthorityOut:RidingAuthorityOutputPort;
        port selectedFaultIndicationOut:SelectedFaultIndicationOutputPort;
    }

    part def DemandPolicy { // LE-DEMAND
        port brakeLeverStateIn:BrakeLeverStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port activeRidingSettingsIn:ActiveRidingSettingsInputPort;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port batteryOperatingLimitsIn:BatteryOperatingLimitsInputPort { doc /* Receives independently qualified discharge, regenerative-charge, and SOC positive wheel-torque limits. */ }
        port actualTractionOutputIn:ActualTractionInputPort;
        port wheelTorqueCommandOut:WheelTorqueCommandOutputPort;
    }

    part def Input { // LE-INPUT
        /* Composes accelerator and coded brake-lever electrical detection functions. Their electrical input ports mark the exposed function boundaries; no rider-operated endpoint or sensor implementation is selected here. */
        part accelerator:AcceleratorPositionIdentification;
        part mechanicalBrakeDetection:MechanicalBrakeDetection;
        port brakeLeverStateOut:BrakeLeverStateOutputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
        port acceleratorHealthOut:AcceleratorHealthOutputPort;
        port brakeHealthOut:BrakeHealthOutputPort;
        flow brakeLeverStateFromFunction from mechanicalBrakeDetection.brakeLeverStateOut.brakeLeverState to brakeLeverStateOut.brakeLeverState;
        flow brakeHealthFromFunction from mechanicalBrakeDetection.brakeHealthOut.qualification to brakeHealthOut.qualification;
        flow acceleratorPositionFromFunction from accelerator.acceleratorPositionOut.acceleratorPosition to acceleratorPositionOut.acceleratorPosition;
        flow acceleratorHealthFromFunction from accelerator.acceleratorHealthOut.qualification to acceleratorHealthOut.qualification;
    }

    part def Traction { // LE-TRACTION
        part tractionControl:TractionControl;
        part motorPositionEstimation:MotorPositionEstimation;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort;
        port tractionElectricalPower:TractionElectricalPowerPort { doc /* Physical bidirectional EnergyPath connection for propulsion and regenerative return. */ }
        port physicalMotorActuation:PhysicalMotorActuationPort;
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort;
        port actualTractionOutputOut:ActualTractionOutputPort;
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort;
        port motorPositionOut:MotorPositionOutputPort { doc /* Delivers the estimator's full electrical Position/Qualification composite to platform and Session fault supervision. */ }
        port hallSignalsIn:HallSignalsInputPort;
        port motorPhaseElectricalIn:MotorPhaseElectricalInputPort;
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort;
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort;
        port tractionConditionEvidenceOut:TractionConditionEvidenceOutputPort;
        flow ridingAuthorityToTractionControl from ridingAuthorityIn.payload to tractionControl.ridingAuthorityIn.payload;
        flow wheelTorqueCommandToTractionControl from wheelTorqueCommandIn.payload to tractionControl.wheelTorqueCommandIn.payload;
        interface energyToTractionControl : X2CityContract_EnergyPath::IfA010TractionElectricalPower
            connect tractionElectricalPower to tractionControl.tractionElectricalPower;
        interface motorActuationFromTractionControl : X2CityContract_MotorControl::IfA005PhysicalMotorActuation
            connect tractionControl.physicalMotorActuation to physicalMotorActuation;
        flow hallSignalsToMotorPositionEstimation from hallSignalsIn.hallSignals to motorPositionEstimation.hallSignalsIn.hallSignals;
        flow motorPhaseElectricalToMotorPositionEstimation from motorPhaseElectricalIn.motorPhaseElectrical to motorPositionEstimation.motorPhaseElectricalIn.motorPhaseElectrical;
        interface motorPositionToTractionControl : X2CityContract_MotorPositionProcessing::IfA005MotorPosition
            connect motorPositionEstimation.motorPositionOut to tractionControl.motorPositionIn;
        interface phaseCurrentToTractionControl : X2CityContract_MotorPositionProcessing::IfA005PhaseCurrentMeasurements
            connect motorPositionEstimation.phaseCurrentOut to tractionControl.phaseCurrentIn;
        flow motorPositionFromEstimation from motorPositionEstimation.motorPositionOut.motorPosition to motorPositionOut.motorPosition;
        flow qualifiedTemperatureFromTractionControl from tractionControl.qualifiedTemperatureOut.payload to qualifiedTemperatureOut.payload;
        flow fastDcLinkVoltageFromTractionControl from tractionControl.fastDcLinkVoltageOut.payload to fastDcLinkVoltageOut.payload;
        flow localConditionFromTractionControl from tractionControl.tractionConditionEvidenceOut.payload to tractionConditionEvidenceOut.payload;
        flow qualifiedMotionFromTractionControl from tractionControl.qualifiedVehicleMotionOut.payload to qualifiedVehicleMotionOut.payload;
        flow actualOutputFromTractionControl from tractionControl.actualTractionOutputOut.payload to actualTractionOutputOut.payload;
        flow electricalBrakingFromTractionControl from tractionControl.electricalBrakingStateOut.payload to electricalBrakingStateOut.payload;
    }

    part def EnergyPath { // LE-ENERGY-PATH
        port batteryPower:BatteryPowerPort { doc /* Physical bidirectional pack-energy connection to BatteryControl. */ }
        port vehicleElectricalPowerOut:VehicleElectricalPowerOutputPort { doc /* Supplies general distributed vehicle electrical power to a vehicle load. */ }
        port tractionElectricalPower:TractionElectricalPowerPort { doc /* Physical bidirectional traction-power branch. */ }
    }




    alias Compute for X2CityComponent_Compute::Compute;
    alias ComputeHardware for X2CityComponent_ComputeHardware::ComputeHardware;
    alias Platform for X2CityComponent_Platform::Platform;

    part def ElectricalPropulsionControlSystem { // LE-EPCS
        part riding:RidingSupervisor;
        part hmiControl:HMIControl;
        part input:Input;
        part traction:Traction;
        part batteryControl:BatteryControl { doc /* Removable BatteryAssembly and vehicle-host BatterySupervision composite. */ }
        part energyPath:EnergyPath { doc /* General vehicle electrical-power distribution sibling. */ }
        part lightControl:LightControl;
        part compute:Compute;
        interface batteryPowerToEnergyPath : IfA010BatteryPower
            connect batteryControl.batteryPower to energyPath.batteryPower;
        interface vehicleElectricalPowerToLightControl : IfA010VehicleElectricalPower
            connect energyPath.vehicleElectricalPowerOut to lightControl.vehicleElectricalPowerIn;
        interface vehicleElectricalPowerToHmi : IfA010VehicleElectricalPower
            connect energyPath.vehicleElectricalPowerOut to hmiControl.vehicleElectricalPowerIn;
        interface vehicleElectricalPowerToCompute : IfA010VehicleElectricalPower
            connect energyPath.vehicleElectricalPowerOut to compute.vehicleElectricalPowerIn;
        interface controllerWakeToCompute : IfA006ControllerWake
            connect hmiControl.controllerWakeOut to compute.controllerWakeIn;
        interface vehicleOperationRequestToSession : IfA006VehicleOperationRequest
            connect hmiControl.vehicleOperationRequestOut to riding.session.vehicleOperationRequestIn;
        interface computeRuntimeInitializationToSession : IfA006ComputeRuntimeInitialization
            connect compute.runtimeInitializationOut to riding.session.runtimeInitializationIn;
        interface sessionSleepRequestToCompute : IfA006ComputeSleepRequest
            connect riding.session.sleepRequestOut to compute.sleepRequestIn;
        interface tractionPowerToTraction : IfA010TractionElectricalPower
            connect energyPath.tractionElectricalPower to traction.tractionElectricalPower;
        interface motorPositionToPlatform : X2CityContract_MotorPositionProcessing::IfA005MotorPosition
            connect traction.motorPositionOut to compute.platform.motorPositionIn;
        interface motorPositionToSession : X2CityContract_MotorPositionProcessing::IfA005MotorPosition
            connect traction.motorPositionOut to riding.session.motorPositionIn;
        interface brakeToSession : X2CityContract_BrakeStateIdentification::IfA001BrakeLeverState
            connect input.brakeLeverStateOut to riding.session.brakeLeverStateIn;
        interface brakeToDemand : X2CityContract_BrakeStateIdentification::IfA001BrakeLeverState
            connect input.brakeLeverStateOut to riding.demand.brakeLeverStateIn;
        interface brakeToLightControl : X2CityContract_BrakeStateIdentification::IfA001BrakeLeverState
            connect input.brakeLeverStateOut to lightControl.brakeLeverStateIn;
        interface brakeHealthToPlatform : X2CityContract_BrakeStateIdentification::IfA008BrakeHealth
            connect input.brakeHealthOut to compute.platform.brakeHealthIn;
        interface temperatureToSession : X2CityContract_TractionControl::IfA008QualifiedTemperature
            connect traction.qualifiedTemperatureOut to riding.session.qualifiedTemperatureIn;
        interface temperatureToPlatform : X2CityContract_TractionControl::IfA008QualifiedTemperature
            connect traction.qualifiedTemperatureOut to compute.platform.qualifiedTemperatureIn;
        interface fastDcLinkVoltageToPlatform : X2CityContract_TractionControl::IfA008FastDcLinkVoltage
            connect traction.fastDcLinkVoltageOut to compute.platform.fastDcLinkVoltageIn;
        interface tractionConditionToSession : X2CityContract_MotorControl::IfA005TractionConditionEvidence
            connect traction.tractionConditionEvidenceOut to riding.session.tractionConditionEvidenceIn;
    }

    // LE-VEH is an installed-vehicle scope view, not a parent of the whole EPCS.
    part def InstalledVehicleScope;

    part def ProjectVehicleModel {
        part epcs:ElectricalPropulsionControlSystem;
        part installedVehicle:InstalledVehicleScope;
    }

    // The selected detailed vehicle binds this System reference to the one MotorControl pilot
    // occurrence; System flows retain their logical IF ownership and do not add a live bridge.
    ref part x2CityVehicle:ProjectVehicleModel;

    // IF-A-001: LE-ACCELERATOR owns qualified Position/Qualification; LE-MECHANICAL-BRAKE owns the exact four-state State/Qualification route inside LE-EPCS. LE-TRACTION owns qualified vehicle motion.
    flow ifA001AcceleratorToSettings from x2CityVehicle.epcs.input.acceleratorPositionOut.acceleratorPosition to x2CityVehicle.epcs.riding.settings.acceleratorPositionIn.acceleratorPosition;
    flow ifA001AcceleratorToSession from x2CityVehicle.epcs.input.acceleratorPositionOut.acceleratorPosition to x2CityVehicle.epcs.riding.session.acceleratorPositionIn.acceleratorPosition;
    flow ifA001AcceleratorToDemand from x2CityVehicle.epcs.input.acceleratorPositionOut.acceleratorPosition to x2CityVehicle.epcs.riding.demand.acceleratorPositionIn.acceleratorPosition;
    flow ifA001AcceleratorToPlatform from x2CityVehicle.epcs.input.acceleratorHealthOut.qualification to x2CityVehicle.epcs.compute.platform.acceleratorHealthIn.qualification;
    flow ifA001VehicleMotionToSettings from x2CityVehicle.epcs.traction.qualifiedVehicleMotionOut.payload to x2CityVehicle.epcs.riding.settings.qualifiedVehicleMotionIn.payload;
    flow ifA001VehicleMotionToSession from x2CityVehicle.epcs.traction.qualifiedVehicleMotionOut.payload to x2CityVehicle.epcs.riding.session.qualifiedVehicleMotionIn.payload;

    // IF-A-002: HMIControl requests feed LE-SET and startup receipt reaches LE-SESSION; demand receives only active settings.
    interface ifA002HmiToSettings : X2CityContract_SettingsPolicy::IfA002RiderSettingsRequest
        connect x2CityVehicle.epcs.hmiControl.ridingSettingsOut to x2CityVehicle.epcs.riding.settings.hmiRiderSettingsRequestIn;
    interface ifA002HmiToSession : X2CityContract_SettingsPolicy::IfA002RiderSettingsRequest
        connect x2CityVehicle.epcs.hmiControl.ridingSettingsOut to x2CityVehicle.epcs.riding.session.hmiRiderSettingsRequestIn;
    flow ifA002ActiveRidingSettingsToDemand from x2CityVehicle.epcs.riding.settings.activeRidingSettingsOut.payload to x2CityVehicle.epcs.riding.demand.activeRidingSettingsIn.payload;

    // IF-A-003: BatteryControl directly provides policy and HMI evidence; Input and Traction do not assemble battery observations.
    interface ifA003ReadinessToSession : IfA003BatteryReadinessAndFault
        connect x2CityVehicle.epcs.batteryControl.batteryReadinessAndFaultOut to x2CityVehicle.epcs.riding.session.batteryReadinessAndFaultIn;
    interface ifA003LimitsToDemand : IfA003BatteryOperatingLimits
        connect x2CityVehicle.epcs.batteryControl.batteryOperatingLimitsOut to x2CityVehicle.epcs.riding.demand.batteryOperatingLimitsIn;
    interface ifA003SocToSession : IfA003BatteryStateOfCharge
        connect x2CityVehicle.epcs.batteryControl.stateOfChargeOut to x2CityVehicle.epcs.riding.session.stateOfChargeIn;
    interface ifA003SocToHmi : IfA003BatteryStateOfCharge
        connect x2CityVehicle.epcs.batteryControl.stateOfChargeOut to x2CityVehicle.epcs.hmiControl.stateOfChargeIn;
    interface ifA003CurrentToHmi : IfA003BatteryCurrent
        connect x2CityVehicle.epcs.batteryControl.batteryCurrentOut to x2CityVehicle.epcs.hmiControl.batteryCurrentIn;

    // IF-A-004: authority informs demand and traction; demand alone provides the signed command.
    flow ifA004AuthorityToDemand from x2CityVehicle.epcs.riding.session.ridingAuthorityOut.payload to x2CityVehicle.epcs.riding.demand.ridingAuthorityIn.payload;
    flow ifA004Authority from x2CityVehicle.epcs.riding.session.ridingAuthorityOut.payload to x2CityVehicle.epcs.traction.ridingAuthorityIn.payload;
    flow ifA004WheelTorqueCommand from x2CityVehicle.epcs.riding.demand.wheelTorqueCommandOut.payload to x2CityVehicle.epcs.traction.wheelTorqueCommandIn.payload;

    // IF-A-005: LE-TRACTION owns qualified vehicle motion and actual-output feedback.
    flow ifA005TractionToSession from x2CityVehicle.epcs.traction.actualTractionOutputOut.payload to x2CityVehicle.epcs.riding.session.actualTractionOutputIn.payload;
    flow ifA005VehicleMotionToDemand from x2CityVehicle.epcs.traction.qualifiedVehicleMotionOut.payload to x2CityVehicle.epcs.riding.demand.qualifiedVehicleMotionIn.payload;
    interface ifA005VehicleMotionToHmi : IfA005QualifiedVehicleMotion
        connect x2CityVehicle.epcs.traction.qualifiedVehicleMotionOut to x2CityVehicle.epcs.hmiControl.vehicleMotionIn;
    flow ifA005TractionToDemand from x2CityVehicle.epcs.traction.actualTractionOutputOut.payload to x2CityVehicle.epcs.riding.demand.actualTractionOutputIn.payload;
    interface ifA005ElectricalBrakingToLightControl : IfA005ElectricalBrakingState
        connect x2CityVehicle.epcs.traction.electricalBrakingStateOut to x2CityVehicle.epcs.lightControl.electricalBrakingStateIn;

    // IF-A-006: selected Session fault indication and HMI's accepted normal-light request.
    interface ifA006SelectedFaultToHmi : X2CityContract_SessionPolicy::IfA006SelectedFaultIndication
        connect x2CityVehicle.epcs.riding.session.selectedFaultIndicationOut to x2CityVehicle.epcs.hmiControl.selectedFaultIn;
    interface ifA006HmiToLightControl : IfA006NormalLightRequest
        connect x2CityVehicle.epcs.hmiControl.runningLightStateOut to x2CityVehicle.epcs.lightControl.runningLightStateIn;
}
