package X2CitySoftwareContract_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    attribute def BrakeCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // ohm.
        attribute resistanceClassificationId:String;
        attribute releasedResistanceLimitOhms:Real;
        attribute appliedResistanceLimitOhms:Real;
        attribute adcRank:Integer;
    }
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scans from AnalogAcquisition. BrakeInterface consumes only the configured source rank with accepted calibration and converts it to a coded brake state; the input remains raw acquisition evidence. */
        in item payload:AnalogSample;
    }
    item def BrakeState:>ContextualSoftwareInformation {
        attribute brakeState:String; // enum: released, applied, implausible, unavailable.
        attribute sourceResistanceOhms:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def BrakeStateOutputPort {
        doc /* Publishes qualified released, applied, implausible or unavailable brake state with source resistance and acquisition provenance to SettingsPolicy, SessionPolicy, DemandPolicy, LightPolicy and service aggregation. Demand uses this state to block positive demand only. */
        out item payload:BrakeState;
    }
    port def BrakeHealthOutputPort {
        doc /* Publishes brake-sensor health evidence to Platform, SessionPolicy and service aggregation. It qualifies the source conversion and freshness rather than commanding physical brake actuation. */
        out item payload:SensorHealthCondition;
    }
}

package X2CitySoftwareComponent_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-BRAKE-IF.V; semantic coded-brake interface.
    part def BrakeInterface {
        /* Interprets only the current completed regular scan with accepted calibration as coded
           brake state/unknown. It owns no DMA storage, light arbitration, demand decision or
           physical brake proof. */
        port executionTimeIn:ExecutionTimeInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        port brakeStateOut:BrakeStateOutputPort;
        port brakeHealthOut:BrakeHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCalibration:BrakeCalibration;
        attribute compiledCalibrationValid:Boolean; // Startup check failure withholds usable brake conversion.
    }
}
