# Vehicle Software Architecture

`ARCH-003_Software_Architecture.md` is the vehicle static architecture and `Runtime_Integration_Contract.md` is its selected vehicle runtime allocation. Load the `.sysml` resources in `Modelling` as one SysML v2 model; the entry package is `X2CitySoftwareArchitecture`.

The model contains only vehicle V instances. `SharedSoftwareTypes.sysml` holds common context/qualification records. `Platform.sysml` carries the vehicle calibration families; `AnalogAcquisition.sysml` owns raw regular/injected records, while the named sensor interface files own typed semantic records and health. The root model has no Detailed Design import.
