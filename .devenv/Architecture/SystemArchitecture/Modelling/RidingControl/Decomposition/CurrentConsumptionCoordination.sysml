package X2CityComponent_CurrentConsumptionCoordination {
    private import X2CityContract_RidingControl::*;
    private import X2CityContract_BatteryControl::*;
    private import X2CityContract_LightControl::*;
    attribute def AuxiliaryReserveCalibration {
        doc /*
            Fixed, compiled reserve components and evidence of applicability. The 0.2 A full-bright
            lighting value is provisional and pending product validation; other auxiliary current is
            configuration-specific and has no selected numerical value here.
        */
        attribute lightingWorstCaseCurrentAmperes:Real = 0.2 {
            doc /*
                Immutable compiled calibration, initially 0.2 A battery-side equivalent for front On and
                rear Full over the qualified operating envelope. Provisional; product validation pending.
                A calibration change requires a rebuild.
            */
        }
        attribute otherAuxiliaryReserveAmperes:Real;
        attribute validatedForConfiguration:Boolean;
    }
    part def CurrentConsumptionCoordination { // LE-CURRENT-CONSUMPTION-COORDINATION
        doc /*
            Sole shared battery-current budget authority. It derives independently qualified traction
            budgets and full-bright lighting availability from battery capability and the fixed
            auxiliary reserve, and supervises the shared budget using qualified signed pack current.
        */
        attribute auxiliaryReserve:AuxiliaryReserveCalibration { doc /* Validated worst-case discharge reserve used with qualified battery capability; its validation covers the applicable configuration and the reserve contributions in CUR-002. */ }
        port batteryOperatingLimitsIn:BatteryOperatingLimitsInputPort { doc /* Independent qualified battery discharge and regenerative charge capabilities. */ }
        port batteryCurrentIn:BatteryCurrentInputPort { doc /* Qualified signed pack-current observation, positive charging and negative discharging, for centralized shared-budget supervision. */ }
        port lightingAvailabilityOut:LightingAvailabilityOutputPort {
            doc /* Qualified full-bright lighting allocation derived from discharge capability and reserve. */
        }
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
        require X2CityRequirement_CurrentConsumptionCoordination::lightingAvailabilityAllocation;
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
                qualified battery discharge maximum minus the total auxiliary reserve). Total reserve is
                auxiliaryReserve.lightingWorstCaseCurrentAmperes plus
                auxiliaryReserve.otherAuxiliaryReserveAmperes, subtracted exactly once even when lights
                are off. The lighting component is the immutable compiled calibration for full-bright
                lighting. The other component covers nonlighting auxiliary loads, board and conversion
                consumption outside the lighting component, and common measurement error and transient
                margins. Both components shall be
                finite and nonnegative. auxiliaryReserve.validatedForConfiguration shall reflect
                validation of the complete reserve for the applicable configuration. It shall allocate
                regenerative charge no greater than qualified battery charge capability without crediting
                auxiliary draw. It shall consume communicated directional capabilities without
                recalculating SOC cutoffs. A qualified zero capability shall yield a zero budget for that
                direction, qualified when applicable allocation inputs are qualified. It shall retain
                independent branch qualification, publish conservative zero for an unqualified branch,
                and distinguish it from qualified zero capability. Until the fixed reserve is validated
                for the applicable configuration, the discharge budget shall be unqualified and
                conservatively zero; no zero-default other auxiliary reserve is assumed.
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
    requirement <'REQ-SYS-CUR-004'> lightingAvailabilityAllocation : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Target: LE-CURRENT-CONSUMPTION-COORDINATION; software realization pending.
            Parent: REQ-SYS-CUR-001. Source: owner decision, 2026-10-28. Verify: T-SW/T-SYS for
            qualified zero, equality, insufficient and sufficient discharge capability, loss and recovery
            of qualification and calibration, and independence from pack current and light request.
            Open: product validation of the provisional lighting calibration and the complete reserve.
        */
        subject coordinator:CurrentConsumptionCoordination = X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.currentConsumptionCoordination;
        require constraint {
            doc /*
                CurrentConsumptionCoordination shall publish lightingAvailabilityOut for full front On,
                rear Full, and the other auxiliary reserve ahead of traction. With qualified battery
                discharge maximum D equal to zero it shall publish qualified Available false, even if the
                other auxiliary reserve is not calibrated. Otherwise, with qualified D and a usable,
                validated configuration reserve as specified in CUR-002, it shall publish qualified
                Available true when D is at least the sum of lightingWorstCaseCurrentAmperes and
                otherAuxiliaryReserveAmperes, and qualified Available false when D is below that sum.
                Missing or invalid D or required calibration shall yield unqualified availability, not a
                qualified false. It shall restore qualified true automatically when sufficient capability
                returns, without another HMI command or restart. The decision shall not depend on current
                running-light request, actual brake state, measured pack current, a recomputed SOC
                threshold, or regenerative current credit. The fixed lighting reserve is already included
                in the total auxiliary reserve and shall not be deducted a second time.
            */
        }
    }
    satisfy lightingAvailabilityAllocation by X2CitySystemArchitecture::x2CityVehicle.epcs.ridingControl.currentConsumptionCoordination;
    #derivation connection def CurrentBudgetDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive allocation : Requirements::RequirementCheck;
        end #derive supervision : Requirements::RequirementCheck;
        end #derive lighting : Requirements::RequirementCheck;
    }
    #derivation connection currentBudgetDerivation : CurrentBudgetDerivation {
        end original ::> sharedCurrentBudget;
        end allocation ::> reserveBasedTractionBudget;
        end supervision ::> sharedBudgetSupervision;
        end lighting ::> lightingAvailabilityAllocation;
    }
}
