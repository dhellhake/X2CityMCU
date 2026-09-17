package X2CityContract_Bms {
    private import X2CitySharedContracts::*;
    item def BmsTelemetryInformation:>ContextualInformation;
    item def BmsReadRequestInformation:>ContextualInformation;
    port def BmsTelemetryOut {
        doc /* Carries battery data and protection-state observations from the supplied BMS assembly to BmsLink. BmsLink validates and qualifies this telemetry before using it as battery evidence; the path carries no software control decision. */
        out item payload:BmsTelemetryInformation;
    }
    port def BmsTelemetryIn {
        doc /* Carries battery data and protection-state observations from the supplied BMS assembly to BmsLink. BmsLink validates and qualifies this telemetry before using it as battery evidence; the path carries no software control decision. */
        in item payload:BmsTelemetryInformation;
    }
    port def BmsReadRequestOut {
        doc /* Carries a read-only battery-information request from BmsLink to the supplied BMS assembly. The request selects observation retrieval and does not write or command the BMS protection function. */
        out item payload:BmsReadRequestInformation;
    }
    port def BmsReadRequestIn {
        doc /* Carries a read-only battery-information request from BmsLink to the supplied BMS assembly. The request selects observation retrieval and does not write or command the BMS protection function. */
        in item payload:BmsReadRequestInformation;
    }
    interface def IfA009BmsReadRequest { end producer:BmsReadRequestOut; end consumer:BmsReadRequestIn; flow producer.payload to consumer.payload; }
    interface def IfA009BmsTelemetry { end producer:BmsTelemetryOut; end consumer:BmsTelemetryIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_Bms {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Bms::*;
    part def Bms { // LE-BMS, supplied assembly
        /* Supplied battery-management assembly that provides battery telemetry and accepts selected read requests. Its responsibility is the external BMS function and interface; project software does not implement this assembly here. */
        port telemetryOut:BmsTelemetryOut;
        port readRequestIn:BmsReadRequestIn;
    }
}
