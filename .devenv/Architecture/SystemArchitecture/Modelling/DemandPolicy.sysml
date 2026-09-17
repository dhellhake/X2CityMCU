package X2CityContract_DemandPolicy {
    private import X2CitySharedContracts::*;
    item def SignedWheelTorqueCommand:>ContextualInformation { attribute expiry:Expiry; }
    port def TorqueCommandOut {
        doc /* Carries DemandPolicy's signed wheel-torque request and expiry to Traction. It is a demand boundary only; SessionPolicy authority remains an independent authorization input. */
        out item payload:SignedWheelTorqueCommand;
    }
    port def TorqueCommandIn {
        doc /* Carries DemandPolicy's signed wheel-torque request and expiry to Traction. It is a demand boundary only; SessionPolicy authority remains an independent authorization input. */
        in item payload:SignedWheelTorqueCommand;
    }
    interface def IfA004TorqueCommand { end producer:TorqueCommandOut; end consumer:TorqueCommandIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_DemandPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_ServiceInformation::*;
    item def DemandPolicyDiagnosticInformation:>ServiceConfigurationInformation;
    port def DemandPolicyDiagnosticOut {
        doc /* Carries DemandPolicy's read-only policy status and diagnostic observations to ServiceInformation. It supports service reporting only and cannot authorize, refresh or command traction. */
        out item payload:DemandPolicyDiagnosticInformation;
    }
    interface def IfA008DemandPolicyDiagnostic { end producer:DemandPolicyDiagnosticOut; end consumer:ServiceConfigurationIn; flow producer.payload to consumer.payload; }
    part def DemandPolicy { // LE-DEMAND
        /* Arbitrates qualified rider facts, traction-owned motion and actual-output feedback,
           active settings, current riding authority, and the battery envelope into a signed
           wheel-torque command. It has no traction actuation authority. */
        port qualifiedRiderMotionIn:QualifiedRiderMotionIn;
        port qualifiedMotionIn:QualifiedMotionIn;
        port activeSettingsIn:ActiveSettingsIn;
        port ridingAuthorityIn:RidingAuthorityIn;
        port batteryEnvelopeIn:BatteryEnvelopeIn;
        port actualOutputIn:ActualOutputIn;
        port torqueCommandOut:TorqueCommandOut;
        // Current policy-status/diagnostic information is read-only and goes only to service information.
        port demandPolicyDiagnosticOut:DemandPolicyDiagnosticOut;
    }
}
