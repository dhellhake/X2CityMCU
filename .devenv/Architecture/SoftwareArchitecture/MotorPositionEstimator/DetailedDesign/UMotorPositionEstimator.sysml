package X2CityDetailedUnit_MotorPositionEstimator {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CitySoftwareContract_MotorPositionEstimator::*;
    item def DetailedMotorPositionRecord :> X2CitySoftwareContract_MotorPositionEstimator::MotorPositionRecord, UnitInformationEnvelope;
    port def HallObservationInputPort { doc /* Consumes the common Hall-observation schema published by U-HALL-POSITION. */ in item payload:HallObservation; }
    port def PhaseCurrentEpochInputPort { doc /* Consumes the common PhaseCurrentEpoch schema published by U-MOTOR-PHASE-FAST. */ in item payload:PhaseCurrentEpoch; }
    port def QualifiedAppliedPhaseVoltageInputPort { doc /* Consumes source-qualified observer voltage, unavailable until the separate source is qualified. */ in item payload:QualifiedAppliedPhaseVoltage; }
    port def MotorPositionOutputPort { doc /* Publishes the detailed refinement of the sole final MotorPosition schema. */ out item payload:DetailedMotorPositionRecord; }
    port def MotorPositionHealthOutputPort { doc /* Projects that same record's Qualification occurrence with compatible existing sensor-health metadata. */ out item payload:X2CitySoftwareContract_MotorPositionEstimator::MotorPositionHealthRecord; }
    port def PlatformContextInputPort { doc /* Preserves component reset/context invalidation at the detailed estimator boundary. */ in item payload:PlatformContext; }
    port def PlatformHealthInputPort { doc /* Withholds dependent output when estimator execution context/health is unavailable. */ in item payload:PlatformHealth; }
    part def ElectricalMotorPositionEstimator {
        /* Retains the last accepted Hall sector only under the parent freshness/context rule,
           produces bounded static sector position when permitted, and interpolates only between
           accepted Hall transitions. It adds motor-model/current/applied-voltage assistance only
           when that branch is observable. It never fabricates sensorless startup, forced
           alignment or a velocity proof from static/absent edges. */
        port executionTimeIn:ExecutionTimeInputPort;
        port hallObservationIn:HallObservationInputPort;
        port phaseCurrentEpochIn:PhaseCurrentEpochInputPort;
        port qualifiedAppliedPhaseVoltageIn:QualifiedAppliedPhaseVoltageInputPort;
        port platformContextIn:PlatformContextInputPort;
        port platformHealthIn:PlatformHealthInputPort;
        port motorPositionOut:MotorPositionOutputPort;
        port motorPositionHealthOut:MotorPositionHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledMotorPositionEstimatorCalibration:MotorPositionEstimatorSoftwareCalibration;
        attribute compiledCalibrationValid:Boolean;
        flow qualificationProjectionToHealth from motorPositionOut.payload.Qualification to motorPositionHealthOut.payload;
    }
}
