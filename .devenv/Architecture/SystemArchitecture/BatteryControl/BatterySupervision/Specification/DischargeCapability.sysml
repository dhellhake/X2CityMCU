package X2CitySpecification_BatterySupervision_DischargeCapability {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BATSUP-005'> dischargePathCapability : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: owner-authorized current-path capability; BAT-001; selected-unit UART facts.
            Verify: T-SW/T-SYS qualified disabled path and independently varied remaining discharge
            evidence. Evidence / open: OI-041/049/061; WS-OI-018/019 field and physical path observability.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                With all other applicable discharge evidence qualified and no retained restart-required
                fault, BatterySupervision shall publish a qualified zero discharge current limit when the
                discharge path is qualified disabled.
            */
        }
    }
    satisfy dischargePathCapability by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-012'> dischargeBaseCurrent : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: REQ-SYS-BMS-001; owner-authorized discharge capability.
            Verify: T-SW/T-SYS multiple qualified capacities including 17 Ah. Evidence / open: 17 Ah
            produces 17 A as example, not a fixed capacity.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the discharge base current IbD in amperes as 1.00 A/Ah
                times C_Ah in ampere-hours.
            */
        }
    }
    satisfy dischargeBaseCurrent by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-013'> dischargeTemperatureCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: REQ-SYS-BMS-001; owner-authorized discharge capability; T2 mapping BMSIF-008.
            Verify: T-SW/T-SYS breakpoints and interpolation. Evidence / open: OI-041/061 T2 accuracy,
            coverage, latency and consumer qualification.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the discharge temperature ceiling ITD = IbD × FD(Tcell),
                where Tcell is qualified T2 at the centre of the cell pack in degrees Celsius and FD is
                piecewise linear through (-5, 0), (0, 0.25), (10, 0.60), (20, 1), (35, 1), (40, 0.75), (45,
                0.40), and (50, 0), and zero at Tcell ≤ -5 and Tcell ≥ 50.
            */
        }
    }
    satisfy dischargeTemperatureCeiling by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-014'> dischargeVoltageCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml);
            [REQ-SYS-SOC-003](../../Specification/OperatingPolicy.sysml) / [REQ-SYS-SOC-005](../../Specification/OperatingPolicy.sysml).
            Sources: REQ-SYS-BMS-001; owner-authorized discharge capability.
            Verify: T-SW/T-SYS calibrated endpoints and independent group readings. Evidence / open: Group
            observation and age follow BMSIF; physical acceptance remains open.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the discharge voltage ceiling IVD = IbD × clip((Vl −
                Dcut) / (Dfull − Dcut), 0, 1), where Vl is the minimum in volts of all fourteen qualified
                series-group readings, Dcut and Dfull are the qualified discharge cutoff and full-current
                calibration voltages respectively, and clip bounds its argument to [0, 1].
            */
        }
    }
    satisfy dischargeVoltageCeiling by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-015'> dischargePackCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml);
            [REQ-SYS-SOC-003](../../Specification/OperatingPolicy.sysml) / [REQ-SYS-SOC-005](../../Specification/OperatingPolicy.sysml).
            Sources: REQ-SYS-BMS-001; owner-authorized discharge capability.
            Verify: T-SW/T-SYS simultaneous derating, qualified zero, independent charge; 17 Ah, 25°C and
            3.8 V per group yields 17 A. Evidence / open: Physical acceptance remains open.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                With required discharge evidence qualified, discharge path enabled and no retained
                restart-required fault, BatterySupervision shall publish a qualified discharge current limit
                exactly equal to min(ITD, IVD).
            */
        }
    }
    satisfy dischargePackCeiling by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
}
