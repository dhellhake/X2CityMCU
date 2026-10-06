package X2CityComponent_ComputeHardware {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ComputeHardware::*;
    private import X2CityContract_Compute::*;
    private import X2CityContract_EnergyPath::*;
    part def ComputeHardware { // LE-COMPUTE-HW
        /* Provides processor, memory and related execution hardware with the MCU wake input. It performs the selected sleep mode and wake capabilities for a current qualified Platform handoff; physical wake remains directly available while software sleeps. HMIControl owns awake physical power-lock observation and interpretation. Mode and wake compatibility remain characterization/derivation gates. */
        port controllerWakeIn:ControllerWakeInputPort { doc /* Receives conditioned hardware wake while the CPU is asleep; no UART or software task is required to deliver this signal. */ }
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* Receives general EnergyPath vehicle electrical power at the Compute hardware boundary. */ }
        port sleepRequestIn:ComputeSleepRequestInputPort { doc /* Receives Platform's validated selected-mode handoff with the Session grant's qualification, source context and expiry preserved; it does not renew permission or reevaluate eligibility. It performs the selected sleep mode and keeps conditioned hardware wake available in that mode. */ }
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
