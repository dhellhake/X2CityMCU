package X2CityDetailedUnit_ServiceInfoCollect {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedUnit_PlatformContext::*;
    // Owner: SC-SERVICE-INFO.V; DD-002; SW-I-008/009. Preserves source provenance and has no control return.
    item def ServiceCollectedRecord :> UnitInformationEnvelope;
    port def ProducerRecordInputPort {
        doc /* Receives source-tagged diagnostic and policy records for service collection without changing their availability or converting them into control permission. */
        in item payload:ContextualSoftwareInformation;
    }
    port def PlatformContextInputPort {
        doc /* Receives the current platform context used to remove stale-source entries from the service collection. */
        in item payload:PlatformContextRecord;
    }
    port def ServiceCollectedOutputPort {
        doc /* Sends the source-aware current collection to snapshot formation; missing records remain missing rather than being replaced with a fallback. */
        out item payload:ServiceCollectedRecord;
    }
    part def ServiceRecordCollector {
        /* Collects current producer-tagged records and platform context into a source-aware service collection. It withdraws old-context entries and never converts missing data into a permission or fallback fact. */
        port producerRecordIn:ProducerRecordInputPort; port contextIn:PlatformContextInputPort; port collectedOut:ServiceCollectedOutputPort; }
}
