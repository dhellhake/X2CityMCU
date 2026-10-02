package X2CityContract_SettingsPolicy {
    private import X2CitySharedContracts::*;
    item def RiderSettingsRequest:>QualifiedInformationRecord {
        doc /* Qualified VD18MT receipt of the concrete requested riding level and requested speed limit. Vehicle control uses its fixed 16-inch basis independently of configurable VD18MT display wheel-size encoding; this request is not active policy. */
        attribute requestedRidingLevel:Integer;
        attribute requestedSpeedLimitKilometresPerHour:Real;
    }
    port def RiderSettingsRequestOutputPort {
        doc /* Carries HMI-qualified rider settings requests to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        out item payload:RiderSettingsRequest;
    }
    port def RiderSettingsRequestInputPort {
        doc /* Receives HMI-qualified rider settings requests. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        in item payload:RiderSettingsRequest;
    }
    interface def IfA002RiderSettingsRequest { end producer:RiderSettingsRequestOutputPort; end consumer:RiderSettingsRequestInputPort; flow producer.payload to consumer.payload; }
    // Only this projection is consumable by demand policy; request and pending state remain here.
    item def ActiveRidingSettings:>QualifiedInformationRecord {
        doc /* SettingsPolicy's already-applied level and speed limit. It is deliberately distinct from a VD18MT request and contains no requested or pending state. */
        attribute activeLevel:String;
        attribute activeSpeedLimitKilometresPerHour:Real;
    }
    port def ActiveRidingSettingsOutputPort {
        doc /* Carries SettingsPolicy's resolved active riding level and speed projection to DemandPolicy. Only applied active state crosses this contract; requested or pending values cannot drive demand. */
        out item payload:ActiveRidingSettings;
    }
    port def ActiveRidingSettingsInputPort {
        doc /* Carries SettingsPolicy's resolved active riding level and speed projection to DemandPolicy. Only applied active state crosses this contract; requested or pending values cannot drive demand. */
        in item payload:ActiveRidingSettings;
    }
    interface def IfA002ActiveRidingSettings { end producer:ActiveRidingSettingsOutputPort; end consumer:ActiveRidingSettingsInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_SettingsPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_SettingsPolicy::*;
    part def SettingsPolicy { // LE-SET
        /* Evaluates qualified accelerator position/rest, traction-owned motion, and settings from HMI.
           It retains requested and pending state, and publishes the active settings projection. */
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port activeRidingSettingsOut:ActiveRidingSettingsOutputPort;
    }
}
