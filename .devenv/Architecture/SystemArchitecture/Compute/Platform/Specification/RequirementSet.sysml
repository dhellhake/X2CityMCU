package X2CitySpecification_Platform_RequirementSet {
    #derivation connection def REQSYSTRQIO001ToREQSYSINP002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSTRQIO001ToREQSYSINP002 : REQSYSTRQIO001ToREQSYSINP002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::atomicFastAcquisitionEpoch;
        end derived ::> X2CitySpecification_Platform_SystemInterfaceAllocations::acquisitionRecordSeparation;
    }

}
