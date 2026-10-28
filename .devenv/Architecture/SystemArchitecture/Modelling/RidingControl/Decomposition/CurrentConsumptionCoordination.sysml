package X2CityComponent_CurrentConsumptionCoordination {
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_BatteryControl::*;
    attribute def AuxiliaryReserveCalibration {
        doc /*
            Fixed, configuration-specific reserve and evidence of its applicability; no numerical value
            is selected here.
        */
        attribute reserveAmperes:Real;
        attribute validatedForConfiguration:Boolean;
    }
    part def CurrentConsumptionCoordination { // LE-CURRENT-CONSUMPTION-COORDINATION
        doc /*
            Sole shared battery-current budget authority. It derives independently qualified traction
            budgets from battery capability and the validated fixed auxiliary reserve, and supervises the
            shared budget using qualified signed pack current.
        */
        attribute auxiliaryReserve:AuxiliaryReserveCalibration { doc /* Validated worst-case discharge reserve used with qualified battery capability; its validation covers the applicable configuration and the reserve contributions in CUR-002. */ }
        port batteryOperatingLimitsIn:BatteryOperatingLimitsInputPort { doc /* Independent qualified battery discharge and regenerative charge capabilities. */ }
        port batteryCurrentIn:BatteryCurrentInputPort { doc /* Qualified signed pack-current observation, positive charging and negative discharging, for centralized shared-budget supervision. */ }
        port tractionCurrentBudgetOut:TractionCurrentBudgetOutputPort { doc /* Independent current-direction traction budgets and qualifications for riding policy. */ }
    }
}

package X2CityRequirement_CurrentConsumptionCoordination {
    private import RequirementTypes::*;
    private import RequirementDerivation::*;
    private import X2CityComponent_RidingControl::*;
    private import X2CityComponent_CurrentConsumptionCoordination::*;

    requirement <'REQ-SYS-CUR-001'> sharedCurrentBudget : SystemRequirement {
        doc /*
            Status: Draft. Target: LE-RIDING. Source: owner decision for central battery-current
            budgeting, 2026-10-28; REQ-SYS-ENE-001 and auxiliary continuity REQ-VEH-AUX-001. Verify:
            analysis and T-SYS of concurrent worst-case auxiliary load and traction, charge and
            discharge, qualification loss, and protection response. Open: reserve evidence, timing,
            current uncertainty and residual transfer under OI-041/049/061 and WS-OI-017/018/019.
        */
        subject riding:RidingControl = X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl;
        require X2CityRequirement_CurrentConsumptionCoordination::reserveBasedTractionBudget;
        require X2CityRequirement_CurrentConsumptionCoordination::sharedBudgetSupervision;
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

    requirement <'REQ-SYS-CUR-002'> reserveBasedTractionBudget : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Target: LE-CURRENT-CONSUMPTION-COORDINATION; software realization pending.
            Parent: REQ-SYS-CUR-001. Source: owner decision, 2026-10-28. Verify: analysis of validated
            reserve and T-SW/T-SYS across zero, insufficient, and changing discharge capability;
            independently vary charge and branch qualification. Open: validated reserve and margins,
            response timing, current uncertainty and acceptance at OI-041/049/061 and WS-OI-017/018/019.
        */
        subject coordinator:CurrentConsumptionCoordination = X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.currentConsumptionCoordination;
        require constraint {
            doc /*
                CurrentConsumptionCoordination shall derive the traction discharge maximum as max(0,
                qualified battery discharge maximum minus validated worst-case
                auxiliaryReserve.reserveAmperes). The auxiliaryReserve.validatedForConfiguration field
                shall reflect validation for the applicable configuration, including a finite nonnegative
                reserve value. The reserve shall cover full-bright lights, display, compute, board and
                conversion consumption, and justified measurement error and transient allowances. It
                shall allocate regenerative charge no greater than qualified battery charge capability
                without crediting auxiliary draw. It shall retain independent branch qualification,
                publish conservative zero for an unqualified branch, and distinguish it from qualified
                zero capability. Until the fixed reserve is validated for the applicable configuration,
                the discharge budget shall be unqualified and conservatively zero; no zero-default
                reserve is assumed.
            */
        }
    }
    satisfy reserveBasedTractionBudget by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.currentConsumptionCoordination;

    requirement <'REQ-SYS-CUR-003'> sharedBudgetSupervision : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Target: LE-CURRENT-CONSUMPTION-COORDINATION; software realization pending.
            Parent: REQ-SYS-CUR-001. Source: owner decision, 2026-10-28. Verify: T-SW/T-SYS apply
            sustained qualified net charge and discharge above independently qualified capability,
            confirm reduction of the affected budget and the allocation ceiling, then vary current loss
            and recovery; verify single authority and existing protection behavior. Open: supervised
            thresholds, response, data age, uncertainty and transient acceptance under OI-041/049/061 and
            WS-OI-017/018/019.
        */
        subject coordinator:CurrentConsumptionCoordination = X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.currentConsumptionCoordination;
        require constraint {
            doc /*
                When qualified measured pack current indicates sustained net discharge above qualified
                battery discharge capability, CurrentConsumptionCoordination shall reduce the traction
                discharge budget. When it indicates sustained net charge above qualified battery charge
                capability, it shall reduce the traction regenerative-charge budget. Each reduced budget
                shall remain at or below its applicable allocation. Detection thresholds, timing and
                response bounds shall be derived and validated. Positive pack current denotes charging
                and negative denotes discharging. No new fault code or latch is implied. Pack-current
                unavailability alone shall not invalidate an otherwise qualified battery capability or
                traction budget enforced with the validated reserve. It shall remain the sole shared
                battery-current budget authority. Existing all-load protection and auxiliary continuity
                remain responsible for overload beyond what zero traction can resolve.
            */
        }
    }
    satisfy sharedBudgetSupervision by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.currentConsumptionCoordination;
    #derivation connection def CurrentBudgetDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive allocation : Requirements::RequirementCheck;
        end #derive supervision : Requirements::RequirementCheck;
    }
    #derivation connection currentBudgetDerivation : CurrentBudgetDerivation {
        end original ::> sharedCurrentBudget;
        end allocation ::> reserveBasedTractionBudget;
        end supervision ::> sharedBudgetSupervision;
    }
}
