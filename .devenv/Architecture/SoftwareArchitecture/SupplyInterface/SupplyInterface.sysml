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
    item def FastDcLinkVoltage:>ContextualSoftwareInformation, X2CityContract_Input::QualifiedSupplyVoltage {
        doc /* Qualified fast local PVDD. The inherited source is fixed to PVDD by this
               interface's immutable acquisition/calibration binding. */
        attribute dcLinkVoltageVolts:Real :>> X2CityContract_Input::QualifiedSupplyVoltage::voltageVolts;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute apertureNanoseconds:Real;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def FastDcLinkVoltageOutputPort :> X2CityContract_Input::FastDcLinkVoltageOutputPort {
        doc /* Publishes qualified fast DC-link voltage with paired source ranks, aperture, timestamp and calibration context to TractionControl. This output is the fast Vdc control input and is not derived by MotorPhaseInterface. */
        out item payload:FastDcLinkVoltage :>> X2CityContract_Input::FastDcLinkVoltageOutputPort::payload;
    }
    item def SupplyVoltage:>ContextualSoftwareInformation, X2CityContract_Input::QualifiedSupplyVoltage {
        attribute supplyRail:X2CityContract_Input::SupplyVoltageSource :>> X2CityContract_Input::QualifiedSupplyVoltage::source;
        attribute railVoltageVolts:Real :>> X2CityContract_Input::QualifiedSupplyVoltage::voltageVolts;
        attribute sourceAdcRank:Integer;
        attribute sourceAdcSequence:Integer;
        attribute rankSkewNanoseconds:Real;
        attribute sampleTimeMicroseconds:Integer;
        attribute configurationContextId:String; // fixed compiled build/config provenance; never live rollover.
    }
    port def SupplyVoltageOutputPort {
        doc /* Publishes qualified regular `GVDD` supply-diagnostic observations to SessionPolicy. supplyRail and railVoltageVolts refine the inherited logical source/value fields; source provenance remains local. */
        out item payload:SupplyVoltage;
    }
    item def SupplyHealthCondition:>SensorHealthCondition, X2CityContract_Input::SupplyQualification {
        doc /* Supply-specific projection joining the System PVDD/GVDD qualification with
               existing software conversion-health diagnostics. */
    }
    port def SupplyHealthOutputPort :> X2CityContract_Input::SupplyHealthOutputPort {
        doc /* Publishes supply conversion-health evidence to Platform, SessionPolicy and TractionControl. The regular logical source/value qualification remains on SupplyVoltage; this record carries fast/regular conversion diagnostics rather than a voltage command. */
        out item qualification:SupplyHealthCondition :>> X2CityContract_Input::SupplyHealthOutputPort::qualification;
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
