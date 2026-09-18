package X2CityDetailedUnit_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::AnalogSampleInputPort;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::SensorHealthOutputPort;

    item def BrakeStateRecord :> BrakeState;
    port def BrakeStateOutputPort {
        doc /* U-BRAKE-QUALIFY sends the qualified brake/lever state to policy consumers; it is the brake-priority source, not a torque command. */
        out item payload:BrakeStateRecord;
    }
    part def BrakeQualifier {
        port executionTimeIn:ExecutionTimeInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCalibration:BrakeCalibration;
        attribute compiledCalibrationValid:Boolean;
        port stateOut:BrakeStateOutputPort;
        port sensorHealthOut:SensorHealthOutputPort;
    }
    // The owner's fixed build-time set qualifies its named regular scan; configuration provenance is not live state.
}
