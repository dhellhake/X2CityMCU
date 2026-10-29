package X2CitySpecification_MotorSignalMeasurement_RequirementSet {
    #derivation connection def REQSYSHSI001ToREQSYSMSM001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSMSM001 : REQSYSHSI001ToREQSYSMSM001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_MotorSignalMeasurement_Requirements::hallAndPhaseCurrentAcquisition;
    }

    #derivation connection def REQSYSHSI009ToREQSYSMSM001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI009ToREQSYSMSM001 : REQSYSHSI009ToREQSYSMSM001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::tractionPhysicalSoftwareBoundary;
        end derived ::> X2CitySpecification_MotorSignalMeasurement_Requirements::hallAndPhaseCurrentAcquisition;
    }

    #derivation connection def REQSYSHSI009ToREQSYSMSM002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI009ToREQSYSMSM002 : REQSYSHSI009ToREQSYSMSM002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::tractionPhysicalSoftwareBoundary;
        end derived ::> X2CitySpecification_MotorSignalMeasurement_Requirements::windingVoltageObservation;
    }

    #derivation connection def REQSYSMPE001ToREQSYSMSM001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSMPE001ToREQSYSMSM001 : REQSYSMPE001ToREQSYSMSM001Derivation {
        end original ::> X2CitySpecification_MotorPositionEstimation_Requirements::motorPositionCompositePublication;
        end derived ::> X2CitySpecification_MotorSignalMeasurement_Requirements::hallAndPhaseCurrentAcquisition;
    }

    #derivation connection def REQSYSMPE002ToREQSYSMSM001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSMPE002ToREQSYSMSM001 : REQSYSMPE002ToREQSYSMSM001Derivation {
        end original ::> X2CitySpecification_MotorPositionEstimation_Requirements::hallBasedElectricalAngle;
        end derived ::> X2CitySpecification_MotorSignalMeasurement_Requirements::hallAndPhaseCurrentAcquisition;
    }

    #derivation connection def REQSYSMPE003ToREQSYSMSM002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSMPE003ToREQSYSMSM002 : REQSYSMPE003ToREQSYSMSM002Derivation {
        end original ::> X2CitySpecification_MotorPositionEstimation_Requirements::modelAssistedAngleRefinement;
        end derived ::> X2CitySpecification_MotorSignalMeasurement_Requirements::windingVoltageObservation;
    }

}
