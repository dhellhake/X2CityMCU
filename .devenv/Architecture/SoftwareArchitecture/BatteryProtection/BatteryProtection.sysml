package X2CitySoftwareContract_BatteryProtection {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_BatteryControl::*;
    item def BatteryOperatingLimitsAssessment :> BatteryOperatingLimits;
    port def BatteryOperatingLimitsAssessmentOutputPort :> BatteryOperatingLimitsOutputPort {
        doc /* Publishes independently qualified effective operating capabilities with their
           field qualification. An unqualified or unavailable electrical branch has effective current limit
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
           do not reset or reacquire the reference. It privately retains the functional effect of restart-required faults recognized
           from qualified operational evidence; both candidates remain unqualified with zero
           current until controller startup. The restriction unit preserves candidate qualification
           without consulting diagnostic status. It derives
           battery-side electrical current limits and SOC/temperature restrictions, with
           branch qualification carried through
           BatteryOperatingLimitsAssessment. BatteryStatus independently carries recognized
           fault evidence and ordering and qualified MOS-disabled warning even if limits are unqualified. It never implements supplied-
           BMS firmware or protective switching. */
        port executionTimeIn:ExecutionTimeInputPort;
        port batteryMeasurementsIn:BatteryMeasurementsInputPort;
        port bmsStatusIn:BatteryStatusInputPort;
        port batteryStatusOut:BatteryStatusOutputPort;
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
