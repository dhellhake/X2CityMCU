package X2CityDetailedUnit_DemandArbiter {
    private import X2CityDetailedSharedContracts::*;
    // Owner: SC-DEMAND; DD-001; UR-DEMAND-001; SW-I-001..005.
    item def DemandRecord :> UnitInformationEnvelope;
    // Documented policy fan-in carries independently owned qualified records.
    // It therefore accepts their common contextual envelope without a runtime cast.
    port def DemandIn { in item payload:UnitInformationEnvelope; }
    port def DemandOut { out item payload:DemandRecord; }
    part def UDemandArbiter {
        /* Combines qualified rider, setting, authority, restriction, and traction observations into a signed, current-context demand command. It rejects unavailable or expired contributions and does not establish physical torque. */
        port inputsIn:DemandIn; port commandOut:DemandOut; }
}
