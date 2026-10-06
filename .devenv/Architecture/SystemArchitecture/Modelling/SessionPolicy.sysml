package X2CityContract_SessionPolicy {
    private import X2CitySharedContracts::*;
    item def RidingAuthority:>QualifiedInformationRecord { attribute expiry:Expiry; }
    item def SelectedFaultIndication:>QualifiedInformationRecord {
        doc /* SessionPolicy's selected reportable wire code, including the no-error code. Session owns selection, priority and restart lifetime; HMI only encodes the selected result. */
        attribute selectedWireCode:Integer;
    }
    port def RidingAuthorityOutputPort {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        out item payload:RidingAuthority;
    }
    port def RidingAuthorityInputPort {
        doc /* Carries SessionPolicy's current riding authority and expiry to DemandPolicy and Traction. Consumers use it as an authorization boundary for motion output; the torque command is a separate contract. */
        in item payload:RidingAuthority;
    }
    port def SelectedFaultIndicationOutputPort { out item selectedFaultIndication:SelectedFaultIndication; }
    port def SelectedFaultIndicationInputPort { in item selectedFaultIndication:SelectedFaultIndication; }
    interface def IfA004RidingAuthority { end producer:RidingAuthorityOutputPort; end consumer:RidingAuthorityInputPort; flow producer.payload to consumer.payload; }
    interface def IfA006SelectedFaultIndication { end session:SelectedFaultIndicationOutputPort; end hmi:SelectedFaultIndicationInputPort; flow session.selectedFaultIndication to hmi.selectedFaultIndication; }
}

package X2CityComponent_SessionPolicy {
    private import X2CitySharedContracts::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_Compute::*;
    private import X2CityContract_HmiControl::*;
    part def SessionPolicy { // LE-SESSION
        /* Owns operation lifecycle, Ready/authority, fault/restart policy, riding authority and sole sleep eligibility. A qualified explicit physical Off ends the current operation session immediately, regardless of vehicle motion; Unknown or unavailable is not Off, and HMI UART loss does not change the physical request. A later On, including before sleep entry, starts fresh session qualification rather than restoring prior Ready or authority. Session publishes a qualified current ComputeSleepRequest with its own expiry only when explicit Off and current qualified traction computeSleepPermitted evidence support eligibility; false revokes the grant. This is not physical inhibition evidence. */
        port vehicleOperationRequestIn:VehicleOperationRequestInputPort;
        port runtimeInitializationIn:ComputeRuntimeInitializationInputPort;
        port sleepRequestOut:ComputeSleepRequestOutputPort { doc /* Publishes SessionPolicy's qualified current sleep eligibility grant and its lifetime. A false value revokes/cancels it; qualification, source context and expiry describe this Session grant and are preserved downstream. */ }
        port brakeLeverStateIn:BrakeLeverStateInputPort;
        port qualifiedTemperatureIn:QualifiedTemperatureInputPort { doc /* Receives qualified motor/traction-board temperature observations; Session owns their operating policy. */ }
        port tractionConditionEvidenceIn:TractionConditionEvidenceInputPort { doc /* Receives local traction condition/fault evidence. Session owns the common latch, selection, priority and restart lifetime. */ }
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort;
        port motorPositionIn:MotorPositionInputPort { doc /* Receives estimator Position and Qualification for existing fault supervision. QualifiedVehicleMotion remains the separate standstill/speed evidence. */ }
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort;
        port batteryReadinessAndFaultIn:BatteryReadinessAndFaultInputPort { doc /* Receives BatteryControl startup assessment and separate recognized battery fault categories. */ }
        port stateOfChargeIn:BatteryStateOfChargeInputPort { doc /* Receives qualified actual SOC for low-charge selection. */ }
        port actualTractionOutputIn:ActualTractionInputPort;
        port ridingAuthorityOut:RidingAuthorityOutputPort;
        port selectedFaultIndicationOut:SelectedFaultIndicationOutputPort;
    }
}
