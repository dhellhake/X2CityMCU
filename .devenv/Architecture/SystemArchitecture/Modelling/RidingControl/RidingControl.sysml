package X2CityContract_RidingControl {
    private import X2CitySharedContracts::*;
    item def RiderSettingsRequest:>QualifiedInformationRecord {
        doc /* Qualified VD18MT receipt of the concrete requested riding level and requested speed limit. The request remains distinct from internally pending and active settings. */
        attribute requestedRidingLevel:Integer;
        attribute requestedSpeedLimitKilometresPerHour:Real;
    }
    port def RiderSettingsRequestOutputPort {
        doc /* Carries the HMI-qualified requested level and speed limit to RidingControl. This is request input, not proof of pending or active settings. */
        out item payload:RiderSettingsRequest;
    }
    port def RiderSettingsRequestInputPort {
        doc /* Receives the HMI-qualified requested level and speed limit. RidingControl retains requested and pending values internally until applied. */
        in item payload:RiderSettingsRequest;
    }
    interface def IfA002RiderSettingsRequest { end producer:RiderSettingsRequestOutputPort; end consumer:RiderSettingsRequestInputPort; flow producer.payload to consumer.payload; }

    // Active settings are retained inside RidingControl and have no System interface.
    item def ActiveRidingSettings:>QualifiedInformationRecord {
        attribute activeLevel:String;
        attribute activeSpeedLimitKilometresPerHour:Real;
    }
    item def RidingAuthority:>QualifiedInformationRecord { attribute expiry:Expiry; }
    item def SelectedFaultIndication:>QualifiedInformationRecord {
        doc /* RidingControl's selected reportable wire code, including the no-error code. */
        attribute selectedWireCode:Integer;
    }
    item def SignedWheelTorqueRequest:>QualifiedInformationRecord {
        doc /* Requested wheel torque in newton-metres; positive is forward propulsion and the sign is wheel-torque direction. Electrical transfer direction is independent. Coordinator-issued traction discharge and regenerative-charge budgets apply independently; branch qualification is explicit; a zero bound means that branch is forbidden or unqualified. */
        attribute requestedWheelTorqueNewtonMetres:Real;
        attribute expiry:Expiry;
        attribute dischargeBudgetQualified:Boolean;
        attribute maximumDischargeCurrentAmperes:Real;
        attribute regenerativeChargeBudgetQualified:Boolean;
        attribute maximumRegenerativeChargeCurrentAmperes:Real;
    }
    item def TractionCurrentBudget {
        doc /* Coordinator-issued traction inverter DC-current magnitude budgets in amperes, based on independently qualified pack capability and the validated fixed auxiliary reserve; the reserved auxiliary draw is excluded from the traction discharge budget. Discharge is battery-to-load; charge is load-to-battery, independent of torque sign. Branches are independently qualified and finite nonnegative; unqualified branches carry conservative zero, while qualified zero is known zero capability. Regenerative allocation never credits auxiliary draw. */
        attribute sourceContext:SourceContext;
        attribute dischargeBudgetQualified:Boolean;
        attribute maximumDischargeCurrentAmperes:Real;
        attribute regenerativeChargeBudgetQualified:Boolean;
        attribute maximumRegenerativeChargeCurrentAmperes:Real;
        attribute expiry:Expiry;
    }
    port def TractionCurrentBudgetOutputPort { doc /* Publishes the coordinator’s independently qualified discharge and regenerative-charge traction budgets with source context and expiry. */ out item payload:TractionCurrentBudget; }
    port def TractionCurrentBudgetInputPort { doc /* Receives the coordinator’s independently qualified traction budgets for demand arbitration and command publication. */ in item payload:TractionCurrentBudget; }
    interface def IfRidingTractionCurrentBudget { end producer:TractionCurrentBudgetOutputPort; end consumer:TractionCurrentBudgetInputPort; flow producer.payload to consumer.payload; }
    port def RidingAuthorityOutputPort {
        doc /* Publishes RidingControl's current authorization with its independent expiry. Authority lifetime is not renewed by the torque-command stream. */
        out item payload:RidingAuthority;
    }
    port def RidingAuthorityInputPort {
        doc /* Receives RidingControl's current authorization and expiry. The consumer evaluates it separately from command validity. */
        in item payload:RidingAuthority;
    }
    port def SelectedFaultIndicationOutputPort {
        doc /* Publishes RidingControl's selected reportable wire code, including the no-error code, with qualification for HMI report encoding. */
        out item selectedFaultIndication:SelectedFaultIndication;
    }
    port def SelectedFaultIndicationInputPort {
        doc /* Receives the selected fault indication for HMI report encoding; the receiver does not select or latch faults. */
        in item selectedFaultIndication:SelectedFaultIndication;
    }
    port def WheelTorqueCommandOutputPort {
        doc /* Publishes signed wheel-torque demand with expiry and independently qualified coordinator-issued traction current budgets. It is a demand boundary, not authorization; zero branch bounds forbid or leave that branch unqualified. Electrical transfer direction is independent of wheel-torque sign. */
        out item payload:SignedWheelTorqueRequest;
    }
    port def WheelTorqueCommandInputPort {
        doc /* Receives signed wheel-torque demand with expiry and independently qualified coordinator-issued traction current budgets. It does not imply authority or infer electrical transfer direction from torque sign. */
        in item payload:SignedWheelTorqueRequest;
    }
    interface def IfA004RidingAuthority { end producer:RidingAuthorityOutputPort; end consumer:RidingAuthorityInputPort; flow producer.payload to consumer.payload; }
    interface def IfA004WheelTorqueCommand { end producer:WheelTorqueCommandOutputPort; end consumer:WheelTorqueCommandInputPort; flow producer.payload to consumer.payload; }
    interface def IfA006SelectedFaultIndication { end producer:SelectedFaultIndicationOutputPort; end consumer:SelectedFaultIndicationInputPort; flow producer.selectedFaultIndication to consumer.selectedFaultIndication; }
}

