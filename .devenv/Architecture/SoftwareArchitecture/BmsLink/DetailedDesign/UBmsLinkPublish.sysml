package X2CityDetailedUnit_BmsLinkPublish {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedUnit_BmsLinkDecode::*;
    private import X2CityContract_BatteryControl::*;
    // Owner: SC-BMS-LINK.V; DD-002. Publishes qualified observations; no BMS write/control capability.
    item def BatteryMeasurementsRecord :> BatteryMeasurements;
    port def BmsDecodedInputPort {
        doc /* Receives source-identified decoded BMS fields from the decoder, including their per-field qualification. */
        in item payload:BmsDecodedRecord;
    }
    port def BatteryMeasurementsOutputPort {
        doc /* Publishes concrete field-qualified pack measurements to battery supervision. BMS receipt order/age is local provenance and is never asserted as an opaque BMS measurement time. */
        out item payload:BatteryMeasurementsRecord;
    }
    part def BatteryMeasurementsPublisher {
        /* Publishes accepted BMS observations with producer context, qualification, and original qualified BMS receipt/source-age evidence. It marks affected information for requalification after relevant reset or source loss without exposing BMS write/control capability. */
        port executionTimeIn:ExecutionTimeInputPort; port decodedIn:BmsDecodedInputPort; port batteryMeasurementsOut:BatteryMeasurementsOutputPort; }
}
