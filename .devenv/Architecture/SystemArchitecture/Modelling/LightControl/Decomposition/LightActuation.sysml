package X2CityComponent_LightActuation {
    private import X2CitySharedContracts::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_LightPower::*;
    private import X2CityComponent_LightPower::*;

    part def LightActuation { // LE-LAMP-HW
        /* Hardware responsibility for realizing selected Front Off/On and Rear Off/Dim/Full modes as physical illumination. It contains LightPower, which receives distributed vehicle energy and provides this actuation boundary's lighting-power contract without implying a separate converter or circuit. With an available mode selection it realizes the selected result wherever supplied power and external protection permit. Before a usable software mode selection exists at initial, start, or reset, it provides the powered fallback of Front Off and Rear Full. It selects no lamp device, GPIO, PWM method, supply topology, or diagnostic/status output. */
        part lightPower:LightPower;
        port lightModesIn:LightModesInputPort;
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* Receives LightControl's delegated distributed vehicle electrical energy for LightPower. */ }
        port lightingPowerIn:LightingPowerInputPort { doc /* Internal-facing consumption port fed only by LightPower; it is not an additional external supply boundary. */ }
        port frontIlluminationOut:FrontIlluminationOutputPort;
        port rearIlluminationOut:RearIlluminationOutputPort;
        flow vehicleElectricalPowerToLightPower from vehicleElectricalPowerIn.vehicleElectricalPower to lightPower.vehicleElectricalPowerIn.vehicleElectricalPower;
        interface lightingPowerFromLightPower : IfA010LightingPower
            connect lightPower.lightingPowerOut to lightingPowerIn;
    }
}
