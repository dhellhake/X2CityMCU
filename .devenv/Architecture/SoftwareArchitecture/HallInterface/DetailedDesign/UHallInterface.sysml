package X2CityDetailedUnit_HallInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_HallInterface::*;
    item def HallCaptureRecord :> HallCapture;
    item def HallElectricalPositionRecord :> HallElectricalPosition;
    port def HallCaptureOutputPort {
        doc /* U-HALL-CAPTURE sends current sampled Hall state, edges and capture integrity to U-HALL-POSITION; it does not claim mechanical vehicle motion. */
        out item payload:HallCaptureRecord;
    }
    port def ElectricalPositionOutputPort {
        doc /* U-HALL-POSITION sends map/alignment-qualified electrical rotor sector, direction and edge timing to traction consumers. */
        out item payload:HallElectricalPositionRecord;
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
    part def ElectricalPositionEstimator { attribute compiledCalibrationId:String; attribute compiledHallCalibration:HallCalibration; attribute compiledCalibrationValid:Boolean; port executionTimeIn:ExecutionTimeInputPort; port hallCaptureIn:HallCaptureInputPort; port electricalPositionOut:ElectricalPositionOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    // SC-HALL-IF.V owns capture integrity through map/alignment/transition/direction/timestamp result.
}
