package X2CitySpecification_RidingControl_RequirementSet {
    #derivation connection def CurrentBudgetDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive allocation : Requirements::RequirementCheck;
        end #derive supervision : Requirements::RequirementCheck;
        end #derive lighting : Requirements::RequirementCheck;
    }
    #derivation connection currentBudgetDerivation : CurrentBudgetDerivation {
        end original ::> X2CitySpecification_RidingControl_CurrentBudgeting::sharedCurrentBudget;
        end allocation ::> X2CitySpecification_CurrentConsumptionCoordination_SharedCurrentBudget::reserveBasedTractionBudget;
        end supervision ::> X2CitySpecification_CurrentConsumptionCoordination_SharedCurrentBudget::sharedBudgetSupervision;
        end lighting ::> X2CitySpecification_CurrentConsumptionCoordination_SharedCurrentBudget::lightingAvailabilityAllocation;
    }
}
