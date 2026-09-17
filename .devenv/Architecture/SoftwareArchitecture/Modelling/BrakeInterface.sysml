package X2CitySoftwareContract_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    port def PBrakeRawI {
        doc /* Receives completed regular ADC scans from AnalogAcquisition. BrakeInterface consumes only the configured source rank with accepted calibration and converts it to a coded brake state; the input remains raw acquisition evidence. */
        in item payload:RegularAdcScanV1;
    }
    item def BrakeStateV1:>ContextualSoftwareInformation {
        attribute brakeState:String; // enum: released, applied, implausible, unavailable.
        attribute sourceResistanceOhms:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def PBrakeStateO {
        doc /* Publishes qualified released, applied, implausible or unavailable brake state with source resistance and acquisition provenance to SettingsPolicy, SessionPolicy, DemandPolicy, LightPolicy and service aggregation. Demand uses this state to block positive demand only. */
        out item payload:BrakeStateV1;
    }
    port def PBrakeHealthO {
        doc /* Publishes brake-sensor health evidence to Platform, SessionPolicy and service aggregation. It qualifies the source conversion and freshness rather than commanding physical brake actuation. */
        out item payload:SensorHealthConditionV1;
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
        port pBrakeRawI:PBrakeRawI;
        port pBrakeStateO:PBrakeStateO;
        port pBrakeHealthO:PBrakeHealthO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
    }
}
