package X2CityComponent_ElectricalPropulsionControlSystem {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RidingControl::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityComponent_DriverInteraction::*;
    private import X2CityComponent_Traction::*;
    private import X2CityComponent_BatteryControl::*;
    private import X2CityComponent_EnergyPath::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_LightControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityComponent_Compute::*;
    private import X2CityContract_Compute::*;
    private import X2CityContract_ComputeHardware::*;
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    part def ElectricalPropulsionControlSystem { // LE-EPCS
        /* Composes RidingControl, rider interaction, traction-owned measurement/qualification, battery, energy, lighting and compute components. */
        part ridingControl:RidingControl;
        part driverInteraction:DriverInteraction;
        part traction:Traction;
        part batteryControl:BatteryControl { doc /* Removable pack and vehicle-host battery supervision composite. */ }
        part energyPath:EnergyPath { doc /* General vehicle electrical-power distribution sibling of BatteryControl. */ }
        part lightControl:LightControl;
        part compute:Compute;
        interface batteryPowerToEnergyPath : IfA010BatteryPower
            connect batteryControl.batteryPower to energyPath.batteryPower;
        interface vehicleElectricalPowerToLightControl : IfA010VehicleElectricalPower
            connect energyPath.vehicleElectricalPowerOut to lightControl.vehicleElectricalPowerIn;
        interface vehicleElectricalPowerToDriverInteraction : IfA010VehicleElectricalPower
            connect energyPath.vehicleElectricalPowerOut to driverInteraction.vehicleElectricalPowerIn;
        interface vehicleElectricalPowerToCompute : IfA010VehicleElectricalPower
            connect energyPath.vehicleElectricalPowerOut to compute.vehicleElectricalPowerIn;
        interface controllerWakeToCompute : IfA006ControllerWake
            connect driverInteraction.controllerWakeOut to compute.controllerWakeIn;
        interface vehicleOperationRequestToRidingControl : IfA006VehicleOperationRequest
            connect driverInteraction.vehicleOperationRequestOut to ridingControl.vehicleOperationRequestIn;
        interface computeRuntimeInitializationToRidingControl : IfA006ComputeRuntimeInitialization
            connect compute.runtimeInitializationOut to ridingControl.runtimeInitializationIn;
        interface ridingControlSleepRequestToCompute : IfA006ComputeSleepRequest
            connect ridingControl.sleepRequestOut to compute.sleepRequestIn;
        interface tractionPowerToTraction : IfA010TractionElectricalPower
            connect energyPath.tractionElectricalPower to traction.tractionElectricalPower;
        interface motorPositionToPlatform : IfA005MotorPosition
            connect traction.motorPositionOut to compute.platform.motorPositionIn;
        interface motorPositionToRidingControl : IfA005MotorPosition
            connect traction.motorPositionOut to ridingControl.motorPositionIn;
        interface brakeToRidingControl : IfA001BrakeLeverState
            connect driverInteraction.brakeLeverStateOut to ridingControl.brakeLeverStateIn;
        interface brakeToLightControl : IfA001BrakeLeverState
            connect driverInteraction.brakeLeverStateOut to lightControl.brakeLeverStateIn;
        interface brakeHealthToPlatform : IfA008BrakeHealth
            connect driverInteraction.brakeHealthOut to compute.platform.brakeHealthIn;
        interface acceleratorToRidingControl : IfA001AcceleratorPosition
            connect driverInteraction.acceleratorPositionOut to ridingControl.acceleratorPositionIn;
        interface acceleratorHealthToPlatform : IfA008AcceleratorHealth
            connect driverInteraction.acceleratorHealthOut to compute.platform.acceleratorHealthIn;
        interface settingsToRidingControl : IfA002RiderSettingsRequest
            connect driverInteraction.ridingSettingsOut to ridingControl.hmiRiderSettingsRequestIn;
        interface selectedFaultToDriverInteraction : IfA006SelectedFaultIndication
            connect ridingControl.selectedFaultIndicationOut to driverInteraction.selectedFaultIn;
        interface ridingAuthorityToTraction : X2CityContract_RidingControl::IfA004RidingAuthority
            connect ridingControl.ridingAuthorityOut to traction.ridingAuthorityIn;
        interface wheelTorqueCommandToTraction : X2CityContract_RidingControl::IfA004WheelTorqueCommand
            connect ridingControl.wheelTorqueCommandOut to traction.wheelTorqueCommandIn;
        interface normalLightToLightControl : IfA006NormalLightRequest
            connect driverInteraction.runningLightStateOut to lightControl.runningLightStateIn;
        interface stateOfChargeToDriverInteraction : IfA003BatteryStateOfCharge
            connect batteryControl.stateOfChargeOut to driverInteraction.stateOfChargeIn;
        interface batteryCurrentToDriverInteraction : IfA003BatteryCurrent
            connect batteryControl.batteryCurrentOut to driverInteraction.batteryCurrentIn;
        interface vehicleMotionToDriverInteraction : IfA005QualifiedVehicleMotion
            connect traction.qualifiedVehicleMotionOut to driverInteraction.vehicleMotionIn;
        interface vehicleMotionToRidingControl : X2CityContract_MotorControl::IfA005QualifiedVehicleMotion
            connect traction.qualifiedVehicleMotionOut to ridingControl.qualifiedVehicleMotionIn;
        interface temperatureToRidingControl : IfA008QualifiedTemperature
            connect traction.qualifiedTemperatureOut to ridingControl.qualifiedTemperatureIn;
        interface temperatureToPlatform : IfA008QualifiedTemperature
            connect traction.qualifiedTemperatureOut to compute.platform.qualifiedTemperatureIn;
        interface fastDcLinkVoltageToPlatform : IfA008FastDcLinkVoltage
            connect traction.fastDcLinkVoltageOut to compute.platform.fastDcLinkVoltageIn;
        interface tractionConditionToRidingControl : IfA005TractionConditionEvidence
            connect traction.tractionConditionEvidenceOut to ridingControl.tractionConditionEvidenceIn;
        interface actualTractionOutputToRidingControl : IfA005ActualTractionOutput
            connect traction.actualTractionOutputOut to ridingControl.actualTractionOutputIn;
        interface batteryReadinessToRidingControl : IfA003BatteryReadinessAndFault
            connect batteryControl.batteryReadinessAndFaultOut to ridingControl.batteryReadinessAndFaultIn;
        interface batteryLimitsToRidingControl : IfA003BatteryOperatingLimits
            connect batteryControl.batteryOperatingLimitsOut to ridingControl.batteryOperatingLimitsIn;
        interface stateOfChargeToRidingControl : IfA003BatteryStateOfCharge
            connect batteryControl.stateOfChargeOut to ridingControl.stateOfChargeIn;
    }
}
