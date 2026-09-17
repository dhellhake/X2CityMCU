package X2CityDetailedUnit_SetState {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SettingsPolicy::*;
    private import X2CitySoftwareContract_TractionControl::*;
    // Owner: SC-SET; DD-001; UR-SET-001; SW-I-001/002.
    item def SettingsStateRecord :> UnitInformationEnvelope;
    item def ActiveSettingsRecord :> ActiveRidingSettingsV1;
    // HMI requests and typed accelerator guard evidence retain their owner records.
    port def SettingsStateIn {
        doc /* Receives HMI setting receipts and required rider context while preserving their source receipt time; an HMI-loss absence does not refresh an active selection. */
        in item payload:ContextualSoftwareInformation;
    }
    port def SettingsStateOut {
        doc /* Publishes requested, pending and active setting state to policy/reporting consumers, retaining original receipt provenance for an active selection. */
        out item payload:SettingsStateRecord;
    }
    port def ActiveSettingsOut {
        doc /* Sends only the current active level and active speed setting projection to Demand; requested and pending values are deliberately excluded. */
        out item payload:ActiveSettingsRecord;
    }
    port def QualifiedMotionIn {
        doc /* Receives U-TRACTION-MOTION's qualified standstill result for setting-application guards; it is not inferred from absent Hall edges or demand. */
        in item payload:QualifiedMotionV1;
    }
    part def USetState {
        /* Validates and manages requested, pending, and active settings using current application guards and context. It publishes settings state without treating a retained value as a current startup receipt. */
        port requestedSettingsIn:SettingsStateIn;
        // Current motion is a separate standstill guard; settings never infer it from demand.
        port motionIn:QualifiedMotionIn;
        port stateOut:SettingsStateOut;
        // Dedicated projection: requested/pending values cannot enter Demand.
        port activeSettingsOut:ActiveSettingsOut;
    }
}
