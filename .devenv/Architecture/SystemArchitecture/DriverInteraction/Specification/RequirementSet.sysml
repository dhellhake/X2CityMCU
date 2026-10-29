package X2CitySpecification_DriverInteraction_RequirementSet {
    #derivation connection def REQSYSHSI001ToREQSYSDRI001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSDRI001 : REQSYSHSI001ToREQSYSDRI001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_DriverInteraction_Requirements::groupedDriverElectricalConnections;
    }

    #derivation connection def REQSYSHSI002ToREQSYSDRI001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI002ToREQSYSDRI001 : REQSYSHSI002ToREQSYSDRI001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::hmiEndpointCommunicationQualification;
        end derived ::> X2CitySpecification_DriverInteraction_Requirements::groupedDriverElectricalConnections;
    }

}
