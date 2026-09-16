package X2CityContract_BatteryProtection {
    private import X2CitySharedContracts::*;
    item def BatteryObservationInformation:>ContextualInformation;
    item def BatteryCapabilityStatus:>ContextualInformation;
    port def BatteryObservationOut { out item payload:BatteryObservationInformation; }
    port def BatteryObservationIn { in item payload:BatteryObservationInformation; }
    port def BatteryCapabilityOut { out item payload:BatteryCapabilityStatus; }
    port def BatteryCapabilityIn { in item payload:BatteryCapabilityStatus; }
    interface def IfA003BatteryObservation { end producer:BatteryObservationOut; end consumer:BatteryObservationIn; flow producer.payload to consumer.payload; }
    interface def IfA003BatteryCapability { end producer:BatteryCapabilityOut; end consumer:BatteryCapabilityIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_BatteryProtection {
    private import X2CitySharedContracts::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_ServiceInformation::*;
    part def BatteryProtection { // LE-BAT-POLICY
        /* Assesses battery observations for capability, operating restrictions, and protection/fault status used by vehicle riding policies. It publishes capability/status and service information while leaving physical protection actuation to supplied energy hardware. */
        port batteryObservationIn:BatteryObservationIn;
        port capabilityOut:BatteryCapabilityOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
