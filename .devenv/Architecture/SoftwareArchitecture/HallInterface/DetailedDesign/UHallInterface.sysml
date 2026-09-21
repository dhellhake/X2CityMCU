package X2CityDetailedUnit_HallInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_HallInterface::*;
    item def HallCaptureRecord :> HallCapture;
    item def HallObservationRecord :> HallObservation;
    port def HallCaptureOutputPort {
        doc /* U-HALL-CAPTURE sends current sampled Hall state, edges and capture integrity to U-HALL-POSITION; it does not claim mechanical vehicle motion. */
        out item payload:HallCaptureRecord;
    }
    port def HallObservationOutputPort {
        doc /* U-HALL-POSITION sends map/alignment-qualified Hall code, sector bounds and
           transition timing to MotorPositionEstimator; it does not own final angle or speed. */
        out item payload:HallObservationRecord;
    }
    port def HallCaptureInputPort {
        doc /* U-HALL-POSITION receives U-HALL-CAPTURE's current raw Hall record for map, transition and direction interpretation. */
        in item payload:HallCaptureRecord;
    }
    port def SensorHealthOutputPort {
        doc /* Hall capture and position publish capture, transition or map health so downstream units withhold their dependent result. */
        out item payload:SensorHealthCondition;
    }
    part def HallCaptureProcessor { port executionTimeIn:ExecutionTimeInputPort; port hallCaptureOut:HallCaptureOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    part def HallObservationProcessor { attribute compiledCalibrationId:String; attribute compiledHallCalibration:HallCalibration; attribute compiledCalibrationValid:Boolean; port executionTimeIn:ExecutionTimeInputPort; port hallCaptureIn:HallCaptureInputPort; port hallObservationOut:HallObservationOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    // SC-HALL-IF.V owns capture integrity through map/alignment/transition/direction/timestamp observation.
}
