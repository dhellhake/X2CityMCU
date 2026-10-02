package X2CityHardware_Vd18mtElectricalConnection {
    private import X2CityContract_HmiElectricalInterface::*;

    item def Vd18mtGroundReturn {
        doc /* VD18MT pin 1 / black wire: common ground return. */
    }
    item def Vd18mtBatteryPositiveSupply {
        doc /* VD18MT pin 3 / yellow wire: battery-positive P+ supply from the vehicle into the display. */
    }
    item def Vd18mtUartTransmit5VClass {
        doc /* VD18MT pin 2 / green wire: controller TX to display RX, 5-V UART class. */
    }
    item def Vd18mtUartReceive5VClass {
        doc /* VD18MT pin 4 / white wire: display TX to controller RX, 5-V UART class. */
    }

    port def Vd18mtElectricalPort {
        doc /* Physical five-wire VD18MT endpoint; it carries power, reference, UART signals and switched power lock. */
        inout item groundReturn:Vd18mtGroundReturn { doc /* Pin 1 / black wire: common ground return. */ }
        out item batteryPositiveSupply:Vd18mtBatteryPositiveSupply { doc /* Pin 3 / yellow wire: vehicle P+ supply to the display. */ }
        out item uartTransmit:Vd18mtUartTransmit5VClass { doc /* Pin 2 / green wire: controller TX to display RX. */ }
        in item uartReceive:Vd18mtUartReceive5VClass { doc /* Pin 4 / white wire: display TX to controller RX. */ }
        in item powerLock:HmiPowerLockSignal { doc /* Pin 5 / red wire: switched battery-positive power lock from the display. */ }
    }

    interface def IfA006Vd18mtElectricalConnection {
        doc /* Physical VD18MT wire connection. Ground is a common electrical reference, not a data message. */
        end vehicleHarness:Vd18mtElectricalPort;
        end suppliedDisplay:~Vd18mtElectricalPort;
        connect vehicleHarness.groundReturn to suppliedDisplay.groundReturn;
        flow vehicleHarness.batteryPositiveSupply to suppliedDisplay.batteryPositiveSupply;
        flow vehicleHarness.uartTransmit to suppliedDisplay.uartTransmit;
        flow suppliedDisplay.uartReceive to vehicleHarness.uartReceive;
        flow suppliedDisplay.powerLock to vehicleHarness.powerLock;
    }

    part def Vd18mtElectricalConnectionContext {
        doc /* Connection context for the existing HC-VEH-HARNESS and HC-RIDER boundaries. These ports represent boundaries only; this context adds no hardware item or containment. */
        port vehicleHarness:Vd18mtElectricalPort;
        port suppliedDisplay:~Vd18mtElectricalPort;
        interface vd18mtDeviceConnection:IfA006Vd18mtElectricalConnection
            connect vehicleHarness to suppliedDisplay;
    }
}
