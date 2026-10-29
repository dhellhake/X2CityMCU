package X2CitySpecification_BatterySupervision_MeasurementQualification {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMSIF-001'> bmsObservationIdentity : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract).
            Verify: T-SW/T-SYS observation identities and units; installed schema remains open under
            OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall preserve the identity and applicable units of each decoded BMS
                observation.
            */
        }
    }
    satisfy bmsObservationIdentity by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-005'> bmsBasicInformationDecoding : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parents: [REQ-SYS-BMS-002](../../Specification/BmsIntegration.sysml), [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml),
            [REQ-SYS-BMS-006](../../Specification/StartupAndClassification.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance). Verify:
            T-SW/T-SYS schema vectors and independent engineering references. Scale, group count and
            temperature are addressed by BMSIF-015/016/008; actual SOC by BATSUP-003. Installed layout,
            units and scaling remain open under OI-041/061.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                For an accepted 0x03 response conforming to the selected-unit schema for payload length,
                field count, positions, encoding, units and scale, BatterySupervision shall decode the
                supported pack voltage, signed current, candidate SOC, capacity-source evidence, group
                count, firmware, protection and named chargePathEnabled and dischargePathEnabled
                observations. Positive current denotes charging and negative current denotes discharging.
            */
        }
    }
    satisfy bmsBasicInformationDecoding by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-006'> bmsGroupVoltageQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance), owner
            decision 2026-10-28 on independent field qualification. Verify: T-SW/T-SYS complete and
            malformed sets, finite zero and below-cutoff values, and independent readings. Physical accuracy
            and adequacy remain open under OI-041/061 and WS-OI-018/019; reference comparisons are
            verification evidence, not runtime agreement checks.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify group voltage only for an accepted 0x04 response conforming
                to the supported schema and containing a complete ordered set of exactly 14 identified
                groups with supported encoding, millivolt-to-volt scaling and finite decoded values. A
                finite zero or below-cutoff value remains qualified; pack voltage and agreement with other
                readings are not prerequisites.
            */
        }
    }
    satisfy bmsGroupVoltageQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-007'> bmsIdentityInformationDecoding : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [BAT-001](../../BatteryAssembly/BatteryAssembly.md#fixed-inputs-and-provenance). Verify: T-SW/T-SYS identity
            decoding against installed-unit captures. Encoding remains open under OI-041/061 and
            WS-OI-018/019. Startup checks are BATSUP-001.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall decode and preserve identity information as informational data only
                when an accepted 0x05 payload conforms to the selected-unit schema.
            */
        }
    }
    satisfy bmsIdentityInformationDecoding by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-008'> bmsTemperatureQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance). Verify:
            T-SW/T-SYS block structure, conversion and source ordinals. Owner mapping identifies T2 as the
            centre-pack probe; T1 physical interpretation is unconfirmed. Field withdrawal and dependent
            limits are BMSIF-017 and BATSUP-009/013. Physical accuracy, coverage, latency and installed
            schema remain open under OI-041/061.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                For an accepted 0x03 response, BatterySupervision shall qualify its temperature block only
                when the block at its defined payload position after the NTC count contains exactly three
                ordered big-endian 16-bit values in 0.1 K units, with count 3. Convert each raw value r to
                Celsius as (r − 2731) / 10 and preserve source ordinals 1=MOS, 2=T1, 3=T2, the centre-pack
                probe.
            */
        }
    }
    satisfy bmsTemperatureQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-009'> bmsFieldQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance), owner
            decisions 2026-10-28 on independent fields and pack-current consumption. Verify: T-SW/T-SYS
            accepted, invalid, absent and stale fields, including field-only SOC and pack-current loss,
            without runtime cross-measurement checks. Field-specific rules include BATSUP-003/007;
            withdrawal and fault recognition are BMSIF-017 and BATSUP-017. Source age and consumer limits
            remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify each applicable field independently if and only if its
                response is accepted, the selected schema supports its required presence, count, order,
                encoding, units and scale, its decoded numeric value is finite, source timeliness is
                satisfied, and its field-specific qualification rules are met. Qualification is independent
                of physical protection and fault status and does not depend on agreement with other BMS
                measurements or on fabricated or display-fallback values.
            */
        }
    }
    satisfy bmsFieldQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-010'> bmsObservationAgeQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance). Verify:
            T-SW/T-SYS same-value updates, nonrenewing events and expiry. Host update age is not physical
            sample age; device refresh, latency and end-to-end limits remain open under OI-041/061 and
            WS-OI-018/019. Startup-captured capacity is governed by BATSUP-007.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall expire each cyclic field’s host timeliness 600 ms after its last
                accepted, qualified relevant update. An identical qualified value renews the timer;
                rejected, malformed, non-success, wrong-request, late, unrelated-field or cached data and
                republication alone do not renew it.
            */
        }
    }
    satisfy bmsObservationAgeQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-011'> bmsObservationRetention : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance). Verify:
            T-SW/T-SYS interruptions, missed replies and sleep/wake with still-qualified observations.
            Expiry and withdrawal are BMSIF-010/017; publication timing is BMSIF-020. Physical delivery and
            use remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall retain each accepted observation while its field qualification and
                source timeliness remain satisfied; a rejected response, brief interruption, missed
                transaction deadline or sleep/wake alone does not invalidate still-qualified data.
            */
        }
    }
    satisfy bmsObservationRetention by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-012'> bmsSourceRequalification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [operating-limit qualification](CommonCurrentCapabilities.sysml). Verify: T-SW/T-SYS
            startup and source loss/recovery. Retained fault effects remain governed by BATSUP-019.
            Required-source criteria remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At controller startup or after loss of source qualification, BatterySupervision shall keep
                affected information unqualified until newly accepted relevant source evidence satisfies its
                qualification criteria.
            */
        }
    }
    satisfy bmsSourceRequalification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-003'> actualSocQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml).
            Source: [REQ-SYS-BMS-001](../../../Specification/BatteryControl.sysml).
            Sources: BAT-001; Battery Integration SOC acceptance; DEC-SOC-001/002, DEC-HMI-002/005.
            Verify: A, T-SW/T-SYS independent SOC references, startup/restart and loss. Evidence / open:
            OI-041/049/061; WS-OI-018 calibration, uncertainty, usable range and age.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify and publish actual state of charge only when the candidate
                is within 0..100 percent and meets the controlled SOC source acceptance criteria against
                actual charge and capacity references for the selected pack, including source and
                calibration evidence, error and uncertainty, usable range and data age suitable for SOC
                mapping and range information.
            */
        }
    }
    satisfy actualSocQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-015'> bmsBasicScaleQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify current and capacity fields from an accepted 0x03 response
                only when its scale indicator selects a scale supported by the selected-unit profile,
                applying that response’s scale to those fields. An unsupported scale leaves those fields
                unqualified without invalidating independent fields.
            */
        }
    }
    satisfy bmsBasicScaleQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-016'> bmsGroupCountQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-002, REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall leave pack data dependent on the reported series-group count
                unqualified when an accepted 0x03 response reports a count other than 14.
            */
        }
    }
    satisfy bmsGroupCountQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-017'> bmsQualificationWithdrawal : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                When a field no longer satisfies its required qualification criteria, BatterySupervision
                shall immediately withdraw that field from dependent use, with affected output publication
                meeting REQ-SYS-BMSIF-020.
            */
        }
    }
    satisfy bmsQualificationWithdrawal by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
}
