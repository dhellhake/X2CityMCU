package X2CitySoftwareContract_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityContract_Input::*;
    attribute def BrakeCalibration {
        attribute sourceId:String;
        attribute engineeringUnit:String; // ohm.
        attribute validatedFourStateClassificationId:String;
        attribute adcRank:Integer;
    }
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scans from AnalogAcquisition. BrakeInterface consumes only the configured source rank with accepted calibration and converts it to a coded brake state; the input remains raw acquisition evidence. */
        in item payload:AnalogSample;
    }
    item def BrakeState:>ContextualSoftwareInformation, QualifiedBrakeInput {
        attribute sourceResistanceOhms:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def BrakeStateOutputPort {
        doc /* Publishes the qualified `Neither`, `Left`, `Right` or `Both` mechanical brake-lever identity with source resistance and acquisition provenance to SettingsPolicy, SessionPolicy, DemandPolicy and LightModeSelection. The inherited qualification represents unknown, unavailable, stale or implausible information; it is never substituted by `Neither`. The inherited brakeLeverActuated projection is true exactly for Left, Right or Both. Demand uses it to block positive demand only. */
        out item payload:BrakeState;
    }
    port def BrakeHealthOutputPort {
        doc /* Publishes the brake conversion-health projection to Platform and SessionPolicy. BrakeState carries the logical BrakeQualification and four-state identity; this implementation health record retains conversion diagnostics and freshness rather than commanding physical brake actuation. */
        out item payload:SensorHealthCondition;
    }
}

package X2CitySoftwareComponent_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-BRAKE-IF.V; semantic coded-brake interface.
    part def BrakeInterface {
        /* Interprets only the current completed regular scan with an accepted, validated
           four-state classification as coded brake identity and qualification. It owns no DMA
           storage, light arbitration, demand decision or physical brake proof. */
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
