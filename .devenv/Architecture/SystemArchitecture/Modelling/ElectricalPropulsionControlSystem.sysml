package X2CityComponent_ElectricalPropulsionControlSystem {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RidingSupervisor::*;
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
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    part def ElectricalPropulsionControlSystem { // LE-EPCS
        /* Composes riding policy, rider interaction, traction-owned measurement/qualification, battery, energy, lighting and compute components. */
        part riding:RidingSupervisor;
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
        interface vehicleOperationRequestToSession : IfA006VehicleOperationRequest
            connect driverInteraction.vehicleOperationRequestOut to riding.session.vehicleOperationRequestIn;
        interface computeRuntimeInitializationToSession : IfA006ComputeRuntimeInitialization
            connect compute.runtimeInitializationOut to riding.session.runtimeInitializationIn;
        interface sessionSleepRequestToCompute : IfA006ComputeSleepRequest
            connect riding.session.sleepRequestOut to compute.sleepRequestIn;
        interface tractionPowerToTraction : IfA010TractionElectricalPower
            connect energyPath.tractionElectricalPower to traction.tractionElectricalPower;
        interface motorPositionToPlatform : IfA005MotorPosition
            connect traction.motorPositionOut to compute.platform.motorPositionIn;
        interface motorPositionToSession : IfA005MotorPosition
            connect traction.motorPositionOut to riding.session.motorPositionIn;
        interface brakeToSession : IfA001BrakeLeverState
            connect driverInteraction.brakeLeverStateOut to riding.session.brakeLeverStateIn;
        interface brakeToDemand : IfA001BrakeLeverState
            connect driverInteraction.brakeLeverStateOut to riding.demand.brakeLeverStateIn;
        interface brakeToLightControl : IfA001BrakeLeverState
            connect driverInteraction.brakeLeverStateOut to lightControl.brakeLeverStateIn;
        interface brakeHealthToPlatform : IfA008BrakeHealth
            connect driverInteraction.brakeHealthOut to compute.platform.brakeHealthIn;
        interface acceleratorToSettings : IfA001AcceleratorPosition
            connect driverInteraction.acceleratorPositionOut to riding.settings.acceleratorPositionIn;
        interface acceleratorToSession : IfA001AcceleratorPosition
            connect driverInteraction.acceleratorPositionOut to riding.session.acceleratorPositionIn;
        interface acceleratorToDemand : IfA001AcceleratorPosition
            connect driverInteraction.acceleratorPositionOut to riding.demand.acceleratorPositionIn;
        interface acceleratorHealthToPlatform : IfA008AcceleratorHealth
            connect driverInteraction.acceleratorHealthOut to compute.platform.acceleratorHealthIn;
        interface settingsToSettingsPolicy : IfA002RiderSettingsRequest
            connect driverInteraction.ridingSettingsOut to riding.settings.hmiRiderSettingsRequestIn;
        interface settingsToSession : IfA002RiderSettingsRequest
            connect driverInteraction.ridingSettingsOut to riding.session.hmiRiderSettingsRequestIn;
        interface selectedFaultToDriverInteraction : IfA006SelectedFaultIndication
            connect riding.session.selectedFaultIndicationOut to driverInteraction.selectedFaultIn;
        interface normalLightToLightControl : IfA006NormalLightRequest
            connect driverInteraction.runningLightStateOut to lightControl.runningLightStateIn;
        interface stateOfChargeToDriverInteraction : IfA003BatteryStateOfCharge
            connect batteryControl.stateOfChargeOut to driverInteraction.stateOfChargeIn;
        interface batteryCurrentToDriverInteraction : IfA003BatteryCurrent
            connect batteryControl.batteryCurrentOut to driverInteraction.batteryCurrentIn;
        interface vehicleMotionToDriverInteraction : IfA005QualifiedVehicleMotion
            connect traction.qualifiedVehicleMotionOut to driverInteraction.vehicleMotionIn;
        interface temperatureToSession : IfA008QualifiedTemperature
            connect traction.qualifiedTemperatureOut to riding.session.qualifiedTemperatureIn;
        interface temperatureToPlatform : IfA008QualifiedTemperature
            connect traction.qualifiedTemperatureOut to compute.platform.qualifiedTemperatureIn;
        interface fastDcLinkVoltageToPlatform : IfA008FastDcLinkVoltage
            connect traction.fastDcLinkVoltageOut to compute.platform.fastDcLinkVoltageIn;
        interface tractionConditionToSession : IfA005TractionConditionEvidence
            connect traction.tractionConditionEvidenceOut to riding.session.tractionConditionEvidenceIn;
    }
}
