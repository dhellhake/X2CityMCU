package X2CityDetailedUnit_SetState {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SettingsPolicy::*;
    private import X2CitySoftwareContract_AcceleratorInterface::AcceleratorPositionInputPort;
    private import X2CitySoftwareContract_TractionControl::*;
    // Owner: SC-SET; DD-001; UR-SET-001; SW-I-001/002.
    item def SettingsStateRecord :> UnitInformationEnvelope;
    item def ActiveSettingsRecord :> ActiveRidingSettings;
    // HMI requests retain their owner records; accelerator composites use acceleratorPositionIn.
    port def SettingsStateInputPort {
        doc /* Receives HMI setting receipts while preserving source receipt time; accelerator composites use acceleratorPositionIn. HMI loss never refreshes an active selection. */
        in item payload:ContextualSoftwareInformation;
    }
    port def SettingsStateOutputPort {
        doc /* Publishes requested, pending and active setting state to policy/reporting consumers, retaining original receipt provenance for an active selection. */
        out item payload:SettingsStateRecord;
    }
    port def ActiveSettingsOutputPort {
        doc /* Sends only the current active level and active speed setting projection to Demand; requested and pending values are deliberately excluded. */
        out item payload:ActiveSettingsRecord;
    }
    port def QualifiedMotionInputPort {
        doc /* Receives U-TRACTION-MOTION's qualified standstill result for setting-application guards; it is not inferred from absent Hall edges or demand. */
        in item payload:QualifiedMotion;
    }
    part def RidingSettingsStateManager {
        /* Validates and manages requested, pending, and active settings using current application guards and context. It publishes settings state without treating a retained value as a current startup receipt. */
        port requestedSettingsIn:SettingsStateInputPort;
        port acceleratorPositionIn:AcceleratorPositionInputPort;
        // Current motion is a separate standstill guard; settings never infer it from demand.
        port motionIn:QualifiedMotionInputPort;
        port stateOut:SettingsStateOutputPort;
        // Dedicated projection: requested/pending values cannot enter Demand.
        port activeSettingsOut:ActiveSettingsOutputPort;
    }
}
