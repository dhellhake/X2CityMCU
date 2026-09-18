package X2CityDetailedUnit_AcceleratorInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CitySoftwareContract_AcceleratorInterface::*;
    private import X2CityDetailedUnit_RiderTemperatureInterfaces::AnalogSampleInputPort;

    item def AcceleratorPositionRecord :> AcceleratorPosition;
    port def AcceleratorPositionOutputPort {
        doc /* U-ACCELERATOR-QUALIFY sends one position-and-health composite to Settings, Session and Demand. Position is used only when its contained Qualification supports it; unavailability and current health are published even with no new ADC sample, without changing Position sample time or refreshing measurement age. */
        out item payload:AcceleratorPositionRecord;
    }
    part def AcceleratorQualifier {
        port analogSampleIn:AnalogSampleInputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCalibration:AcceleratorCalibration;
        attribute compiledCalibrationValid:Boolean;
        port executionTimeIn:ExecutionTimeInputPort;
        port acceleratorPositionOut:AcceleratorPositionOutputPort;
    }
    // The owner's fixed build-time set qualifies its named regular scan; configuration provenance is not live state.
}
