package X2CitySharedContracts {
    attribute def ValidityStatus;
    attribute def FreshnessStatus;
    attribute def SourceContext;
    attribute def Expiry;

    item def QualifiedInformationRecord {
        attribute validity:ValidityStatus;
        attribute freshness:FreshnessStatus;
        attribute sourceContext:SourceContext;
    }

}
