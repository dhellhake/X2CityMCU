package X2CityDetailedUnit_HmiAdapter {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-HMI.V; DD-001; UR-HMI-001; SW-I-002/006. Supplied VD18MT remains opaque.
    item def HmiSettingsRecord :> UnitInformationEnvelope;
    item def HmiLightRecord :> UnitInformationEnvelope;
    item def HmiReportRecord :> UnitInformationEnvelope;
    port def HmiSettingsOut { out item payload:HmiSettingsRecord; }
    port def HmiLightOut { out item payload:HmiLightRecord; }
    port def HmiReportIn { in item payload:HmiReportRecord; }
    part def UHmiAdapter {
        /* Interprets qualified VD18MT settings/light input and forms outgoing HMI-related reports. It owns transport/parser observations and link-loss handling, while retaining no authority to grant operation. */
        port settingsOut:HmiSettingsOut; port lightOut:HmiLightOut; port reportIn:HmiReportIn; }
}
