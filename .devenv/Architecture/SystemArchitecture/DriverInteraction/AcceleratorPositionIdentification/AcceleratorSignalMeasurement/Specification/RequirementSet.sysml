package X2CitySpecification_AcceleratorSignalMeasurement_RequirementSet {
    #derivation connection def REQSYSACC001ToREQSYSACC003Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC003 : REQSYSACC001ToREQSYSACC003Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorSignalMeasurement_Requirements::acceleratorElectricalSignalMeasurement;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC014Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC014 : REQSYSACC006ToREQSYSACC014Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorSignalMeasurement_Requirements::acceleratorMeasurementPublication;
    }

    #derivation connection def REQSYSACC031ToREQSYSACC043Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC031ToREQSYSACC043 : REQSYSACC031ToREQSYSACC043Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorElectricalInterfaceCompatibility;
        end derived ::> X2CitySpecification_AcceleratorSignalMeasurement_Requirements::acceleratorSensorElectricalCompatibility;
    }

    #derivation connection def REQSYSHSI001ToREQSYSACC003Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSACC003 : REQSYSHSI001ToREQSYSACC003Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_AcceleratorSignalMeasurement_Requirements::acceleratorElectricalSignalMeasurement;
    }

    #derivation connection def REQSYSHSI001ToREQSYSACC014Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSACC014 : REQSYSHSI001ToREQSYSACC014Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_AcceleratorSignalMeasurement_Requirements::acceleratorMeasurementPublication;
    }

}
