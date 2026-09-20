package X2CityContract_Input {
    private import X2CitySharedContracts::*;
    item def QualifiedBrakeInput:>QualifiedInformationRecord {
        doc /* InputQualification's qualified mechanical brake-lever state. true means either or both levers are actuated; false means both levers are qualified released. It is not a measured brake force and does not assert electrical or recuperative braking. Qualification carries unavailable or unknown states. */
        attribute brakeLeverActuated:Boolean;
    }
    port def BrakeStateOutputPort {
        doc /* Carries InputQualification's qualified mechanical brake-lever state to policy consumers. Accelerator position/rest is a separate typed LE-ACCELERATOR publication; Traction separately publishes vehicle motion qualification and actual electrical braking. */
        out item payload:QualifiedBrakeInput;
    }
    port def BrakeStateInputPort {
        doc /* Carries InputQualification's qualified mechanical brake-lever state to policy consumers. Accelerator position/rest is a separate typed LE-ACCELERATOR publication; Traction separately publishes vehicle motion qualification and actual electrical braking. */
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
        flow qualifiedBrakeFromInputQualification from inputQualification.brakeLeverStateOut.payload to qualifiedBrakeInputOut.payload;
        flow acceleratorPositionFromFunction from accelerator.acceleratorPositionOut.acceleratorPosition to acceleratorPositionOut.acceleratorPosition;
        flow acceleratorHealthFromFunction from accelerator.acceleratorHealthOut.qualification to acceleratorHealthOut.qualification;
        flow riderElectricalToAccelerator from riderDevices.acceleratorElectricalSignalOut.signal to accelerator.electricalSignalIn.signal;
    }
}
