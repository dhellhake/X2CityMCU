# HmiInformationProcessing
## HMI information-processing requirements

**Type:** Abstract Software Requirement. **Target:** `LE-HMI`. **Status:** Draft allocation.

`LE-HMI` consumes the electrical endpoint's current-context transport evidence and publishes separate `ridingSettingsOut` and `runningLightStateOut` records, each containing its semantic value and qualification. It receives `SelectedFaultIndication`, qualified actual SOC/current and qualified vehicle motion to form the outgoing report. It also derives one qualified `VehicleOperationRequest` from `HmiPowerLockObservation` and publishes that composite to RidingControl, independently of UART transport or protocol. RidingControl owns sleep eligibility. No separate HMI-health route exists; initialization or invalidity is not a received setting, and a transmission is not display acknowledgement.

## Specification

- [Requirements](Specification/Requirements.sysml)
