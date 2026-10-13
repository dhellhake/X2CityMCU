package X2CitySoftwareContract_HallInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    attribute def HallCalibration {
        attribute sourceId:String;
        attribute electricalMapId:String;
        attribute alignmentElectricalDegrees:Real;
        attribute captureTimerId:String;
        attribute captureTimerTickNanoseconds:Real;
    }
    item def HallCapture:>ContextualSoftwareInformation {
        attribute capturedHallState:Integer;
        attribute captureChannel:String;
        // The capture boundary relates any native timer capture to the common host-boot domain;
        // the call time never pretends that an older edge occurred at invocation.
        attribute captureTimeMicroseconds:Integer;
        attribute captureSequence:Integer;
    }
    port def HallCaptureInputPort {
        doc /* Receives captured Hall channel state, channel identity, common-domain capture time and sequence from the vehicle capture boundary. HallInterface validates transitions and capture integrity before deriving electrical position. */
        in item payload:HallCapture;
    }
    item def HallObservation:>ContextualSoftwareInformation {
        // This is an observation, not the final electrical-angle estimate.  The bounded sector
        // is usable at rest after map/alignment acceptance; signed speed remains separately
        // qualified by MotorPositionEstimator.
        attribute hallCode:Integer;
        attribute electricalSector:Integer;
        attribute sectorLowerElectricalDegrees:Real;
        attribute sectorUpperElectricalDegrees:Real;
        attribute transitionDirection:String; // enum: forward, reverse, unavailable.
        attribute transitionTimeMicroseconds:Integer;
        attribute transitionSequence:Integer;
        attribute acceptedTransition:Boolean;
        attribute observationTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def HallObservationOutputPort {
        doc /* Publishes qualified Hall code/sector/bounds and accepted transition evidence to
           MotorPositionEstimator. It does not publish a final electrical angle or infer speed,
           vehicle motion or standstill. */
        out item payload:HallObservation;
    }
    port def HallHealthOutputPort {
        doc /* Publishes Hall capture and position-estimation health evidence to Platform, RidingControl session logic and TractionControl. Overrun, incoherence, age, context or calibration failure is represented through the health qualification. */
        out item payload:SensorHealthCondition;
    }
}

package X2CitySoftwareComponent_HallInterface {
    private import X2CitySoftwareContract_HallInterface::*;
    // SC-HALL-IF.V; qualified Hall-observation interface.
    part def HallInterface {
        /* Owns capture integrity, rings and bounded access; transition acceptance, direction
           and map/alignment-qualified Hall observation. It publishes unavailable on overrun,
           incoherence, age, context or calibration failure. MotorPositionEstimator alone owns
           final electrical angle and signed-speed estimation. */
        port executionTimeIn:ExecutionTimeInputPort;
        port hallCaptureIn:HallCaptureInputPort;
        port hallObservationOut:HallObservationOutputPort;
        port hallHealthOut:HallHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledHallCalibration:HallCalibration;
        attribute compiledCalibrationValid:Boolean; // Startup check failure withholds electrical-position qualification.
        // U-HALL-CAPTURE and U-HALL-POSITION retain the direct bounded fast-access path.
    }
}
