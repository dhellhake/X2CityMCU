package X2CitySpecification_BatteryControl_Reporting {
    private import X2CityComponent_BatteryControl::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMS-010'> batteryStatusReporting : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Parent: [REQ-SYS-BMS-003](BmsIntegration.sysml). Source:
            [REQ-SYS-BMS-005](../../Specification/BatteryControl.sysml), BAT-001 and DEC-FLT-005–009.
            Planned verification: I, T-SYS. Observe BatteryStatus at its BatteryControl-to-RidingControl
            interface for current, cleared and unknown battery conditions; verify the data are available for
            downstream reporting without battery-local code selection or priority.
            Open: physical delivery and end-to-end reporting timing remain subject to validation under
            OI-041/049.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CitySpecification_BatterySupervision_Reporting::bmsMosDisabledStatus;
        require X2CitySpecification_BatterySupervision_FaultHandling::batteryFaultRecognition;
        require X2CitySpecification_BatterySupervision_Reporting::batteryStatusPublication;
        require X2CitySpecification_BatterySupervision_StartupAndRestart::batteryStatusRestart;
        require X2CitySpecification_BatterySupervision_Reporting::batteryFaultReportEvidence;
        require X2CitySpecification_BatterySupervision_Reporting::lowDischargeVoltageStatus;
        require constraint {
            doc /*
                BatteryControl shall provide RidingControl with BatteryStatus containing the qualified
                battery-fault, MOS-warning and low-discharge-voltage conditions, preserving unknown
                qualification where applicable.
            */
        }
    }
    satisfy batteryStatusReporting by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
}
