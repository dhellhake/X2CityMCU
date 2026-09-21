package X2CitySoftwareContract_MotorPositionEstimator {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    attribute def MotorPositionEstimatorSoftwareCalibration :> X2CityContract_MotorPositionProcessing::MotorPositionEstimatorCalibration {
        attribute sourceId:String;
        attribute staticSectorErrorBoundElectricalDegrees:Real;
        attribute interpolationErrorBoundElectricalDegrees:Real;
        attribute buildValidated:Boolean;
    }
    item def MotorPositionHealthRecord :> MotorPositionQualification, SensorHealthCondition;
    item def MotorPositionRecord :> MotorPosition {
        // This is the canonical Position/Qualification composite. The identical Qualification
        // occurrence is also published through motorPositionHealthOut; no base-to-subtype cast
        // or separately invented health value is used.
        item Qualification:MotorPositionHealthRecord :>> MotorPosition::Qualification;
    }
    port def HallObservationInputPort {
        doc /* Receives the qualified Hall code, sector bounds and accepted transition evidence.
           This remains the mandatory angle reference. */
        in item payload:HallObservation;
    }
    port def PhaseCurrentEpochInputPort {
        doc /* Receives existing same-operation semantic phase current as an observer contribution;
           it neither creates nor forwards the MotorControl fast-current route. */
        in item payload:PhaseCurrentEpoch;
    }
    port def QualifiedAppliedPhaseVoltageInputPort {
        doc /* Receives only separately source-qualified applied winding voltage. It can remain
           unavailable without invalidating an acceptable Hall-only estimate. */
        in item payload:QualifiedAppliedPhaseVoltage;
    }
    port def MotorPositionOutputPort {
        doc /* The sole final electrical-position output. Position and Qualification stay paired;
           angle availability, observer contribution and signed-speed availability are independent. */
        out item payload:MotorPositionRecord;
    }
    port def MotorPositionHealthOutputPort {
        doc /* Publishes position-estimation health compatible with the existing SensorHealth
           fan-in. It distinguishes recognized required-source failures from weak observer
           observability, which is not a fault by itself. */
        out item payload:MotorPositionHealthRecord;
    }
}

package X2CitySoftwareComponent_MotorPositionEstimator {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_MotorPositionEstimator::*;
    private import X2CitySoftwareContract_Platform::*;
    part def MotorPositionEstimator {
        /* Realizes MotorPositionProcessing from mandatory qualified Hall observations. A valid
           static Hall sector may give a bounded angle at rest. Accepted transitions permit
           bounded interpolation. Current, immutable motor model and separately qualified
           applied-voltage evidence can improve the estimate only when observable. Weak back-EMF
           makes observer contribution unavailable, not a fault. Missing mandatory Hall evidence,
           source contradiction or a recognized required-source failure makes the dependent output
           unavailable and leaves common fault policy to its existing owner. */
        port executionTimeIn:ExecutionTimeInputPort;
        port hallObservationIn:HallObservationInputPort;
        port phaseCurrentEpochIn:PhaseCurrentEpochInputPort;
        port qualifiedAppliedPhaseVoltageIn:QualifiedAppliedPhaseVoltageInputPort;
        port motorPositionOut:MotorPositionOutputPort;
        port motorPositionHealthOut:MotorPositionHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledMotorPositionEstimatorCalibration:MotorPositionEstimatorSoftwareCalibration;
        attribute compiledCalibrationValid:Boolean;
        flow qualificationProjectionToHealth from motorPositionOut.payload.Qualification to motorPositionHealthOut.payload;
    }
}
