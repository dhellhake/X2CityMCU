package X2CityComponent_TractionHardware {
    private import X2CitySharedContracts::*;
    private import X2CityContract_MotorSignalMeasurement::*;
    private import X2CityContract_Input::*;
    part def TractionHardware { // LE-TRACTION-HW
        /* Provides physical propulsion conversion, actuation and physical Hall/current/bridge-observation evidence.
           This supplied role selects no duplicated controller occurrence, ADC, DMA, pin, firmware timing or semantic conversion. */
        port hallSignalsOut:HallSignalsOutputPort { doc /* Presents raw physical Hall electrical levels to MotorSignalMeasurement. */ }
        port motorPhaseElectricalOut:MotorPhaseElectricalOutputPort { doc /* Presents raw physical phase-current and bridge-voltage observation to MotorSignalMeasurement. */ }
        port temperatureElectricalSignalOut:TemperatureElectricalSignalOutputPort { doc /* Presents motor and traction-board temperature electrical signals to the shared input measurement boundary. */ }
        port supplyElectricalSignalOut:SupplyElectricalSignalOutputPort { doc /* Presents local traction PVDD and generated GVDD electrical signals to the shared input measurement boundary. */ }
    }
}
