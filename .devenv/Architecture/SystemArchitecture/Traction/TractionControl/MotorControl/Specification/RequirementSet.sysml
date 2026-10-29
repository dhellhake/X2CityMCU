package X2CitySpecification_MotorControl_RequirementSet {
    #derivation connection def REQSYSPWR003ToREQSYSTRQACT003Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSPWR003ToREQSYSTRQACT003 : REQSYSPWR003ToREQSYSTRQACT003Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::torqueWithdrawalAtSwitchOff;
        end derived ::> X2CitySpecification_MotorControl_Requirements::physicalStageSleepPermission;
    }

    #derivation connection def REQSYSTRQIO001ToREQSYSSUPPLYIF001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSTRQIO001ToREQSYSSUPPLYIF001 : REQSYSTRQIO001ToREQSYSSUPPLYIF001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::atomicFastAcquisitionEpoch;
        end derived ::> X2CitySpecification_MotorControl_Requirements::supplyObservationQualification;
    }

}
