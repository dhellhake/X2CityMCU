package X2CityComponent_ElectricalPropulsionControlSystem {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RidingSupervisor::*;
    private import X2CityComponent_Input::*;
    private import X2CityComponent_Traction::*;
    private import X2CityComponent_BatteryControl::*;
    private import X2CityComponent_EnergyPath::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_LightControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_Input::*;
    private import X2CityComponent_Compute::*;
    part def ElectricalPropulsionControlSystem { // LE-EPCS
        /* Composes vehicle riding, input, traction, the battery composite, separate power distribution, lighting, and compute logical components. */
        part riding:RidingSupervisor;
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
        interface tractionPowerToTraction : IfA010TractionElectricalPower
            connect energyPath.tractionElectricalPower to traction.tractionElectricalPower;
        interface motorPositionHealthToPlatform : IfA005MotorPositionHealth
            connect traction.motorPositionHealthOut to compute.platform.motorPositionHealthIn;
        interface tractionTemperatureToInputHardware : IfA007TemperatureElectricalSignal
            connect traction.tractionHardware.temperatureElectricalSignalOut to input.inputHardware.temperatureElectricalSignalIn;
        interface tractionSupplyToInputHardware : IfA007SupplyElectricalSignal
            connect traction.tractionHardware.supplyElectricalSignalOut to input.inputHardware.supplyElectricalSignalIn;
        interface brakeToSettings : IfA001QualifiedBrakeInput
            connect input.qualifiedBrakeInputOut to riding.settings.qualifiedBrakeInputIn;
        interface brakeToSession : IfA001QualifiedBrakeInput
            connect input.qualifiedBrakeInputOut to riding.session.qualifiedBrakeInputIn;
        interface brakeToDemand : IfA001QualifiedBrakeInput
            connect input.qualifiedBrakeInputOut to riding.demand.qualifiedBrakeInputIn;
        interface brakeToLightControl : IfA001QualifiedBrakeInput
            connect input.qualifiedBrakeInputOut to lightControl.brakeLeverStateIn;
        interface brakeHealthToSession : IfA008BrakeHealth
            connect input.brakeHealthOut to riding.session.brakeHealthIn;
        interface brakeHealthToPlatform : IfA008BrakeHealth
            connect input.brakeHealthOut to compute.platform.brakeHealthIn;
        interface temperatureToSession : IfA008QualifiedTemperature
            connect input.qualifiedTemperatureOut to riding.session.qualifiedTemperatureIn;
        interface temperatureHealthToSession : IfA008TemperatureHealth
            connect input.temperatureHealthOut to riding.session.temperatureHealthIn;
        interface temperatureHealthToPlatform : IfA008TemperatureHealth
            connect input.temperatureHealthOut to compute.platform.temperatureHealthIn;
        interface fastDcLinkVoltageToTraction : IfA008FastDcLinkVoltage
            connect input.fastDcLinkVoltageOut to traction.fastDcLinkVoltageIn;
        interface regularSupplyVoltageToSession : IfA008RegularSupplyVoltage
            connect input.regularSupplyVoltageOut to riding.session.regularSupplyVoltageIn;
        interface supplyHealthToSession : IfA008SupplyHealth
            connect input.supplyHealthOut to riding.session.supplyHealthIn;
        interface supplyHealthToPlatform : IfA008SupplyHealth
            connect input.supplyHealthOut to compute.platform.supplyHealthIn;
        interface supplyHealthToTraction : IfA008SupplyHealth
            connect input.supplyHealthOut to traction.supplyHealthIn;
    }
}
