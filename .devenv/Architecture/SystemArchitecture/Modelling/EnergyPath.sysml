package X2CityContract_EnergyPath {
    item def VehicleElectricalPower {
        doc /* Generic distributed vehicle electrical energy supplied from EnergyPath to a vehicle load. It specifies no voltage, conversion, protection, switching, or circuit realization. */
    }

    port def VehicleElectricalPowerOutputPort {
        doc /* Provides distributed vehicle electrical energy at an EnergyPath or Energy boundary. */
        out item vehicleElectricalPower:VehicleElectricalPower;
    }
    port def VehicleElectricalPowerInputPort {
        doc /* Receives distributed vehicle electrical energy at a vehicle load boundary. */
        in item vehicleElectricalPower:VehicleElectricalPower;
    }
    interface def IfA010VehicleElectricalPower {
        end producer:VehicleElectricalPowerOutputPort;
        end consumer:VehicleElectricalPowerInputPort;
        flow producer.vehicleElectricalPower to consumer.vehicleElectricalPower;
    }
}

package X2CityComponent_EnergyPath {
    private import X2CityContract_EnergyPath::*;

    part def EnergyPath { // LE-ENERGY-PATH
        /* Provides distributed vehicle electrical energy from the energy source to vehicle loads. This physical boundary carries energy; it does not define policy behavior or a supply realization. */
        port vehicleElectricalPowerOut:VehicleElectricalPowerOutputPort { doc /* Supplies distributed vehicle electrical energy to Energy's vehicle-load boundary. */ }
    }
}
