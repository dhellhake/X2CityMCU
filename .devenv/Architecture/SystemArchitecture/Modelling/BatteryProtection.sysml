package X2CityContract_BatteryProtection {
    private import X2CitySharedContracts::*;
    item def BatteryConditionObservation:>QualifiedInformationRecord;
    item def BatteryCapabilityEnvelope:>QualifiedInformationRecord;
    port def BatteryConditionObservationOutputPort {
        doc /* Carries battery and traction condition observations assembled by Input from the BMS/energy and traction paths to BatteryProtection. These records remain qualified observations; they do not contain the resulting charge or discharge envelope. */
        out item payload:BatteryConditionObservation;
    }
    port def BatteryConditionObservationInputPort {
        doc /* Carries battery and traction condition observations assembled by Input from the BMS/energy and traction paths to BatteryProtection. These records remain qualified observations; they do not contain the resulting charge or discharge envelope. */
        in item payload:BatteryConditionObservation;
    }
    port def BatteryCapabilityEnvelopeOutputPort {
        doc /* Carries BatteryProtection's separate positive-discharge and negative-charge capability envelope and protection status to SessionPolicy and DemandPolicy. Each policy applies the relevant qualified sign branch as a constraint on its decision. */
        out item payload:BatteryCapabilityEnvelope;
    }
    port def BatteryCapabilityEnvelopeInputPort {
        doc /* Carries BatteryProtection's separate positive-discharge and negative-charge capability envelope and protection status to SessionPolicy and DemandPolicy. Each policy applies the relevant qualified sign branch as a constraint on its decision. */
        in item payload:BatteryCapabilityEnvelope;
    }
    interface def IfA003BatteryConditionObservation { end producer:BatteryConditionObservationOutputPort; end consumer:BatteryConditionObservationInputPort; flow producer.payload to consumer.payload; }
    interface def IfA003BatteryCapabilityEnvelope { end producer:BatteryCapabilityEnvelopeOutputPort; end consumer:BatteryCapabilityEnvelopeInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_BatteryProtection {
    private import X2CitySharedContracts::*;
    private import X2CityContract_BatteryProtection::*;
    part def BatteryProtection { // LE-BAT-POLICY
        /* Assesses battery observations for the distinct positive-discharge and negative-charge
           envelope, restrictions, and protection/fault status used by riding policies. */
        port batteryConditionObservationIn:BatteryConditionObservationInputPort;
        port batteryCapabilityEnvelopeOut:BatteryCapabilityEnvelopeOutputPort;
    }
}
