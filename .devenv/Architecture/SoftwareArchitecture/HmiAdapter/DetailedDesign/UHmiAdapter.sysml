package X2CityDetailedUnit_HmiAdapter {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    // Owner: SC-HMI.V; DD-001; UR-HMI-001; SW-I-002/006. Supplied VD18MT remains opaque.
    item def HmiSettingsRecord :> UnitInformationEnvelope;
    item def HmiLightRecord :> UnitInformationEnvelope;
    item def HmiReportRecord :> UnitInformationEnvelope;
    port def HmiSettingsOutputPort {
        doc /* Publishes qualified VD18MT setting receipts to U-SET-STATE, preserving receipt provenance so retained active settings are not mistaken for new requests. */
        out item payload:HmiSettingsRecord;
    }
    port def HmiLightOutputPort {
        doc /* Publishes the qualified VD18MT normal-light request to U-LIGHT-MODE; link loss does not fabricate a new normal request. */
        out item payload:HmiLightRecord;
    }
    // Session report and battery presentation retain their source-specific record identities.
    port def HmiReportInputPort {
        doc /* Receives source-specific Session and Battery presentation records for VD18MT report formation without coercing either into a generic control state. */
        in item payload:ContextualSoftwareInformation;
    }
    part def HmiAdapterUnit {
        /* Interprets qualified VD18MT settings/light input and forms outgoing HMI-related reports. It owns transport/parser observations and link-loss handling, while retaining no authority to grant operation. */
        port executionTimeIn:ExecutionTimeInputPort; port settingsOut:HmiSettingsOutputPort; port lightOut:HmiLightOutputPort; port reportIn:HmiReportInputPort; }
}
