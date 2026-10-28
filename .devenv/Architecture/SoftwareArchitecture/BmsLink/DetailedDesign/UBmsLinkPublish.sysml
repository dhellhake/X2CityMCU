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
        doc /* Publishes concrete field-qualified pack measurements to battery supervision. Per-field source age stays private and is never asserted as an opaque BMS measurement time. */
        out item payload:BatteryMeasurementsRecord;
    }
    part def BatteryMeasurementsPublisher {
        /* On each normal invocation, checks private per-source/per-field timers and publishes current status even when no decoded frame arrived. Only a newly accepted matching response resets that field timer; unrelated/malformed/cached input and qualification-only snapshots do not. ProtectionPathState is qualified as one shared source field by protectionPathStateValid; preserve its separate chargePathEnabled and dischargePathEnabled values. At vehicle-controller startup publish BatteryMeasurements.sourceContext for the current producer boot and begin affected fields, including optional nominal capacity, unavailable; require fresh accepted evidence to requalify. Ordinary per-field expiry withdraws only the affected qualification and retains its value and sourceContext. A recognized startup compatibility failure retains dependent-field unqualification until normal or unexpected controller startup; ordinary missing initial data does not latch. Publish its independently qualified diagnostic contribution via bmsStatusOut for reporting only even while numerical fields remain unqualified, without exposing a startup-pass Boolean or qualifying incompatible values. BatteryMeasurements contains no source-age or receipt timestamp. */
        port executionTimeIn:ExecutionTimeInputPort; port decodedIn:BmsDecodedInputPort; port batteryMeasurementsOut:BatteryMeasurementsOutputPort; port bmsStatusOut:BatteryStatusOutputPort; }
}
