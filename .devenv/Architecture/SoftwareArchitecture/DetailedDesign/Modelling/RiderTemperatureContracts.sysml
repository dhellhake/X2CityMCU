package X2CityDetailedUnit_RiderTemperatureInterfaces {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;

    // Compatibility aliases preserve the original public API names and qualified identities.
    alias AcceleratorPositionRecord for X2CityDetailedUnit_AcceleratorInterface::AcceleratorPositionRecord;
    alias AcceleratorPositionOutputPort for X2CityDetailedUnit_AcceleratorInterface::AcceleratorPositionOutputPort;
    alias AcceleratorQualifier for X2CityDetailedUnit_AcceleratorInterface::AcceleratorQualifier;
    alias BrakeStateRecord for X2CityDetailedUnit_BrakeInterface::BrakeStateRecord;
    alias BrakeStateOutputPort for X2CityDetailedUnit_BrakeInterface::BrakeStateOutputPort;
    alias BrakeQualifier for X2CityDetailedUnit_BrakeInterface::BrakeQualifier;
    alias TemperatureRecord for X2CityDetailedUnit_TemperatureInterface::TemperatureRecord;
    alias TemperatureOutputPort for X2CityDetailedUnit_TemperatureInterface::TemperatureOutputPort;
    alias TemperatureQualifier for X2CityDetailedUnit_TemperatureInterface::TemperatureQualifier;

    port def RegularScanInputPort {
        doc /* The accelerator, brake and temperature qualifiers receive only the completed regular-DMA scan from U-ANALOG-ACQ-REGULAR. */
        in item payload:RegularScan;
    }
    port def CalibrationInputPort {
        doc /* Receives the active channel conversion, plausibility and calibration data used to qualify rider and temperature observations. */
        in item payload:CalibrationBundleRecord;
    }
    port def SensorHealthOutputPort {
        doc /* Each qualifier publishes its conversion, plausibility and source health so dependent policy can withhold affected observations. */
        out item payload:SensorHealthCondition;
    }
}
