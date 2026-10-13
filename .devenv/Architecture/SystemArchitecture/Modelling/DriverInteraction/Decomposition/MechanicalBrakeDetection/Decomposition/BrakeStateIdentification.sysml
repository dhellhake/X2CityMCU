package X2CityContract_BrakeStateIdentification {
    private import X2CitySharedContracts::*;
    private import X2CityContract_BrakeSignalMeasurement::*;

    enum def BrakeLeverCombination { enum Neither; enum Left; enum Right; enum Both; }
    item def BrakeLeverStateValue {
        attribute leverCombination:BrakeLeverCombination;
        attribute measurementTimeMicroseconds:Integer;
    }
    item def BrakeQualification:>QualifiedInformationRecord {
        doc /* Initial unqualification and a recognized measurement fault remain distinct. */
        attribute initialQualificationPending:Boolean;
        attribute recognizedMeasurementFault:Boolean;
    }
    item def BrakeLeverState {
        doc /* Single semantic brake publication. Consumers derive any actuation meaning from State only when Qualification permits use. */
        item State:BrakeLeverStateValue;
        item Qualification:BrakeQualification;
    }
    port def BrakeLeverStateOutputPort { doc /* Publishes the complete State/Qualification brake lever composite. */ out item brakeLeverState:BrakeLeverState; }
    port def BrakeLeverStateInputPort { doc /* Receives the complete State/Qualification brake lever composite. */ in item brakeLeverState:BrakeLeverState; }
    port def BrakeHealthOutputPort { doc /* Publishes only the Qualification projection from the same BrakeLeverState composite. */ out item qualification:BrakeQualification; }
    port def BrakeHealthInputPort { doc /* Receives the Qualification projection; it cannot establish a usable State. */ in item qualification:BrakeQualification; }
    interface def IfA001BrakeLeverState { end producer:BrakeLeverStateOutputPort; end consumer:BrakeLeverStateInputPort; flow producer.brakeLeverState to consumer.brakeLeverState; }
    interface def IfA008BrakeHealth { end producer:BrakeHealthOutputPort; end consumer:BrakeHealthInputPort; flow producer.qualification to consumer.qualification; }
    attribute def ResistanceAcceptanceBand {
        attribute minResistanceOhms:Real;
        attribute maxResistanceOhms:Real;
    }
    attribute def BrakeStateCalibration {
        attribute neitherPressed:ResistanceAcceptanceBand;
        attribute leftPressed:ResistanceAcceptanceBand;
        attribute rightPressed:ResistanceAcceptanceBand;
        attribute bothPressed:ResistanceAcceptanceBand;
    }
}

package X2CityComponent_BrakeStateIdentification {
    private import X2CityContract_BrakeSignalMeasurement::*;
    private import X2CityContract_BrakeStateIdentification::*;
    part def BrakeStateIdentification { // LE-BRAKE-STATE
        /* Software responsibility for converting brake measurement evidence into semantic State, firmware-owned measurement time, and Qualification. Its immutable compiled calibration has four resistance bands with TBD derived values; startup validation rejects unordered or overlapping bands. */
        attribute stateCalibration:BrakeStateCalibration { doc /* One immutable compiled set containing neitherPressed, leftPressed, rightPressed, and bothPressed resistance-acceptance bands. */ }
        port brakeMeasurementIn:BrakeMeasurementInputPort { doc /* Consumes abstract physical brake-response evidence. */ }
        port brakeLeverStateOut:BrakeLeverStateOutputPort { doc /* Provides the one State/Qualification composite. */ }
        port brakeHealthOut:BrakeHealthOutputPort { doc /* Provides only the Qualification projection to Platform. */ }
        // The health publication is a projection of one BrakeLeverState composite.
        flow healthProjectionFromState from brakeLeverStateOut.brakeLeverState.Qualification to brakeHealthOut.qualification;
    }
}
