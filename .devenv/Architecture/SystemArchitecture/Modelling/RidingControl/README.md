# RidingControl system component

`RidingControl.sysml` defines `LE-RIDING` as one software-allocated leaf in the EPCS. It retains the existing settings, session lifecycle/authority/reporting and demand responsibilities within one boundary. It receives each shared typed input once and retains separate authority, torque-command, selected-fault and sleep-request outputs. The four unit-level contracts remain in the software component model; no additional hardware component or external active-settings interface is introduced.

The architecture allocation and interfaces are documented in [ARCH-001](../../ARCH-001_System_Architecture.md) and the sole software realization in [SC-RIDING-CONTROL](../../../SoftwareArchitecture/RidingControl/README.md).
