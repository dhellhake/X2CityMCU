package X2CitySpecification_X2CityMCU_VehicleQualification {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-VEH-PERF-001'> levelFiveAccelerationPerformance : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Vehicle_Qualification.md#req-veh-perf-001 (line 17).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-perf-001"></a>`REQ-VEH-PERF-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Use the supplied 130 kg load case and
            qualify pavement/grade, ambient and starting SOC. From a qualified Ready state, verify active
            Level 5 and record the speed setting, full-accelerator/brake demand, speed and elapsed time for
            the 0–20 km/h interval. Evaluate average acceleration as (20/3.6)/Δt ≥0.5 m/s².
            Sources: [PD §6.5](../../../../README.md#65-gradient-and-performance-requirements), `PERF-002`,
            `CON-038`, [DV-010](../../../../README.md#dv-010-speed-acceleration-and-repeated-stops),
            [DEC-PERF-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-perf-001)
            Open dependencies / qualifications: `OI-018`, `OI-054`, `WS-OI-001`, `WS-OI-013`: Define demand
            sequence, start/end events, repeatability, speed/time references and load/grade/temperature/SOC
            tolerances and uncertainty. No mechanical-suitability test gate is included.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                In active Level 5 with full accelerator demand, the EPCS as installed on the supplied BMW
                X2City shall achieve average acceleration of at least 0.5 m/s² from standstill to 20 km/h on
                level dry pavement at 130 kg total carried mass and +20 °C ambient, starting at the normal
                upper charge limit of 80% actual SOC subject to the derived conservative control tolerance.
            */
        }
    }
    satisfy levelFiveAccelerationPerformance by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-PERF-002'> levelFiveFlatSpeedPerformance : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Vehicle_Qualification.md#req-veh-perf-002 (line 18).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-perf-002"></a>`REQ-VEH-PERF-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. With active Level 5, the speed limit
            set to 40 km/h and full accelerator demand, measure actual speed over the derived
            sustained-travel interval and compare it with the validated acceptance band. Separately observe
            both-sign torque withdrawal at/above the active cutoff and recovery below it; a brief peak or
            successful cutoff alone does not establish sustained capability.
            Sources: [PD §6.5](../../../../README.md#65-gradient-and-performance-requirements), `PERF-001`,
            `CON-038`,
            [DEC-SPD-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-spd-001),
            [REQ-SYS-SPD-003](RiderControl.sysml),
            [DEC-PERF-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-perf-001)
            Open dependencies / qualifications: `OI-018`, `OI-054`, `WS-OI-013`, `WS-OI-015`: Derive the
            below-40 acceptance band, duration/distance, permissible speed variation and speed/torque
            reference accuracy; preserve the unconditional 40 km/h cutoff. Target achievement creates no
            automatic speed-regulation function or authority to exceed a rider-selected lower limit.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                In active Level 5 with full accelerator demand, the EPCS as installed on the supplied BMW
                X2City shall achieve the 40 km/h flat-ground operating-speed target at 130 kg total mass,
                +20 °C ambient and dry pavement, starting at the normal upper charge limit of 80% actual SOC
                subject to conservative control tolerance. Sustained travel just below 40 km/h shall be
                accepted within the tolerance determined during system validation.
            */
        }
    }
    satisfy levelFiveFlatSpeedPerformance by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-PERF-003'> uphillSustainedSpeedPerformance : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Vehicle_Qualification.md#req-veh-perf-003 (line 19).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-perf-003"></a>`REQ-VEH-PERF-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Confirm active Level 5 and full
            accelerator demand; record actual speed throughout the qualifying uphill distance and verify the
            minimum-speed and distance criteria using the derived measurement rules. Record SOC and
            component condition/limits before and during the duty. Establish entry conditions separately
            from the standstill hill-launch case.
            Sources: [PD §6.5](../../../../README.md#65-gradient-and-performance-requirements), `PERF-003`,
            `CON-037`,
            [DEC-PERF-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-perf-001)
            Open dependencies / qualifications: `OI-018`, `OI-025`, `OI-054`, `WS-OI-013`, `WS-OI-017`:
            Define grade/distance tolerances, segment entry, qualifying SOC points/margins and thermal
            preparation. Hill capability and voltage-cutoff behavior require distinct acceptance cases.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                In active Level 5 with full accelerator demand, the EPCS as installed on the supplied BMW
                X2City shall sustain at least 10 km/h up a 14% grade for at least 100 m at 130 kg total
                mass, +20 °C ambient and dry pavement, under the derived hill-qualification SOC conditions.
            */
        }
    }
    satisfy uphillSustainedSpeedPerformance by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-PERF-004'> uphillStartPerformance : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Vehicle_Qualification.md#req-veh-perf-004 (line 20).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-perf-004"></a>`REQ-VEH-PERF-004`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Begin Ready; use the supplied
            mechanical brake as context for the rider sequence. Confirm active Level 5; record the full
            accelerator request, electrical lever state, applied torque and direction/displacement through
            forward launch; evaluate EPCS response and rollback limits. Include the valid positive-demand
            rollback case under existing electrical brake-priority and profile rules.
            Sources: [PD §6.5](../../../../README.md#65-gradient-and-performance-requirements), `PERF-004`,
            `CON-037`,
            [DEC-TRQ-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-trq-003),
            [DEC-BRK-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-brk-001),
            [REQ-SYS-TRQ-010](RiderControl.sysml),
            [DEC-PERF-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-perf-001)
            Open dependencies / qualifications: `OI-018`, `OI-054`, `WS-OI-001`, `WS-OI-003`, `WS-OI-006`,
            `WS-OI-013`: Define E/E input sequence, measurement time origin, EPCS response/rollback and
            successful-forward-launch criteria. No automatic motor holding, zero-rollback promise or
            transfer of the flat 0.5 m/s² target to hill launch is implied.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                From standstill on a 14% uphill grade, the EPCS as installed on the supplied BMW X2City
                shall initiate forward motor-powered travel in response to the rider's full accelerator
                demand in active Level 5 at 130 kg total mass, +20 °C ambient and dry pavement, under the
                derived hill-qualification SOC conditions.
            */
        }
    }
    satisfy uphillStartPerformance by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-PERF-005'> descentRegenerationAvailability : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Vehicle_Qualification.md#req-veh-perf-005 (line 21).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-perf-005"></a>`REQ-VEH-PERF-005` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `A`, `T-SYS`. Exercise applicable
            SOC/charge-acceptance and electrical regeneration states at the defined descent condition.
            Observe electrical current/torque limitation and response; use external mechanical braking only
            as the supplied platform context, without accepting brake distance, effort, fade or thermal
            performance.
            Sources: [PD §6.5](../../../../README.md#65-gradient-and-performance-requirements), `PERF-005`,
            `CON-037`, [DEC-REG-004](../../DEC-001_Decisions_and_Open_Issues.md#dec-reg-004)
            Open dependencies / qualifications: `OI-025`, `OI-048`, `OI-054`, `WS-OI-005`, `WS-OI-006`,
            `WS-OI-013`: Derive electrical entry/exit conditions, current/torque reference and response
            bounds. No mechanical braking acceptance is assigned.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                At the supplied 130 kg total-mass, +20 °C, dry 14% descent duty, the EPCS as installed on
                the supplied BMW X2City shall preserve its qualified regeneration availability and
                withdrawal behavior at the qualified highest-group-voltage charge cutoff and when
                regeneration is unavailable. The mechanical brakes are assumed available and adequate as
                supplied; their braking performance is outside project qualification.
            */
        }
    }
    satisfy descentRegenerationAvailability by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-RNG-001'> qualifiedRidingRange : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Vehicle_Qualification.md#req-veh-rng-001 (line 39).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-rng-001"></a>`REQ-VEH-RNG-001` **Draft successor; historical approval
            retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`: establish the qualified riding
            trace, record actual distance, speed/stops/dwell, SOC, battery-side energy and regeneration, and
            accept only a complete run meeting every condition.
            Sources: `RQ-001`, `OBJ-001`, `DEC-REG-001`, `REQ-SYS-REG-008`
            Open dependencies / qualifications: Derive beginning-of-life, trace, reference and SOC/distance
            uncertainty acceptance. The voltage- and temperature-based regenerative envelope remains
            separate.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                The EPCS as installed on the supplied BMW X2City shall complete at least 70 km under the
                qualified RQ-001 profile in active Level 5 on level paved ground at +20 °C ambient and 130
                kg total mass using a new/beginning-of-life battery, starting at normal full charge no
                greater than 80% actual SOC, with actual SOC remaining within 10–80% throughout.
            */
        }
    }
    satisfy qualifiedRidingRange by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
