package X2CityContract_ServiceInformation {
    private import X2CitySharedContracts::*;
    item def ServiceReportInformation:>QualifiedInformationRecord;
    port def ServiceReportOutputPort {
        doc /* Carries producer status, configuration and diagnostic observations from logical components to ServiceInformation and then service access. The records support read-only service presentation and do not configure or command their producers. */
        out item payload:ServiceReportInformation;
    }
    port def ServiceReportInputPort {
        doc /* Carries producer status, configuration and diagnostic observations from logical components to ServiceInformation and then service access. The records support read-only service presentation and do not configure or command their producers. */
        in item payload:ServiceReportInformation;
    }
    interface def IfA008ServiceReport { end producer:ServiceReportOutputPort; end consumer:ServiceReportInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_ServiceInformation {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ServiceInformation::*;
    part def ServiceInformation { // LE-SERVICE-INFO
        /* Aggregates service report information from applicable logical producers. It forwards the current report to the service access boundary. */
        port serviceReportIn:ServiceReportInputPort;
        port serviceReportOut:ServiceReportOutputPort;
    }
}
