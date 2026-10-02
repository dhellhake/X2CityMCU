package X2CityComponent_ComputeHardware {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ComputeHardware::*;
    part def ComputeHardware { // LE-COMPUTE-HW
        /* Provides processor, memory, related execution hardware and the MCU wake input for the compute boundary. This is a supplied physical role; software behavior is allocated to the platform and policies. */
        port controllerWakeIn:ControllerWakeInputPort { doc /* Receives conditioned hardware wake while the CPU is asleep; no UART or software task is required to deliver this signal. */ }
    }
}

package X2CityContract_ComputeHardware {
    item def ControllerWakeSignal {
        doc /* Vehicle-hardware-conditioned MCU-safe controller wake signal derived from the supplied display's raw power-lock line. This logical type is distinct from the raw supplied signal and specifies no pin, voltage, wake mode or conditioning circuit. */
    }
    port def ControllerWakeOutputPort { doc /* Publishes the conditioned controller wake signal from HMI electrical hardware. */ out item controllerWake:ControllerWakeSignal; }
    port def ControllerWakeInputPort { doc /* Receives the conditioned controller wake signal at the compute boundary. */ in item controllerWake:ControllerWakeSignal; }
    interface def IfA006ControllerWake { doc /* Carries the conditioned hardware wake from HMIControl to Compute without involving EnergyPath or MCU software. */ end hmiControl:ControllerWakeOutputPort; end compute:ControllerWakeInputPort; flow hmiControl.controllerWake to compute.controllerWake; }
}
