package X2CitySharedContracts {
    attribute def Validity;
    attribute def Freshness;
    attribute def SourceContext;
    attribute def Expiry;

    item def ContextualInformation {
        attribute validity:Validity;
        attribute freshness:Freshness;
        attribute sourceContext:SourceContext;
    }

}
