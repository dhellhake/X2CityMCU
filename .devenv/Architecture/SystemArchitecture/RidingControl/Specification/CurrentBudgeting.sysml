package X2CitySpecification_RidingControl_CurrentBudgeting {
    private import X2CityComponent_RidingControl::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-CUR-001'> sharedCurrentBudget : SystemRequirement {
        doc /*
            Status: Draft. Target: LE-RIDING. Source: owner decision for central battery-current
            budgeting, 2026-10-28; REQ-SYS-ENE-001 and auxiliary continuity REQ-VEH-AUX-001. Verify:
            analysis and T-SYS of concurrent worst-case auxiliary load and traction, charge and
            discharge, qualification loss, and protection response. Open: reserve evidence, timing,
            current uncertainty and residual transfer under OI-041/049/061 and WS-OI-017/018/019.
        */
        subject riding:RidingControl = X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require X2CitySpecification_CurrentConsumptionCoordination_SharedCurrentBudget::reserveBasedTractionBudget;
        require X2CitySpecification_CurrentConsumptionCoordination_SharedCurrentBudget::sharedBudgetSupervision;
        require X2CitySpecification_CurrentConsumptionCoordination_SharedCurrentBudget::lightingAvailabilityAllocation;
        require constraint {
            doc /*
                RidingControl shall allocate battery current capability through one shared budget
                authority so traction and other loads are accounted for together. When auxiliary demand
                alone exceeds discharge capability, zero traction does not resolve the overload; existing
                all-load protection and auxiliary continuity obligations remain applicable.
            */
        }
    }
    satisfy sharedCurrentBudget by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
}
