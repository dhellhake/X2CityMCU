package X2CitySoftwareContract_TractionControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_TractionControl::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CityContract_MotorPositionProcessing::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CitySoftwareContract_SupplyInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_MotorPositionEstimator::MotorPositionRecord;
    attribute def ActualOutputEstimationCalibration {
        attribute estimatorId:String;
        attribute motorTorqueConstantNewtonMetresPerAmpere:Real;
        attribute transmissionRatio:Real;
        attribute estimatorResponseBoundMicroseconds:Integer;
        attribute buildValidated:Boolean;
    }
    attribute def MotionEstimationCalibration {
        attribute electricalMapId:String;
        attribute motorPolePairCount:Integer;
        attribute finalDriveRatio:Real;
        attribute loadedWheelCircumferenceMetres:Real;
        attribute standstillObservabilityBoundMicroseconds:Integer;
        attribute buildValidated:Boolean;
    }
    port def RidingAuthorityInputPort :> X2CityContract_SessionPolicy::RidingAuthorityInputPort {
        doc /* Receives SessionPolicy authority generation and its independent validity/expiry context. TractionControl accepts commands only when this authority is current in the common host-boot monotonic microsecond domain. */
        in item payload:RidingAuthority :>> X2CityContract_SessionPolicy::RidingAuthorityInputPort::payload;
    }
    port def WheelTorqueRequestInputPort :> X2CityContract_DemandPolicy::WheelTorqueCommandInputPort {
        doc /* Receives DemandPolicy's requested signed wheel-torque command with authority linkage,
           expiry, and independently dimensioned battery charge/discharge-current bounds. Traction
           uses the amperage bounds as electrical limits; they are not wheel-torque values. */
        in item payload:WheelTorqueRequest :>> X2CityContract_DemandPolicy::WheelTorqueCommandInputPort::payload;
    }
    port def MotorPositionInputPort :> X2CityContract_MotorPositionProcessing::MotorPositionInputPort {
        doc /* Receives the one final qualified electrical position from MotorPositionEstimator
           for FOC and downstream observation, retaining the software Qualification refinement
           for local gating. Hall observations are not a second final-angle path. Position
           availability and signed-speed availability remain independent. */
        in item payload:MotorPositionRecord :>> X2CityContract_MotorPositionProcessing::MotorPositionInputPort::motorPosition;
    }
    port def PhaseCurrentEpochInputPort :> X2CityContract_MotorPositionProcessing::PhaseCurrentMeasurementsInputPort {
        doc /* Receives the qualified same-aperture phase-current epoch from MotorPhaseInterface for fast FOC feedback. The current record already carries calibration, rank plausibility and timing qualification. */
        in item payload:PhaseCurrentEpoch :>> X2CityContract_MotorPositionProcessing::PhaseCurrentMeasurementsInputPort::phaseCurrentMeasurements;
    }
    port def FastDcLinkVoltageInputPort :> X2CityContract_TractionControl::FastDcLinkVoltageInputPort {
        doc /* Receives qualified fast DC-link voltage from SupplyInterface for fast control scaling and protection. The value is produced from the dedicated injected acquisition path and its fixed compiled configuration provenance. */
        in item payload:FastDcLinkVoltage :>> X2CityContract_TractionControl::FastDcLinkVoltageInputPort::payload;
    }
    port def QualifiedTemperatureInputPort :> X2CityContract_TractionControl::QualifiedTemperatureInputPort {
        doc /* Receives the value-bearing qualified motor/traction-board observation for local categorized condition evaluation. */
        in item payload:X2CitySoftwareContract_TemperatureInterface::QualifiedTemperature :>> X2CityContract_TractionControl::QualifiedTemperatureInputPort::payload;
    }
    port def RegularSupplyVoltageInputPort {
        doc /* Receives the qualified regular GVDD value for local categorized condition evaluation. */
        in item payload:X2CitySoftwareContract_SupplyInterface::SupplyVoltage;
    }
    port def SupplyHealthInputPort {
        doc /* Receives software conversion-health evidence and forwards it into the existing
               aggregate sensor-health input. Logical PVDD/GVDD qualification remains value-bearing. */
        in item qualification:SupplyHealthCondition;
    }
    port def TractionSensorHealthInputPort {
        doc /* Receives qualified source-health evidence from sensor interfaces to gate traction control. Platform's independent FastSafetyState is published separately and is not recreated from this input. */
        in item payload:SensorHealthCondition;
    }
    port def MotionHealthInputPort {
        doc /* Receives Hall capture/position health only for vehicle-motion qualification. It is separate from the broader traction-control health gate and does not add a runtime check or alter the released Hall qualification criteria. */
        in item payload:SensorHealthCondition;
    }
    attribute def CurrentObservationGeneration;
    item def TractionOutputStageExchange:>ContextualSoftwareInformation {
        item tractionStageEvidence:TractionStageEvidence;
        item tractionHardwareProtectionEvidence:TractionHardwareProtectionEvidence;
        attribute currentObservationGeneration:CurrentObservationGeneration;
        attribute outputStageObservationAvailable:Boolean;
        attribute outputStageObservationTimeMicroseconds:Integer;
        attribute outputStageState:String;
        attribute outputStageEvidenceSourceId:String;
        attribute outputStageEvidenceConfigurationId:String;
    }
    port def TractionOutputStageExchangePort {
        doc /* Publishes the typed phase-excitation command (including its overriding inhibition) and separately receives independently observed physical-stage state and hardware-protection evidence. It is not a register or pin definition and does not turn a requested command into actual-torque evidence. */
        out item phaseExcitationCommand:PhaseExcitationCommand;
        in item evidence:TractionOutputStageExchange;
    }
    port def QualifiedMotionOutputPort :> QualifiedVehicleMotionOutputPort {
        doc /* Publishes qualified physical vehicle motion and standstill evidence to SettingsPolicy, SessionPolicy and DemandPolicy. The publication remains live during startup/disarm and reports unavailable until its qualification criteria are met. */
        out item payload:QualifiedMotion :>> QualifiedVehicleMotionOutputPort::payload;
    }
    port def AppliedTractionStateOutputPort :> ActualTractionOutputPort {
        doc /* Publishes qualified observed applied-output evidence, including independently qualified positive torque and powered-forward travel, to DemandPolicy. It is derived from actual output observations and remains separate from the requested command. */
        out item payload:X2CitySharedSoftwareTypes::ActualTractionOutput :>> ActualTractionOutputPort::payload;
    }
    item def TractionObservation:>ContextualSoftwareInformation, X2CityContract_MotorControl::TractionConditionEvidence {
        doc /* Local categorized traction evidence. Startup-pending or unavailable evidence remains
               distinct from recognizedFault; Session alone owns the latched fault and clean-restart lifetime. */
    }
    port def TractionObservationOutputPort :> X2CityContract_MotorControl::TractionConditionEvidenceOutputPort {
        doc /* Publishes the software refinement of locally evaluated and categorized traction condition evidence to SessionPolicy. Session owns vehicle-wide fault latching, priority/report selection and restart policy; this is not a command or actuation channel. */
        out item payload:TractionObservation :>> X2CityContract_MotorControl::TractionConditionEvidenceOutputPort::payload;
    }
    item def ElectricalBrakingStateRecord:>ContextualSoftwareInformation, ElectricalBrakingState {
        attribute actualOutputObservationTimeMicroseconds:Integer;
        attribute actualOutputObservationGeneration:ContextGeneration;
    }
    port def ElectricalBrakingStateOutputPort :> X2CityContract_MotorControl::ElectricalBrakingStateOutputPort {
        doc /* Publishes Traction-owned actual active motor electrical-braking state, projected from qualified applied-output evidence with its current qualification and observation time. A requested negative torque is not this state. */
        out item payload:ElectricalBrakingStateRecord :>> X2CityContract_MotorControl::ElectricalBrakingStateOutputPort::payload;
    }
}

