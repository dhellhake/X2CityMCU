package X2CitySharedContracts {
    // Information items summarize the canonical IF-A contracts. Fields, protocols,
    // numerical bounds, timing, behavior, and software-unit routes are intentionally absent.
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
