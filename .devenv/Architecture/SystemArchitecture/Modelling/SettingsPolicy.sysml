package X2CityContract_SettingsPolicy {
    private import X2CitySharedContracts::*;
    item def SettingsInformation:>ContextualInformation;
    port def SettingsOut {
        doc /* Carries owner-qualified rider settings requests from HMI or Input to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        out item payload:SettingsInformation;
    }
    port def SettingsIn {
        doc /* Carries owner-qualified rider settings requests from HMI or Input to SettingsPolicy and SessionPolicy. The request is raw policy input and is not proof of pending or active state; DemandPolicy consumes the separate active projection. */
        in item payload:SettingsInformation;
    }
    interface def IfA002Settings { end producer:SettingsOut; end consumer:SettingsIn; flow producer.payload to consumer.payload; }
    // Only this projection is consumable by demand policy; request and pending state remain here.
    item def ActiveSettingsInformation:>SettingsInformation;
    port def ActiveSettingsOut {
        doc /* Carries SettingsPolicy's resolved active riding level and speed projection to DemandPolicy. Only applied active state crosses this contract; requested or pending values cannot drive demand. */
        out item payload:ActiveSettingsInformation;
    }
    port def ActiveSettingsIn {
        doc /* Carries SettingsPolicy's resolved active riding level and speed projection to DemandPolicy. Only applied active state crosses this contract; requested or pending values cannot drive demand. */
        in item payload:ActiveSettingsInformation;
    }
    interface def IfA002ActiveSettings { end producer:ActiveSettingsOut; end consumer:ActiveSettingsIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_SettingsPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_ServiceInformation::*;
    part def SettingsPolicy { // LE-SET
        /* Evaluates qualified rider facts, traction-owned motion, and settings from HMI and input.
           It retains requested and pending state, and publishes the active settings projection. */
        port riderMotionIn:QualifiedRiderMotionIn;
        port qualifiedMotionIn:QualifiedMotionIn;
        port hmiSettingsIn:SettingsIn;
        port inputSettingsIn:SettingsIn;
        port activeSettingsOut:ActiveSettingsOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
