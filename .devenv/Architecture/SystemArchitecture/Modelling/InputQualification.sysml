package X2CityComponent_InputQualification {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    part def InputQualification { // LE-INPUT-QUAL
        /* Converts physical brake, temperature and supply measurement evidence into qualified observations.
           It owns neither Session/Traction policy nor accelerator qualification. */
        port codedBrakeMeasurementIn:CodedBrakeMeasurementInputPort;
        port temperatureMeasurementIn:TemperatureMeasurementInputPort;
        port supplyVoltageMeasurementIn:SupplyVoltageMeasurementInputPort;
        port brakeLeverStateOut:BrakeStateOutputPort { doc /* Publishes Neither, Left, Right or Both only when qualified. */ }
        port brakeHealthOut:BrakeHealthOutputPort;
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort;
        port temperatureHealthOut:TemperatureHealthOutputPort;
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort { doc /* Qualified PVDD only. */ }
        port regularSupplyVoltageOut:RegularSupplyVoltageOutputPort { doc /* Qualified GVDD only. */ }
        port supplyHealthOut:SupplyHealthOutputPort;
    }
}
