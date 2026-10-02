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
    private import X2CityContract_Input::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_SessionPolicy::*;
    part def SessionPolicy { // LE-SESSION
        /* Evaluates qualified accelerator position/rest, mechanical-brake state, vehicle motion, estimator Position/Qualification fault evidence, settings, BatteryControl readiness/fault evidence and actual SOC, and observed outputs into riding authority and rider information while leaving traction actuation to Traction. */
        port brakeLeverStateIn:BrakeLeverStateInputPort;
        port qualifiedTemperatureIn:QualifiedTemperatureInputPort { doc /* Receives qualified motor/traction-board temperature observations; Session owns their operating policy. */ }
        port temperatureHealthIn:TemperatureHealthInputPort;
        port regularSupplyVoltageIn:RegularSupplyVoltageInputPort { doc /* Receives qualified regular GVDD observation; Session owns its operating policy. */ }
        port supplyHealthIn:SupplyHealthInputPort;
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
