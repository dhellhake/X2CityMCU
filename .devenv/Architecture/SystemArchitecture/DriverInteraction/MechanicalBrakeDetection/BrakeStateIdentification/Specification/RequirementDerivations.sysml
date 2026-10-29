package X2CitySpecification_BrakeStateIdentification_RequirementDerivations {
    #derivation connection def REQSYSBRK006ToREQSYSBRKSW001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRK006ToREQSYSBRKSW001 : REQSYSBRK006ToREQSYSBRKSW001Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::brakeLeverIdentityDetection;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeResistanceStateClassification;
    }

    #derivation connection def REQSYSBRK007ToREQSYSBRKSW002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRK007ToREQSYSBRKSW002 : REQSYSBRK007ToREQSYSBRKSW002Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::invalidBrakeStateRepresentation;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeCalibrationStartupValidation;
    }

    #derivation connection def REQSYSBRK008ToREQSYSBRKSW002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRK008ToREQSYSBRKSW002 : REQSYSBRK008ToREQSYSBRKSW002Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::unusableBrakeStateRejection;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeCalibrationStartupValidation;
    }

    #derivation connection def REQSYSBRK008ToREQSYSBRKSW003Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRK008ToREQSYSBRKSW003 : REQSYSBRK008ToREQSYSBRKSW003Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::unusableBrakeStateRejection;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeMeasurementAgeQualification;
    }

    #derivation connection def REQSYSBRKDET001ToREQSYSBRKSW001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRKDET001ToREQSYSBRKSW001 : REQSYSBRKDET001ToREQSYSBRKSW001Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::brakeStateCompositePublication;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeResistanceStateClassification;
    }

    #derivation connection def REQSYSBRKDET001ToREQSYSBRKSW005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRKDET001ToREQSYSBRKSW005 : REQSYSBRKDET001ToREQSYSBRKSW005Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::brakeStateCompositePublication;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeMeasurementTimeRetention;
    }

    #derivation connection def REQSYSBRKDET002ToREQSYSBRKSW004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRKDET002ToREQSYSBRKSW004 : REQSYSBRKDET002ToREQSYSBRKSW004Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::brakeQualificationAndFaultRetention;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeStateRequalification;
    }

    #derivation connection def REQSYSBRKDET002ToREQSYSBRKSW006Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRKDET002ToREQSYSBRKSW006 : REQSYSBRKDET002ToREQSYSBRKSW006Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::brakeQualificationAndFaultRetention;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeMeasurementFaultDelivery;
    }

    #derivation connection def REQSYSHSI001ToREQSYSBRKSW001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSBRKSW001 : REQSYSHSI001ToREQSYSBRKSW001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeResistanceStateClassification;
    }

    #derivation connection def REQSYSHSI007ToREQSYSBRKSW004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI007ToREQSYSBRKSW004 : REQSYSHSI007ToREQSYSBRKSW004Derivation {
        end original ::> X2CitySpecification_Platform_SystemHardwareSoftwareInterface::endpointContextRequalification;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeStateRequalification;
    }

    #derivation connection def REQSYSINT002ToREQSYSBRKSW004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSINT002ToREQSYSBRKSW004 : REQSYSINT002ToREQSYSBRKSW004Derivation {
        end original ::> X2CitySpecification_X2CityMCU_InterfaceQualification::currentStartupPrerequisiteQualification;
        end derived ::> X2CitySpecification_BrakeStateIdentification_Requirements::brakeStateRequalification;
    }

}
