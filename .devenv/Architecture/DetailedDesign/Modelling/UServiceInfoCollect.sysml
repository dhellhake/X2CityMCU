package X2CityDetailedUnit_ServiceInfoCollect {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedUnit_PlatformContext::*;
    // Owner: SC-SERVICE-INFO.V; DD-002; SW-I-008/009. Preserves source provenance and has no control return.
    item def ServiceCollectedRecord :> UnitInformationEnvelope;
    port def ProducerRecordIn { in item payload:ContextualSoftwareInformation; }
    port def PlatformContextIn { in item payload:PlatformContextRecord; }
    port def ServiceCollectedOut { out item payload:ServiceCollectedRecord; }
    part def UServiceInfoCollect {
        /* Collects current producer-tagged records and platform context into a source-aware service collection. It withdraws old-context entries and never converts missing data into a permission or fallback fact. */
        port producerRecordIn:ProducerRecordIn; port contextIn:PlatformContextIn; port collectedOut:ServiceCollectedOut; }
}
