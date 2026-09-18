# X2City vehicle system architecture SysML v2 model

`ARCH-001_System_Architecture.md` is the logical vehicle architecture authority. Load the `.sysml` resources in `Modelling/` recursively, including subfolders, as one SysML v2 model, rooted at `X2CitySystemArchitecture`.

Component navigation: [Accelerator position identification](Modelling/AcceleratorPositionIdentification/README.md) (parent decomposition, hardware signal measurement, and software position processing).

The model is static and logical. It defines vehicle component composition and information contracts `IF-A-001` through `IF-A-006` and `IF-A-009`. `LE-ACCELERATOR` is the Draft end-to-end accelerator function: RiderDevices electrical signal through logical signal measurement and position processing to one qualified `AcceleratorPosition`, with typed policy and platform-health routes. The two leaves describe HW/SW responsibility; acquisition and transfer realization remains prospective. Debugger inspection of operational variables is an engineering method outside this runtime decomposition. Physical energy, protection, mechanical and handling boundaries remain in ARCH-002. BMS/cell charge-acceptance facts constrain generated wheel energy entering the installed pack.

Validation is structural and source-contract review only; this Draft does not claim a SysML compiler result.
