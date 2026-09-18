package X2CitySoftwareContract_SupplyInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CitySoftwareContract_Platform::*;
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
    port def FastInjectedEpochInputPort {
        doc /* Receives paired raw injected ADC values from AnalogAcquisition for fast DC-link voltage conversion. SupplyInterface applies its accepted fast-link calibration and aperture qualification before publishing Vdc. */
        in item payload:FastInjectedEpoch;
    }
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scans from AnalogAcquisition for regular supply-rail conversion. The regular path keeps its own source binding, state and calibration context separate from fast DC-link acquisition. */
        in item payload:AnalogSample;
    }
    item def FastDcLinkVoltage:>ContextualSoftwareInformation {
        attribute dcLinkVoltageVolts:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute apertureNanoseconds:Real;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def FastDcLinkVoltageOutputPort {
        doc /* Publishes qualified fast DC-link voltage with paired source ranks, aperture, timestamp and calibration context to TractionControl. This output is the fast Vdc control input and is not derived by MotorPhaseInterface. */
        out item payload:FastDcLinkVoltage;
    }
    item def SupplyVoltage:>ContextualSoftwareInformation {
        attribute supplyRail:String; // enum: board, logic, auxiliary, or fitted rail identity.
        attribute railVoltageVolts:Real;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute rankSkewNanoseconds:Real;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def SupplyVoltageOutputPort {
        doc /* Publishes qualified regular board, logic, auxiliary or fitted-rail voltage observations to SessionPolicy and BatteryProtection. The record retains the selected rail identity and source provenance. */
        out item payload:SupplyVoltage;
    }
    port def SupplyHealthOutputPort {
        doc /* Publishes supply conversion health evidence to Platform, SessionPolicy and TractionControl. It qualifies the fast and regular source paths rather than carrying a voltage command. */
        out item payload:SensorHealthCondition;
    }
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
        port executionTimeIn:ExecutionTimeInputPort;
        port fastInjectedEpochIn:FastInjectedEpochInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort;
        port supplyVoltageOut:SupplyVoltageOutputPort;
        port supplyHealthOut:SupplyHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledSupplyCalibration:SupplyCalibration;
        attribute compiledCalibrationValid:Boolean; // Startup check failure withholds affected supply conversion.
        // U-SUPPLY-FAST and U-SUPPLY-REGULAR have separate semantic state.
    }
}
