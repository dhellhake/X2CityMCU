package X2CityContract_SessionPolicy {
    private import X2CitySharedContracts::*;
    item def RidingAuthority:>QualifiedInformationRecord { attribute expiry:Expiry; }
    port def RidingAuthorityOutputPort {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        out item payload:RidingAuthority;
    }
    port def RidingAuthorityInputPort {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        in item payload:RidingAuthority;
    }
    interface def IfA004RidingAuthority { end producer:RidingAuthorityOutputPort; end consumer:RidingAuthorityInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_SessionPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_HmiAdapter::*;
    private import X2CityContract_SessionPolicy::*;
    part def SessionPolicy { // LE-SESSION
        /* Evaluates qualified accelerator position/rest, coded brake, vehicle motion, settings, battery capability, and observed outputs into riding authority and rider information while leaving traction actuation to Traction. */
        port qualifiedBrakeInputIn:BrakeStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port inputRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port batteryCapabilityEnvelopeIn:BatteryCapabilityEnvelopeInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port ridingAuthorityOut:RidingAuthorityOutputPort;
        port riderStatusInformationOut:RiderStatusInformationOutputPort;
    }
}
