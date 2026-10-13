package X2CityComponent_Traction {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_TractionControl::*;
    private import X2CityComponent_MotorPositionEstimation::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_MotorSignalMeasurement::*;
    part def Traction { // LE-TRACTION
        /* Wrapper for TractionControl and sibling MotorPositionEstimation. Hall and phase electrical observation
           enter the estimator directly: board packaging never makes TractionHardware their logical source. */
        part tractionControl:TractionControl;
        part motorPositionEstimation:MotorPositionEstimation;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort;
        port tractionElectricalPower:TractionElectricalPowerPort { doc /* Physical bidirectional EnergyPath connection for propulsion and regenerative return. */ }
        port physicalMotorActuation:PhysicalMotorActuationPort { doc /* Explicit physical motor-actuation boundary delegated to TractionControl hardware. */ }
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort { doc /* Delegates TractionControl's qualified physical-motion evidence. */ }
        port actualTractionOutputOut:ActualTractionOutputPort { doc /* Delegates TractionControl's actual output-stage evidence. */ }
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort { doc /* Publishes MotorControl's qualified actual electrical-braking projection for LightControl. */ }
        port motorPositionOut:MotorPositionOutputPort { doc /* Delivers the estimator's full electrical Position/Qualification composite to platform and Session fault supervision. */ }
        port hallSignalsIn:HallSignalsInputPort { doc /* Direct physical Hall input for sibling MotorPositionEstimation. */ }
        port motorPhaseElectricalIn:MotorPhaseElectricalInputPort { doc /* Direct physical phase-current/voltage observation for sibling MotorPositionEstimation. */ }
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort { doc /* Value-carrying qualified motor/board temperature observation. */ }
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort { doc /* Value-carrying qualified PVDD observation. */ }
        port tractionConditionEvidenceOut:TractionConditionEvidenceOutputPort { doc /* Local categorized traction evidence for Session; it has no local latch. */ }
        flow ridingAuthorityToTractionControl from ridingAuthorityIn.payload to tractionControl.ridingAuthorityIn.payload;
        flow wheelTorqueCommandToTractionControl from wheelTorqueCommandIn.payload to tractionControl.wheelTorqueCommandIn.payload;
        interface energyToTractionControl : IfA010TractionElectricalPower
            connect tractionElectricalPower to tractionControl.tractionElectricalPower;
        interface motorActuationFromTractionControl : IfA005PhysicalMotorActuation
            connect tractionControl.physicalMotorActuation to physicalMotorActuation;
        flow hallSignalsToMotorPositionEstimation from hallSignalsIn.hallSignals to motorPositionEstimation.hallSignalsIn.hallSignals;
        flow motorPhaseElectricalToMotorPositionEstimation from motorPhaseElectricalIn.motorPhaseElectrical to motorPositionEstimation.motorPhaseElectricalIn.motorPhaseElectrical;
        interface motorPositionToTractionControl : IfA005MotorPosition
            connect motorPositionEstimation.motorPositionOut to tractionControl.motorPositionIn;
        interface phaseCurrentToTractionControl : IfA005PhaseCurrentMeasurements
            connect motorPositionEstimation.phaseCurrentOut to tractionControl.phaseCurrentIn;
        flow motorPositionFromEstimation from motorPositionEstimation.motorPositionOut.motorPosition to motorPositionOut.motorPosition;
        flow qualifiedTemperatureFromTractionControl from tractionControl.qualifiedTemperatureOut.payload to qualifiedTemperatureOut.payload;
        flow fastDcLinkVoltageFromTractionControl from tractionControl.fastDcLinkVoltageOut.payload to fastDcLinkVoltageOut.payload;
        flow localConditionFromTractionControl from tractionControl.tractionConditionEvidenceOut.payload to tractionConditionEvidenceOut.payload;
        flow qualifiedMotionFromTractionControl from tractionControl.qualifiedVehicleMotionOut.payload to qualifiedVehicleMotionOut.payload;
        flow actualOutputFromTractionControl from tractionControl.actualTractionOutputOut.payload to actualTractionOutputOut.payload;
        flow electricalBrakingFromTractionControl from tractionControl.electricalBrakingStateOut.payload to electricalBrakingStateOut.payload;
    }
}