package X2CityComponent_RidingControl {
    private import X2CitySharedContracts::*;
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_Compute::*;
    private import X2CityContract_HmiControl::*;
    private import X2CityComponent_RidingPolicy::*;
    private import X2CityComponent_CurrentConsumptionCoordination::*;

    part def RidingControl { // LE-RIDING
        part ridingPolicy:RidingPolicy;
        part currentConsumptionCoordination:CurrentConsumptionCoordination;
        interface currentBudgetAllocation : IfRidingTractionCurrentBudget connect currentConsumptionCoordination.tractionCurrentBudgetOut to ridingPolicy.tractionCurrentBudgetIn;
        doc /* System responsibility composed of software-allocated riding policy and current coordination leaves. It owns requested, pending and active settings, operation and fault lifetime, riding authority, demand arbitration, regenerative recovery and post-stop state. Qualified explicit physical Off ends the operation session immediately regardless of motion; Unknown or unavailable is not Off, and HMI UART loss does not alter the physical request. A later On starts fresh qualification, including if sleep has not begun. Authority and signed wheel-torque demand remain independent outputs. */
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
        port stateOfChargeIn:BatteryStateOfChargeInputPort { doc /* Qualified actual SOC for RidingControl low-SOC propulsion cutoff/recovery, and fault policy. */ }
        port actualTractionOutputIn:ActualTractionInputPort { doc /* Qualified actual applied wheel-torque/output observations from Traction for demand and powered-forward regenerative rearm policy; not stage-state or PWM evidence. */ }
        port batteryOperatingLimitsIn:BatteryOperatingLimitsInputPort { doc /* Existing stream feeds battery Ready guards and the coordinator allocation. Eligibility depends on operational qualification and values, independently of BatteryStatus. A qualified zero is known no capability; an unqualified branch carries conservative zero without qualification. Zero charge acceptance suppresses requested regenerative braking without implying zero wheel torque. */ }
        port batteryCurrentIn:BatteryCurrentInputPort { doc /* Qualified measured pack current for the sole coordinator shared-budget supervision. */ }
        port ridingAuthorityOut:RidingAuthorityOutputPort { doc /* Current authorization and its expiry; independent of the signed torque command. */ }
        port wheelTorqueCommandOut:WheelTorqueCommandOutputPort { doc /* Signed wheel-torque demand and current bounds; authorization remains a separate output. */ }
        port selectedFaultIndicationOut:SelectedFaultIndicationOutputPort { doc /* Selected reportable fault code and qualification for HMI encoding. */ }
        port sleepRequestOut:ComputeSleepRequestOutputPort { doc /* Qualified current sleep eligibility grant only when explicit Off and current qualified traction computeSleepPermitted evidence support eligibility. False revokes the grant; this is not physical inhibition evidence. */ }
        flow vehicleOperationRequestInToPolicy from vehicleOperationRequestIn.request to ridingPolicy.vehicleOperationRequestIn.request;
        flow runtimeInitializationInToPolicy from runtimeInitializationIn.initialization to ridingPolicy.runtimeInitializationIn.initialization;
        flow brakeLeverStateInToPolicy from brakeLeverStateIn.brakeLeverState to ridingPolicy.brakeLeverStateIn.brakeLeverState;
        flow acceleratorPositionInToPolicy from acceleratorPositionIn.acceleratorPosition to ridingPolicy.acceleratorPositionIn.acceleratorPosition;
        flow qualifiedVehicleMotionInToPolicy from qualifiedVehicleMotionIn.payload to ridingPolicy.qualifiedVehicleMotionIn.payload;
        flow motorPositionInToPolicy from motorPositionIn.motorPosition to ridingPolicy.motorPositionIn.motorPosition;
        flow qualifiedTemperatureInToPolicy from qualifiedTemperatureIn.payload to ridingPolicy.qualifiedTemperatureIn.payload;
        flow tractionConditionEvidenceInToPolicy from tractionConditionEvidenceIn.payload to ridingPolicy.tractionConditionEvidenceIn.payload;
        flow hmiRiderSettingsRequestInToPolicy from hmiRiderSettingsRequestIn.payload to ridingPolicy.hmiRiderSettingsRequestIn.payload;
        flow batteryStatusInToPolicy from batteryStatusIn.status to ridingPolicy.batteryStatusIn.status;
        flow stateOfChargeInToPolicy from stateOfChargeIn.stateOfCharge to ridingPolicy.stateOfChargeIn.stateOfCharge;
        flow actualTractionOutputInToPolicy from actualTractionOutputIn.payload to ridingPolicy.actualTractionOutputIn.payload;
        flow batteryOperatingLimitsInToPolicy from batteryOperatingLimitsIn.operatingLimits to ridingPolicy.batteryOperatingLimitsIn.operatingLimits;
        flow ridingAuthorityOutFromPolicy from ridingPolicy.ridingAuthorityOut.payload to ridingAuthorityOut.payload;
        flow wheelTorqueCommandOutFromPolicy from ridingPolicy.wheelTorqueCommandOut.payload to wheelTorqueCommandOut.payload;
        flow selectedFaultIndicationOutFromPolicy from ridingPolicy.selectedFaultIndicationOut.selectedFaultIndication to selectedFaultIndicationOut.selectedFaultIndication;
        flow sleepRequestOutFromPolicy from ridingPolicy.sleepRequestOut.request to sleepRequestOut.request;
        flow operatingLimitsToCoordinator from batteryOperatingLimitsIn.operatingLimits to currentConsumptionCoordination.batteryOperatingLimitsIn.operatingLimits;
        flow packCurrentToCoordinator from batteryCurrentIn.batteryCurrent to currentConsumptionCoordination.batteryCurrentIn.batteryCurrent;
    }
}
