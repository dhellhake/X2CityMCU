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
    }
}
