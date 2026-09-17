package X2CitySoftwareContract_TractionControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CitySoftwareContract_SupplyInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    port def PTrAuthI {
        doc /* Receives SessionPolicy authority generation and its independent validity/expiry context. TractionControl accepts commands only when this authority is current in its named clock context. */
        in item payload:PSesAuthOInformation;
    }
    port def PTrCommandI {
        doc /* Receives DemandPolicy's requested signed wheel-torque command with authority linkage and independent expiry. TractionControl validates both command and authority before fast actuation. */
        in item payload:PDemCommandOInformation;
    }
    port def PTrHallI {
        doc /* Receives complete qualified electrical Hall position from HallInterface for FOC phase alignment and direction. It is electrical position evidence, not a substitute for qualified physical vehicle motion. */
        in item payload:HallElectricalPositionV1;
    }
    port def PTrPhaseCurrentI {
        doc /* Receives the qualified same-aperture phase-current epoch from MotorPhaseInterface for fast FOC feedback. The current record already carries calibration, rank plausibility and timing qualification. */
        in item payload:PhaseCurrentEpochV1;
    }
    port def PTrFastVdcI {
        doc /* Receives qualified fast DC-link voltage from SupplyInterface for fast control scaling and protection. The value is produced from the dedicated injected acquisition path and its active calibration context. */
        in item payload:FastDcLinkVoltageV1;
    }
    port def PTrSensorHealthI {
        doc /* Receives qualified source-health evidence from sensor interfaces to gate traction control. Platform's independent FastSafetyState is published separately and is not recreated from this input. */
        in item payload:SensorHealthConditionV1;
    }
    attribute def CurrentObservationGeneration;
    item def PTrOutputIoInformation:>ContextualSoftwareInformation {
        attribute currentObservationGeneration:CurrentObservationGeneration;
        attribute outputStageObservationAvailable:Boolean;
        attribute outputStageObservationTimestampTicks:Integer;
        attribute outputStageState:String;
        attribute outputStageEvidenceSourceId:String;
        attribute outputStageEvidenceConfigurationId:String;
    }
    port def PTrOutputIo {
        doc /* Exchanges opaque traction information and physical-stage observation with the vehicle boundary in both directions. The boundary carries actuation-stage state and provenance; it is not a register or pin definition and does not turn a requested torque into actual-torque evidence. */
        inout item payload:PTrOutputIoInformation;
    }
    port def PTrQualifiedMotionO {
        doc /* Publishes qualified physical vehicle motion and standstill evidence to SettingsPolicy, SessionPolicy, DemandPolicy and service aggregation. The publication remains live during startup/disarm and reports unavailable until its qualification criteria are met. */
        out item payload:QualifiedMotionV1;
    }
    port def PTrActualOutputO {
        doc /* Publishes qualified observed applied-output evidence, including independently qualified positive torque and powered-forward travel, to DemandPolicy and service aggregation. It is derived from actual output observations and remains separate from the requested command. */
        out item payload:ActualTractionOutputV1;
    }
    item def PTrObsOInformation:>ContextualSoftwareInformation;
    port def PTrObsO {
        doc /* Publishes the traction observation envelope to SessionPolicy, BatteryProtection, LightPolicy and service aggregation. It provides current traction facts for policy and reporting, not a command or actuation channel. */
        out item payload:PTrObsOInformation;
    }
}

package X2CitySoftwareComponent_TractionControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    part def TractionControl {
        /* Owns fast orchestration, authority/command acceptance, Hall-sensored FOC and the next
           sampling plan. It consumes complete qualified electrical position, current and fast Vdc;
           it performs no sensor conversion. Output alone stages and writes CCR1..4/JSQR. A
           component boundary does not imply a task, queue or delayed fast handoff. Its physical
           output boundary provides physical-stage state/provenance evidence. U-TRACTION-ACTUAL-
           OUTPUT combines it with qualified phase current, electrical position, physical motion
           and activated estimation calibration before publishing an actual wheel-torque estimate;
           it never turns a requested torque command into actual-torque evidence. */
        port pTrAuthI:PTrAuthI;
        port pTrCommandI:PTrCommandI;
        port pTrHallI:PTrHallI;
        port pTrPhaseCurrentI:PTrPhaseCurrentI;
        port pTrFastVdcI:PTrFastVdcI;
        port pTrSensorHealthI:PTrSensorHealthI;
        port pTrOutputIo:PTrOutputIo;
        // Existing Hall/capture-health evidence and calibration may support this interpretation;
        // static or absent Hall edges alone never establish standstill. This publication remains
        // live during startup/disarm, reporting unavailable until validated qualification criteria
        // support it, so a later Ready guard has no circular command dependency.
        port pTrQualifiedMotionO:PTrQualifiedMotionO;
        port pTrActualOutputO:PTrActualOutputO;
        port pTrObsO:PTrObsO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
        // JEOS-to-output fast handoffs are Detailed Design-owned unit internals; no public SC
        // fast ports or ARCH-003 routes exist here.
    }
}
