package X2CityContract_Bms {
    private import X2CitySharedContracts::*;
    item def BmsTelemetryInformation:>ContextualInformation;
    item def BmsReadRequestInformation:>ContextualInformation;
    port def BmsTelemetryOut { out item payload:BmsTelemetryInformation; }
    port def BmsTelemetryIn { in item payload:BmsTelemetryInformation; }
    port def BmsReadRequestOut { out item payload:BmsReadRequestInformation; }
    port def BmsReadRequestIn { in item payload:BmsReadRequestInformation; }
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
