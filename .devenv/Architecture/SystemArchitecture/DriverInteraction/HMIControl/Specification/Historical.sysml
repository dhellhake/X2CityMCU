package X2CitySpecification_HMIControl_Historical {
    private import X2CityComponent_HmiControl::HMIControl;
    private import RequirementTypes::*;

    requirement <'REQ-VEH-HMI-019'> pendingSettingFeedbackWithdrawal : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/DriverInteraction/HMIControl/HMIControl.md#req-veh-hmi-019
            (line 72).
            Original target: LE-HMI-CONTROL.
            Original type: System Requirement.
            Status: Withdrawn.
            ID: <a id="req-veh-hmi-019"></a>`REQ-VEH-HMI-019` **Withdrawn**
            Original obligation column: Requirement
            Sources / verification / gate: `DEC-HMI-007`; no pending-feedback implementation or
            communication-loss requirement remains.
        */
        subject owner:HMIControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.driverInteraction.hmiControl;
        require constraint {
            doc /*
                Additional pending-setting feedback is no longer required.
            */
        }
    }

}
