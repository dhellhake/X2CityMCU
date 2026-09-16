package X2CitySharedSoftwareTypes {
    attribute def Validity;
    attribute def Qualification;
    attribute def Freshness;
    attribute def Health;
    attribute def ProducerContext;
    attribute def ConfigurationContext;
    attribute def ContextGeneration;
    // Software-contract scalar convention: engineering values use SysML Real/Integer/Boolean
    // primitives with a unit-bearing property name; controlled enum values use String until the
    // owning HSI binds its exact vocabulary and serialization layout.
    item def ContextualSoftwareInformation {
        attribute validity:Validity;
        // Qualification and current health remain distinct from availability/freshness.
        attribute qualification:Qualification;
        attribute freshness:Freshness;
        attribute health:Health;
        attribute producerContext:ProducerContext;
        attribute configurationContext:ConfigurationContext;
        // Identifies the current vehicle host/reset generation; it is not a global session.
        attribute currentGeneration:ContextGeneration;
    }
}
