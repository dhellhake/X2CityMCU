package X2CityComponent_ElectricalPropulsionControlSystem {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RidingSupervisor::*;
    private import X2CityComponent_Input::*;
    private import X2CityComponent_Traction::*;
    private import X2CityComponent_Energy::*;
    private import X2CityComponent_LightControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityComponent_Compute::*;
    part def ElectricalPropulsionControlSystem { // LE-EPCS
        /* Composes the vehicle riding, input, traction, energy, lighting and compute logical components. */
        part riding:RidingSupervisor;
        part input:Input;
        part traction:Traction;
        part energy:Energy;
        part lightControl:LightControl;
        part compute:Compute;
        interface vehicleElectricalPowerToLightControl : IfA010VehicleElectricalPower
            connect energy.vehicleElectricalPowerOut to lightControl.vehicleElectricalPowerIn;
    }
}
