package X2CityContract_BatteryProtection {
    private import X2CitySharedContracts::*;
    item def BatteryObservationInformation:>ContextualInformation;
    item def BatteryEnvelopeInformation:>ContextualInformation;
    port def BatteryObservationOut {
        doc /* Carries battery and traction condition observations assembled by Input from the BMS/energy and traction paths to BatteryProtection. These records remain qualified observations; they do not contain the resulting charge or discharge envelope. */
        out item payload:BatteryObservationInformation;
    }
    port def BatteryObservationIn {
        doc /* Carries battery and traction condition observations assembled by Input from the BMS/energy and traction paths to BatteryProtection. These records remain qualified observations; they do not contain the resulting charge or discharge envelope. */
        in item payload:BatteryObservationInformation;
    }
    port def BatteryEnvelopeOut {
        doc /* Carries BatteryProtection's separate positive-discharge and negative-charge capability envelope and protection status to SessionPolicy and DemandPolicy. Each policy applies the relevant qualified sign branch as a constraint on its decision. */
        out item payload:BatteryEnvelopeInformation;
    }
    port def BatteryEnvelopeIn {
        doc /* Carries BatteryProtection's separate positive-discharge and negative-charge capability envelope and protection status to SessionPolicy and DemandPolicy. Each policy applies the relevant qualified sign branch as a constraint on its decision. */
        in item payload:BatteryEnvelopeInformation;
    }
    interface def IfA003BatteryObservation { end producer:BatteryObservationOut; end consumer:BatteryObservationIn; flow producer.payload to consumer.payload; }
    interface def IfA003BatteryEnvelope { end producer:BatteryEnvelopeOut; end consumer:BatteryEnvelopeIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_BatteryProtection {
    private import X2CitySharedContracts::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_ServiceInformation::*;
    part def BatteryProtection { // LE-BAT-POLICY
        /* Assesses battery observations for the distinct positive-discharge and negative-charge
           envelope, restrictions, and protection/fault status used by riding policies. */
        port batteryObservationIn:BatteryObservationIn;
        port batteryEnvelopeOut:BatteryEnvelopeOut;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
