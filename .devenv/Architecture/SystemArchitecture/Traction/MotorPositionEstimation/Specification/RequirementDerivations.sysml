package X2CitySpecification_MotorPositionEstimation_RequirementDerivations {
    #derivation connection def REQSYSFLT003ToREQSYSMPE004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT003ToREQSYSMPE004 : REQSYSFLT003ToREQSYSMPE004Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::invalidAcceleratorTorqueInhibition;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::motorPositionQualificationAndFaultEvidence;
    }

    #derivation connection def REQSYSHSI001ToREQSYSMPE001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSMPE001 : REQSYSHSI001ToREQSYSMPE001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::motorPositionCompositePublication;
    }

    #derivation connection def REQSYSHSI001ToREQSYSMPE002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSMPE002 : REQSYSHSI001ToREQSYSMPE002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::hallBasedElectricalAngle;
    }

    #derivation connection def REQSYSHSI001ToREQSYSMPE004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSMPE004 : REQSYSHSI001ToREQSYSMPE004Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::motorPositionQualificationAndFaultEvidence;
    }

    #derivation connection def REQSYSHSI009ToREQSYSMPE001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI009ToREQSYSMPE001 : REQSYSHSI009ToREQSYSMPE001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::tractionPhysicalSoftwareBoundary;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::motorPositionCompositePublication;
    }

    #derivation connection def REQSYSHSI009ToREQSYSMPE003Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI009ToREQSYSMPE003 : REQSYSHSI009ToREQSYSMPE003Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::tractionPhysicalSoftwareBoundary;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::modelAssistedAngleRefinement;
    }

    #derivation connection def REQSYSHSI009ToREQSYSMPE005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI009ToREQSYSMPE005 : REQSYSHSI009ToREQSYSMPE005Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::tractionPhysicalSoftwareBoundary;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::phaseCurrentFeedbackPublication;
    }

    #derivation connection def REQSYSMPE002ToREQSYSMPE006Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSMPE002ToREQSYSMPE006 : REQSYSMPE002ToREQSYSMPE006Derivation {
        end original ::> X2CitySpecification_MotorPositionEstimation_Requirements::hallBasedElectricalAngle;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::electricalAngleContinuity;
    }

    #derivation connection def REQSYSMPE003ToREQSYSMPE006Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSMPE003ToREQSYSMPE006 : REQSYSMPE003ToREQSYSMPE006Derivation {
        end original ::> X2CitySpecification_MotorPositionEstimation_Requirements::modelAssistedAngleRefinement;
        end derived ::> X2CitySpecification_MotorPositionEstimation_Requirements::electricalAngleContinuity;
    }

}
