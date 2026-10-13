package X2CityContract_HmiControl {
    private import X2CitySharedContracts::*;
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_ComputeHardware::*;

    enum def HmiPowerLockObservationState { enum Active; enum Inactive; enum Unknown; }
    item def HmiPowerLockObservation {
        doc /* Awake vehicle-local observation of the supplied VD18MT power-lock signal after electrical conditioning. Integrity reports observation quality; this raw signal observation makes no supplied-display metadata claim and is independent of UART framing or protocol availability. */
        attribute state:HmiPowerLockObservationState;
        attribute integrity:ValidityStatus;
    }
    enum def VehicleOperationRequestState { enum On; enum Off; enum Unknown; }
    item def VehicleOperationRequestQualification:>QualifiedInformationRecord {
        doc /* Qualification for HMIControl's interpretation of the conditioned physical power-lock observation. */
    }
    item def VehicleOperationRequest {
        doc /* HMIControl's qualified semantic interpretation of the physical power-lock request. The intended qualified Inactive-to-Off mapping remains Draft pending selected-unit characterization and is not observation proof. Only qualified explicit Off ends the operation session; Unknown or unavailable is not Off. */
        attribute Request:VehicleOperationRequestState;
        item Qualification:VehicleOperationRequestQualification;
    }

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
    port def HmiPowerLockObservationOutputPort { doc /* Publishes awake conditioned physical power-lock state and integrity from HmiElectricalInterface to HmiInformationProcessing. */ out item observation:HmiPowerLockObservation; }
    port def HmiPowerLockObservationInputPort { doc /* Receives the awake conditioned physical power-lock state and integrity for HMIControl's semantic request qualification. */ in item observation:HmiPowerLockObservation; }
    port def VehicleOperationRequestOutputPort { doc /* Publishes HMIControl's qualified physical On/Off interpretation to RidingControl. */ out item request:VehicleOperationRequest; }
    port def VehicleOperationRequestInputPort { doc /* Receives HMIControl's qualified physical On/Off interpretation; UART state is not part of this contract. */ in item request:VehicleOperationRequest; }

    interface def IfA006HmiUartReceivedData { end electrical:HmiUartReceivedDataOutputPort; end information:HmiUartReceivedDataInputPort; flow electrical.receivedData to information.receivedData; }
    interface def IfA006HmiUartTransmittedData { end information:HmiUartTransmittedDataOutputPort; end electrical:HmiUartTransmittedDataInputPort; flow information.transmittedData to electrical.transmittedData; }
    interface def IfA006HmiPowerLockObservation { end electrical:HmiPowerLockObservationOutputPort; end information:HmiPowerLockObservationInputPort; flow electrical.observation to information.observation; }
    interface def IfA006VehicleOperationRequest { end hmi:VehicleOperationRequestOutputPort; end receiver:VehicleOperationRequestInputPort; flow hmi.request to receiver.request; }
}

package X2CityComponent_HmiControl {
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_ComputeHardware::*;
    private import X2CityContract_HmiElectricalInterface::*;
    private import X2CityComponent_HmiElectricalInterface::*;
    private import X2CityComponent_HmiInformationProcessing::*;

    part def HMIControl { // LE-HMI-CONTROL
        /* Vehicle-side rider interaction, kept separate from riding policy. The electrical leaf owns physical power-lock identification and qualification while awake and forwards a hardware-conditioned wake signal directly to Compute; the software leaf interprets the power-lock observation independently of UART framing and owns display information exchange. */
        part hmiElectricalInterface:HmiElectricalInterface; // LE-HMI-ELECTRICAL
        part hmiInformationProcessing:HmiInformationProcessing; // LE-HMI
        port ridingSettingsOut:RiderSettingsRequestOutputPort { doc /* Qualified requested riding level/speed receipt for RidingControl. */ }
        port runningLightStateOut:NormalLightRequestOutputPort { doc /* Qualified normal-light request for LightControl; it carries no retained-light policy. */ }
        port selectedFaultIn:SelectedFaultIndicationInputPort { doc /* Qualified Session-selected wire code, including no-error, for report encoding only. */ }
        port stateOfChargeIn:BatteryStateOfChargeInputPort { doc /* Qualified actual SOC for rider-information encoding. */ }
        port batteryCurrentIn:BatteryCurrentInputPort { doc /* Qualified signed pack current for rider-information encoding. */ }
        port vehicleMotionIn:QualifiedVehicleMotionInputPort { doc /* Qualified Traction-owned speed/direction/standstill for rider-information encoding. */ }
        port vehicleOperationRequestOut:VehicleOperationRequestOutputPort { doc /* HMI-owned qualified physical On/Off semantic request to RidingControl, independent of UART framing or protocol availability. */ }
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* EnergyPath supply made available to the VD18MT on/off function. */ }
        port vd18mtConnection:HmiDevicePort { doc /* Vehicle-side logical VD18MT energy and information exchange. */ }
        port controllerWakeOut:ControllerWakeOutputPort { doc /* Conditioned hardware wake forwarded from HmiElectricalInterface to Compute, independent of UART/software execution. */ }
        interface receivedDataToInformation : IfA006HmiUartReceivedData
            connect hmiElectricalInterface.uartReceivedDataOut to hmiInformationProcessing.uartReceivedDataIn;
        interface transmittedDataToElectrical : IfA006HmiUartTransmittedData
            connect hmiInformationProcessing.uartTransmittedDataOut to hmiElectricalInterface.uartTransmittedDataIn;
        interface powerLockObservationToInformation : IfA006HmiPowerLockObservation
            connect hmiElectricalInterface.powerLockObservationOut to hmiInformationProcessing.powerLockObservationIn;
        flow settingsFromInformation from hmiInformationProcessing.ridingSettingsOut.payload to ridingSettingsOut.payload;
        flow lightRequestFromInformation from hmiInformationProcessing.runningLightStateOut.normalLightRequest to runningLightStateOut.normalLightRequest;
        flow selectedFaultToInformation from selectedFaultIn.selectedFaultIndication to hmiInformationProcessing.selectedFaultIn.selectedFaultIndication;
        flow stateOfChargeToInformation from stateOfChargeIn.stateOfCharge to hmiInformationProcessing.stateOfChargeIn.stateOfCharge;
        flow batteryCurrentToInformation from batteryCurrentIn.batteryCurrent to hmiInformationProcessing.batteryCurrentIn.batteryCurrent;
        flow vehicleMotionToInformation from vehicleMotionIn.payload to hmiInformationProcessing.vehicleMotionIn.payload;
        flow operationRequestFromInformation from hmiInformationProcessing.vehicleOperationRequestOut.request to vehicleOperationRequestOut.request;
        flow powerToElectrical from vehicleElectricalPowerIn.vehicleElectricalPower to hmiElectricalInterface.vehicleElectricalPowerIn.vehicleElectricalPower;
        flow displayPowerFromElectrical from hmiElectricalInterface.vd18mtConnection.displayPower to vd18mtConnection.displayPower;
        flow informationToDisplayFromElectrical from hmiElectricalInterface.vd18mtConnection.informationToDisplay to vd18mtConnection.informationToDisplay;
        flow informationFromDisplayToElectrical from vd18mtConnection.informationFromDisplay to hmiElectricalInterface.vd18mtConnection.informationFromDisplay;
        flow powerLockToElectrical from vd18mtConnection.powerLock to hmiElectricalInterface.vd18mtConnection.powerLock;
        flow conditionedWakeToCompute from hmiElectricalInterface.controllerWakeOut.controllerWake to controllerWakeOut.controllerWake;
    }
}
