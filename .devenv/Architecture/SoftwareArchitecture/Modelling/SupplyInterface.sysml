package X2CitySoftwareContract_SupplyInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    port def PSupplyFastRawI { in item payload:FastInjectedEpochV1; }
    port def PSupplyRegularRawI { in item payload:RegularAdcScanV1; }
    item def FastDcLinkVoltageV1:>ContextualSoftwareInformation {
        attribute dcLinkVoltageVolts:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute apertureNanoseconds:Real;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def PSupplyFastVdcO { out item payload:FastDcLinkVoltageV1; }
    item def SupplyVoltageV1:>ContextualSoftwareInformation {
        attribute supplyRail:String; // enum: board, logic, auxiliary, or fitted rail identity.
        attribute railVoltageVolts:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute rankSkewNanoseconds:Real;
        attribute sampleTimestampTicks:Integer;
        attribute calibrationContextId:String;
    }
    port def PSupplyRegularO { out item payload:SupplyVoltageV1; }
    port def PSupplyHealthO { out item payload:SensorHealthConditionV1; }
}

package X2CitySoftwareComponent_SupplyInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_SupplyInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-SUPPLY-IF.V; separate fast DC-link and regular supply-voltage semantic state.
    part def SupplyInterface {
        /* Owns DC-link voltage conversion from the fast injected aperture and regular supply
           voltage conversion from completed DMA scans. These paths keep distinct state/context;
           no Vdc conversion is delegated to MotorPhaseInterface. */
        port pSupplyFastRawI:PSupplyFastRawI;
        port pSupplyRegularRawI:PSupplyRegularRawI;
        port pSupplyFastVdcO:PSupplyFastVdcO;
        port pSupplyRegularO:PSupplyRegularO;
        port pSupplyHealthO:PSupplyHealthO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
        // U-SUPPLY-FAST and U-SUPPLY-REGULAR have separate semantic state.
    }
}
