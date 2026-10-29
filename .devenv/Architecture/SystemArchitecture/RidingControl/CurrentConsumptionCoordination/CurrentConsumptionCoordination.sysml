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
