package X2CityComponent_AcceleratorPositionIdentification {
    private import X2CityComponent_AcceleratorSignalMeasurement::*;
    private import X2CityComponent_AcceleratorPositionProcessing::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    private import X2CityContract_AcceleratorPositionProcessing::*;

    part def AcceleratorPositionIdentification { // LE-ACCELERATOR
        /* End-to-end logical accelerator function: electrical signal through measurement to qualified Position/Qualification. It owns no torque mapping, policy authorization or session latch. */
        part signalMeasurement:AcceleratorSignalMeasurement;
        part positionProcessing:AcceleratorPositionProcessing;
        port electricalSignalIn:AcceleratorElectricalSignalInputPort { doc /* Receives RiderDevices' unqualified electrical accelerator signal. */ }
        port acceleratorPositionOut:AcceleratorPositionOutputPort { doc /* Publishes one Position/Qualification composite to policy consumers. */ }
        port acceleratorHealthOut:AcceleratorHealthOutputPort { doc /* Publishes the composite Qualification projection to platform health. */ }
        flow electricalSignalToSignalMeasurement from electricalSignalIn.payload to signalMeasurement.electricalSignalIn.payload;
        flow measurementToPositionProcessing from signalMeasurement.measurementOut.payload to positionProcessing.measurementIn.payload;
        flow positionFromPositionProcessing from positionProcessing.acceleratorPositionOut.payload to acceleratorPositionOut.payload;
        flow healthFromPositionProcessing from positionProcessing.acceleratorHealthOut.payload to acceleratorHealthOut.payload;
    }
}
