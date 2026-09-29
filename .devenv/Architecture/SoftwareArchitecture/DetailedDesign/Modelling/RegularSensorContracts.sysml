package X2CityDetailedUnit_RegularSensorQualification {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;

    // Shared detailed contracts for semantic owners of completed regular ADC records.
    alias AcceleratorPositionRecord for X2CityDetailedUnit_AcceleratorInterface::AcceleratorPositionRecord;
    alias AcceleratorPositionOutputPort for X2CityDetailedUnit_AcceleratorInterface::AcceleratorPositionOutputPort;
    alias AcceleratorQualifier for X2CityDetailedUnit_AcceleratorInterface::AcceleratorQualifier;
    alias BrakeLeverStateOutputPort for X2CityDetailedUnit_BrakeInterface::BrakeLeverStateOutputPort;
    alias BrakeHealthOutputPort for X2CityDetailedUnit_BrakeInterface::BrakeHealthOutputPort;
    alias BrakeQualifier for X2CityDetailedUnit_BrakeInterface::BrakeQualifier;
    alias TemperatureRecord for X2CityDetailedUnit_TemperatureInterface::TemperatureRecord;
    alias TemperatureOutputPort for X2CityDetailedUnit_TemperatureInterface::TemperatureOutputPort;
    alias TemperatureQualifier for X2CityDetailedUnit_TemperatureInterface::TemperatureQualifier;

    port def AnalogSampleInputPort {
        doc /* Accelerator, brake and traction-board/motor-temperature qualifiers receive only the completed regular-DMA scan from U-ANALOG-ACQ-REGULAR. */
        in item payload:AnalogSampleRecord;
    }
    port def SensorHealthOutputPort {
        doc /* Temperature qualifiers publish conversion, plausibility and source health so dependent policy can withhold affected observations. Brake uses its exact BrakeQualification projection instead. */
        out item payload:SensorHealthCondition;
    }
}
