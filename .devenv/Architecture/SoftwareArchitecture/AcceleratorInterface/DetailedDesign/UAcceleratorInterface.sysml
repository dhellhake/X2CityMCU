package X2CityDetailedUnit_AcceleratorInterface {
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::RegularScanInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::CalibrationInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::SensorHealthOutputPort;

    item def AcceleratorPositionRecord :> AcceleratorPositionV1;
    port def AcceleratorPositionOutputPort {
        doc /* U-ACCELERATOR-QUALIFY sends the qualified accelerator position to Settings, Session, Demand and Service; invalid analog evidence is not pedal demand. */
        out item payload:AcceleratorPositionRecord;
    }
    part def AcceleratorQualifier {
        port scanIn:RegularScanInputPort;
        port calibrationIn:CalibrationInputPort;
        port positionOut:AcceleratorPositionOutputPort;
        port sensorHealthOut:SensorHealthOutputPort;
    }
    // Each owner interprets only its named regular scan under the active calibration/context.
}
