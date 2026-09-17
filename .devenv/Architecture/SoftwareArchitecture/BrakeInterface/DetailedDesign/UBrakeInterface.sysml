package X2CityDetailedUnit_BrakeInterface {
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::AnalogSampleInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::CalibrationInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::SensorHealthOutputPort;

    item def BrakeStateRecord :> BrakeState;
    port def BrakeStateOutputPort {
        doc /* U-BRAKE-QUALIFY sends the qualified brake/lever state to policy consumers; it is the brake-priority source, not a torque command. */
        out item payload:BrakeStateRecord;
    }
    part def BrakeQualifier {
        port analogSampleIn:AnalogSampleInputPort;
        port calibrationIn:CalibrationInputPort;
        port stateOut:BrakeStateOutputPort;
        port sensorHealthOut:SensorHealthOutputPort;
    }
    // Each owner interprets only its named regular scan under the active calibration/context.
}
