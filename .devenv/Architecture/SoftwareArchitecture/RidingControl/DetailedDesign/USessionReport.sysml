package X2CityDetailedUnit_SessionReport {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_BatteryControl::*;
    // Owner: SC-RIDING-CONTROL; DD-001; UR-SESSION-002.
    item def SelectedFaultIndicationRecord :> UnitInformationEnvelope, X2CitySoftwareContract_RidingControl::SoftwareSelectedFaultIndication;
    port def SessionReportInputPort {
        doc /* Receives the eligibility and related observation envelope used to select the current Session report group; the envelope is report input, not authority. */
        in item payload:UnitInformationEnvelope;
    }
    port def ReportBatteryStatusInputPort { doc /* Direct reporting-only status stream with independent fault, local thermal and qualified MOS warning conditions. This unit applies its own delivery watchdog using caller-supplied ExecutionTime. */ in item payload:BatteryStatus; }
    port def ReportStateOfChargeInputPort { doc /* Qualified actual SOC for the independent low-SOC report cause; this unit checks delivery current under its own caller-time watchdog. */ in item payload:BatteryStateOfCharge; }
    port def SelectedFaultIndicationOutputPort {
        doc /* Sends Session's already-selected qualified fault/no-error indication to HMI without granting authority or changing inhibition. */
        out item selectedFaultIndication:SelectedFaultIndicationRecord;
    }
    part def SessionReportPublisher {
        /* Selects the existing retained report group above the composed, automatically clearing low-priority 0x01 warning. MOS state and SOC must each be qualified and current under this unit's private, independent delivery watchdog using caller-supplied ExecutionTime; current assessment/limit-branch qualification does not qualify MOS state. MOS true activates the MOS cause, qualified false clears it, and missing/stale/unqualified MOS delivery withdraws its warning evidence without implying enabled state or retaining stale 0x01. Reporting does not grant authority or change session inhibition. */
        port executionTimeIn:ExecutionTimeInputPort; port eligibilityIn:SessionReportInputPort;
        port batteryStatusIn:ReportBatteryStatusInputPort; port stateOfChargeIn:ReportStateOfChargeInputPort;
        port selectedFaultOut:SelectedFaultIndicationOutputPort;
        attribute mosDisabledStatePublicationTimeoutMicroseconds:Integer;
        attribute lastBatteryStatusReceiptTimeMicroseconds:Integer;
        attribute stateOfChargePublicationTimeoutMicroseconds:Integer;
        attribute lastStateOfChargeReceiptTimeMicroseconds:Integer;
    }
}
