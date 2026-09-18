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
    // Owner: SC-DEMAND; DD-001; UR-DEMAND-001; SW-I-001..005.
    port def DemandAcceleratorInputPort {
        doc /* Receives U-ACCELERATOR-QUALIFY's composite. It uses Position as the active-profile request source only when contained Qualification supports it, and retains the health evidence when Position is unavailable. */
        in item payload:AcceleratorPosition;
    }
    port def DemandBrakeInputPort {
        doc /* Receives the qualified brake/lever state from U-BRAKE-QUALIFY; lever action blocks only the positive branch. */
        in item payload:BrakeState;
    }
    port def DemandActiveSettingsInputPort {
        doc /* Receives U-SET-STATE's active level 0–5 and active normalized speed limit; pending settings cannot enter this port. */
        in item payload:ActiveRidingSettings;
    }
    port def DemandAuthorityInputPort {
        doc /* Receives Session authority with independent generation, decision and expiry timestamps; matching generation never prolongs authority expiry. */
        in item payload:RidingAuthority;
    }
    port def DemandBatteryCapabilityInputPort {
        doc /* Receives Battery Protection's independently qualified positive-propulsion and negative-regeneration ceilings, reasons and restriction generations. */
        in item payload:BatteryCapabilityEnvelope;
    }
    port def DemandMotionInputPort {
        doc /* Receives qualified vehicle speed, direction and standstill from U-TRACTION-MOTION for cutoffs, recovery and rearm guards. */
        in item payload:QualifiedMotion;
    }
    port def DemandActualOutputInputPort {
        doc /* Receives U-TRACTION-ACTUAL-OUTPUT's qualified applied-wheel-torque estimate and powered-forward evidence for post-stop regen rearm. */
        in item payload:ActualTractionOutput;
    }
    port def DemandPlatformContextInputPort {
        doc /* Receives the current platform context that invalidates Demand state and prevents an old decision from crossing a reset boundary. */
        in item payload:PlatformContext;
    }
    port def DemandPlatformHealthInputPort {
        doc /* Receives platform health that can withdraw both torque signs without inventing a Session fault latch. */
        in item payload:PlatformHealth;
    }
    port def DemandCommandOutputPort {
        doc /* Sends the signed requested wheel torque, decision sequence and independently expiring command to U-TRACTION-ACCEPT; it is a request, never output evidence. */
        out item payload:WheelTorqueRequest;
    }
    part def DemandArbiter {
        /* Atomically evaluates current qualified rider, active-setting, authority, capability,
           motion and actual-output snapshots. It emits requestedWheelTorqueNewtonMetres with
           independent authority generation and command expiry. Pending settings, a command or PWM/register state never establish
           motion, actual applied torque, powered-forward travel or post-stop regen rearm. */
        port executionTimeIn:ExecutionTimeInputPort;
        port acceleratorIn:DemandAcceleratorInputPort;
        port brakeIn:DemandBrakeInputPort;
        port activeSettingsIn:DemandActiveSettingsInputPort;
        port authorityIn:DemandAuthorityInputPort;
        port batteryCapabilityIn:DemandBatteryCapabilityInputPort;
        port motionIn:DemandMotionInputPort;
        port actualOutputIn:DemandActualOutputInputPort;
        port platformContextIn:DemandPlatformContextInputPort;
        port platformHealthIn:DemandPlatformHealthInputPort;
        attribute compiledCalibrationId:String;
        attribute compiledDemandPolicyCalibration:DemandPolicyCalibration;
        attribute compiledCalibrationValid:Boolean;
        port commandOut:DemandCommandOutputPort;
    }
}
