# X2City vehicle system architecture SysML v2 model

`ARCH-001_System_Architecture.md` is the logical vehicle architecture authority. Load the `.sysml` resources in `Modelling/` as one SysML v2 model, rooted at `X2CitySystemArchitecture`.

The model is static and logical. It defines vehicle component composition and information contracts `IF-A-001` through `IF-A-006`, `IF-A-008`, and `IF-A-009`. Physical energy, protection, mechanical and handling boundaries remain in ARCH-002. BMS/cell charge-acceptance facts constrain generated wheel energy entering the installed pack.

Validation is structural and source-contract review only; this Draft does not claim a SysML compiler result.
