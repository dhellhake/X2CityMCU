package X2CityComponent_Traction {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_MotorControl::*;
    private import X2CityComponent_MotorPositionEstimation::*;
    private import X2CityComponent_TractionHardware::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_DemandPolicy::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_MotorSignalMeasurement::*;
    part def Traction { // LE-TRACTION
        /* Composes MotorControl, MotorPositionEstimation and traction hardware. Motor-position estimation is a
           sibling of MotorControl: it delivers electrical position and explicit phase measurements, while physical
           actuation and the bidirectional traction-power boundary remain in Traction. */
        part motorControl:MotorControl;
        part motorPositionEstimation:MotorPositionEstimation;
        part tractionHardware:TractionHardware;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort;
        port tractionElectricalPower:TractionElectricalPowerPort { doc /* Physical bidirectional EnergyPath connection for propulsion and regenerative return. */ }
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort;
        port actualTractionOutputOut:ActualTractionOutputPort;
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort { doc /* Publishes MotorControl's qualified actual electrical-braking projection for LightControl. */ }
        port motorPositionHealthOut:MotorPositionHealthOutputPort { doc /* Delivers estimator health to the existing platform fault-supervision path. */ }
        port fastDcLinkVoltageIn:FastDcLinkVoltageInputPort { doc /* Receives qualified local PVDD for the existing fast traction-control route. */ }
        port supplyHealthIn:SupplyHealthInputPort { doc /* Receives supply-path qualification only; it does not set Session policy. */ }
        // Delegates the existing logical traction boundary to its sole MotorControl occurrence.
        flow ridingAuthorityToMotorControl from ridingAuthorityIn.payload to motorControl.ridingAuthorityIn.payload;
        flow wheelTorqueCommandToMotorControl from wheelTorqueCommandIn.payload to motorControl.wheelTorqueCommandIn.payload;
        flow fastDcLinkVoltageToMotorControl from fastDcLinkVoltageIn.payload to motorControl.fastDcLinkVoltageIn.payload;
        flow supplyHealthToMotorControl from supplyHealthIn.qualification to motorControl.supplyHealthIn.qualification;
        flow hallSignalsToMotorPositionEstimation from tractionHardware.hallSignalsOut.hallSignals to motorPositionEstimation.hallSignalsIn.hallSignals;
        flow motorPhaseElectricalToMotorPositionEstimation from tractionHardware.motorPhaseElectricalOut.motorPhaseElectrical to motorPositionEstimation.motorPhaseElectricalIn.motorPhaseElectrical;
        interface motorPositionToMotorControl : IfA005MotorPosition
            connect motorPositionEstimation.motorPositionOut to motorControl.motorPositionIn;
        interface phaseCurrentToMotorControl : IfA005PhaseCurrentMeasurements
            connect motorPositionEstimation.phaseCurrentOut to motorControl.phaseCurrentIn;
        flow motorPositionHealthFromEstimation from motorPositionEstimation.motorPositionHealthOut.health to motorPositionHealthOut.health;
        flow qualifiedMotionFromMotorControl from motorControl.qualifiedVehicleMotionOut.payload to qualifiedVehicleMotionOut.payload;
        flow actualOutputFromMotorControl from motorControl.actualTractionOutputOut.payload to actualTractionOutputOut.payload;
        flow electricalBrakingFromMotorControl from motorControl.electricalBrakingStateOut.payload to electricalBrakingStateOut.payload;
    }
}
