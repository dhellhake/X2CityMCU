package X2CitySoftwareContract_AcceleratorInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    port def PAccelRawI { in item payload:RegularAdcScanV1; }
    item def AcceleratorPositionV1:>ContextualSoftwareInformation {
        attribute acceleratorPositionPercent:Real; // percent, 0..100 after qualified scaling.
        attribute acceleratorAtRest:Boolean;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def PAccelPositionO { out item payload:AcceleratorPositionV1; }
    port def PAccelHealthO { out item payload:SensorHealthConditionV1; }
}

package X2CitySoftwareComponent_AcceleratorInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-ACCELERATOR-IF.V; semantic rider-position interface.
    part def AcceleratorInterface {
        /* Accepts a completed regular scan and active calibration only in the current context,
           then publishes accelerator position/rest/availability. It owns no DMA storage or rider
           demand decision. */
        port pAccelRawI:PAccelRawI;
        port pAccelPositionO:PAccelPositionO;
        port pAccelHealthO:PAccelHealthO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
    }
}
