package X2CitySoftwareContract_Platform {
    private import X2CitySharedSoftwareTypes::*;
    // P-PLT-CONTEXT-O is a stable ARCH-003 port identifier.
    item def PPltContextOInformation:>ContextualSoftwareInformation;
    port def PPltContextO { out item payload:PPltContextOInformation; }
    // P-PLT-RETENTION-O is a stable ARCH-003 port identifier.
    item def PPltRetentionOInformation:>ContextualSoftwareInformation;
    port def PPltRetentionO { out item payload:PPltRetentionOInformation; }
    // P-PLT-HEALTH-O is a stable ARCH-003 port identifier.
    item def PPltHealthOInformation:>ContextualSoftwareInformation {
        attribute fastSafetyState:String; // enum: inactive, armed, inhibited, latched.
    }
    port def PPltHealthO { out item payload:PPltHealthOInformation; }
    // Normalized qualified evidence from one producer. Platform consumes this evidence without
    // publishing it back as a new sensor cause; a platform fast-safety state is separate from a
    // Session-recognized fault and its fault-code policy.
    item def SensorHealthConditionV1:>ContextualSoftwareInformation {
        attribute source:String;
        attribute reason:String;
        attribute severity:String;
        attribute immediateFastInhibitRequested:Boolean;
        attribute evidenceTimestampTicks:Integer;
        attribute relatedAdcSequence:Integer;
        attribute calibrationContextId:String;
    }
    // P-PLT-SENSOR-HEALTH-I is a stable normalized health-evidence ingress.
    port def PPltSensorHealthI { in item payload:SensorHealthConditionV1; }
    // Typed calibration entries carry logical coefficients/identities, never selected numeric
    // values. U-PLATFORM-CALIBRATION validates and freezes the bundle before publication.
    attribute def RawAcquisitionBindingCalibration {
        attribute sourceId:String;
        attribute regularAdcRank:Integer;
        attribute injectedFirstAdcRank:Integer;
        attribute injectedSecondAdcRank:Integer;
        attribute regularTriggerId:String;
        attribute injectedTriggerId:String;
    }
    attribute def CurrentPhaseCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // A and A/ADC-code as applicable.
        attribute phaseAssociation:String;
        attribute currentOffsetAmperes:Real;
        attribute currentGainAmperesPerAdcCode:Real;
        attribute currentPolarity:String;
        attribute referenceCurrentAmperes:Real;
        attribute firstAdcRank:Integer;
        attribute secondAdcRank:Integer;
    }
    attribute def SupplyCalibration {
        attribute fastDcLinkSourceId:String;
        attribute fastDcLinkGainVoltsPerAdcCode:Real;
        attribute fastDcLinkOffsetVolts:Real;
        attribute fastDcLinkAdcRank:Integer;
        attribute regularRailSourceId:String;
        attribute regularRailGainVoltsPerAdcCode:Real;
        attribute regularRailOffsetVolts:Real;
        attribute regularRailAdcRank:Integer;
    }
    attribute def HallCalibration {
        attribute sourceId:String;
        attribute electricalMapId:String;
        attribute alignmentElectricalDegrees:Real;
        attribute captureTimerId:String;
        attribute captureTimerTickNanoseconds:Real;
    }
    attribute def AcceleratorCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // percent.
        attribute minimumPositionPercent:Real;
        attribute maximumPositionPercent:Real;
        attribute restThresholdPercent:Real;
        attribute adcRank:Integer;
    }
    attribute def BrakeCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // ohm.
        attribute resistanceClassificationId:String;
        attribute releasedResistanceLimitOhms:Real;
        attribute appliedResistanceLimitOhms:Real;
        attribute adcRank:Integer;
    }
    attribute def TemperatureCalibration {
        attribute boardTemperatureSourceId:String;
        attribute motorTemperatureSourceId:String;
        attribute engineeringUnit:String; // degC.
        attribute boardTemperatureOffsetCelsius:Real;
        attribute boardTemperatureGainCelsiusPerAdcCode:Real;
        attribute motorTemperatureOffsetCelsius:Real;
        attribute motorTemperatureGainCelsiusPerAdcCode:Real;
        attribute boardAdcRank:Integer;
        attribute motorAdcRank:Integer;
    }
    item def CalibrationBundleV1:>ContextualSoftwareInformation {
        attribute immutable:Boolean;
        attribute bundleId:String;
        attribute bundleRevision:String;
        attribute activationContextId:String;
        attribute rawAcquisitionBinding:RawAcquisitionBindingCalibration;
        attribute currentPhaseCalibration:CurrentPhaseCalibration;
        attribute supplyCalibration:SupplyCalibration;
        attribute hallCalibration:HallCalibration;
        attribute acceleratorCalibration:AcceleratorCalibration;
        attribute brakeCalibration:BrakeCalibration;
        attribute temperatureCalibration:TemperatureCalibration;
    }
    // P-PLT-CALIBRATION-O directly carries the immutable typed CalibrationBundleV1.
    item def PPltCalibrationOInformation:>CalibrationBundleV1;
    port def PPltCalibrationO { out item payload:PPltCalibrationOInformation; }
}

package X2CitySoftwareComponent_Platform {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-PLATFORM; static architecture only. No unit-local API, task, or hardware pin is declared here.
    part def Platform {
        /* Establishes local execution/reset context, retained-state access, and platform-health
           information for its host instance. U-PLATFORM-BINDING owns static peripheral/IRQ/rank/
           trigger configuration; U-PLATFORM-CALIBRATION owns immutable typed calibration-bundle
           lifecycle and activation only while disarmed in a new context. Vehicle sensor interfaces read
           their applicable entry and accept semantic
           calibration. It consumes qualified sensor evidence to drive its separate FastSafetyState
           without feeding its health publication back as a new sensor root cause. Platform does
           not own ADC sampling, control math, or PWM/JSQR writes. */
        port pPltContextO:PPltContextO;
        port pPltRetentionO:PPltRetentionO;
        port pPltHealthO:PPltHealthO;
        port pPltCalibrationO:PPltCalibrationO;
        port pPltSensorHealthI:PPltSensorHealthI;
        // A platform instance also consumes its own generation/health service events.
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
    }
}