package X2CitySoftwareComponent_TractionControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityComponent_MotorControl::*;
    private import X2CitySoftwareComponent_AnalogAcquisition::*;
    private import X2CitySoftwareComponent_TemperatureInterface::*;
    private import X2CitySoftwareComponent_SupplyInterface::*;
    part def TractionControl {
        /* Owns fast orchestration, authority/command acceptance, Hall-sensored FOC and the next
           sampling plan. It consumes complete qualified electrical position, current and fast Vdc;
           it performs no sensor conversion. Output alone stages and writes CCR1..4/JSQR. A
           component boundary does not imply a task, queue or delayed fast handoff. Its physical
           output boundary provides physical-stage state/provenance evidence. U-TRACTION-ACTUAL-
           OUTPUT combines it with qualified phase current, electrical position, physical motion
           and compiled estimation calibration before publishing an actual wheel-torque estimate;
           it never turns a requested torque command into actual-torque evidence. */
        port executionTimeIn:ExecutionTimeInputPort;
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port wheelTorqueRequestIn:WheelTorqueRequestInputPort;
        port motorPositionIn:MotorPositionInputPort;
        port phaseCurrentEpochIn:PhaseCurrentEpochInputPort;
        port fastDcLinkVoltageIn:FastDcLinkVoltageInputPort;
        port qualifiedTemperatureIn:QualifiedTemperatureInputPort;
        port regularSupplyVoltageIn:RegularSupplyVoltageInputPort;
        port supplyHealthIn:SupplyHealthInputPort;
        port sensorHealthIn:TractionSensorHealthInputPort;
        port motionHealthIn:MotionHealthInputPort;
        port tractionOutputStageExchange:TractionOutputStageExchangePort;
        // Existing Hall/capture-health evidence and calibration may support this interpretation;
        // static or absent Hall edges alone never establish standstill. This publication remains
        // live during startup/disarm, reporting unavailable until validated qualification criteria
        // support it, so a later Ready guard has no circular command dependency.
        port qualifiedMotionOut:QualifiedMotionOutputPort;
        port appliedTractionStateOut:AppliedTractionStateOutputPort;
        port tractionObservationOut:TractionObservationOutputPort;
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        // Fixed build-time estimation and motion parameters. The ID is read-only provenance and
        // does not select or activate calibration at runtime.
        attribute compiledCalibrationId:String;
        // Preserve the existing detailed sensorHealthIn/control binding for conversion-health
        // evidence; this adds no new control unit or route.
        flow supplyHealthToSensorHealth from supplyHealthIn.qualification to sensorHealthIn.payload;
        attribute compiledActualOutputEstimationCalibration:ActualOutputEstimationCalibration;
        attribute compiledMotionEstimationCalibration:MotionEstimationCalibration;
        attribute compiledCalibrationValid:Boolean; // Build/startup validation failure withholds dependent estimate/motion results.
        // JEOS-to-output fast handoffs are Detailed Design-owned unit internals; no public SC
        // fast ports or ARCH-003 routes exist here.
    }

    part def MotorControlRealization :> X2CityComponent_MotorControl::MotorControl {
        /* Allocation wrapper for the expanded logical MotorControl responsibility. It selects
           the existing control core and the separate shared acquisition, temperature and supply
           components as cooperating realization roles. It does not add an MCU instance, task,
           conversion path, or output writer: TractionControl remains the sole CCR/JSQR writer,
           and the referenced sensor components retain their existing semantic ownership. */
        port ridingAuthorityIn:X2CitySoftwareContract_TractionControl::RidingAuthorityInputPort :>> X2CityComponent_MotorControl::MotorControl::ridingAuthorityIn;
        port wheelTorqueCommandIn:X2CitySoftwareContract_TractionControl::WheelTorqueRequestInputPort :>> X2CityComponent_MotorControl::MotorControl::wheelTorqueCommandIn;
        port motorPositionIn:X2CitySoftwareContract_TractionControl::MotorPositionInputPort :>> X2CityComponent_MotorControl::MotorControl::motorPositionIn;
        port phaseCurrentIn:X2CitySoftwareContract_TractionControl::PhaseCurrentEpochInputPort :>> X2CityComponent_MotorControl::MotorControl::phaseCurrentIn;
        port tractionConditionEvidenceOut:X2CitySoftwareContract_TractionControl::TractionObservationOutputPort :>> X2CityComponent_MotorControl::MotorControl::tractionConditionEvidenceOut;
        port qualifiedTemperatureOut:X2CitySoftwareContract_TemperatureInterface::QualifiedTemperatureOutputPort :>> X2CityComponent_MotorControl::MotorControl::qualifiedTemperatureOut;
        port fastDcLinkVoltageOut:X2CitySoftwareContract_SupplyInterface::FastDcLinkVoltageOutputPort :>> X2CityComponent_MotorControl::MotorControl::fastDcLinkVoltageOut;
        port qualifiedVehicleMotionOut:X2CitySoftwareContract_TractionControl::QualifiedMotionOutputPort :>> X2CityComponent_MotorControl::MotorControl::qualifiedVehicleMotionOut;
        port actualTractionOutputOut:X2CitySoftwareContract_TractionControl::AppliedTractionStateOutputPort :>> X2CityComponent_MotorControl::MotorControl::actualTractionOutputOut;
        port electricalBrakingStateOut:X2CitySoftwareContract_TractionControl::ElectricalBrakingStateOutputPort :>> X2CityComponent_MotorControl::MotorControl::electricalBrakingStateOut;

        part controlCore:TractionControl;
        ref part analogAcquisition:AnalogAcquisition;
        ref part temperatureInterface:TemperatureInterface;
        ref part supplyInterface:SupplyInterface;

        // The physical logical observations use a different representation from ADC records.
        // These allocations identify the existing acquisition/conversion responsibilities; they
        // deliberately create no identity flow and no extra SC input. Physical source binding and
        // evidence that the selected hardware can supply both observations remain integration gates.
        allocation temperatureMeasurementAcquisition allocate temperatureMeasurementIn to analogAcquisition.rawAdcAcquisitionIn;
        allocation temperatureMeasurementConversion allocate temperatureMeasurementIn to temperatureInterface.analogSampleIn;
        allocation supplyMeasurementAcquisition allocate supplyVoltageMeasurementIn to analogAcquisition.rawAdcAcquisitionIn;
        allocation fastSupplyMeasurementConversion allocate supplyVoltageMeasurementIn to supplyInterface.fastInjectedEpochIn;
        allocation regularSupplyMeasurementConversion allocate supplyVoltageMeasurementIn to supplyInterface.analogSampleIn;

        // Identity bindings delegate the refined logical boundary to the one existing control
        // core and shared semantic producers. No duplicate writer or observation state is created.
        bind ridingAuthorityIn.payload = controlCore.ridingAuthorityIn.payload;
        bind wheelTorqueCommandIn.payload = controlCore.wheelTorqueRequestIn.payload;
        bind motorPositionIn.payload = controlCore.motorPositionIn.payload;
        bind phaseCurrentIn.payload = controlCore.phaseCurrentEpochIn.payload;
        bind temperatureInterface.qualifiedTemperatureOut.payload = controlCore.qualifiedTemperatureIn.payload;
        bind supplyInterface.fastDcLinkVoltageOut.payload = controlCore.fastDcLinkVoltageIn.payload;
        bind supplyInterface.supplyVoltageOut.payload = controlCore.regularSupplyVoltageIn.payload;
        bind tractionStageEvidenceIn.payload = controlCore.tractionOutputStageExchange.evidence.tractionStageEvidence;
        bind tractionHardwareProtectionEvidenceIn.payload = controlCore.tractionOutputStageExchange.evidence.tractionHardwareProtectionEvidence;
        bind controlCore.tractionOutputStageExchange.phaseExcitationCommand = phaseExcitationCommandOut.payload;
        bind controlCore.tractionObservationOut.payload = tractionConditionEvidenceOut.payload;
        bind temperatureInterface.qualifiedTemperatureOut.payload = qualifiedTemperatureOut.payload;
        bind supplyInterface.fastDcLinkVoltageOut.payload = fastDcLinkVoltageOut.payload;
        bind controlCore.qualifiedMotionOut.payload = qualifiedVehicleMotionOut.payload;
        bind controlCore.appliedTractionStateOut.payload = actualTractionOutputOut.payload;
        bind controlCore.electricalBrakingStateOut.payload = electricalBrakingStateOut.payload;
    }
}
