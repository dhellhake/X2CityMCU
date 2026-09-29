package X2CitySoftwareContract_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_AnalogAcquisition::*;
    private import X2CityContract_BrakeStateIdentification::*;
    attribute def BrakeCalibration :> BrakeStateCalibration {
        // Static source binding/refinement data. The inherited calibration contains the four
        // immutable resistance acceptance bands; this type never replaces them with an ID.
        attribute sourceId:String;
        attribute adcRank:Integer;
    }
    item def SoftwareBrakeQualification :> BrakeQualification {
        // `sourceContext` and validity are inherited from the logical qualification. These
        // software fields preserve fault ordering and reset/configuration rejection without
        // adding a third member to the State/Qualification composite.
        attribute recognizedFaultTimeMicroseconds:Integer;
        attribute recognizedFaultReason:String;
        attribute configurationContextId:String;
        attribute currentGeneration:ContextGeneration;
    }
    item def SoftwareBrakeLeverState :> BrakeLeverState {
        item Qualification:SoftwareBrakeQualification :>> BrakeLeverState::Qualification;
    }
    port def AnalogSampleInputPort {
        doc /* Receives completed regular ADC scans from AnalogAcquisition. BrakeInterface consumes only its compiled source/rank binding and derives resistance using the approved physical-transfer calibration; it selects no circuit, excitation, linear transfer coefficient or threshold. */
        in item payload:AnalogSample;
    }
    port def BrakeLeverStateOutputPort :> X2CityContract_BrakeStateIdentification::BrakeLeverStateOutputPort {
        doc /* Publishes exactly the System `BrakeLeverState` composite: `State` has the four-valued lever combination and actual measurement time; `Qualification` distinguishes startup-pending from a recognized measurement fault. Consumers derive any-actuation from a qualified combination and do not receive a separate Boolean projection. */
        out item brakeLeverState:SoftwareBrakeLeverState :>> X2CityContract_BrakeStateIdentification::BrakeLeverStateOutputPort::brakeLeverState;
    }
    port def BrakeHealthOutputPort :> X2CityContract_BrakeStateIdentification::BrakeHealthOutputPort {
        doc /* Publishes only the exact `BrakeQualification` projection to Platform. Qualification-only updates can report a new pending/fault condition without refreshing `State.measurementTimeMicroseconds`. */
        out item qualification:SoftwareBrakeQualification :>> X2CityContract_BrakeStateIdentification::BrakeHealthOutputPort::qualification;
    }
}

package X2CitySoftwareComponent_BrakeInterface {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_BrakeInterface::*;
    private import X2CitySoftwareContract_Platform::*;
    // SC-BRAKE-IF.V; semantic coded-brake interface.
    part def BrakeInterface {
        /* Interprets only the current completed regular scan with an accepted, validated
           four-state classification as coded brake identity and qualification. It owns no DMA
           storage, light arbitration, demand decision, physical-brake proof or Settings dependency. */
        port executionTimeIn:ExecutionTimeInputPort;
        port analogSampleIn:AnalogSampleInputPort;
        port brakeLeverStateOut:BrakeLeverStateOutputPort;
        port brakeHealthOut:BrakeHealthOutputPort;
        port platformContextIn:~PlatformContextOutputPort;
        port platformHealthIn:~PlatformHealthOutputPort;
        attribute compiledCalibrationId:String;
        attribute compiledCalibration:BrakeCalibration;
        attribute compiledCalibrationValid:Boolean; // Startup check failure withholds usable brake conversion.
        // This is a projection, never a separately owned health state.
        flow brakeQualificationProjection from brakeLeverStateOut.brakeLeverState.Qualification to brakeHealthOut.qualification;
    }
}
