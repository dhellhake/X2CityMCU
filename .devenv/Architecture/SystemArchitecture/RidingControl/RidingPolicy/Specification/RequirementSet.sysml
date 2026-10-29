package X2CitySpecification_RidingPolicy_RequirementSet {
    #derivation connection def REQSYSBRK001ToREQSYSCTL002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSBRK001ToREQSYSCTL002 : REQSYSBRK001ToREQSYSCTL002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_BrakeInterfaceAndPriority::brakePriorityOverAccelerator;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::signedWheelTorqueArbitration;
    }

    #derivation connection def REQSYSCMP001ToREQSYSCTL005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSCMP001ToREQSYSCTL005 : REQSYSCMP001ToREQSYSCTL005Derivation {
        end original ::> X2CitySpecification_HMIControl_Requirements::qualifiedVehicleOperationRequest;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionClosureOnOffRequest;
    }

    #derivation connection def REQSYSCMP001ToREQSYSCTL007Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSCMP001ToREQSYSCTL007 : REQSYSCMP001ToREQSYSCTL007Derivation {
        end original ::> X2CitySpecification_HMIControl_Requirements::qualifiedVehicleOperationRequest;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::freshStartupAfterWake;
    }

    #derivation connection def REQSYSFLT005ToREQSYSCTL001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT005ToREQSYSCTL001 : REQSYSFLT005ToREQSYSCTL001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::sessionFaultInhibitionRetention;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::ridingEligibilityAndBudgetCoordination;
    }

    #derivation connection def REQSYSFLT006ToREQSYSCTL001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT006ToREQSYSCTL001 : REQSYSFLT006ToREQSYSCTL001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::freshFaultAssessmentAtRestart;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::ridingEligibilityAndBudgetCoordination;
    }

    #derivation connection def REQSYSFLT011ToREQSYSCTL007Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSFLT011ToREQSYSCTL007 : REQSYSFLT011ToREQSYSCTL007Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::failureHistoryDiscardAtRestart;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::freshStartupAfterWake;
    }

    #derivation connection def REQSYSHSI004ToREQSYSCTL005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSHSI004ToREQSYSCTL005 : REQSYSHSI004ToREQSYSCTL005Derivation {
        end original ::> X2CitySpecification_MotorControl_SystemHardwareSoftwareInterface::authorityAndTorqueCommandBoundary;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionClosureOnOffRequest;
    }

    #derivation connection def REQSYSINT002ToREQSYSCTL001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSINT002ToREQSYSCTL001 : REQSYSINT002ToREQSYSCTL001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_InterfaceQualification::currentStartupPrerequisiteQualification;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::ridingEligibilityAndBudgetCoordination;
    }

    #derivation connection def REQSYSPWR002ToREQSYSCTL005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSPWR002ToREQSYSCTL005 : REQSYSPWR002ToREQSYSCTL005Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::movingAndStationarySwitchOff;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionClosureOnOffRequest;
    }

    #derivation connection def REQSYSPWR003ToREQSYSCTL002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSPWR003ToREQSYSCTL002 : REQSYSPWR003ToREQSYSCTL002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::torqueWithdrawalAtSwitchOff;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::signedWheelTorqueArbitration;
    }

    #derivation connection def REQSYSPWR003ToREQSYSCTL005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSPWR003ToREQSYSCTL005 : REQSYSPWR003ToREQSYSCTL005Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::torqueWithdrawalAtSwitchOff;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionClosureOnOffRequest;
    }

    #derivation connection def REQSYSPWR003ToREQSYSCTL006Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSPWR003ToREQSYSCTL006 : REQSYSPWR003ToREQSYSCTL006Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::torqueWithdrawalAtSwitchOff;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::qualifiedSleepEligibilityGrant;
    }

    #derivation connection def REQSYSREG001ToREQSYSCTL002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSREG001ToREQSYSCTL002 : REQSYSREG001ToREQSYSCTL002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_RiderControl::regenerationOperatingPermissives;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::signedWheelTorqueArbitration;
    }

    #derivation connection def REQSYSSOC008ToREQSYSCTL001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSOC008ToREQSYSCTL001 : REQSYSSOC008ToREQSYSCTL001Derivation {
        end original ::> X2CitySpecification_RidingControl_Requirements::propulsionCapabilityRecoveryRamp;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::ridingEligibilityAndBudgetCoordination;
    }

    #derivation connection def REQSYSSOC008ToREQSYSCTL002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSOC008ToREQSYSCTL002 : REQSYSSOC008ToREQSYSCTL002Derivation {
        end original ::> X2CitySpecification_RidingControl_Requirements::propulsionCapabilityRecoveryRamp;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::signedWheelTorqueArbitration;
    }

    #derivation connection def REQSYSSPD003ToREQSYSCTL002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSPD003ToREQSYSCTL002 : REQSYSSPD003ToREQSYSCTL002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_RiderControl::speedCutoffTorqueWithdrawal;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::signedWheelTorqueArbitration;
    }

    #derivation connection def REQSYSSTA001ToREQSYSCTL001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA001ToREQSYSCTL001 : REQSYSSTA001ToREQSYSCTL001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::readyEligibilityGuards;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::ridingEligibilityAndBudgetCoordination;
    }

    #derivation connection def REQSYSSTA001ToREQSYSCTL005Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA001ToREQSYSCTL005 : REQSYSSTA001ToREQSYSCTL005Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::readyEligibilityGuards;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionClosureOnOffRequest;
    }

    #derivation connection def REQSYSSTA001ToREQSYSCTL007Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA001ToREQSYSCTL007 : REQSYSSTA001ToREQSYSCTL007Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::readyEligibilityGuards;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::freshStartupAfterWake;
    }

    #derivation connection def REQSYSSTA002ToREQSYSCTL001Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA002ToREQSYSCTL001 : REQSYSSTA002ToREQSYSCTL001Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::preReadyTorqueInhibition;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::ridingEligibilityAndBudgetCoordination;
    }

    #derivation connection def REQSYSSTA006ToREQSYSCTL007Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSSTA006ToREQSYSCTL007 : REQSYSSTA006ToREQSYSCTL007Derivation {
        end original ::> X2CitySpecification_X2CityMCU_PowerStartupAndFaults::startupSelfTestRenewal;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::freshStartupAfterWake;
    }

    #derivation connection def REQSYSTRQ001ToREQSYSCTL002Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQSYSTRQ001ToREQSYSCTL002 : REQSYSTRQ001ToREQSYSCTL002Derivation {
        end original ::> X2CitySpecification_X2CityMCU_RiderControl::acceleratorSignedTorqueDemand;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::signedWheelTorqueArbitration;
    }

    #derivation connection def REQVEHHMI006ToREQSYSCTL004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQVEHHMI006ToREQSYSCTL004 : REQVEHHMI006ToREQSYSCTL004Derivation {
        end original ::> X2CitySpecification_RidingControl_SessionReportPolicy::sessionFaultReportRetention;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionFaultAndWarningSelection;
    }

    #derivation connection def REQVEHHMI007ToREQSYSCTL004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQVEHHMI007ToREQSYSCTL004 : REQVEHHMI007ToREQSYSCTL004Derivation {
        end original ::> X2CitySpecification_RidingControl_SessionReportPolicy::firstDetectedFaultReportSelection;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionFaultAndWarningSelection;
    }

    #derivation connection def REQVEHHMI009ToREQSYSCTL004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQVEHHMI009ToREQSYSCTL004 : REQVEHHMI009ToREQSYSCTL004Derivation {
        end original ::> X2CitySpecification_RidingControl_SessionReportPolicy::batteryWarningReportComposition;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionFaultAndWarningSelection;
    }

    #derivation connection def REQVEHHMI010ToREQSYSCTL004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQVEHHMI010ToREQSYSCTL004 : REQVEHHMI010ToREQSYSCTL004Derivation {
        end original ::> X2CitySpecification_RidingControl_SessionReportPolicy::retainedFaultReportPriority;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionFaultAndWarningSelection;
    }

    #derivation connection def REQVEHHMI018ToREQSYSCTL004Derivation {
        end #original original : Requirements::RequirementCheck;
        end #derive derived : Requirements::RequirementCheck;
    }
    #derivation connection rEQVEHHMI018ToREQSYSCTL004 : REQVEHHMI018ToREQSYSCTL004Derivation {
        end original ::> X2CitySpecification_RidingControl_SessionReportPolicy::tiedFaultReportSelection;
        end derived ::> X2CitySpecification_RidingPolicy_SettingsAndControlPolicy::sessionFaultAndWarningSelection;
    }

}
