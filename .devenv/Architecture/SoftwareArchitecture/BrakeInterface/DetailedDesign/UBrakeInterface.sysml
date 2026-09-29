package X2CityDetailedUnit_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityDetailedUnit_RegularSensorQualification::AnalogSampleInputPort;

    // Owner: SC-BRAKE-IF.V; DD-001; REQ-SYS-BRKSW-001–006; UR-BRAKE-QUALIFY-001.

    port def BrakeLeverStateOutputPort :> X2CitySoftwareContract_BrakeInterface::BrakeLeverStateOutputPort {
        doc /* U-BRAKE-QUALIFY sends the exact `BrakeLeverState` State/Qualification composite to policy consumers. State measurement time changes only for a new measurement; current startup-pending or recognized-fault qualification can change independently. */
        out item brakeLeverState:SoftwareBrakeLeverState :>> X2CitySoftwareContract_BrakeInterface::BrakeLeverStateOutputPort::brakeLeverState;
    }
    port def BrakeHealthOutputPort :> X2CitySoftwareContract_BrakeInterface::BrakeHealthOutputPort {
        doc /* Sends only the exact BrakeQualification projection to U-PLATFORM-HEALTH. */
        out item qualification:SoftwareBrakeQualification :>> X2CitySoftwareContract_BrakeInterface::BrakeHealthOutputPort::qualification;
    }
    part def BrakeQualifier {
        port executionTimeIn:ExecutionTimeInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCalibration:BrakeCalibration;
        attribute compiledCalibrationValid:Boolean;
        port brakeLeverStateOut:BrakeLeverStateOutputPort;
        port brakeHealthOut:BrakeHealthOutputPort;
        // The health output is the exact Qualification projection of the one state composite.
        flow brakeQualificationProjection from brakeLeverStateOut.brakeLeverState.Qualification to brakeHealthOut.qualification;
    }
    // The owner's fixed build-time set qualifies its named regular scan; configuration provenance is not live state.
}
