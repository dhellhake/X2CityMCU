package X2CitySpecification_AcceleratorPositionProcessing_RequirementSet {
    #derivation connection def REQSYSACC001ToREQSYSACC002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC002 : REQSYSACC001ToREQSYSACC002Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorMeasurementTransformation;
    }

    #derivation connection def REQSYSACC001ToREQSYSACC017Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC001ToREQSYSACC017 : REQSYSACC001ToREQSYSACC017Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionComposite;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorAcquisitionTimeRetention;
    }

    #derivation connection def REQSYSACC004ToREQSYSACC010Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC004ToREQSYSACC010 : REQSYSACC004ToREQSYSACC010Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::normalizedAcceleratorPosition;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorPositionQualification;
    }

    #derivation connection def REQSYSACC005ToREQSYSACC012Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC005ToREQSYSACC012 : REQSYSACC005ToREQSYSACC012Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorInitialQualificationDistinction;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorCalibrationFailureResponse;
    }

    #derivation connection def REQSYSACC005ToREQSYSACC020Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC005ToREQSYSACC020 : REQSYSACC005ToREQSYSACC020Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorInitialQualificationDistinction;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorQualificationStateDistinction;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC010Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC010 : REQSYSACC006ToREQSYSACC010Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorPositionQualification;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC012Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC012 : REQSYSACC006ToREQSYSACC012Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorCalibrationFailureResponse;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC013Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC013 : REQSYSACC006ToREQSYSACC013Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorMeasurementAgeQualification;
    }

    #derivation connection def REQSYSACC006ToREQSYSACC021Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC006ToREQSYSACC021 : REQSYSACC006ToREQSYSACC021Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::invalidAcceleratorMeasurementRejection;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorMeasurementEvidenceRejection;
    }

    #derivation connection def REQSYSACC007ToREQSYSACC013Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC007ToREQSYSACC013 : REQSYSACC007ToREQSYSACC013Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorMeasurementTimeRetention;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorMeasurementAgeQualification;
    }

    #derivation connection def REQSYSACC007ToREQSYSACC017Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC007ToREQSYSACC017 : REQSYSACC007ToREQSYSACC017Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorMeasurementTimeRetention;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorAcquisitionTimeRetention;
    }

    #derivation connection def REQSYSACC007ToREQSYSACC018Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC007ToREQSYSACC018 : REQSYSACC007ToREQSYSACC018Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorMeasurementTimeRetention;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorHealthUpdatePublication;
    }

    #derivation connection def REQSYSACC008ToREQSYSACC002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC008ToREQSYSACC002 : REQSYSACC008ToREQSYSACC002Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionConsumerDelivery;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorMeasurementTransformation;
    }

    #derivation connection def REQSYSACC008ToREQSYSACC012Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC008ToREQSYSACC012 : REQSYSACC008ToREQSYSACC012Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionConsumerDelivery;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorCalibrationFailureResponse;
    }

    #derivation connection def REQSYSACC008ToREQSYSACC018Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC008ToREQSYSACC018 : REQSYSACC008ToREQSYSACC018Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionConsumerDelivery;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorHealthUpdatePublication;
    }

    #derivation connection def REQSYSACC026ToREQSYSACC038Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC026ToREQSYSACC038 : REQSYSACC026ToREQSYSACC038Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::startupAcceleratorPositionQualification;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::startupAcceleratorQualification;
    }

    #derivation connection def REQSYSACC027ToREQSYSACC039Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC027ToREQSYSACC039 : REQSYSACC027ToREQSYSACC039Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorPositionRequalification;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorMeasurementRequalification;
    }

    #derivation connection def REQSYSACC029ToREQSYSACC040Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC029ToREQSYSACC040 : REQSYSACC029ToREQSYSACC040Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorFaultEventRetention;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorFaultQualificationDelivery;
    }

    #derivation connection def REQSYSACC046ToREQSYSACC010Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC046ToREQSYSACC010 : REQSYSACC046ToREQSYSACC010Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorRestVoltageMapping;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorPositionQualification;
    }

    #derivation connection def REQSYSACC047ToREQSYSACC010Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC047ToREQSYSACC010 : REQSYSACC047ToREQSYSACC010Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorFullThrottleVoltageMapping;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorPositionQualification;
    }

    #derivation connection def REQSYSACC048ToREQSYSACC010Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC048ToREQSYSACC010 : REQSYSACC048ToREQSYSACC010Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorNonRestVoltageMapping;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorPositionQualification;
    }

    #derivation connection def REQSYSACC049ToREQSYSACC011Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSACC049ToREQSYSACC011 : REQSYSACC049ToREQSYSACC011Derivation {
        end original ::> X2CitySpecification_AcceleratorPositionIdentification_Requirements::acceleratorVoltageBandValidation;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorCalibrationStartupValidation;
    }

    #derivation connection def REQSYSSTA003ToREQSYSACC011Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA003ToREQSYSACC011 : REQSYSSTA003ToREQSYSACC011Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::startupRiderInputQualification;
        end derived ::> X2CitySpecification_AcceleratorPositionProcessing_Requirements::acceleratorCalibrationStartupValidation;
    }

}
