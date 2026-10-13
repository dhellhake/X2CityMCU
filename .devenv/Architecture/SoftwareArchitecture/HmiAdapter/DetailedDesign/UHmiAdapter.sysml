package X2CityDetailedUnit_HmiAdapter {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_HmiAdapter::*;
    private import X2CitySoftwareContract_RidingControl::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_MotorControl::*;
    // Owner: SC-HMI.V; DD-001; UR-HMI-001; SW-I-002/006. Supplied VD18MT remains opaque.
    item def HmiSettingsRecord :> UnitInformationEnvelope, HmiRiderSettingsRequest;
    item def HmiLightRecord :> UnitInformationEnvelope, HmiNormalLightRequest;
    item def HmiReceivedDataRecord :> UnitInformationEnvelope, HmiUartReceivedData;
    item def HmiTransmittedDataRecord :> UnitInformationEnvelope, HmiUartTransmittedData;
    port def HmiSettingsOutputPort {
        doc /* Publishes qualified VD18MT level/speed receipts to U-SET-STATE and U-SESSION-ELIGIBILITY, preserving receipt provenance so retained active settings are not mistaken for new requests. */
        out item payload:HmiSettingsRecord;
    }
    port def VehicleOperationRequestOutputPort :> X2CityContract_HmiControl::VehicleOperationRequestOutputPort;
    port def HmiLightOutputPort {
        doc /* Publishes the qualified VD18MT normal-light request to U-LIGHT-MODE; link loss does not fabricate a new normal request. */
        out item normalLightRequest:HmiLightRecord;
    }
    port def HmiReceivedDataInputPort { doc /* Receives electrical UART byte/link evidence. Activity, loss and initialization remain distinct from decoded settings receipt. */ in item receivedData:HmiReceivedDataRecord; }
    port def SelectedFaultIndicationInputPort { doc /* Receives Session's selected fault/no-error code; no local report selection or acknowledgement is created. */ in item selectedFaultIndication:X2CitySoftwareContract_RidingControl::SoftwareSelectedFaultIndication; }
    port def BatteryStateOfChargeInputPort { doc /* Receives qualified actual SOC for the HMI's usable SOC display mapping; an unqualified candidate does not become display SOC. */ in item payload:BatteryStateOfCharge; }
    port def BatteryCurrentInputPort { doc /* Receives qualified signed pack current for HMI conversion; the adapter applies its established absolute-value/clamped fallback when the value is unusable. */ in item payload:BatteryCurrent; }
    port def QualifiedVehicleMotionInputPort { doc /* Receives Traction's qualified physical motion for speed/period encoding; unresolved status bits, invalid speed and timing retain their protocol fallbacks. */ in item payload:QualifiedMotion; }
    port def HmiTransmittedDataOutputPort { doc /* Publishes protocol bytes encoding selected-fault, SOC, current and speed for electrical transmission. A transmitted report is not display receipt. */ out item transmittedData:HmiTransmittedDataRecord; }
    part def HmiAdapterUnit {
        /* Interprets qualified VD18MT settings/light input and encodes selected-fault, battery and
           motion fields. It owns parser observations and link-loss handling, while retaining no
           authority, fault selection, physical power-lock or display acknowledgement. */
        port executionTimeIn:ExecutionTimeInputPort;
        port uartReceivedDataIn:HmiReceivedDataInputPort;
        port ridingSettingsOut:HmiSettingsOutputPort;
        port vehicleOperationRequestOut:VehicleOperationRequestOutputPort;
        port runningLightStateOut:HmiLightOutputPort;
        port selectedFaultIn:SelectedFaultIndicationInputPort;
        port stateOfChargeIn:BatteryStateOfChargeInputPort;
        port batteryCurrentIn:BatteryCurrentInputPort;
        port vehicleMotionIn:QualifiedVehicleMotionInputPort;
        port uartTransmittedDataOut:HmiTransmittedDataOutputPort;
    }
}
