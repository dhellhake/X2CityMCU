package X2CitySoftwareContract_HmiAdapter {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CitySoftwareContract_SessionPolicy::*;

    item def HmiRiderSettingsRequest :> ContextualSoftwareInformation, RiderSettingsRequest {
        doc /* Receipt time of the latest validated frame in the caller-supplied host-boot monotonic microsecond domain, not a battery or motor measurement time. A new valid frame refreshes it even when values are unchanged; invalid frames, cached republications and qualification-only updates do not. Before the first valid frame it is unusable under qualification. */
        attribute receiptTimeMicroseconds:Integer;
    }
    item def HmiNormalLightRequest :> ContextualSoftwareInformation, NormalLightRequest {
        doc /* Receipt time of the latest validated frame in the caller-supplied host-boot monotonic microsecond domain, not a battery or motor measurement time. A new valid frame refreshes it even when values are unchanged; invalid frames, cached republications and qualification-only updates do not. Before the first valid frame it is unusable under qualification. */
        attribute receiptTimeMicroseconds:Integer;
    }
    port def RiderSettingsRequestOutputPort :> X2CityContract_SettingsPolicy::RiderSettingsRequestOutputPort {
        doc /* Publishes one qualified current-context rider level/speed receipt. It retains the exact receipt qualification and never substitutes decoder initialization, link state or retained settings. */
        out item payload:HmiRiderSettingsRequest :>> X2CityContract_SettingsPolicy::RiderSettingsRequestOutputPort::payload;
    }
    port def HmiNormalLightRequestOutputPort :> X2CityContract_LightControl::NormalLightRequestOutputPort {
        doc /* Publishes HMI's qualified normal-light request with source/context metadata. Link loss does not fabricate a new request; LightPolicy owns retention. */
        out item normalLightRequest:HmiNormalLightRequest :>> X2CityContract_LightControl::NormalLightRequestOutputPort::normalLightRequest;
    }
    port def SelectedFaultIndicationInputPort :> X2CityContract_SessionPolicy::SelectedFaultIndicationInputPort {
        doc /* Receives Session's already-selected fault wire code, including qualified no-error. HMI neither ranks faults nor owns another report truth. */
        in item selectedFaultIndication:X2CitySoftwareContract_SessionPolicy::SoftwareSelectedFaultIndication :>> X2CityContract_SessionPolicy::SelectedFaultIndicationInputPort::selectedFaultIndication;
    }
    port def BatteryStateOfChargeInputPort :> X2CityContract_BatteryControl::BatteryStateOfChargeInputPort {
        doc /* Receives qualified actual SOC for presentation; a fallback encoding never becomes a battery fact. */
        in item stateOfCharge:BatteryStateOfCharge :>> X2CityContract_BatteryControl::BatteryStateOfChargeInputPort::stateOfCharge;
    }
    port def BatteryCurrentInputPort :> X2CityContract_BatteryControl::BatteryCurrentInputPort {
        doc /* Receives qualified signed pack current for presentation; the protocol may encode a bounded magnitude without changing source qualification. */
        in item batteryCurrent:BatteryCurrent :>> X2CityContract_BatteryControl::BatteryCurrentInputPort::batteryCurrent;
    }
    port def QualifiedVehicleMotionInputPort :> X2CityContract_MotorControl::QualifiedVehicleMotionInputPort {
        doc /* Receives Traction's qualified physical vehicle speed/direction/standstill record for display speed and period. Invalid speed/status bits remain protocol fallback gates. */
        in item payload:QualifiedMotion :>> X2CityContract_MotorControl::QualifiedVehicleMotionInputPort::payload;
    }
}

package X2CitySoftwareComponent_HmiAdapter {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_HmiAdapter::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityContract_LightControl::*;
    private import X2CitySoftwareContract_Platform::*;
    part def HmiAdapter {
        /* SC-HMI.V realizes LE-HMI information processing. It decodes qualified VD18MT frames,
           publishes settings/light requests, and encodes the selected Session fault, battery and
           motion records. Software owns framing/protocol/timestamps; the electrical leaf owns
           the fixed five-pin electrical roles and conditioned on/wake path, while a concrete
           driver/peripheral binding remains a realization decision. */
        port executionTimeIn:ExecutionTimeInputPort;
        port uartReceivedDataIn:HmiUartReceivedDataInputPort;
        port uartTransmittedDataOut:HmiUartTransmittedDataOutputPort;
        port ridingSettingsOut:RiderSettingsRequestOutputPort;
        port runningLightStateOut:HmiNormalLightRequestOutputPort;
        port selectedFaultIn:SelectedFaultIndicationInputPort;
        port stateOfChargeIn:BatteryStateOfChargeInputPort;
        port batteryCurrentIn:BatteryCurrentInputPort;
        port vehicleMotionIn:QualifiedVehicleMotionInputPort;
        // Reset and health facts invalidate local decoder context; neither becomes a receipt,
        // selected fault or HMI health publication.
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
    }
}
