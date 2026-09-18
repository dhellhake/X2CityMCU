package X2CityComponent_RidingSupervisor {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_SettingsPolicy::*;
    private import X2CityComponent_SessionPolicy::*;
    private import X2CityComponent_DemandPolicy::*;
    private import X2CityComponent_HmiAdapter::*;
    // ARCH-001; LE identifiers remain authoritative.
    part def RidingSupervisor { // LE-RIDING
        /* Composes settings, session, demand, and HMI policy components for supervised riding. It coordinates rider intent, authority, demand and presentation across those policies. */
        part settings:SettingsPolicy;
        part session:SessionPolicy;
        part demand:DemandPolicy;
        part hmi:HmiAdapter;
    }
}
