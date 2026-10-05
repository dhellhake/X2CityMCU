package X2CityComponent_ElectricalPropulsionControlSystem {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RidingSupervisor::*;
    private import X2CityComponent_HmiControl::*;
    private import X2CityComponent_HmiElectricalInterface::*;
    private import X2CityContract_HmiElectricalInterface::*;
    private import X2CityComponent_Input::*;
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
    private import X2CityContract_ComputeHardware::*;
    part def ElectricalPropulsionControlSystem { // LE-EPCS
        /* Composes riding policy, rider interaction, traction-owned measurement/qualification, battery, energy, lighting and compute components. */
        part riding:RidingSupervisor;
        part hmiControl:HMIControl;
        part input:Input;
        part traction:Traction;
        part batteryControl:BatteryControl { doc /* Removable pack and vehicle-host battery supervision composite. */ }
        part energyPath:EnergyPath { doc /* General vehicle electrical-power distribution sibling of BatteryControl. */ }
        part lightControl:LightControl;
        part compute:Compute;
        interface batteryPowerToEnergyPath : IfA010BatteryPower
            connect batteryControl.batteryPower to energyPath.batteryPower;
        interface vehicleElectricalPowerToLightControl : IfA010VehicleElectricalPower
            connect energyPath.vehicleElectricalPowerOut to lightControl.vehicleElectricalPowerIn;
        interface vehicleElectricalPowerToHmi : IfA010VehicleElectricalPower
            connect energyPath.vehicleElectricalPowerOut to hmiControl.vehicleElectricalPowerIn;
        interface vd18mtDeviceConnection : IfA006HmiDeviceConnection
            connect hmiControl.vd18mtConnection to input.riderDevices.vd18mtConnection;
        interface controllerWakeToCompute : IfA006ControllerWake
            connect hmiControl.controllerWakeOut to compute.controllerWakeIn;
        interface tractionPowerToTraction : IfA010TractionElectricalPower
            connect energyPath.tractionElectricalPower to traction.tractionElectricalPower;
        interface motorPositionToPlatform : IfA005MotorPosition
            connect traction.motorPositionOut to compute.platform.motorPositionIn;
        interface motorPositionToSession : IfA005MotorPosition
            connect traction.motorPositionOut to riding.session.motorPositionIn;
        interface brakeToSession : IfA001BrakeLeverState
            connect input.brakeLeverStateOut to riding.session.brakeLeverStateIn;
        interface brakeToDemand : IfA001BrakeLeverState
            connect input.brakeLeverStateOut to riding.demand.brakeLeverStateIn;
        interface brakeToLightControl : IfA001BrakeLeverState
            connect input.brakeLeverStateOut to lightControl.brakeLeverStateIn;
        interface brakeHealthToPlatform : IfA008BrakeHealth
            connect input.brakeHealthOut to compute.platform.brakeHealthIn;
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
