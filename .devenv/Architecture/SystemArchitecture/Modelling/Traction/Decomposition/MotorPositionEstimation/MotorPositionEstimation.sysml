package X2CityComponent_MotorPositionEstimation {
    private import X2CityComponent_MotorSignalMeasurement::*;
    private import X2CityComponent_MotorPositionProcessing::*;
    private import X2CityContract_MotorSignalMeasurement::*;
    private import X2CityContract_MotorPositionProcessing::*;

    part def MotorPositionEstimation { // LE-MOTOR-POSITION
        /* End-to-end electrical rotor-position function. Hall evidence is mandatory; current and
           applied-voltage evidence may improve the accepted estimate when observable. It owns no
           torque command, sensorless fallback, forced alignment, stationary holding or peripheral binding. */
        part signalMeasurement:MotorSignalMeasurement;
        part positionProcessing:MotorPositionProcessing;
        port hallSignalsIn:HallSignalsInputPort { doc /* Direct raw physical Hall electrical levels at the Traction boundary. */ }
        port motorPhaseElectricalIn:MotorPhaseElectricalInputPort { doc /* Direct raw physical phase-current and bridge-voltage observation at the Traction boundary. */ }
        port motorPositionOut:MotorPositionOutputPort { doc /* Publishes the one electrical Position/Qualification composite to MotorControl and fault supervision. Recognized faults retain Qualification and leave unavailable Position members unavailable. */ }
        port phaseCurrentOut:PhaseCurrentMeasurementsOutputPort { doc /* Publishes semantic qualified phase-current feedback needed by MotorControl. Applied-winding voltage remains estimator-internal evidence. */ }
        flow hallSignalsToMeasurement from hallSignalsIn.hallSignals to signalMeasurement.hallSignalsIn.hallSignals;
        flow motorPhaseElectricalToMeasurement from motorPhaseElectricalIn.motorPhaseElectrical to signalMeasurement.motorPhaseElectricalIn.motorPhaseElectrical;
        interface measurementsToProcessing : IfA005MotorSignalMeasurements
            connect signalMeasurement.motorSignalMeasurementsOut to positionProcessing.motorSignalMeasurementsIn;
        flow positionFromProcessing from positionProcessing.motorPositionOut.motorPosition to motorPositionOut.motorPosition;
        flow phaseCurrentFromProcessing from positionProcessing.phaseCurrentOut.phaseCurrentMeasurements to phaseCurrentOut.phaseCurrentMeasurements;
    }
}
