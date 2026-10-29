package X2CitySpecification_Traction_RequirementDerivations {
    #derivation connection def REQSYSFLT009ToREQSYSINT004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT009ToREQSYSINT004 : REQSYSFLT009ToREQSYSINT004Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::commonFaultTorqueInhibition;
        end derived ::> X2CitySpecification_Traction_InterfaceQualification::torqueCommandAuthorizationValidity;
    }

    #derivation connection def REQSYSPWR003ToREQSYSINT004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSPWR003ToREQSYSINT004 : REQSYSPWR003ToREQSYSINT004Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::torqueWithdrawalAtSwitchOff;
        end derived ::> X2CitySpecification_Traction_InterfaceQualification::torqueCommandAuthorizationValidity;
    }

    #derivation connection def REQSYSREG011ToREQSYSINT003Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSREG011ToREQSYSINT003 : REQSYSREG011ToREQSYSINT003Derivation {
        end original ::> X2CitySpecification_X2CityMCU_RiderControl::regenerationEligibilityAfterStopping;
        end derived ::> X2CitySpecification_Traction_InterfaceQualification::actualMotorOutputDistinction;
    }

    #derivation connection def REQSYSSTA002ToREQSYSINT004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA002ToREQSYSINT004 : REQSYSSTA002ToREQSYSINT004Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::preReadyTorqueInhibition;
        end derived ::> X2CitySpecification_Traction_InterfaceQualification::torqueCommandAuthorizationValidity;
    }

    #derivation connection def REQVEHLGT004ToREQSYSINT003Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQVEHLGT004ToREQSYSINT003 : REQVEHLGT004ToREQSYSINT003Derivation {
        end original ::> X2CitySpecification_LightControl_LightingBehavior::electricalBrakingRearLight;
        end derived ::> X2CitySpecification_Traction_InterfaceQualification::actualMotorOutputDistinction;
    }

}
