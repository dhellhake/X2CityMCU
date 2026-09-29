package X2CityComponent_InputQualification {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    part def InputQualification { // LE-INPUT-QUAL
        /* Converts physical temperature and supply measurement evidence into qualified observations.
           It owns neither Session/Traction policy nor accelerator or brake qualification. */
        port temperatureMeasurementIn:TemperatureMeasurementInputPort;
        port supplyVoltageMeasurementIn:SupplyVoltageMeasurementInputPort;
        port qualifiedTemperatureOut:QualifiedTemperatureOutputPort;
        port temperatureHealthOut:TemperatureHealthOutputPort;
        port fastDcLinkVoltageOut:FastDcLinkVoltageOutputPort { doc /* Qualified PVDD only. */ }
        port regularSupplyVoltageOut:RegularSupplyVoltageOutputPort { doc /* Qualified GVDD only. */ }
        port supplyHealthOut:SupplyHealthOutputPort;
    }
}
