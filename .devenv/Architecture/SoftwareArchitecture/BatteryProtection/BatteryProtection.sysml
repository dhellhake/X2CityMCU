package X2CitySoftwareContract_BatteryProtection {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_BatteryControl::*;
    item def BatteryOperatingLimitsAssessment :> BatteryOperatingLimits;
    port def BatteryOperatingLimitsAssessmentOutputPort :> BatteryOperatingLimitsOutputPort {
        doc /* Publishes independently qualified effective operating capabilities with their
           field qualification, including the independently qualified composite MOS-disabled
           status. An unqualified or unavailable electrical branch has effective current limit
           zero; a qualified zero is a valid known capability. */
        out item operatingLimits:BatteryOperatingLimitsAssessment :>> BatteryOperatingLimitsOutputPort::operatingLimits;
    }
}

package X2CitySoftwareComponent_BatteryProtection {
    private import X2CitySoftwareContract_BatteryProtection::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityComponent_BatterySupervision::*;
    part def BatteryProtection {
        /* Vehicle-resident battery supervision assesses qualified observations/source evidence
           against compiled pack constraints. It consumes published field qualifications and
           does not inspect raw BMS fields. U-BAT-POLICY-EVALUATE owns one private per-cycle
           startup nominal-capacity reference shared by regenerative-charge and discharge
           base currents. It captures the same
           qualified finite positive capacity at normal or unexpected controller startup and
           retains it through the complete controller cycle; later field or context changes
           do not reset or reacquire the reference. It derives
           battery-side electrical current limits and SOC/temperature restrictions, with
           branch qualification carried through
           BatteryOperatingLimitsAssessment, including independently qualified composite MOS
           disabled status. BatteryFaultStatus independently carries recognized
           fault evidence and ordering even if limits are unqualified. It never implements supplied-
           BMS firmware or protective switching. */
        port executionTimeIn:ExecutionTimeInputPort;
        port batteryMeasurementsIn:BatteryMeasurementsInputPort;
        port batteryFaultStatusOut:BatteryFaultStatusOutputPort;
        port batteryOperatingLimitsOut:BatteryOperatingLimitsAssessmentOutputPort;
        port stateOfChargeOut:BatteryStateOfChargeOutputPort;
        port batteryCurrentOut:BatteryCurrentOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledBatteryConfigurationId:String;
        attribute compiledBatteryConfigurationValid:Boolean;
        attribute compiledVoltageDeratingCalibration:X2CityComponent_BatterySupervision::BatteryVoltageDeratingCalibration;
    }
}
