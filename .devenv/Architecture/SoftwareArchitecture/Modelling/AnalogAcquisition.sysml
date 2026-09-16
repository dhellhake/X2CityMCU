package X2CitySoftwareContract_AnalogAcquisition {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    // P-AA-RAW-I is the vehicle ADC acquisition boundary; it carries no sensor meaning.
    item def PAArawIInformation:>ContextualSoftwareInformation;
    port def PAArawI { in item payload:PAArawIInformation; }
    item def RegularAdcScanV1:>ContextualSoftwareInformation {
        // Raw DMA scan: channel identity and ADC code, never a semantic sensor value.
        attribute adcSequence:Integer;
        attribute completionTimestampTicks:Integer;
        attribute rawRankIndex:Integer;
        attribute rawAdcCode:Integer;
        attribute calibrationContextId:String;
    }
    port def PAARegularO { out item payload:RegularAdcScanV1; }
    item def FastInjectedEpochV1:>ContextualSoftwareInformation {
        // JEOS/JDR epoch: the paired raw rank values share the stated aperture.
        attribute adcSequence:Integer;
        attribute acquisitionTimestampTicks:Integer;
        attribute apertureNanoseconds:Real;
        attribute currentPairIdentity:String;
        attribute firstRawAdcCode:Integer;
        attribute secondRawAdcCode:Integer;
        attribute calibrationContextId:String;
    }
    port def PAAFastO { out item payload:FastInjectedEpochV1; }
    port def PAAHealthO { out item payload:SensorHealthConditionV1; }
}

package X2CitySoftwareComponent_AnalogAcquisition {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-ANALOG-ACQ.V; static architecture only.
    part def AnalogAcquisition {
        /* Owns raw regular DMA completion and raw injected JEOS/JDR acquisition only. The regular
           and fast paths have distinct records, state, buffers and producer contexts. It assigns
           no accelerator, brake, temperature, current, voltage or rotor meaning to either record. */
        port pAaRawI:PAArawI;
        port pAaRegularO:PAARegularO;
        port pAaFastO:PAAFastO;
        port pAaHealthO:PAAHealthO;
        port platformContextRequired:~PPltContextO;
        port platformHealthRequired:~PPltHealthO;
        port calibrationRequired:~PPltCalibrationO;
        // U-ANALOG-ACQ-REGULAR and U-ANALOG-ACQ-FAST are distinct DD owners.
    }
}
