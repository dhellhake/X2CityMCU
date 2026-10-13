package X2CityComponent_HmiInformationProcessing {
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_MotorControl::*;

    part def HmiInformationProcessing { // LE-HMI
        /* Vehicle-side VD18MT framing, protocol interpretation, timestamps and report encoding, plus semantic qualification of the independently observed physical power-lock request. Operation-request qualification does not depend on UART framing or protocol availability. It has no power-switching, Ready, fault-selection/latching, setting-guard or light-retention responsibility. */
        port uartReceivedDataIn:HmiUartReceivedDataInputPort { doc /* Qualified received VD18MT bytes plus electrical-interface integrity. */ }
        port uartTransmittedDataOut:HmiUartTransmittedDataOutputPort { doc /* Qualified bytes for electrical transmission; it conveys no display acknowledgement. */ }
        port powerLockObservationIn:HmiPowerLockObservationInputPort { doc /* Awake conditioned physical power-lock state and integrity from HmiElectricalInterface; independent of UART. */ }
        port vehicleOperationRequestOut:VehicleOperationRequestOutputPort { doc /* Publishes qualified On/Off/Unknown semantic request and its Qualification from the physical power-lock observation. */ }
        port ridingSettingsOut:RiderSettingsRequestOutputPort { doc /* Qualified requested riding level and speed receipt for RidingControl. */ }
        port runningLightStateOut:NormalLightRequestOutputPort { doc /* Qualified normal-light request only; LightControl retains and selects its physical response. */ }
        port selectedFaultIn:SelectedFaultIndicationInputPort { doc /* Qualified Session-selected wire code, including no-error; this leaf neither prioritizes nor latches faults. */ }
        port stateOfChargeIn:BatteryStateOfChargeInputPort { doc /* Qualified actual SOC for VD18MT report encoding. */ }
        port batteryCurrentIn:BatteryCurrentInputPort { doc /* Qualified signed pack current for VD18MT report encoding. */ }
        port vehicleMotionIn:QualifiedVehicleMotionInputPort { doc /* Qualified Traction-owned physical speed/direction/standstill for VD18MT speed encoding. */ }
    }
}
