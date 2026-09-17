package X2CityDetailedUnit_DemandArbiter {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_SettingsPolicy::*;
    private import X2CitySoftwareContract_SessionPolicy::*;
    private import X2CitySoftwareContract_BatteryProtection::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_DemandPolicy::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    // Owner: SC-DEMAND; DD-001; UR-DEMAND-001; SW-I-001..005.
    port def DemandAcceleratorIn {
        doc /* Receives the qualified accelerator position from U-ACCELERATOR-QUALIFY as the active-profile request source. */
        in item payload:AcceleratorPositionV1;
    }
    port def DemandBrakeIn {
        doc /* Receives the qualified brake/lever state from U-BRAKE-QUALIFY; lever action blocks only the positive branch. */
        in item payload:BrakeStateV1;
    }
    port def DemandActiveSettingsIn {
        doc /* Receives U-SET-STATE's active level 0–5 and active normalized speed limit; pending settings cannot enter this port. */
        in item payload:ActiveRidingSettingsV1;
    }
    port def DemandAuthorityIn {
        doc /* Receives Session authority with independent generation, decision and expiry timestamps; matching generation never prolongs authority expiry. */
        in item payload:PSesAuthOInformation;
    }
    port def DemandBatteryCapabilityIn {
        doc /* Receives Battery Protection's independently qualified positive-propulsion and negative-regeneration ceilings, reasons and restriction generations. */
        in item payload:PBatEnvelopeOInformation;
    }
    port def DemandMotionIn {
        doc /* Receives qualified vehicle speed, direction and standstill from U-TRACTION-MOTION for cutoffs, recovery and rearm guards. */
        in item payload:QualifiedMotionV1;
    }
    port def DemandActualOutputIn {
        doc /* Receives U-TRACTION-ACTUAL-OUTPUT's qualified applied-wheel-torque estimate and powered-forward evidence for post-stop regen rearm. */
        in item payload:ActualTractionOutputV1;
    }
    port def DemandPlatformContextIn {
        doc /* Receives the current platform context that invalidates Demand state and prevents an old decision from crossing a reset boundary. */
        in item payload:PPltContextOInformation;
    }
    port def DemandPlatformHealthIn {
        doc /* Receives platform health that can withdraw both torque signs without inventing a Session fault latch. */
        in item payload:PPltHealthOInformation;
    }
    port def DemandCalibrationIn {
        doc /* Receives the activated resolved DemandPolicyCalibration maps, endpoints, ramps, taper and timing data; an ID without resolved data is unusable. */
        in item payload:CalibrationBundleRecord;
    }
    port def DemandCommandOut {
        doc /* Sends the signed requested wheel torque, decision sequence and independently expiring command to U-TRACTION-ACCEPT; it is a request, never output evidence. */
        out item payload:PDemCommandOInformation;
    }
    port def DemandDiagnosticOut {
        doc /* Sends service-only restriction, unavailable and regeneration-recovery episode diagnostics to Service; it has no rider indication or control return path. */
        out item payload:PDemDiagnosticOInformation;
    }
    part def UDemandArbiter {
        /* Atomically evaluates current qualified rider, active-setting, authority, capability,
           motion and actual-output snapshots. It emits requestedWheelTorqueNewtonMetres with
           independent authority generation and command expiry; diagnostic reasons are
           service-only. Pending settings, a command or PWM/register state never establish
           motion, actual applied torque, powered-forward travel or post-stop regen rearm. */
        port acceleratorIn:DemandAcceleratorIn;
        port brakeIn:DemandBrakeIn;
        port activeSettingsIn:DemandActiveSettingsIn;
        port authorityIn:DemandAuthorityIn;
        port batteryCapabilityIn:DemandBatteryCapabilityIn;
        port motionIn:DemandMotionIn;
        port actualOutputIn:DemandActualOutputIn;
        port platformContextIn:DemandPlatformContextIn;
        port platformHealthIn:DemandPlatformHealthIn;
        port calibrationIn:DemandCalibrationIn;
        port commandOut:DemandCommandOut;
        port diagnosticOut:DemandDiagnosticOut;
    }
}
