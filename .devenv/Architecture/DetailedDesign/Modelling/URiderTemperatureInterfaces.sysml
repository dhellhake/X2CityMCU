package X2CityDetailedUnit_RiderTemperatureInterfaces {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_TemperatureInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    item def AcceleratorPositionRecord :> AcceleratorPositionV1;
    item def BrakeStateRecord :> BrakeStateV1;
    item def TemperatureRecord :> QualifiedTemperatureV1;
    port def RegularScanInputPort {
        doc /* The accelerator, brake and temperature qualifiers receive only the completed regular-DMA scan from U-ANALOG-ACQ-REGULAR. */
        in item payload:RegularScanV1;
    }
    port def CalibrationInputPort {
        doc /* Receives the active channel conversion, plausibility and calibration data used to qualify rider and temperature observations. */
        in item payload:CalibrationBundleRecord;
    }
    port def AcceleratorPositionOutputPort {
        doc /* U-ACCELERATOR-QUALIFY sends the qualified accelerator position to Settings, Session, Demand and Service; invalid analog evidence is not pedal demand. */
        out item payload:AcceleratorPositionRecord;
    }
    port def BrakeStateOutputPort {
        doc /* U-BRAKE-QUALIFY sends the qualified brake/lever state to policy consumers; it is the brake-priority source, not a torque command. */
        out item payload:BrakeStateRecord;
    }
    port def TemperatureOutputPort {
        doc /* U-TEMPERATURE-QUALIFY sends the qualified vehicle temperature observation to its thermal and battery-policy consumers. */
        out item payload:TemperatureRecord;
    }
    port def SensorHealthOutputPort {
        doc /* Each qualifier publishes its conversion, plausibility and source health so dependent policy can withhold affected observations. */
        out item payload:SensorHealthConditionV1;
    }
    part def AcceleratorQualifier { port scanIn:RegularScanInputPort; port calibrationIn:CalibrationInputPort; port positionOut:AcceleratorPositionOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    part def BrakeQualifier { port scanIn:RegularScanInputPort; port calibrationIn:CalibrationInputPort; port stateOut:BrakeStateOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    part def TemperatureQualifier { port scanIn:RegularScanInputPort; port calibrationIn:CalibrationInputPort; port temperatureOut:TemperatureOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    // Each owner interprets only its named regular scan under the active calibration/context.
}
