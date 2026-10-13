package X2CityComponent_DriverInteraction {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_AcceleratorPositionIdentification::*;
    private import X2CityComponent_MechanicalBrakeDetection::*;
    private import X2CityComponent_HmiControl::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_BrakeSignalMeasurement::*;
    private import X2CityContract_HmiElectricalInterface::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_ComputeHardware::*;

    port def DriverElectricalConnectionPort {
        doc /* Grouped System logical rider connection. Each child retains its own signal, energy, qualification and timing contract. Required supply, reference and loading compatibility follows the child electrical requirements; ARCH-002 owns conductor, pin, ground, voltage-class and circuit realization. */
        port acceleratorConnection:AcceleratorElectricalSignalInputPort { doc /* Receives the unqualified accelerator electrical observation for AcceleratorPositionIdentification; child requirements govern electrical compatibility. */ }
        port brakeLeverConnection:BrakeElectricalSignalInputPort { doc /* Receives the unqualified passive coded-brake electrical signal for MechanicalBrakeDetection; child requirements govern electrical compatibility. */ }
        port vd18mtConnection:HmiDevicePort { doc /* Exchanges display energy, raw UART bytes and the supplied power-lock signal with HMIControl in their existing directions; child requirements govern electrical compatibility. */ }
    }

    part def DriverInteraction { // LE-INPUT
        /* Composes rider accelerator, coded brake-lever and VD18MT interaction. This grouping does not merge raw-wire validity or timestamps. Session, Demand and LightControl retain operating policy. HMI hardware wake remains effective while MCU software sleeps. */
        part accelerator:AcceleratorPositionIdentification;
        part mechanicalBrakeDetection:MechanicalBrakeDetection;
        part hmiControl:HMIControl;
        port driverElectricalConnection:DriverElectricalConnectionPort { doc /* Exposes the three distinct typed logical electrical subinterfaces to the vehicle boundary. */ }
        port brakeLeverStateOut:BrakeLeverStateOutputPort { doc /* Publishes the qualified brake State/Qualification composite to Session, Demand and LightControl. */ }
        port brakeHealthOut:BrakeHealthOutputPort { doc /* Publishes only the brake Qualification projection to Platform health supervision. */ }
        port acceleratorPositionOut:AcceleratorPositionOutputPort { doc /* Publishes the qualified accelerator Position/Qualification composite to riding policy consumers. */ }
        port acceleratorHealthOut:AcceleratorHealthOutputPort { doc /* Publishes only the accelerator Qualification projection to Platform health supervision. */ }
        port ridingSettingsOut:RiderSettingsRequestOutputPort { doc /* Forwards HMIControl's qualified riding-settings request to RidingControl, which retains requested, pending and active settings internally. */ }
        port runningLightStateOut:NormalLightRequestOutputPort { doc /* Forwards HMIControl's qualified normal-light request to LightControl, which retains lighting policy. */ }
        port selectedFaultIn:SelectedFaultIndicationInputPort { doc /* Receives the Session-selected fault indication for HMI report encoding, without selecting or latching faults here. */ }
        port stateOfChargeIn:BatteryStateOfChargeInputPort { doc /* Receives qualified battery SOC for HMI rider-information encoding. */ }
        port batteryCurrentIn:BatteryCurrentInputPort { doc /* Receives qualified signed pack current for HMI rider-information encoding. */ }
        port vehicleMotionIn:QualifiedVehicleMotionInputPort { doc /* Receives qualified Traction vehicle motion for HMI rider-information encoding. */ }
        port vehicleOperationRequestOut:VehicleOperationRequestOutputPort { doc /* Forwards HMIControl's qualified physical On/Off request to RidingControl, independent of UART state. */ }
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* Receives EnergyPath supply for the display on/off function, available while MCU software sleeps. */ }
        port controllerWakeOut:ControllerWakeOutputPort { doc /* Forwards the conditioned hardware wake to Compute independently of UART or running software. */ }
        flow acceleratorSignalToFunction from driverElectricalConnection.acceleratorConnection.signal to accelerator.electricalSignalIn.signal;
        flow brakeSignalToFunction from driverElectricalConnection.brakeLeverConnection.signal to mechanicalBrakeDetection.brakeElectricalSignalIn.signal;
        flow displayPowerFromHmi from hmiControl.vd18mtConnection.displayPower to driverElectricalConnection.vd18mtConnection.displayPower;
        flow reportFromHmi from hmiControl.vd18mtConnection.informationToDisplay to driverElectricalConnection.vd18mtConnection.informationToDisplay;
        flow requestToHmi from driverElectricalConnection.vd18mtConnection.informationFromDisplay to hmiControl.vd18mtConnection.informationFromDisplay;
        flow powerLockToHmi from driverElectricalConnection.vd18mtConnection.powerLock to hmiControl.vd18mtConnection.powerLock;
        flow brakeLeverStateFromFunction from mechanicalBrakeDetection.brakeLeverStateOut.brakeLeverState to brakeLeverStateOut.brakeLeverState;
        flow brakeHealthFromFunction from mechanicalBrakeDetection.brakeHealthOut.qualification to brakeHealthOut.qualification;
        flow acceleratorPositionFromFunction from accelerator.acceleratorPositionOut.acceleratorPosition to acceleratorPositionOut.acceleratorPosition;
        flow acceleratorHealthFromFunction from accelerator.acceleratorHealthOut.qualification to acceleratorHealthOut.qualification;
        flow settingsFromHmi from hmiControl.ridingSettingsOut.payload to ridingSettingsOut.payload;
        flow lightRequestFromHmi from hmiControl.runningLightStateOut.normalLightRequest to runningLightStateOut.normalLightRequest;
        flow selectedFaultToHmi from selectedFaultIn.selectedFaultIndication to hmiControl.selectedFaultIn.selectedFaultIndication;
        flow stateOfChargeToHmi from stateOfChargeIn.stateOfCharge to hmiControl.stateOfChargeIn.stateOfCharge;
        flow batteryCurrentToHmi from batteryCurrentIn.batteryCurrent to hmiControl.batteryCurrentIn.batteryCurrent;
        flow vehicleMotionToHmi from vehicleMotionIn.payload to hmiControl.vehicleMotionIn.payload;
        flow operationRequestFromHmi from hmiControl.vehicleOperationRequestOut.request to vehicleOperationRequestOut.request;
        flow powerToHmi from vehicleElectricalPowerIn.vehicleElectricalPower to hmiControl.vehicleElectricalPowerIn.vehicleElectricalPower;
        flow conditionedWakeFromHmi from hmiControl.controllerWakeOut.controllerWake to controllerWakeOut.controllerWake;
    }
}
