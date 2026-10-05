package X2CityComponent_Input {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_RiderDevices::*;
    private import X2CityComponent_AcceleratorPositionIdentification::*;
    private import X2CityComponent_MechanicalBrakeDetection::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_BrakeSignalMeasurement::*;
    private import X2CityContract_BrakeStateIdentification::*;
    part def Input { // LE-INPUT
        /* Composes rider devices, accelerator and mechanical-brake functions. TractionControl owns motor/board-temperature and PVDD/GVDD measurement and qualification. */
        part riderDevices:RiderDevices;
        part accelerator:AcceleratorPositionIdentification;
        part mechanicalBrakeDetection:MechanicalBrakeDetection;
        port brakeLeverStateOut:BrakeLeverStateOutputPort;
        port brakeHealthOut:BrakeHealthOutputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
        port acceleratorHealthOut:AcceleratorHealthOutputPort;
        flow brakeLeverStateFromFunction from mechanicalBrakeDetection.brakeLeverStateOut.brakeLeverState to brakeLeverStateOut.brakeLeverState;
        flow brakeHealthFromFunction from mechanicalBrakeDetection.brakeHealthOut.qualification to brakeHealthOut.qualification;
        flow acceleratorPositionFromFunction from accelerator.acceleratorPositionOut.acceleratorPosition to acceleratorPositionOut.acceleratorPosition;
        flow acceleratorHealthFromFunction from accelerator.acceleratorHealthOut.qualification to acceleratorHealthOut.qualification;
        flow riderElectricalToAccelerator from riderDevices.acceleratorElectricalSignalOut.signal to accelerator.electricalSignalIn.signal;
        interface brakeElectricalSignalToDetection : IfA007BrakeElectricalSignal
            connect riderDevices.brakeElectricalSignalOut to mechanicalBrakeDetection.brakeElectricalSignalIn;
    }
}
