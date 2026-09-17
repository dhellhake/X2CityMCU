package X2CityContract_Bms {
    private import X2CitySharedContracts::*;
    item def BmsTelemetry:>QualifiedInformationRecord;
    item def BmsReadRequest:>QualifiedInformationRecord;
    port def BmsTelemetryOutputPort {
        doc /* Carries battery data and protection-state observations from the supplied BMS assembly to BmsLink. BmsLink validates and qualifies this telemetry before using it as battery evidence; the path carries no software control decision. */
        out item payload:BmsTelemetry;
    }
    port def BmsTelemetryInputPort {
        doc /* Carries battery data and protection-state observations from the supplied BMS assembly to BmsLink. BmsLink validates and qualifies this telemetry before using it as battery evidence; the path carries no software control decision. */
        in item payload:BmsTelemetry;
    }
    port def BmsReadRequestOutputPort {
        doc /* Carries a read-only battery-information request from BmsLink to the supplied BMS assembly. The request selects observation retrieval and does not write or command the BMS protection function. */
        out item payload:BmsReadRequest;
    }
    port def BmsReadRequestInputPort {
        doc /* Carries a read-only battery-information request from BmsLink to the supplied BMS assembly. The request selects observation retrieval and does not write or command the BMS protection function. */
        in item payload:BmsReadRequest;
    }
    interface def IfA009BmsReadRequest { end producer:BmsReadRequestOutputPort; end consumer:BmsReadRequestInputPort; flow producer.payload to consumer.payload; }
    interface def IfA009BmsTelemetry { end producer:BmsTelemetryOutputPort; end consumer:BmsTelemetryInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_Bms {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Bms::*;
    part def Bms { // LE-BMS, supplied assembly
        /* Supplied battery-management assembly that provides battery telemetry and accepts selected read requests. Its responsibility is the external BMS function and interface; project software does not implement this assembly here. */
        port bmsTelemetryOut:BmsTelemetryOutputPort;
        port bmsReadRequestIn:BmsReadRequestInputPort;
    }
}
