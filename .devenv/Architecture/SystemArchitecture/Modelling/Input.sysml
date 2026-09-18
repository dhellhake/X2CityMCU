package X2CityContract_Input {
    private import X2CitySharedContracts::*;
    item def QualifiedBrakeInput:>QualifiedInformationRecord;
    port def BrakeStateOutputPort {
        doc /* Carries input-qualified coded-brake actuation or unknown to policy consumers. Accelerator position/rest is a separate typed LE-ACCELERATOR publication; Traction separately publishes vehicle motion qualification. */
        out item payload:QualifiedBrakeInput;
    }
    port def BrakeStateInputPort {
        doc /* Carries input-qualified coded-brake actuation or unknown to policy consumers. Accelerator position/rest is a separate typed LE-ACCELERATOR publication; Traction separately publishes vehicle motion qualification. */
        in item payload:QualifiedBrakeInput;
    }
    interface def IfA001QualifiedBrakeInput { end producer:BrakeStateOutputPort; end consumer:BrakeStateInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_Input {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RiderDevices::*;
    private import X2CityComponent_InputHardware::*;
    private import X2CityComponent_InputQualification::*;
    private import X2CityComponent_BmsLink::*;
    private import X2CityComponent_AcceleratorPositionIdentification::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_SettingsPolicy::*;
    private import X2CityContract_BatteryProtection::*;
    private import X2CityContract_HmiAdapter::*;
    part def Input { // LE-INPUT
        /* Composes rider devices, retained generic input hardware/qualification, the accelerator function,
           and the BMS link. Traction owns vehicle motion and actual-output
           feedback; LE-INPUT does not republish those observations. */
        part riderDevices:RiderDevices;
        part inputHardware:InputHardware;
        part inputQualification:InputQualification;
        part accelerator:AcceleratorPositionIdentification;
        part bmsLink:BmsLink;
        port qualifiedBrakeInputOut:BrakeStateOutputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
        port acceleratorHealthOut:AcceleratorHealthOutputPort;
        port riderSettingsRequestOut:RiderSettingsRequestOutputPort;
        port energyBatteryObservationIn:BatteryConditionObservationInputPort;
        port tractionBatteryObservationIn:BatteryConditionObservationInputPort;
        port batteryConditionObservationOut:BatteryConditionObservationOutputPort;
        port lightingContextOut:LightingContextOutputPort;
        flow acceleratorPositionFromFunction from accelerator.acceleratorPositionOut.payload to acceleratorPositionOut.payload;
        flow acceleratorHealthFromFunction from accelerator.acceleratorHealthOut.payload to acceleratorHealthOut.payload;
        flow riderElectricalToAccelerator from riderDevices.acceleratorElectricalSignalOut.payload to accelerator.electricalSignalIn.payload;
    }
}
