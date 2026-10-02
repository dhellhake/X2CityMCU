package X2CityContract_HmiControl {
    private import X2CitySharedContracts::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_ComputeHardware::*;

    item def HmiUartReceivedData:>QualifiedInformationRecord {
        doc /* Bytes received by the electrical HMI interface from the supplied VD18MT, with the interface's transport-integrity observation. Framing, protocol meaning and timestamps are HmiInformationProcessing responsibilities. */
        attribute receivedBytes:Integer[*];
        attribute transportIntegrity:ValidityStatus;
    }
    item def HmiUartTransmittedData:>QualifiedInformationRecord {
        doc /* Software-prepared bytes requested for electrical transmission to the supplied VD18MT. Inherited qualification covers the software handoff only; it is neither physical-transmission evidence nor display acknowledgement. */
        attribute transmittedBytes:Integer[*];
    }

    port def HmiUartReceivedDataOutputPort { doc /* Publishes received VD18MT bytes and electrical-interface integrity to HmiInformationProcessing. */ out item receivedData:HmiUartReceivedData; }
    port def HmiUartReceivedDataInputPort { doc /* Receives VD18MT bytes and electrical-interface integrity for HMI framing/protocol interpretation. */ in item receivedData:HmiUartReceivedData; }
    port def HmiUartTransmittedDataOutputPort { doc /* Publishes software-prepared bytes and handoff qualification for electrical transmission, with no physical-send or display-acknowledgement claim. */ out item transmittedData:HmiUartTransmittedData; }
    port def HmiUartTransmittedDataInputPort { doc /* Receives software-prepared bytes and handoff qualification for electrical transmission; the electrical leaf does not interpret protocol fields. */ in item transmittedData:HmiUartTransmittedData; }

    interface def IfA006HmiUartReceivedData { end electrical:HmiUartReceivedDataOutputPort; end information:HmiUartReceivedDataInputPort; flow electrical.receivedData to information.receivedData; }
    interface def IfA006HmiUartTransmittedData { end information:HmiUartTransmittedDataOutputPort; end electrical:HmiUartTransmittedDataInputPort; flow information.transmittedData to electrical.transmittedData; }
}

package X2CityComponent_HmiControl {
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_ComputeHardware::*;
    private import X2CityContract_HmiElectricalInterface::*;
    private import X2CityComponent_HmiElectricalInterface::*;
    private import X2CityComponent_HmiInformationProcessing::*;

    part def HMIControl { // LE-HMI-CONTROL
        /* Vehicle-side rider interaction, kept separate from riding policy. The electrical leaf transforms supplied-device energy and information exchanges to physical realization and forwards a hardware-conditioned wake signal to Compute; the software leaf owns byte framing and information exchange. */
        part hmiElectricalInterface:HmiElectricalInterface; // LE-HMI-ELECTRICAL
        part hmiInformationProcessing:HmiInformationProcessing; // LE-HMI
        port ridingSettingsOut:RiderSettingsRequestOutputPort { doc /* Qualified requested riding level/speed receipt for SettingsPolicy and SessionPolicy. */ }
        port runningLightStateOut:NormalLightRequestOutputPort { doc /* Qualified normal-light request for LightControl; it carries no retained-light policy. */ }
        port selectedFaultIn:SelectedFaultIndicationInputPort { doc /* Qualified Session-selected wire code, including no-error, for report encoding only. */ }
        port stateOfChargeIn:BatteryStateOfChargeInputPort { doc /* Qualified actual SOC for rider-information encoding. */ }
        port batteryCurrentIn:BatteryCurrentInputPort { doc /* Qualified signed pack current for rider-information encoding. */ }
        port vehicleMotionIn:QualifiedVehicleMotionInputPort { doc /* Qualified Traction-owned speed/direction/standstill for rider-information encoding. */ }
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* EnergyPath supply made available to the VD18MT on/off function. */ }
        port vd18mtConnection:HmiDevicePort { doc /* Vehicle-side logical VD18MT energy and information exchange. */ }
        port controllerWakeOut:ControllerWakeOutputPort { doc /* Conditioned hardware wake forwarded from HmiElectricalInterface to Compute, independent of UART/software execution. */ }
        interface receivedDataToInformation : IfA006HmiUartReceivedData
            connect hmiElectricalInterface.uartReceivedDataOut to hmiInformationProcessing.uartReceivedDataIn;
        interface transmittedDataToElectrical : IfA006HmiUartTransmittedData
            connect hmiInformationProcessing.uartTransmittedDataOut to hmiElectricalInterface.uartTransmittedDataIn;
        flow settingsFromInformation from hmiInformationProcessing.ridingSettingsOut.payload to ridingSettingsOut.payload;
        flow lightRequestFromInformation from hmiInformationProcessing.runningLightStateOut.normalLightRequest to runningLightStateOut.normalLightRequest;
        flow selectedFaultToInformation from selectedFaultIn.selectedFaultIndication to hmiInformationProcessing.selectedFaultIn.selectedFaultIndication;
        flow stateOfChargeToInformation from stateOfChargeIn.stateOfCharge to hmiInformationProcessing.stateOfChargeIn.stateOfCharge;
        flow batteryCurrentToInformation from batteryCurrentIn.batteryCurrent to hmiInformationProcessing.batteryCurrentIn.batteryCurrent;
        flow vehicleMotionToInformation from vehicleMotionIn.payload to hmiInformationProcessing.vehicleMotionIn.payload;
        flow powerToElectrical from vehicleElectricalPowerIn.vehicleElectricalPower to hmiElectricalInterface.vehicleElectricalPowerIn.vehicleElectricalPower;
        flow displayPowerFromElectrical from hmiElectricalInterface.vd18mtConnection.displayPower to vd18mtConnection.displayPower;
        flow informationToDisplayFromElectrical from hmiElectricalInterface.vd18mtConnection.informationToDisplay to vd18mtConnection.informationToDisplay;
        flow informationFromDisplayToElectrical from vd18mtConnection.informationFromDisplay to hmiElectricalInterface.vd18mtConnection.informationFromDisplay;
        flow powerLockToElectrical from vd18mtConnection.powerLock to hmiElectricalInterface.vd18mtConnection.powerLock;
        flow conditionedWakeToCompute from hmiElectricalInterface.controllerWakeOut.controllerWake to controllerWakeOut.controllerWake;
    }
}
