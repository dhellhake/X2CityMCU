package X2CityDetailedUnit_SupplyInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_SupplyInterface::*;
    private import X2CityDetailedUnit_AnalogAcquisition::*;
    item def FastDcLinkVoltageRecord :> FastDcLinkVoltage;
    item def RegularSupply :> SupplyVoltage;
    port def FastDcLinkVoltageOutputPort {
        doc /* U-SUPPLY-FAST sends calibrated current local Vdc derived from the same fast epoch to traction control; regular supply data cannot substitute for it. */
        out item payload:FastDcLinkVoltageRecord;
    }
    port def RegularSupplyOutputPort {
        doc /* U-SUPPLY-REGULAR sends slower supply and rail diagnostics to policy and service consumers. */
        out item payload:RegularSupply;
    }
    port def InjectedEpochInputPort {
        doc /* U-SUPPLY-FAST receives the selected current JEOS/JDR raw epoch from fast acquisition for Vdc conversion. */
        in item payload:InjectedEpoch;
    }
    port def AnalogSampleInputPort {
        doc /* U-SUPPLY-REGULAR receives the distinct completed regular-DMA scan for non-fast supply conversion. */
        in item payload:AnalogSampleRecord;
    }
    port def SensorHealthOutputPort {
        doc /* Publishes fast Vdc and regular supply conversion health so consumers can reject the affected electrical observation. */
        out item payload:SensorHealthCondition;
    }
    part def FastSupplyVoltageProcessor { attribute compiledCalibrationId:String; attribute compiledSupplyCalibration:SupplyCalibration; attribute compiledCalibrationValid:Boolean; port executionTimeIn:ExecutionTimeInputPort; port injectedEpochIn:InjectedEpochInputPort; port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    part def RegularSupplyVoltageProcessor { attribute compiledCalibrationId:String; attribute compiledSupplyCalibration:SupplyCalibration; attribute compiledCalibrationValid:Boolean; port executionTimeIn:ExecutionTimeInputPort; port analogSampleIn:AnalogSampleInputPort; port regularSupplyOut:RegularSupplyOutputPort; port sensorHealthOut:SensorHealthOutputPort; }
    // SC-SUPPLY-IF.V owns rank-2 fast Vdc conversion and non-fast regular supplies separately.
}
