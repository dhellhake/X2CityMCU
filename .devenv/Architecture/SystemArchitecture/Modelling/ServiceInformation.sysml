package X2CityContract_ServiceInformation {
    private import X2CitySharedContracts::*;
    item def ServiceConfigurationInformation:>ContextualInformation;
    port def ServiceConfigurationOut { out item payload:ServiceConfigurationInformation; }
    port def ServiceConfigurationIn { in item payload:ServiceConfigurationInformation; }
    interface def IfA008ServiceConfiguration { end producer:ServiceConfigurationOut; end consumer:ServiceConfigurationIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_ServiceInformation {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ServiceInformation::*;
    part def ServiceInformation { // LE-SERVICE-INFO
        /* Aggregates service configuration information from applicable logical producers. It forwards the current configuration information to the service access boundary. */
        port serviceConfigurationIn:ServiceConfigurationIn;
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
