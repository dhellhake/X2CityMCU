package X2CityContract_DemandPolicy {
    private import X2CitySharedContracts::*;
    item def SignedWheelTorqueCommand:>ContextualInformation { attribute expiry:Expiry; }
    port def TorqueCommandOut { out item payload:SignedWheelTorqueCommand; }
    port def TorqueCommandIn { in item payload:SignedWheelTorqueCommand; }
    interface def IfA004TorqueCommand { end producer:TorqueCommandOut; end consumer:TorqueCommandIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_DemandPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_ServiceInformation::*;
    part def DemandPolicy { // LE-DEMAND
        /* Evaluates qualified rider motion, settings, battery capability, and observed outputs into a signed wheel-torque command. It publishes the demand decision and service configuration; traction actuation remains in the traction boundary. */
        port riderMotionIn:QualifiedRiderMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port capabilityIn:BatteryCapabilityIn;
        port tractionOutputIn:ActualOutputIn;
        port inputOutputIn:ActualOutputIn;
        port torqueCommandOut:TorqueCommandOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
