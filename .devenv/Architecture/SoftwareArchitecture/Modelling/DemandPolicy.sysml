package X2CitySoftwareContract_DemandPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_SettingsPolicy::*;
    private import X2CitySoftwareContract_BatteryProtection::*;
    port def PDemAcceleratorI {
        doc /* Receives the qualified accelerator position and rest indication from AcceleratorInterface. DemandPolicy uses the record as rider input only after its source, age and calibration context are acceptable. */
        in item payload:AcceleratorPositionV1;
    }
    port def PDemBrakeI {
        doc /* Receives the qualified coded brake state from BrakeInterface. A valid applied state constrains positive demand, while an invalid or unavailable brake observation is a common invalid contributor that withdraws both positive and regenerative demand. */
        in item payload:BrakeStateV1;
    }
    port def PDemActiveSettingsI {
        doc /* Receives only the already active riding level and speed limit from SettingsPolicy. Pending or merely requested settings cannot enter torque-demand calculation through this port. */
        in item payload:ActiveRidingSettingsV1;
    }
    port def PDemAuthorityI {
        doc /* Receives SessionPolicy authority generation, decision time and expiry in their named clock context. DemandPolicy checks authority independently from command age and never obtains authority through diagnostics. */
        in item payload:PSesAuthOInformation;
    }
    port def PDemBatteryCapabilityI {
        doc /* Receives BatteryProtection's separate positive propulsion and negative regeneration capability branches. DemandPolicy applies the relevant sign branch and its own qualification evidence rather than using aggregate envelope validity for both signs. */
        in item payload:PBatEnvelopeOInformation;
    }
    port def PDemMotionI {
        doc /* Receives qualified physical vehicle motion from TractionControl for speed cutoffs, standstill, rollback and post-stop guards. Electrical Hall direction or command absence cannot substitute for this observation. */
        in item payload:QualifiedMotionV1;
    }
    port def PDemActualOutputI {
        doc /* Receives qualified actual applied-output evidence from TractionControl, separate from the requested command. DemandPolicy uses positive applied torque and powered-forward travel evidence for regeneration rearm decisions. */
        in item payload:ActualTractionOutputV1;
    }
    item def PDemCommandOInformation:>ContextualSoftwareInformation {
        attribute requestedWheelTorqueNewtonMetres:Real;
        attribute authorityGeneration:AuthorityGeneration;
        attribute decisionSequence:Integer;
        attribute decisionTimestampTicks:Integer;
        attribute commandExpiryTimestampTicks:Integer;
        attribute commandClockId:String;
        attribute commandClockContextId:String;
    }
    port def PDemCommandO {
        doc /* Publishes the requested signed wheel torque to TractionControl with decision sequence, authority generation, decision timestamp and independent command expiry. Consumers must validate both the authority record and command expiry in the named clock/context. */
        out item payload:PDemCommandOInformation;
    }
    item def PDemDiagnosticOInformation:>ContextualSoftwareInformation {
        attribute activeLevel:String;
        attribute activeSpeedLimitKilometresPerHour:Real;
        attribute positiveDemandDisposition:String;
        attribute regenerationDisposition:String;
        attribute applicableRestrictionEpisodeGeneration:ContextGeneration;
        attribute regenerationRecoveryEpisodeGeneration:ContextGeneration;
        attribute regenerationRecoveryQualified:Boolean;
        attribute postStopRegenerationRearmState:String;
        attribute profileId:String;
    }
    port def PDemDiagnosticO {
        doc /* Publishes the current demand-policy explanation, including active settings, sign dispositions, restriction and recovery generations, to ServiceInformation. This record is diagnostic context and cannot authorize or refresh a command. */
        out item payload:PDemDiagnosticOInformation;
    }
}

package X2CitySoftwareComponent_DemandPolicy {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    part def DemandPolicy {
        /* Arbitrates typed qualified rider inputs, applied settings, authority, battery capability,
           qualified physical motion and actual applied-output evidence. It publishes a requested
           signed wheel-torque command with generation and expiry plus a read-only policy diagnostic.
           Brake actuation blocks positive demand only; accelerator alone can request regeneration.
           Demand never owns actual torque, ADC/FOC/hardware or authority issuance. */
        port pDemAcceleratorI:PDemAcceleratorI;
        port pDemBrakeI:PDemBrakeI;
        port pDemActiveSettingsI:PDemActiveSettingsI;
        port pDemAuthorityI:PDemAuthorityI;
        port pDemBatteryCapabilityI:PDemBatteryCapabilityI;
        port pDemMotionI:PDemMotionI;
        port pDemActualOutputI:PDemActualOutputI;
        port pDemCommandO:PDemCommandO;
        port pDemDiagnosticO:PDemDiagnosticO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
    }
}
