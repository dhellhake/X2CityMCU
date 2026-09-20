package X2CityContract_EnergyPath {
    private import X2CityContract_BatteryControl::*;
    item def VehicleElectricalPower {
        doc /* Generic distributed vehicle electrical energy supplied from EnergyPath to a vehicle load. It specifies no voltage, conversion, protection, switching, or circuit realization. */
    }
    item def TractionElectricalPower {
        doc /* Physical bidirectional electrical-energy connection between EnergyPath and Traction. It supports propulsion discharge and regenerative return without asserting a protection, switching, or software-control realization. */
    }

    port def VehicleElectricalPowerOutputPort {
        doc /* Provides distributed vehicle electrical energy at an EnergyPath boundary. */
        out item vehicleElectricalPower:VehicleElectricalPower;
    }
    port def VehicleElectricalPowerInputPort {
        doc /* Receives distributed vehicle electrical energy at a vehicle load boundary. */
        in item vehicleElectricalPower:VehicleElectricalPower;
    }
    port def TractionElectricalPowerPort {
        doc /* Physical bidirectional traction-power connection. */
        inout item tractionElectricalPower:TractionElectricalPower;
    }
    interface def IfA010VehicleElectricalPower {
        end producer:VehicleElectricalPowerOutputPort;
        end consumer:VehicleElectricalPowerInputPort;
        flow producer.vehicleElectricalPower to consumer.vehicleElectricalPower;
    }
    interface def IfA010TractionElectricalPower {
        end energyPath:TractionElectricalPowerPort;
        end traction:TractionElectricalPowerPort;
        flow energyPath.tractionElectricalPower to traction.tractionElectricalPower;
        flow traction.tractionElectricalPower to energyPath.tractionElectricalPower;
    }
}

package X2CityComponent_EnergyPath {
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_BatteryControl::*;

    part def EnergyPath { // LE-ENERGY-PATH
        /* Provides general vehicle electrical-power distribution from BatteryControl to vehicle loads and the physical traction connection. It carries energy but does not define policy, protection, switching, or a supply realization. */
        port batteryPower:BatteryPowerPort { doc /* Receives and returns physical pack energy for discharge and regeneration. */ }
        port vehicleElectricalPowerOut:VehicleElectricalPowerOutputPort { doc /* Supplies general distributed vehicle electrical power to a vehicle-load boundary. */ }
        port tractionElectricalPower:TractionElectricalPowerPort { doc /* Physical bidirectional traction-energy branch. */ }
    }
}
