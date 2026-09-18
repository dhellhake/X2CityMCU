package X2CitySharedContracts {
    attribute def ValidityStatus;
    attribute def SourceContext;
    attribute def Expiry;

    item def QualifiedInformationRecord {
        attribute validity:ValidityStatus;
        attribute sourceContext:SourceContext;
    }

}
