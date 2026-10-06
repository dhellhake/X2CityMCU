package X2CityContract_Compute {
    private import X2CitySharedContracts::*;

    item def ComputeRuntimeInitialization:>QualifiedInformationRecord {
        doc /* Reports availability of required runtime clocks, peripherals, and Platform's runtime monotonic timebase used by caller-supplied time references after initialization. It is not vehicle Ready or an aggregate of unrelated self-tests. */
        attribute requiredRuntimeReady:Boolean;
    }
    item def ComputeSleepRequest:>QualifiedInformationRecord {
        doc /* SessionPolicy is the sole sleep-eligibility owner and originates this qualified current request and its lifetime. It publishes enterSleep=true only while qualified explicit HMI Off and current qualified TractionConditionEvidence.computeSleepPermitted evidence both support eligibility. A false request revokes/cancels the grant. Consumers require valid, present, current-context, unexpired qualification; forwarding or copying preserves expiry and source context and cannot renew permission. */
        attribute enterSleep:Boolean;
        attribute expiry:Expiry;
    }

    port def ComputeRuntimeInitializationOutputPort { doc /* Publishes Platform runtime initialization availability to SessionPolicy. */ out item initialization:ComputeRuntimeInitialization; }
    port def ComputeRuntimeInitializationInputPort { doc /* Receives Platform runtime initialization availability for session qualification. */ in item initialization:ComputeRuntimeInitialization; }
    port def ComputeSleepRequestOutputPort { doc /* Carries SessionPolicy's qualified sleep request or explicit cancellation through Platform to ComputeHardware. */ out item request:ComputeSleepRequest; }
    port def ComputeSleepRequestInputPort { doc /* Receives the current qualified sleep request. False, absent, invalid, expired, context-mismatched, superseded or cancelled requests clear any older pending true request; it cannot be replayed or renewed downstream. */ in item request:ComputeSleepRequest; }

    interface def IfA006ComputeRuntimeInitialization { end platform:ComputeRuntimeInitializationOutputPort; end session:ComputeRuntimeInitializationInputPort; flow platform.initialization to session.initialization; }
    interface def IfA006ComputeSleepRequest { end session:ComputeSleepRequestOutputPort; end compute:ComputeSleepRequestInputPort; flow session.request to compute.request; }
    interface def IfA006PlatformSleepHandoff { end platform:ComputeSleepRequestOutputPort; end hardware:ComputeSleepRequestInputPort; flow platform.request to hardware.request; }
}

package X2CityComponent_Compute {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_ComputeHardware::*;
    private import X2CityComponent_Platform::*;
    private import X2CityContract_Compute::*;
    private import X2CityContract_ComputeHardware::*;
    private import X2CityContract_EnergyPath::*;

    part def Compute { // LE-COMPUTE
        /* Composes compute hardware and runtime Platform. Vehicle function blocks remain sibling allocations hosted by this MCU. The conditioned HMI wake is delegated directly to hardware; SessionPolicy owns sleep eligibility, and Platform checks request validity at execution before carrying out the selected handoff. */
        part computeHardware:ComputeHardware;
        part platform:Platform;
        port controllerWakeIn:ControllerWakeInputPort { doc /* Receives conditioned HMI hardware wake and delegates it to the compute hardware while the CPU is asleep. */ }
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* Receives general distributed EnergyPath supply at the compute boundary; no voltage, conversion, protection, or switching realization is selected. */ }
        port runtimeInitializationOut:ComputeRuntimeInitializationOutputPort;
        port sleepRequestIn:ComputeSleepRequestInputPort;
        flow controllerWakeToHardware from controllerWakeIn.controllerWake to computeHardware.controllerWakeIn.controllerWake;
        flow vehicleElectricalPowerToHardware from vehicleElectricalPowerIn.vehicleElectricalPower to computeHardware.vehicleElectricalPowerIn.vehicleElectricalPower;
        flow runtimeInitializationFromPlatform from platform.runtimeInitializationOut.initialization to runtimeInitializationOut.initialization;
        flow sleepRequestToPlatform from sleepRequestIn.request to platform.sleepRequestIn.request;
        interface sleepRequestToHardware : IfA006PlatformSleepHandoff
            connect platform.computeHardwareSleepRequestOut to computeHardware.sleepRequestIn;
    }
}
