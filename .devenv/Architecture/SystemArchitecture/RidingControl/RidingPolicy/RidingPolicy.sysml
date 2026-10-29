package X2CityComponent_RidingPolicy {
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_Compute::*;
    private import X2CityContract_HmiControl::*;
    part def RidingPolicy { // LE-RIDING-POLICY
        doc /* Owns requested, pending and active settings, operation-session and fault lifetime, riding authority, demand arbitration, capability recovery, regenerative recovery and post-stop state. Explicit qualified Off ends the session regardless of motion; subsequent On begins fresh qualification. Authority and signed demand are separate outputs. */
        port tractionCurrentBudgetIn:TractionCurrentBudgetInputPort { doc /* Receives the sole coordinator's independently qualified traction current budgets for demand and command publication. */ }
        port vehicleOperationRequestIn:VehicleOperationRequestInputPort { doc /* Qualified interpretation of the physical On/Off request; UART availability is independent. */ }
        port runtimeInitializationIn:ComputeRuntimeInitializationInputPort { doc /* Compute startup/runtime readiness evidence for operation qualification. */ }
        port brakeLeverStateIn:BrakeLeverStateInputPort { doc /* Qualified brake lever State and Qualification from DriverInteraction. */ }
        port acceleratorPositionIn:AcceleratorPositionInputPort { doc /* Qualified accelerator Position and Qualification from DriverInteraction. */ }
        port qualifiedVehicleMotionIn:QualifiedVehicleMotionInputPort { doc /* Traction-owned qualified speed, direction and standstill evidence. */ }
        port motorPositionIn:MotorPositionInputPort { doc /* Estimator Position and Qualification for existing fault supervision. */ }
        port qualifiedTemperatureIn:QualifiedTemperatureInputPort { doc /* Qualified motor and traction-board temperature observations. */ }
        port tractionConditionEvidenceIn:TractionConditionEvidenceInputPort { doc /* Local traction condition evidence for RidingControl fault selection and lifetime. */ }
        port hmiRiderSettingsRequestIn:RiderSettingsRequestInputPort { doc /* Qualified requested settings; requested and pending state remains internal. */ }
        port batteryStatusIn:BatteryStatusInputPort { doc /* Reporting conditions only; first-recognized diagnostic selection uses common ordering. Ready, torque and restoration use operational values and qualification, not BatteryStatus. */ }
        port actualTractionOutputIn:ActualTractionInputPort { doc /* Qualified actual applied wheel-torque/output observations from Traction for demand and powered-forward regenerative rearm policy; not stage-state or PWM evidence. */ }
        port batteryOperatingLimitsIn:BatteryOperatingLimitsInputPort { doc /* Existing stream feeds battery Ready guards and the coordinator allocation. Required discharge assessment must be qualified for Ready; qualified zero is distinct from unqualified. Eligibility depends on operational qualification and values, independently of BatteryStatus. A qualified zero is known no capability; an unqualified branch carries conservative zero without qualification. Zero charge acceptance suppresses requested regenerative braking without implying zero wheel torque. */ }
        port ridingAuthorityOut:RidingAuthorityOutputPort { doc /* Current authorization and its expiry; independent of the signed torque command. */ }
        port wheelTorqueCommandOut:WheelTorqueCommandOutputPort { doc /* Signed wheel-torque demand and current bounds; authorization remains a separate output. */ }
        port selectedFaultIndicationOut:SelectedFaultIndicationOutputPort { doc /* Selected reportable fault code and qualification for HMI encoding. */ }
        port sleepRequestOut:ComputeSleepRequestOutputPort { doc /* Qualified current sleep eligibility grant only when explicit Off and current qualified traction computeSleepPermitted evidence support eligibility. False revokes the grant; this is not physical inhibition evidence. */ }
    }
}
