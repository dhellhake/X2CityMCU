package X2CityDetailedUnit_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CityDetailedUnit_RegularSensorQualification::AnalogSampleInputPort;
    private import X2CityDetailedUnit_RegularSensorQualification::SensorHealthOutputPort;

    item def BrakeStateRecord :> BrakeState;
    port def BrakeStateOutputPort {
        doc /* U-BRAKE-QUALIFY sends the qualified Neither/Left/Right/Both brake-lever identity to policy consumers; unknown remains qualification, not a valid released identity. It is the brake-priority source, not a torque command. */
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
