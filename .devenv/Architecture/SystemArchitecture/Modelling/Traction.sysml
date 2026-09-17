package X2CityComponent_Traction {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_MotorControl::*;
    private import X2CityComponent_TractionHardware::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_MotorControl::*;
    part def Traction { // LE-TRACTION
        /* Composes motor control and traction hardware to apply riding authority and torque commands. It publishes actual output and battery observations for policy evaluation while physical actuation remains in the traction boundary. */
        part motorControl:MotorControl;
        part tractionHardware:TractionHardware;
        port authorityIn:RidingAuthorityIn;
        port torqueCommandIn:TorqueCommandIn;
        port batteryObservationOut:BatteryObservationOut;
        port qualifiedMotionOut:QualifiedMotionOut;
        port actualOutputOut:ActualOutputOut;
    }
}
