package X2CityComponent_Compute {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_ComputeHardware::*;
    private import X2CityComponent_Platform::*;
    private import X2CityContract_ComputeHardware::*;
    part def Compute { // LE-COMPUTE
        /* Composes compute hardware and platform services that host the system software functions. It provides the execution/platform boundary without allocating individual software units here, and delegates the hardware wake input to the processor boundary. */
        part computeHardware:ComputeHardware;
        part platform:Platform;
        port controllerWakeIn:ControllerWakeInputPort { doc /* Receives conditioned HMI hardware wake and delegates it to the compute hardware while the CPU is asleep. */ }
        flow controllerWakeToHardware from controllerWakeIn.controllerWake to computeHardware.controllerWakeIn.controllerWake;
    }
}
