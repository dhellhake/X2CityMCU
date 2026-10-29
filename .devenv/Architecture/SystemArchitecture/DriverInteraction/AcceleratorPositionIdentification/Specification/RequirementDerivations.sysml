package X2CitySpecification_AcceleratorPositionIdentification_RequirementDerivations {
    #derivation connection def REQSYSACC001ToREQSYSACC004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC004 : REQSYSACC001ToREQSYSACC004Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::normalizedAcceleratorPosition;
    }

    #derivation connection def REQSYSACC001ToREQSYSACC007Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC007 : REQSYSACC001ToREQSYSACC007Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorMeasurementTimeRetention;
    }

    #derivation connection def REQSYSACC001ToREQSYSACC008Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC008 : REQSYSACC001ToREQSYSACC008Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionConsumerDelivery;
    }

    #derivation connection def REQSYSACC001ToREQSYSACC009Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC009 : REQSYSACC001ToREQSYSACC009Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionErrorBound;
    }

    #derivation connection def REQSYSACC001ToREQSYSACC022Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC022 : REQSYSACC001ToREQSYSACC022Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionResponseTime;
    }

    #derivation connection def REQSYSACC001ToREQSYSACC024Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC024 : REQSYSACC001ToREQSYSACC024Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::independentPhysicalAcceleratorIdentification;
    }

    #derivation connection def REQSYSACC004ToREQSYSACC046Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC004ToREQSYSACC046 : REQSYSACC004ToREQSYSACC046Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::normalizedAcceleratorPosition;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorRestVoltageMapping;
    }

    #derivation connection def REQSYSACC004ToREQSYSACC047Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC004ToREQSYSACC047 : REQSYSACC004ToREQSYSACC047Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::normalizedAcceleratorPosition;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorFullThrottleVoltageMapping;
    }

    #derivation connection def REQSYSACC004ToREQSYSACC048Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC004ToREQSYSACC048 : REQSYSACC004ToREQSYSACC048Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::normalizedAcceleratorPosition;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorNonRestVoltageMapping;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC027Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC027 : REQSYSACC006ToREQSYSACC027Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionRequalification;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC046Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC046 : REQSYSACC006ToREQSYSACC046Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorRestVoltageMapping;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC047Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC047 : REQSYSACC006ToREQSYSACC047Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorFullThrottleVoltageMapping;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC048Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC048 : REQSYSACC006ToREQSYSACC048Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorNonRestVoltageMapping;
    }

    #derivation connection def REQSYSACC007ToREQSYSACC027Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC007ToREQSYSACC027 : REQSYSACC007ToREQSYSACC027Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorMeasurementTimeRetention;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionRequalification;
    }

    #derivation connection def REQSYSACC046ToREQSYSACC049Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC046ToREQSYSACC049 : REQSYSACC046ToREQSYSACC049Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorRestVoltageMapping;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorVoltageBandValidation;
    }

    #derivation connection def REQSYSACC047ToREQSYSACC049Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC047ToREQSYSACC049 : REQSYSACC047ToREQSYSACC049Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorFullThrottleVoltageMapping;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorVoltageBandValidation;
    }

    #derivation connection def REQSYSFLT003ToREQSYSACC005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT003ToREQSYSACC005 : REQSYSFLT003ToREQSYSACC005Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::invalidAcceleratorTorqueInhibition;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorInitialQualificationDistinction;
    }

    #derivation connection def REQSYSFLT003ToREQSYSACC006Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT003ToREQSYSACC006 : REQSYSFLT003ToREQSYSACC006Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::invalidAcceleratorTorqueInhibition;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
    }

    #derivation connection def REQSYSFLT003ToREQSYSACC029Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT003ToREQSYSACC029 : REQSYSFLT003ToREQSYSACC029Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::invalidAcceleratorTorqueInhibition;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorFaultEventRetention;
    }

    #derivation connection def REQSYSFLT005ToREQSYSACC029Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT005ToREQSYSACC029 : REQSYSFLT005ToREQSYSACC029Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::sessionFaultInhibitionRetention;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorFaultEventRetention;
    }

    #derivation connection def REQSYSHSI001ToREQSYSACC001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSACC001 : REQSYSHSI001ToREQSYSACC001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
    }

    #derivation connection def REQSYSHSI001ToREQSYSACC006Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSACC006 : REQSYSHSI001ToREQSYSACC006Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
    }

    #derivation connection def REQSYSHSI001ToREQSYSACC031Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI001ToREQSYSACC031 : REQSYSHSI001ToREQSYSACC031Derivation {
        end original ::> X2CitySpecification_X2CityMCU_SystemHardwareSoftwareInterface::qualifiedInputObservationBoundary;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorElectricalInterfaceCompatibility;
    }

    #derivation connection def REQSYSHSI007ToREQSYSACC026Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI007ToREQSYSACC026 : REQSYSHSI007ToREQSYSACC026Derivation {
        end original ::> X2CitySpecification_Platform_SystemHardwareSoftwareInterface::endpointContextRequalification;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::startupAcceleratorPositionQualification;
    }

    #derivation connection def REQSYSSTA003ToREQSYSACC005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA003ToREQSYSACC005 : REQSYSSTA003ToREQSYSACC005Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::startupRiderInputQualification;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorInitialQualificationDistinction;
    }

    #derivation connection def REQSYSSTA003ToREQSYSACC026Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA003ToREQSYSACC026 : REQSYSSTA003ToREQSYSACC026Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::startupRiderInputQualification;
        end derived ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::startupAcceleratorPositionQualification;
    }

}
