package X2CityDetailedComponent_TractionControlImplementation {
    private import X2CitySoftwareComponent_TractionControl::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityDetailedUnit_TractionAccept::*;
    private import X2CityDetailedUnit_TractionActualOutput::*;
    private import X2CityDetailedUnit_TractionMotion::*;
    private import X2CityDetailedUnit_TractionControl::*;
    private import X2CityDetailedUnit_TractionOutput::*;

    // Retains the existing detailed observation envelope at the selected DD boundary while
    // refining the software service-report occurrence with its compatible owner record.
    port def DetailedTractionObservationOutputPort :> X2CitySoftwareContract_TractionControl::TractionObservationOutputPort {
        doc /* Publishes the existing U-TRACTION-ACCEPT observation envelope at the selected detailed boundary. The record remains compatible with the inherited software service-report occurrence and with existing detailed generic consumers. */
        out item payload:TractionObservationRecord :>> X2CitySoftwareContract_TractionControl::TractionObservationOutputPort::payload;
    }

    part def TractionControlImplementation :> TractionControl {
        /* The selected detailed realization of SC-TRACTION-CTRL.V owns these five existing
           units. Its inherited logical/software ports remain explicit architecture boundaries;
           this composition introduces no runtime task, queue, calibration choice or hardware
           allocation. U-TRACTION-ACCEPT remains the public applied-output forwarder, motion
           retains its Hall-specific qualification inputs, and U-TRACTION-OUTPUT remains the
           sole PWM/ADC plan committer. */
        port ridingAuthorityIn:X2CitySoftwareContract_TractionControl::RidingAuthorityInputPort :>> TractionControl::ridingAuthorityIn;
        port wheelTorqueRequestIn:X2CitySoftwareContract_TractionControl::WheelTorqueRequestInputPort :>> TractionControl::wheelTorqueRequestIn;
        port hallElectricalPositionIn:X2CitySoftwareContract_TractionControl::HallElectricalPositionInputPort :>> TractionControl::hallElectricalPositionIn;
        port phaseCurrentEpochIn:X2CitySoftwareContract_TractionControl::PhaseCurrentEpochInputPort :>> TractionControl::phaseCurrentEpochIn;
        port fastDcLinkVoltageIn:X2CitySoftwareContract_TractionControl::FastDcLinkVoltageInputPort :>> TractionControl::fastDcLinkVoltageIn;
        port sensorHealthIn:X2CitySoftwareContract_TractionControl::TractionSensorHealthInputPort :>> TractionControl::sensorHealthIn;
        port motionHealthIn:X2CitySoftwareContract_TractionControl::MotionHealthInputPort :>> TractionControl::motionHealthIn;
        port tractionOutputStageExchange:X2CitySoftwareContract_TractionControl::TractionOutputStageExchangePort :>> TractionControl::tractionOutputStageExchange;
        port qualifiedMotionOut:X2CitySoftwareContract_TractionControl::QualifiedMotionOutputPort :>> TractionControl::qualifiedMotionOut;
        port appliedTractionStateOut:X2CitySoftwareContract_TractionControl::AppliedTractionStateOutputPort :>> TractionControl::appliedTractionStateOut;
        port tractionObservationOut:DetailedTractionObservationOutputPort :>> TractionControl::tractionObservationOut;
        port platformContextIn:~X2CitySoftwareContract_Platform::PlatformContextOutputPort :>> TractionControl::platformContextIn;
        port platformHealthIn:~X2CitySoftwareContract_Platform::PlatformHealthOutputPort :>> TractionControl::platformHealthIn;
        // The inherited component owns one immutable compiled parameter set. These attributes
        // bind that same set to the two detailed estimators; no unit receives a runtime message.
        attribute compiledCalibrationId:String :>> TractionControl::compiledCalibrationId;
        attribute compiledActualOutputEstimationCalibration:ActualOutputEstimationCalibration :>> TractionControl::compiledActualOutputEstimationCalibration;
        attribute compiledMotionEstimationCalibration:MotionEstimationCalibration :>> TractionControl::compiledMotionEstimationCalibration;
        attribute compiledCalibrationValid:Boolean :>> TractionControl::compiledCalibrationValid;

        part accept:TractionCommandAcceptor;
        part actualOutput:ActualTractionOutputEstimator;
        part motion:VehicleMotionEstimator;
        part control:FocControl;
        part output:TractionOutputCommitter;

        // Boundary-to-unit mappings preserve the current direct handoffs; they introduce no
        // scheduler, queue, second command path, or change to the qualification conditions.
        flow authorityToAccept from ridingAuthorityIn.payload to accept.authorityIn.payload;
        // This selected realization inherits TractionControl.executionTimeIn as its sole
        // boundary occurrence. The direct fast caller supplies the same fixed invocation
        // reference to every unit within this one bounded component invocation. A separately
        // dispatched component or standalone unit receives a fresh caller sample. These mappings
        // add no scheduler or queue; timeout/deadline guards conservatively cover elapsed time
        // from this snapshot through their relevant effect.
        flow executionTimeToAccept from executionTimeIn.payload to accept.executionTimeIn.payload;
        flow executionTimeToActualOutput from executionTimeIn.payload to actualOutput.executionTimeIn.payload;
        flow executionTimeToMotion from executionTimeIn.payload to motion.executionTimeIn.payload;
        flow executionTimeToControl from executionTimeIn.payload to control.executionTimeIn.payload;
        flow executionTimeToOutput from executionTimeIn.payload to output.executionTimeIn.payload;
        flow commandToAccept from wheelTorqueRequestIn.payload to accept.commandIn.payload;
        flow hallToControl from hallElectricalPositionIn.payload to control.electricalPositionIn.payload;
        flow hallToMotion from hallElectricalPositionIn.payload to motion.electricalPositionIn.payload;
        flow hallToActualOutput from hallElectricalPositionIn.payload to actualOutput.electricalPositionIn.payload;
        flow phaseToControl from phaseCurrentEpochIn.payload to control.phaseFeedbackIn.payload;
        flow phaseToActualOutput from phaseCurrentEpochIn.payload to actualOutput.phaseFeedbackIn.payload;
        flow fastDcLinkToControl from fastDcLinkVoltageIn.payload to control.fastDcLinkVoltageIn.payload;
        flow sensorHealthToControl from sensorHealthIn.payload to control.sensorHealthIn.payload;
        flow motionHealthToMotion from motionHealthIn.payload to motion.motionHealthIn.payload;
        flow stageEvidenceToOutput from tractionOutputStageExchange.payload to output.outputStageEvidenceIn.payload;
        flow pwmAndAdcPlanToOutput from control.pwmAndAdcSamplingPlanOut.payload to output.pwmAndAdcSamplingPlanIn.payload;
        flow outputObservationToActualOutput from output.outputObservationOut.payload to actualOutput.outputStageEvidenceIn.payload;
        flow outputObservationToBoundary from output.outputObservationOut.payload to tractionOutputStageExchange.payload;
        flow qualifiedMotionToBoundary from motion.qualifiedMotionOut.payload to qualifiedMotionOut.payload;
        flow actualOutputToAccept from actualOutput.appliedTractionStateOut.payload to accept.actualOutputIn.payload;
        flow qualifiedMotionToActualOutput from motion.qualifiedMotionOut.payload to actualOutput.qualifiedMotionIn.payload;
        flow appliedOutputToBoundary from accept.appliedTractionStateOut.payload to appliedTractionStateOut.payload;
        flow observationToBoundary from accept.observationOut.payload to tractionObservationOut.payload;
        flow platformContextToMotion from platformContextIn.payload to motion.platformContextIn.payload;
        flow platformContextToActualOutput from platformContextIn.payload to actualOutput.platformContextIn.payload;
        flow platformHealthToMotion from platformHealthIn.payload to motion.platformHealthIn.payload;
        flow platformHealthToActualOutput from platformHealthIn.payload to actualOutput.platformHealthIn.payload;
        bind compiledCalibrationId = motion.compiledCalibrationId;
        bind compiledCalibrationId = actualOutput.compiledCalibrationId;
        bind compiledMotionEstimationCalibration = motion.compiledMotionEstimationCalibration;
        bind compiledActualOutputEstimationCalibration = actualOutput.compiledActualOutputEstimationCalibration;
        bind compiledCalibrationValid = motion.compiledCalibrationValid;
        bind compiledCalibrationValid = actualOutput.compiledCalibrationValid;
        flow acceptedDemandToControl from accept.acceptedCommandOut.payload to control.acceptedDemandIn.payload;
    }
}
