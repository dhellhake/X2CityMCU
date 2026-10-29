package X2CitySpecification_X2CityMCU_RequirementSet {
    #derivation connection def REQSYSBRK008ToREQSYSINT001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRK008ToREQSYSINT001 : REQSYSBRK008ToREQSYSINT001Derivation {
        end original ::> X2CitySpecification_MechanicalBrakeDetection_Requirements::unusableBrakeStateRejection;
        end derived ::> X2CitySpecification_X2CityMCU_InterfaceQualification::informationValueAndQualificationSeparation;
    }

    #derivation connection def REQSYSENE002ToREQSYSBMS009Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSENE002ToREQSYSBMS009 : REQSYSENE002ToREQSYSBMS009Derivation {
        end original ::> X2CitySpecification_X2CityMCU_EnergyAndProtection::abnormalConditionProtectiveResponse;
        end derived ::> X2CitySpecification_X2CityMCU_BatteryControl::batteryProtectionWithoutController;
    }

    #derivation connection def REQSYSENE003ToREQSYSBMS009Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSENE003ToREQSYSBMS009 : REQSYSENE003ToREQSYSBMS009Derivation {
        end original ::> X2CitySpecification_X2CityMCU_EnergyAndProtection::residualAndGeneratedEnergyControl;
        end derived ::> X2CitySpecification_X2CityMCU_BatteryControl::batteryProtectionWithoutController;
    }

    #derivation connection def REQSYSFLT010ToREQSYSINT002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT010ToREQSYSINT002 : REQSYSFLT010ToREQSYSINT002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::startupSocUnavailabilityReporting;
        end derived ::> X2CitySpecification_X2CityMCU_InterfaceQualification::currentStartupPrerequisiteQualification;
    }

    #derivation connection def REQSYSSTA001ToREQSYSINT002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA001ToREQSYSINT002 : REQSYSSTA001ToREQSYSINT002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::readyEligibilityGuards;
        end derived ::> X2CitySpecification_X2CityMCU_InterfaceQualification::currentStartupPrerequisiteQualification;
    }

    #derivation connection def REQSYSSTA003ToREQSYSINT001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA003ToREQSYSINT001 : REQSYSSTA003ToREQSYSINT001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::startupRiderInputQualification;
        end derived ::> X2CitySpecification_X2CityMCU_InterfaceQualification::informationValueAndQualificationSeparation;
    }

    #derivation connection def REQSYSSTA005ToREQSYSINT001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA005ToREQSYSINT001 : REQSYSSTA005ToREQSYSINT001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::readyWithUnavailableSoc;
        end derived ::> X2CitySpecification_X2CityMCU_InterfaceQualification::informationValueAndQualificationSeparation;
    }

    #derivation connection def REQSYSSTA006ToREQSYSINT002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA006ToREQSYSINT002 : REQSYSSTA006ToREQSYSINT002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::startupSelfTestRenewal;
        end derived ::> X2CitySpecification_X2CityMCU_InterfaceQualification::currentStartupPrerequisiteQualification;
    }

    #derivation connection def REQSYSSTA007ToREQSYSINT001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA007ToREQSYSINT001 : REQSYSSTA007ToREQSYSINT001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::startupTemperatureInformationQualification;
        end derived ::> X2CitySpecification_X2CityMCU_InterfaceQualification::informationValueAndQualificationSeparation;
    }

    #derivation connection def REQVEHENV003ToREQSYSSTO001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQVEHENV003ToREQSYSSTO001 : REQVEHENV003ToREQSYSSTO001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_EnvironmentAndStorage::outdoorStorageFunctionalRetention;
        end derived ::> X2CitySpecification_X2CityMCU_EnvironmentAndStorage::fittedBatteryStorageChargeRetention;
    }

}
