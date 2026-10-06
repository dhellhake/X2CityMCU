package X2CityContract_HmiElectricalInterface {
    private import X2CitySharedContracts::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_ComputeHardware::*;

    item def HmiDisplayRequestData {
        doc /* Raw protocol bytes received from the supplied display. Qualification, integrity/context, framing and meaning are established inside the vehicle; this type makes no supplied-display metadata claim. */
        attribute bytes:Integer[*];
    }
    item def HmiControllerReportData {
        doc /* Raw protocol bytes sent from the vehicle to the supplied display. It makes no physical-transmission or display-acknowledgement claim. */
        attribute bytes:Integer[*];
    }
    item def HmiPowerLockSignal {
        doc /* Raw supplied VD18MT power-lock line. It is a supplied electrical signal that must be conditioned to an MCU-safe wake signal by vehicle hardware; it is not a UART/software command. Physical voltage, pin and conditioning realization belong to ARCH-002. */
    }
    port def HmiDevicePort {
        doc /* Vehicle-side logical VD18MT exchange boundary. It carries supplied-display energy, raw protocol bytes and the supplied power-lock signal; conductor, pin, ground and voltage-class realization belongs to ARCH-002. Receive integrity/context is vehicle-local evidence, not metadata asserted by the supplied display. */
        out item displayPower:VehicleElectricalPower;
        out item informationToDisplay:HmiControllerReportData;
        in item informationFromDisplay:HmiDisplayRequestData;
        in item powerLock:HmiPowerLockSignal;
    }
    interface def IfA006HmiDeviceConnection {
        doc /* Connects the vehicle and supplied VD18MT through required logical energy, information and raw power-lock signal exchanges. ARCH-002 refines their physical conductor and connector realization. */
        end vehicle:HmiDevicePort;
        end display:~HmiDevicePort;
        flow vehicle.displayPower to display.displayPower;
        flow vehicle.informationToDisplay to display.informationToDisplay;
        flow display.informationFromDisplay to vehicle.informationFromDisplay;
        flow display.powerLock to vehicle.powerLock;
    }
}

package X2CityComponent_HmiElectricalInterface {
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_HmiElectricalInterface::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_ComputeHardware::*;

    part def HmiElectricalInterface { // LE-HMI-ELECTRICAL
        /* Hardware responsibility transforms System logical HMI energy and information exchanges to their physical realization. It supplies vehicle-local transport evidence with received bytes, transmits software-prepared bytes, identifies and qualifies the conditioned physical power-lock state while awake, and conditions the supplied raw power-lock line to an MCU-safe controller wake signal. Framing and protocol interpretation remain HmiInformationProcessing responsibilities. ARCH-002 owns conductors, pins, ground, voltage class and connector detail. EnergyPath makes display supply available before MCU startup; the wake path is hardware-level and does not require UART or running software. */
        port vd18mtConnection:HmiDevicePort { doc /* Vehicle-side logical VD18MT connection. */ }
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* Distributed EnergyPath supply available to the VD18MT on/off function. */ }
        port uartReceivedDataOut:HmiUartReceivedDataOutputPort { doc /* Received display UART bytes plus electrical-interface integrity for software parsing. */ }
        port uartTransmittedDataIn:HmiUartTransmittedDataInputPort { doc /* Software-prepared controller UART bytes plus integrity for electrical transmission. */ }
        port powerLockObservationOut:HmiPowerLockObservationOutputPort { doc /* Publishes awake Active/Inactive/Unknown state and separate integrity for the conditioned physical VD18MT power-lock signal. */ }
        port controllerWakeOut:ControllerWakeOutputPort { doc /* Conditioned MCU-safe wake signal derived from the supplied raw power-lock line. */ }
        flow vehiclePowerToDisplay from vehicleElectricalPowerIn.vehicleElectricalPower to vd18mtConnection.displayPower;
        flow informationToDisplay from uartTransmittedDataIn.transmittedData.transmittedBytes to vd18mtConnection.informationToDisplay.bytes;
        flow informationFromDisplay from vd18mtConnection.informationFromDisplay.bytes to uartReceivedDataOut.receivedData.receivedBytes;
    }
}
