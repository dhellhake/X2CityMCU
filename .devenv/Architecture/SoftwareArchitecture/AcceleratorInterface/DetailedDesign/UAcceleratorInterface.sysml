package X2CityDetailedUnit_AcceleratorInterface {
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::RegularScanInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::CalibrationInputPort;

    item def AcceleratorPositionRecord :> AcceleratorPosition;
    port def AcceleratorPositionOutputPort {
        doc /* U-ACCELERATOR-QUALIFY sends one position-and-health composite to Settings, Session, Demand and Service. Position is used only when its contained Qualification supports it; unavailability and current health are published even with no new ADC sample, without refreshing Position sample provenance or measurement freshness. */
        out item payload:AcceleratorPositionRecord;
    }
    part def AcceleratorQualifier {
        port scanIn:RegularScanInputPort;
        port calibrationIn:CalibrationInputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
    }
    // Each owner interprets only its named regular scan under the active calibration/context.
}
