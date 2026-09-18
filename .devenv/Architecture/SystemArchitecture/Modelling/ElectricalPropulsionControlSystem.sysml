package X2CityComponent_ElectricalPropulsionControlSystem {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RidingSupervisor::*;
    private import X2CityComponent_Input::*;
    private import X2CityComponent_Traction::*;
    private import X2CityComponent_Energy::*;
    private import X2CityComponent_Auxiliary::*;
    private import X2CityComponent_Compute::*;
    part def ElectricalPropulsionControlSystem { // LE-EPCS
        /* Composes the vehicle riding, input, traction, energy, auxiliary and compute logical components. */
        part riding:RidingSupervisor;
        part input:Input;
        part traction:Traction;
        part energy:Energy;
        part auxiliary:Auxiliary;
        part compute:Compute;
    }
}
