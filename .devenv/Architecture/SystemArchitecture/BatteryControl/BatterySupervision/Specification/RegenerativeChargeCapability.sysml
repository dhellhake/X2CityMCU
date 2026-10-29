package X2CitySpecification_BatterySupervision_RegenerativeChargeCapability {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BATSUP-004'> chargePathCapability : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: owner-authorized current-path capability; BAT-001; selected-unit UART facts.
            Verify: T-SW/T-SYS qualified disabled path and independently varied remaining charge evidence.
            Evidence / open: OI-041/049/061; WS-OI-018/019 field and physical path observability.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                With all other applicable charge evidence qualified and no retained restart-required fault,
                BatterySupervision shall publish a qualified zero regenerative current limit when the charge
                path is qualified disabled.
            */
        }
    }
    satisfy chargePathCapability by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-008'> regenerativeBaseCurrent : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: REQ-SYS-BMS-001; owner-authorized regenerative capability.
            Verify: T-SW/T-SYS multiple qualified capacities including 17 Ah. Evidence / open: 17 Ah
            produces 5.10 A as example, not a fixed capacity.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the regenerative base current Ib in amperes as 0.30 A/Ah
                times C_Ah in ampere-hours.
            */
        }
    }
    satisfy regenerativeBaseCurrent by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-009'> regenerativeTemperatureCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml).
            Sources: REQ-SYS-BMS-001; owner-authorized regenerative capability; T2 mapping BMSIF-008.
            Verify: T-SW/T-SYS breakpoints and interpolation. Evidence / open: OI-041/061 T2 accuracy,
            coverage, latency and consumer qualification.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the regenerative temperature ceiling IT = Ib × fT(Tcell),
                where Tcell is qualified T2 at the centre of the cell pack in degrees Celsius and fT is
                piecewise linear through (5, 0), (10, 0.25), (15, 0.50), (20, 1), (30, 1), (35, 0.75), and
                (40, 0), and zero at Tcell ≤ 5 and Tcell ≥ 40.
            */
        }
    }
    satisfy regenerativeTemperatureCeiling by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-010'> regenerativeVoltageCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml);
            [REQ-SYS-REG-002](../../Specification/OperatingPolicy.sysml); [REQ-SYS-REG-012](../../Specification/OperatingPolicy.sysml).
            Sources: REQ-SYS-BMS-001; owner-authorized regenerative capability.
            Verify: T-SW/T-SYS calibrated endpoints and independent group readings. Evidence / open: Group
            observation and age follow BMSIF; physical acceptance remains open.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the regenerative voltage ceiling IV = Ib × clip((Rcut −
                Vh) / (Rcut − Rfull), 0, 1), where Vh is the maximum in volts of all fourteen qualified
                series-group readings, Rfull and Rcut are the qualified regenerative full-current and cutoff
                calibration voltages respectively, and clip bounds its argument to [0, 1].
            */
        }
    }
    satisfy regenerativeVoltageCeiling by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-011'> regenerativePackCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../../Specification/StartupAndClassification.sysml);
            [REQ-SYS-REG-002](../../Specification/OperatingPolicy.sysml); [REQ-SYS-REG-012](../../Specification/OperatingPolicy.sysml).
            Sources: REQ-SYS-BMS-001; owner-authorized regenerative capability.
            Verify: T-SW/T-SYS simultaneous derating, qualified zero, independent discharge; 17 Ah, 25°C and
            3.8 V per group yields 5.10 A. Evidence / open: RidingControl retains fault and re-entry guards.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                With required regenerative evidence qualified, charge path enabled and no retained
                restart-required fault, BatterySupervision shall publish a qualified regenerative current
                limit exactly equal to min(IT, IV).
            */
        }
    }
    satisfy regenerativePackCeiling by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
}
