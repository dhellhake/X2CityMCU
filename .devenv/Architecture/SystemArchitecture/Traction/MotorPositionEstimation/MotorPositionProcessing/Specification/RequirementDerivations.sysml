package X2CitySpecification_MotorPositionProcessing_RequirementDerivations {
    #derivation connection def REQSYSTRQIO001ToREQSYSPHASEIF001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSTRQIO001ToREQSYSPHASEIF001 : REQSYSTRQIO001ToREQSYSPHASEIF001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::atomicFastAcquisitionEpoch;
        end derived ::> X2CitySpecification_MotorPositionProcessing_Requirements::phaseCurrentFeedbackQualification;
    }

}
