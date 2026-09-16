package X2CityDetailedUnit_SetState {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-SET; DD-001; UR-SET-001; SW-I-001/002.
    item def SettingsStateRecord :> UnitInformationEnvelope;
    port def SettingsStateIn { in item payload:UnitInformationEnvelope; }
    port def SettingsStateOut { out item payload:SettingsStateRecord; }
    part def USetState {
        /* Validates and manages requested, pending, and active settings using current application guards and context. It publishes settings state without treating a retained value as a current startup receipt. */
        port requestedSettingsIn:SettingsStateIn;
        port stateOut:SettingsStateOut;
    }
}
