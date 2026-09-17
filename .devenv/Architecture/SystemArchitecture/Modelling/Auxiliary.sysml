package X2CityComponent_Auxiliary {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_LightPolicy::*;
    private import X2CityComponent_AuxiliaryPower::*;
    private import X2CityComponent_LampHardware::*;
    private import X2CityContract_LightPolicy::*;
    part def Auxiliary { // LE-AUX
        /* Coordinates lighting intent, auxiliary power, and lamp hardware. It evaluates rider, traction, and HMI/input context through LightPolicy and provides the resulting light intent to the actuation boundary. */
        part lightPolicy:LightPolicy;
        part auxiliaryPower:AuxiliaryPower;
        part lampHardware:LampHardware;
        port lightActuationIntentIn:LightActuationIntentInputPort;
    }
}
