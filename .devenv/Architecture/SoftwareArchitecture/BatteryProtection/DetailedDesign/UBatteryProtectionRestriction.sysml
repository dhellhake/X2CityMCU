package X2CityDetailedUnit_BatteryProtectionRestriction {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CityDetailedUnit_BatteryProtectionEvaluate::*;
    private import X2CityDetailedUnit_PlatformRetention::*;
    private import X2CitySoftwareContract_BatteryProtection::*;
    private import X2CityDetailedUnit_HmiAdapter::*;
    // Owner: SC-BAT-POLICY.V; DD-002. It owns reached10% restriction and retains no battery-fault history.
    item def BatteryEnvelopeRecord :> BatteryCapabilityEnvelope;
    item def BatteryEnvelopePresentationRecord :> HmiReportRecord;
    port def BatteryEnvelopeCandidateInputPort {
        doc /* Receives evaluated charge/discharge candidates before applying the vehicle reached-10%-SOC restriction and operation context. */
        in item payload:BatteryEnvelopeCandidate;
    }
    port def RetentionCandidateInputPort {
        doc /* Receives the platform retention candidate used only after requalification; it cannot recreate a battery fault history. */
        in item payload:RetentionCandidateRecord;
    }
    port def BatteryEnvelopeOutputPort {
        doc /* Publishes the propulsion and regeneration capability envelope consumed by Demand and other policy consumers, with separate branch reasons and restriction generation. */
        out item payload:BatteryEnvelopeRecord;
    }
    port def BatteryEnvelopePresentationOutputPort {
        doc /* Sends the battery-envelope presentation record to HMI reporting; it is presentation data, not an authority or physical-protection output. */
        out item payload:BatteryEnvelopePresentationRecord;
    }
    part def BatteryCapabilityRestrictor {
        /* Applies operation context to battery envelope candidates and publishes propulsion and regeneration consequences. Vehicle scope owns the reached10% restriction until qualified actual SOC exceeds 20%; retention is accepted only after requalification, and this unit does not provide physical protection. */
        port executionTimeIn:ExecutionTimeInputPort; port candidateIn:BatteryEnvelopeCandidateInputPort; port retentionCandidateIn:RetentionCandidateInputPort; port envelopeOut:BatteryEnvelopeOutputPort; port presentationOut:BatteryEnvelopePresentationOutputPort; }
}
