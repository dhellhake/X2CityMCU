package X2CitySoftwareContract_BatteryProtection {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_BatteryControl::*;
    item def BatteryOperatingLimitsAssessment :> BatteryOperatingLimits {
        // Host-local decision time for Demand's independent freshness check. It is neither an
        // opaque BMS measurement time nor a general clock-service message.
        attribute operatingLimitsAssessmentTimeMicroseconds:Integer;
    }
    port def BatteryOperatingLimitsAssessmentOutputPort :> BatteryOperatingLimitsOutputPort {
        doc /* Publishes the assessed operating limits with their host-local assessment reference.
           For either unqualified, forbidden, or unavailable electrical branch, its published
           effective current limit is zero; a Real limit never authorizes an unknown branch. */
        out item operatingLimits:BatteryOperatingLimitsAssessment :>> BatteryOperatingLimitsOutputPort::operatingLimits;
    }
}

package X2CitySoftwareComponent_BatteryProtection {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BatteryProtection::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CitySoftwareContract_Platform::*;
    part def BatteryProtection {
        /* Vehicle-resident battery supervision. It assesses qualified pack measurements against
           fixed compiled pack configuration and qualified BMS source-configuration evidence,
           derives battery-side current limits and SOC
           restrictions, and never implements supplied-BMS firmware or protective switching. */
        port executionTimeIn:ExecutionTimeInputPort;
        port batteryMeasurementsIn:BatteryMeasurementsInputPort;
        port lowSocRetentionCandidateIn:~RetentionCandidateOutputPort;
        port batteryReadinessAndFaultOut:BatteryReadinessAndFaultOutputPort;
        port batteryOperatingLimitsOut:BatteryOperatingLimitsAssessmentOutputPort;
        port stateOfChargeOut:BatteryStateOfChargeOutputPort;
        port batteryCurrentOut:BatteryCurrentOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledBatteryConfigurationId:String;
        attribute compiledBatteryConfigurationValid:Boolean;
    }
}
