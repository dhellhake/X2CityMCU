package X2CitySoftwareContract_TractionControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_HallInterface::*;
    private import X2CitySoftwareContract_MotorPhaseInterface::*;
    private import X2CitySoftwareContract_SupplyInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // P-TR-AUTH-I and P-TR-COMMAND-I retain the exact owner-defined payload types.
    port def PTrAuthI { in item payload:PSesAuthOInformation; }
    port def PTrCommandI { in item payload:PDemCommandOInformation; }
    // Traction accepts completed qualified electrical position, current and Vdc only.
    port def PTrHallI { in item payload:HallElectricalPositionV1; }
    port def PTrPhaseCurrentI { in item payload:PhaseCurrentEpochV1; }
    port def PTrFastVdcI { in item payload:FastDcLinkVoltageV1; }
    // Qualified source evidence gates control; Platform handles its independent FastSafetyState.
    port def PTrSensorHealthI { in item payload:SensorHealthConditionV1; }
    attribute def CurrentObservationGeneration;
    // P-TR-OUTPUT-I/O is an opaque information/actuation boundary, not a pin/register model.
    item def PTrOutputIoInformation:>ContextualSoftwareInformation {
        attribute currentObservationGeneration:CurrentObservationGeneration;
    }
    port def PTrOutputIo { inout item payload:PTrOutputIoInformation; }
    // P-TR-OBS-O is a stable ARCH-003 port identifier.
    item def PTrObsOInformation:>ContextualSoftwareInformation;
    port def PTrObsO { out item payload:PTrObsOInformation; }
}

package X2CitySoftwareComponent_TractionControl {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-TRACTION-CTRL; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def TractionControl {
        /* Owns fast orchestration, authority/command acceptance, Hall-sensored FOC and the next
           sampling plan. It consumes complete qualified electrical position, current and fast Vdc;
           it performs no sensor conversion. Output alone stages and writes CCR1..4/JSQR. A
           component boundary does not imply a task, queue or delayed fast handoff. */
        port pTrAuthI:PTrAuthI;
        port pTrCommandI:PTrCommandI;
        port pTrHallI:PTrHallI;
        port pTrPhaseCurrentI:PTrPhaseCurrentI;
        port pTrFastVdcI:PTrFastVdcI;
        port pTrSensorHealthI:PTrSensorHealthI;
        port pTrOutputIo:PTrOutputIo;
        port pTrObsO:PTrObsO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        // R-V28/R-V29 are Detailed Design-owned unit handoffs; no public SC fast ports exist here.
    }
}
