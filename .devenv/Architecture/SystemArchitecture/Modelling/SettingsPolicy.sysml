package X2CityContract_SettingsPolicy {
    private import X2CitySharedContracts::*;
    item def RiderSettingsRequest:>QualifiedInformationRecord;
    port def RiderSettingsRequestOutputPort {
        doc /* Carries owner-qualified rider settings requests from HMI or Input to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        out item payload:RiderSettingsRequest;
    }
    port def RiderSettingsRequestInputPort {
        doc /* Carries owner-qualified rider settings requests from HMI or Input to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        in item payload:RiderSettingsRequest;
    }
    interface def IfA002RiderSettingsRequest { end producer:RiderSettingsRequestOutputPort; end consumer:RiderSettingsRequestInputPort; flow producer.payload to consumer.payload; }
    // Only this projection is consumable by demand policy; request and pending state remain here.
    item def ActiveRidingSettings:>RiderSettingsRequest;
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
    private import X2CityContract_Input::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_ServiceInformation::*;
    part def SettingsPolicy { // LE-SET
        /* Evaluates qualified accelerator position/rest, coded brake, traction-owned motion, and settings from HMI and input.
           It retains requested and pending state, and publishes the active settings projection. */
        port qualifiedBrakeInputIn:BrakeStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port inputRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port activeRidingSettingsOut:ActiveRidingSettingsOutputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }
}
