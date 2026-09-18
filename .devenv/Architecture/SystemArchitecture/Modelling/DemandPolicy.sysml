package X2CityContract_DemandPolicy {
    private import X2CitySharedContracts::*;
    item def SignedWheelTorqueRequest:>QualifiedInformationRecord { attribute expiry:Expiry; }
    port def WheelTorqueCommandOutputPort {
        doc /* Carries DemandPolicy's signed wheel-torque request and expiry to Traction. It is a demand boundary only; SessionPolicy authority remains an independent authorization input. */
        out item payload:SignedWheelTorqueRequest;
    }
    port def WheelTorqueCommandInputPort {
        doc /* Carries DemandPolicy's signed wheel-torque request and expiry to Traction. It is a demand boundary only; SessionPolicy authority remains an independent authorization input. */
        in item payload:SignedWheelTorqueRequest;
    }
    interface def IfA004WheelTorqueCommand { end producer:WheelTorqueCommandOutputPort; end consumer:WheelTorqueCommandInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_DemandPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_DemandPolicy::*;
    part def DemandPolicy { // LE-DEMAND
        /* Arbitrates qualified accelerator position/rest and coded-brake inputs, traction-owned vehicle motion and actual-output feedback,
           active settings, current riding authority, and the battery envelope into a signed
           wheel-torque command. It has no traction actuation authority. */
        port qualifiedBrakeInputIn:BrakeStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port activeRidingSettingsIn:ActiveRidingSettingsInputPort;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port batteryCapabilityEnvelopeIn:BatteryCapabilityEnvelopeInputPort;
        port actualTractionOutputIn:ActualTractionInputPort;
        port wheelTorqueCommandOut:WheelTorqueCommandOutputPort;
    }
}
