package X2CityComponent_RidingSupervisor {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_SettingsPolicy::*;
    private import X2CityComponent_SessionPolicy::*;
    private import X2CityComponent_DemandPolicy::*;

    part def RidingSupervisor { // LE-RIDING
        /* Composes settings, session and demand policy. Vehicle-side rider interaction is the sibling LE-HMI-CONTROL function, not a riding-policy child. */
        part settings:SettingsPolicy;
        part session:SessionPolicy;
        part demand:DemandPolicy;
    }
}
