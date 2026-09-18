package X2CityContract_AcceleratorPositionProcessing {
    private import X2CitySharedContracts::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    item def AcceleratorPositionValue { attribute acceleratorPositionPercent:Real; attribute acceleratorAtRest:Boolean; attribute measurementTimeMicroseconds:Integer; }
    item def AcceleratorPositionQualification:>QualifiedInformationRecord {
        doc /* Position qualification and source-health evidence. Initial unqualification and recognized measurement fault are distinct; health-only updates never change Position measurement time. */
        attribute initialQualificationPending:Boolean;
        attribute recognizedMeasurementFault:Boolean;
    }
    item def AcceleratorPosition {
        doc /* Single composite publication with Position and Qualification. Consumers use Position only when Qualification permits it, while retaining Qualification when Position is unavailable. */
        item Position:AcceleratorPositionValue;
        item Qualification:AcceleratorPositionQualification;
    }
    port def AcceleratorPositionOutputPort { doc /* Publishes qualified position/rest and actual Position measurement time without torque mapping, authorization or session state. */ out item acceleratorPosition:AcceleratorPosition; }
    port def AcceleratorPositionInputPort { doc /* Receives the single qualified accelerator Position/Qualification composite. */ in item acceleratorPosition:AcceleratorPosition; }
    port def AcceleratorHealthOutputPort { doc /* Publishes the Qualification health projection to the platform health owner. */ out item qualification:AcceleratorPositionQualification; }
    port def AcceleratorHealthInputPort { doc /* Receives the Qualification health projection; it cannot make a Position valid or fresh. */ in item qualification:AcceleratorPositionQualification; }
    interface def IfA001AcceleratorPosition { end producer:AcceleratorPositionOutputPort; end consumer:AcceleratorPositionInputPort; flow producer.acceleratorPosition to consumer.acceleratorPosition; }
    interface def IfA008AcceleratorHealth { end producer:AcceleratorHealthOutputPort; end consumer:AcceleratorHealthInputPort; flow producer.qualification to consumer.qualification; }
    attribute def AcceleratorEndpointCalibration {
        attribute restVoltageMinimumVolts:Real { doc /* Validated lower bound, in volts, of the accelerator signal relative to sensor reference return at the mechanical released stop. */ }
        attribute restVoltageMaximumVolts:Real { doc /* Validated upper bound, in volts, of the accelerator signal relative to sensor reference return at the mechanical released stop. */ }
        attribute fullThrottleVoltageMinimumVolts:Real { doc /* Validated lower bound, in volts, of the accelerator signal relative to sensor reference return at the mechanical full-throttle stop. */ }
        attribute fullThrottleVoltageMaximumVolts:Real { doc /* Validated upper bound, in volts, of the accelerator signal relative to sensor reference return at the mechanical full-throttle stop. */ }
    }
}

package X2CityComponent_AcceleratorPositionProcessing {
    private import X2CityContract_AcceleratorPositionProcessing::*;
    private import X2CityContract_AcceleratorSignalMeasurement::*;
    part def AcceleratorPositionProcessing { // LE-ACCELERATOR-QUAL
        /* Software responsibility for handling accelerator measurement evidence and publishing semantic position/rest, measurement time, and qualification. */
        attribute endpointCalibration:AcceleratorEndpointCalibration { doc /* One immutable compiled calibration set; all four limits are determined during vehicle validation and used and validated together. */ }
        port measurementIn:AcceleratorMeasurementInputPort { doc /* Consumes abstract accelerator measurement evidence. */ }
        port acceleratorPositionOut:AcceleratorPositionOutputPort { doc /* Provides the one semantic Position/Qualification composite. */ }
        port acceleratorHealthOut:AcceleratorHealthOutputPort { doc /* Provides only the Qualification projection to platform health. */ }
        // The health publication is a projection of one AcceleratorPosition composite.
        flow healthProjectionFromPosition from acceleratorPositionOut.acceleratorPosition.Qualification to acceleratorHealthOut.qualification;
    }
}
