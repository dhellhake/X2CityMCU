package X2CityContract_LightPower {
    private import X2CityContract_EnergyPath::*;

    item def LightingPower {
        doc /* Physical lighting power provided by LightPower to the owning LightActuation boundary. It specifies no converter, PWM, circuit, sensing, or control-state realization. */
    }

    port def LightingPowerOutputPort {
        doc /* Provides physical lighting power from LightPower to its owning LightActuation. */
        out item lightingPower:LightingPower;
    }
    port def LightingPowerInputPort {
        doc /* Receives physical lighting power inside the owning LightActuation. */
        in item lightingPower:LightingPower;
    }
    interface def IfA010LightingPower {
        end producer:LightingPowerOutputPort;
        end consumer:LightingPowerInputPort;
        flow producer.lightingPower to consumer.lightingPower;
    }
}

package X2CityComponent_LightPower {
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_LightPower::*;
    private import X2CityContract_LightControl::*;

    part def LightPower { // LE-LIGHT-POWER
        /* Receives distributed vehicle electrical energy and provides the physical lighting-power supply consumed by its owning LightActuation. Qualified unavailable withdraws lighting supply or actuation, including before usable software modes; in the live powered actuation context an unqualified update cannot release a known restriction. Qualified available permits supply subject to EnergyPath and protection limits. It specifies no separate converter or circuit implementation. */
        port lightingAvailabilityIn:LightingAvailabilityInputPort { doc /* Receives the qualified budget-derived operational constraint delegated by LightActuation. */ }
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* Receives the owning LightActuation's delegated distributed vehicle electrical energy. */ }
        port lightingPowerOut:LightingPowerOutputPort { doc /* Provides the physical lighting-power contract consumed by the owning LightActuation. */ }
    }
}
