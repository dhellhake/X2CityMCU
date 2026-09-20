package X2CityComponent_BatterySupervision {
    private import X2CityContract_BatteryControl::*;

    part def BatterySupervision { // LE-BATTERY-SUPERVISION
        doc /* Project software responsibility on the vehicle host. It logically owns the existing BmsLink read/qualification and BatteryProtection operating-policy responsibilities; their existing software components realize this part, while supplied BMS internals remain outside it. */
        port bmsTelemetryIn:BmsTelemetryInputPort { doc /* Read-only UART response input from the supplied BMS. */ }
        port bmsReadRequestOut:BmsReadRequestOutputPort { doc /* Read-only UART request output to the supplied BMS. */ }
        port batteryReadinessAndFaultOut:BatteryReadinessAndFaultOutputPort { doc /* Publishes one startup assessment and separate recognized thermal/battery fault evidence to SessionPolicy. */ }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort { doc /* Publishes independent discharge/regeneration branch limits and SOC-positive-propulsion limits to DemandPolicy. */ }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort { doc /* Publishes qualified actual SOC for HMI and SessionPolicy low-charge selection. */ }
        port batteryCurrentOut:BatteryCurrentOutputPort { doc /* Publishes qualified signed pack current in amperes for HMI. */ }
    }
}
