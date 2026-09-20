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
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort;
        port actualTractionOutputOut:ActualTractionOutputPort;
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort { doc /* Publishes MotorControl's qualified actual electrical-braking projection for LightControl. */ }
        // Delegates the existing logical traction boundary to its sole MotorControl occurrence.
        // Battery observation ownership remains at Traction and is not changed by this pilot.
        flow ridingAuthorityToMotorControl from ridingAuthorityIn.payload to motorControl.ridingAuthorityIn.payload;
        flow wheelTorqueCommandToMotorControl from wheelTorqueCommandIn.payload to motorControl.wheelTorqueCommandIn.payload;
        flow qualifiedMotionFromMotorControl from motorControl.qualifiedVehicleMotionOut.payload to qualifiedVehicleMotionOut.payload;
        flow actualOutputFromMotorControl from motorControl.actualTractionOutputOut.payload to actualTractionOutputOut.payload;
        flow electricalBrakingFromMotorControl from motorControl.electricalBrakingStateOut.payload to electricalBrakingStateOut.payload;
    }
}
