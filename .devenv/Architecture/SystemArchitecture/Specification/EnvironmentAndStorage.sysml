package X2CitySpecification_X2CityMCU_EnvironmentAndStorage {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-VEH-ENV-001'> ridingAmbientOperatingLimits : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Environment_and_Storage.md#req-veh-env-001 (line 17).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-veh-env-001"></a>`REQ-VEH-ENV-001` **Draft successor updated 2026-10-27;
            historical approval provenance retained**
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. Qualify ambient/component
            references, cold soak, startup and representative E/E duty at range boundaries; separately
            characterize conditioned-battery propulsion and the zero-capability cold boundary. Verify
            temperature-information/fault responses.
            Sources: `OBJ-012`, `PERF-007`, `CON-039`, `CON-040`,
            [PD §8.2](../../../../README.md#82-ambient-parking-and-weather-exposure),
            [DEC-BAT-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-bat-002),
            [OI-051](../../../../README.md#15-unresolved-issues)
            Open dependencies / qualifications: `OI-025`, `OI-036`, `OI-038`, `OI-039`, `OI-054`, `OI-055`,
            `WS-OI-019`: Derive soak/duty, permitted E/E capability, cell conditioning/use criteria,
            uncertainty and component compatibility before environmental qualification/use. No minimum
            winter distance or full reference-performance guarantee is added.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Project E/E equipment shall remain within its qualified operating limits throughout the
                supplied −10 °C to +40 °C riding-ambient range, including cold-soaked controller/electronics
                startup. After cold soak, propulsion requires sufficiently warm cells and nonzero qualified
                discharge capability under
                [BATSUP-012–015](../BatteryControl/BatterySupervision/Specification/DischargeCapability.sysml);
                the discharge temperature curve gives zero at cell temperature ≤−5°C. Validated reductions
                in cold EPCS performance remain permitted within qualified limits.
            */
        }
    }
    satisfy ridingAmbientOperatingLimits by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-ENV-002'> adverseWeatherOperatingLimits : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Environment_and_Storage.md#req-veh-env-002 (line 18).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-env-002"></a>`REQ-VEH-ENV-002`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. Qualify E/E exposure, signal
            integrity, electrical protection and rider-demand response over supplied use conditions; no
            tyre, traction, steering or mechanical-brake qualification is assigned. Keep reference dry hill
            qualification separate; retain active speed, torque and regeneration limits.
            Sources: `OBJ-012`, `PERF-008`, `CON-039`, `CON-053`,
            [PD §8.1](../../../../README.md#81-surface-and-use-environment),
            [DEC-ENV-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-env-001)
            Open dependencies / qualifications: `OI-054`, `OI-055`: Define electrical exposure and
            signal/protection acceptance for the supplied use conditions. Ice, deep snow and off-road
            operation are outside intended use, with unexpected ice still a hazard-analysis input.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                E/E propulsion, electrical brake-input priority and protection shall remain within qualified
                limits during supplied dry, wet and light-snow use conditions; whole-vehicle traction,
                steering and mechanical braking remain external platform functions. Validated reductions in
                EPCS acceleration, power and speed are permitted in adverse conditions.
            */
        }
    }
    satisfy adverseWeatherOperatingLimits by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-VEH-ENV-003'> outdoorStorageFunctionalRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Environment_and_Storage.md#req-veh-env-003 (line 19).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-veh-env-003"></a>`REQ-VEH-ENV-003`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. Qualify each configuration
            separately for the full duty, without required routine attendance; cover defined solar/local
            temperatures, spray/snowmelt, condensation, freezing/thawing and contamination profiles. Inspect
            electrical condition, contacts and required E/E functions afterward; use qualified initial SOC
            for the fitted case.
            Sources: `OBJ-012`, `IU-017`, `IU-019`, `CON-039`, `OS-004`,
            [PD §8.2](../../../../README.md#82-ambient-parking-and-weather-exposure),
            [DEC-ENV-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-env-001),
            [DEC-STO-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-sto-002)
            Open dependencies / qualifications: `OI-056`, `OI-062`, `OI-063`: Derive electrical exposure
            sequences/severities, normal-full entry tolerance, preparation details and post-storage E/E
            acceptance. No unconditional Ready, full post-storage performance/range, immersion or
            pressure-washing capability is established. Detached-pack storage conditions remain separate.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                Project E/E equipment and battery electrical interfaces shall withstand at least 168 h of
                unattended outdoor storage at −15 °C to +40 °C under the defined sun, rain and snow
                exposures, both with the battery fitted and with it removed and the empty bay exposed. For
                the fitted case, storage shall begin at normal full charge under DEC-STO-002. After normal
                temperature conditioning, energy preparation if needed, pre-ride checks and battery
                refitting/startup qualification, E/E equipment shall retain its required functions within
                qualified limits.
            */
        }
    }
    satisfy outdoorStorageFunctionalRetention by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STO-001'> fittedBatteryStorageChargeRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Environment_and_Storage.md#req-sys-sto-001 (line 27).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-sto-001"></a>`REQ-SYS-STO-001`
            Original obligation column: Requirement
            Derived from: [REQ-VEH-ENV-003](EnvironmentAndStorage.sysml)
            Planned verification / distinguishing cases: `I`, `A`, `T-SYS`. Qualify DEC-STO-002 normal-full
            entry, usable headroom, off-state loads, self-discharge, temperature effects and
            SOC/cell-voltage uncertainty. Verify the complete fitted configuration over the storage profiles
            against conservative limits and any derived protection action; distinguish this duty from
            powered post-cutoff HMI/lighting.
            Sources: `OBJ-014`, `CON-050`,
            [PD §6.6](../../../../README.md#66-range-reserve-and-energy-sizing),
            [PD §8.2](../../../../README.md#82-ambient-parking-and-weather-exposure),
            [DEC-STO-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-sto-002)
            Open dependencies / qualifications: `OI-041`, `OI-045`, `OI-056`, `OI-061`, `OI-063`: Qualify
            normal-full entry tolerance, load/uncertainty margins and all-load protection before
            capacity/storage qualification freeze. No 168 h promise from arbitrary SOC or either
            propulsion/range endpoint, voltage-cutoff all-load floor, fixed post-storage range or reduced 70
            km qualification follows. DEC-STO-002 excludes entry above 80% or below qualified normal full
            from this duration qualification; no forced discharge or protection topology is selected.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                From normal full charge at 80% actual SOC subject to the qualified conservative SOC/control
                tolerance and qualified battery conditions, the EPCS shall keep the fitted battery within
                qualified storage SOC/cell-voltage limits throughout at least 168 h of powered-off vehicle
                storage, including total residual consumption and self-discharge, without energy
                replenishment or routine attendance.
            */
        }
    }
    satisfy fittedBatteryStorageChargeRetention by X2CitySystemArchitecture::x2CityVehicle.epcs;

    requirement <'REQ-SYS-STO-002'> removedBatteryStorageChargeRetention : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Environment_and_Storage.md#req-sys-sto-002 (line 33).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: unspecified in source.
            ID: <a id="req-sys-sto-002"></a>`REQ-SYS-STO-002`
            Original obligation column: Requirement
            Planned verification / acceptance: I, A, T-SYS: verify the complete detached pack for 672 h over
            the qualified indoor temperature/exposure profile; account for all off-state consumption,
            self-discharge and uncertainty, inspect afterward and exercise required functions under their
            normal permissives.
            Sources: [DEC-STO-001](../../DEC-001_Decisions_and_Open_Issues.md#dec-sto-001),
            [DEC-STO-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-sto-002), OBJ-014,
            CON-050, VS-012; [PD §§6.6–6.7](../../../../README.md#66-range-reserve-and-energy-sizing)
            Open dependencies / qualifications: OI-041/056/061/063: qualify DEC-STO-002 normal-full
            entry/tolerance, storage limits, load budget, humidity/transfer preparation and post-storage
            acceptance before energy-capacity/storage qualification freeze. This is the same pack as the
            fitted configuration; no arbitrary-SOC duty, forced discharge from above 80%, guaranteed
            remaining range or automatic Ready is implied.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                From normal full charge at 80% actual SOC subject to the qualified conservative
                preparation/control tolerance and qualified battery conditions, the removed battery shall
                withstand at least 672 h unattended storage dry indoors at 15–30 °C, remain within qualified
                storage SOC/cell-voltage limits without energy replenishment or routine attendance, and
                retain suitability for its required functions after normal post-storage handling,
                temperature conditioning, energy preparation if needed and qualification.
            */
        }
    }
    satisfy removedBatteryStorageChargeRetention by X2CitySystemArchitecture::x2CityVehicle.epcs;

}
