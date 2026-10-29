package X2CityComponent_BatterySupervision {
    doc /*
        Requirement status is Draft unless a record states its canonical historical approval. Named
        verification methods, source links and OI/WS dependencies are planning evidence; numerical
        acceptance criteria remain controlled qualification inputs.
    */
    private import X2CityContract_BatteryControl::*;
    private import RequirementTypes::AbstractSoftwareRequirement;

    attribute def BatteryVoltageDeratingCalibration {
        doc /*
            Endpoints in volts per series group: discharge uses Vl and regeneration uses Vh.
        */
        attribute dischargeFullCurrentVoltageVolts:Real {
            doc /*
                Discharge voltage factor is 1; other constraints may reduce final current.
            */
        }
        attribute dischargeCutoffVoltageVolts:Real {
            doc /*
                Discharge voltage factor is 0.
            */
        }
        attribute regenerativeFullCurrentVoltageVolts:Real {
            doc /*
                Regenerative voltage factor is 1; other constraints may reduce final current.
            */
        }
        attribute regenerativeCutoffVoltageVolts:Real {
            doc /*
                Regenerative voltage factor is 0.
            */
        }
    }

    part def BatterySupervision { // LE-BATTERY-SUPERVISION
        doc /*
            Vehicle-host logical responsibility for reading and qualifying BMS information, capability and
            operating policy. Software realization is pending; supplied BMS internals remain outside it.
        */
        attribute voltageDeratingCalibration:BatteryVoltageDeratingCalibration {
            doc /*
                Immutable compiled calibration set; these current values await product validation.
            */
            :>> dischargeFullCurrentVoltageVolts = 3.40;
            :>> dischargeCutoffVoltageVolts = 3.10;
            :>> regenerativeFullCurrentVoltageVolts = 4.00;
            :>> regenerativeCutoffVoltageVolts = 4.10;
        }
        port bmsTelemetryIn:BmsTelemetryInputPort {
            doc /*
                Read-only UART response input from the supplied BMS.
            */
        }
        port bmsReadRequestOut:BmsReadRequestOutputPort {
            doc /*
                Read-only UART request output to the supplied BMS.
            */
        }
        port batteryStatusOut:BatteryStatusOutputPort {
            doc /*
                Publishes independent battery reporting conditions including lowDischargeVoltageWarning;
                operating qualification and effective limits travel on BatteryOperatingLimits.
            */
        }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort {
            doc /*
                Publishes independent charge/discharge assessments for RidingControl budgeting and
                EnergyPath enforcement of total battery bounds.
            */
        }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort {
            doc /*
                Publishes qualified actual SOC to HMI for display and range information.
            */
        }
        port batteryCurrentOut:BatteryCurrentOutputPort {
            doc /*
                Publishes independently qualified signed pack current in amperes to
                RidingControl.CurrentConsumptionCoordination and HMIControl.
            */
        }
    }

    requirement <'REQ-SYS-BMSIF-001'> bmsObservationIdentity : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract).
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

    requirement <'REQ-SYS-BMSIF-002'> bmsReadCommandRestriction : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md). Verify: T-SW/T-SYS request
            command restriction; installed support remains open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall issue only supported read-only BMS requests 0x03, 0x04 and 0x05.
            */
        }
    }
    satisfy bmsReadCommandRestriction by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-003'> bmsResponseValidation : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract).
            Verify: T-SW envelope vectors and T-SYS selected-unit captures. Transaction acceptance is
            BMSIF-014. Installed framing evidence remains open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall accept a response envelope only when its boundaries are complete
                and unambiguous, its start and end markers are valid, its declared length is within protocol
                bounds and matches the received bytes, and its checksum is valid.
            */
        }
    }
    satisfy bmsResponseValidation by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-014'> bmsTransactionAcceptance : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract).
            Verify: T-SW/T-SYS matching, success/error status and deadline boundaries. Installed response
            correlation and status remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall accept a response for measurement updates only when its envelope
                meets REQ-SYS-BMSIF-003, it matches the outstanding read request, and it reports success
                within 100 ms of the start of request transmission. A valid-envelope non-success response is
                a transaction failure.
            */
        }
    }
    satisfy bmsTransactionAcceptance by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-005'> bmsBasicInformationDecoding : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parents: [REQ-SYS-BMS-002](../BatteryControl.sysml), [REQ-SYS-BMS-003](../BatteryControl.sysml),
            [REQ-SYS-BMS-006](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance). Verify:
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
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance), owner
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
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md). Verify: T-SW/T-SYS identity
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
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance). Verify:
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
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance), owner
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
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance). Verify:
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
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance). Verify:
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
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [operating-limit qualification](BatterySupervision.sysml#req-sys-batsup-002). Verify: T-SW/T-SYS
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

    requirement <'REQ-SYS-BMSIF-013'> bmsReadServiceTiming : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract),
            [qualification and response budget](../Battery_Integration.md#qualification-evidence-and-response-budget).
            Verify: T-SW/T-SYS cyclic schedule. Transaction acceptance, outstanding request limit, retry and
            publication are BMSIF-014/018/019/020. Installed device response, refresh, sleep and energy
            remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall request Basic (0x03) and complete 14-group voltage (0x04)
                information each every 200 ms, alternating nominally 100 ms apart.
            */
        }
    }
    satisfy bmsReadServiceTiming by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSPOL-001'> batteryCapabilityPolicy : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-006, REQ-SYS-BMS-007, REQ-SYS-BMS-008, REQ-SYS-SOC-003, REQ-SYS-SOC-004,
            REQ-SYS-SOC-005, REQ-SYS-REG-002 and REQ-SYS-REG-012 (../BatteryControl.sysml).
            Source: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001).
            Sources: Battery Integration qualification and response budget; event/recovery matrix.
            Verify: A, T-SW/T-SYS/T-FI independent branch outputs and restriction reasons. Evidence / open:
            IF-A-003/009; OI-041/045/048/049/061; physical protection remains separate.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish the independent charge and discharge branch qualifications,
                effective current limits and restriction reasons on BatteryOperatingLimits.
            */
        }
    }
    satisfy batteryCapabilityPolicy by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-001'> bmsStartupChecks : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-006](../BatteryControl.sysml).
            Sources: selected-unit UART acceptance (BMS_Information.md).
            Verify: T-SW/T-SYS accepted, missing, invalid and mismatched startup evidence at normal and
            unexpected startup. Evidence / open: OI-041/061 version interpretation.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller startup, BatterySupervision shall pass exactly two
                compatibility checks only when the same current accepted Basic (0x03) response reports
                decoded software version 3.2 and 14 series groups, using the selected-unit protocol
                reference for version interpretation.
            */
        }
    }
    satisfy bmsStartupChecks by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-002'> operatingLimitQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-006](../BatteryControl.sysml).
            Sources: BAT-001; Battery Integration per-consumer acceptance; owner decision 2026-10-28.
            Verify: I/A/T-SW/T-SYS/T-FI startup and independent shared/branch loss, including immediate
            invalid-T2 withdrawal and BMSIF-020 publication. Evidence / open: OI-041/049/061;
            WS-OI-007/018/019 input subsets, temperature and measurement accuracy.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish a branch unqualified with a zero effective current limit
                whenever either startup check has not passed or any required evidence for that branch is
                unqualified, including an unknown path state. Required evidence comprises the captured
                capacity, qualified T2, all fourteen group voltages, the applicable voltage calibration and
                the applicable path state; charge-only evidence does not gate discharge and discharge-only
                evidence does not gate charge. Actual SOC and pack current are not required evidence.
            */
        }
    }
    satisfy operatingLimitQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-003'> actualSocQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-003](../BatteryControl.sysml).
            Source: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001).
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

    requirement <'REQ-SYS-BATSUP-004'> chargePathCapability : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
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

    requirement <'REQ-SYS-BATSUP-005'> dischargePathCapability : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
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

    requirement <'REQ-SYS-BATSUP-006'> bmsMosDisabledStatus : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-010](../BatteryControl.sysml).
            Sources: qualified BMS charge/discharge path observation; BMSIF-009–011.
            Verify: T-SW/T-SYS all enabled, disabled and unqualified path combinations and recovery.
            Evidence / open: Display-code selection remains RidingControl responsibility; status does not
            establish isolation or a fault.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish the independent BatteryStatus MOS-disabled warning as
                qualified present when both path states are qualified and either is disabled, qualified
                absent when both are qualified enabled, and unqualified when either state is unqualified.
            */
        }
    }
    satisfy bmsMosDisabledStatus by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-007'> startupCapacityReference : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: REQ-SYS-BMS-001 (../Battery_Integration.md); owner-authorized pack capability
            decisions.
            Verify: T-SW/T-SYS positive, zero, negative, nonfinite, missing and unqualified capacity and
            restart. Evidence / open: Installed-unit scaling and profile calibration; standard nominal
            capacity excludes remaining capacity and learned FCC.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller startup, BatterySupervision shall capture as C_Ah
                the first finite, positive, qualified standard nominal full-pack capacity in ampere-hours
                from a current accepted Basic (0x03) response.
            */
        }
    }
    satisfy startupCapacityReference by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-008'> regenerativeBaseCurrent : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
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
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
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
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml);
            [REQ-SYS-REG-002](../BatteryControl.sysml); [REQ-SYS-REG-012](../BatteryControl.sysml).
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
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml);
            [REQ-SYS-REG-002](../BatteryControl.sysml); [REQ-SYS-REG-012](../BatteryControl.sysml).
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

    requirement <'REQ-SYS-BATSUP-012'> dischargeBaseCurrent : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
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
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
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
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml);
            [REQ-SYS-SOC-003](../BatteryControl.sysml) / [REQ-SYS-SOC-005](../BatteryControl.sysml).
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
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml);
            [REQ-SYS-SOC-003](../BatteryControl.sysml) / [REQ-SYS-SOC-005](../BatteryControl.sysml).
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

    requirement <'REQ-SYS-BATSUP-016'> voltageDeratingCalibrationQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: controlled compiled calibration and applicable pack/cell envelopes.
            Verify: T-SW/T-SYS missing, nonfinite, nonpositive, reversed or equal endpoints, configuration
            mismatch and independent branches. Evidence / open: Numerical pack/cell envelope validation and
            release evidence remain open.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify each voltage derating calibration pair independently only
                when both values are present, finite, positive, correspond to the controlled compiled
                configuration and lie within the applicable qualified pack and cell envelopes, with
                discharge cutoff less than discharge full-current voltage or regenerative full-current
                voltage less than regenerative cutoff voltage, respectively.
            */
        }
    }
    satisfy voltageDeratingCalibrationQualification by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-017'> batteryFaultRecognition : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml);
            [REQ-SYS-BMS-010](../BatteryControl.sysml).
            Sources: FLT-005/006, BMS-007 and startup mismatch.
            Verify: T-SW/T-SYS actual BMS thermal and other faults and accepted mismatch without added
            debounce. Evidence / open: Fault retention follows BATSUP-019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall recognize a battery fault immediately upon an accepted actual
                BMS-reported fault, including a BMS thermal fault, or an accepted startup version or
                group-count mismatch.
            */
        }
    }
    satisfy batteryFaultRecognition by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-019'> batteryFaultRetainedEffect : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: FLT-005/006, BMS-007 and TMP-001/002.
            Verify: T-SW/T-SYS source and path recovery, valid unrelated measurements, normal and unexpected
            restart. Evidence / open: Independent valid measurement qualification follows BMSIF.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                Upon recognition of a restart-required battery-side fault, BatterySupervision shall retain
                both operating branches unqualified with effective current limits zero until the next normal
                or unexpected controller restart, regardless of source or path recovery, live condition
                clearing or requalification.
            */
        }
    }
    satisfy batteryFaultRetainedEffect by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-020'> batteryStatusPublication : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-010](../BatteryControl.sysml).
            Sources: FLT-005/006, BMS-007, TMP-001/002 and BATSUP-001.
            Verify: T-SW/T-SYS concurrent conditions and BMSIF-020 component publication. Evidence / open:
            Physical delivery, recognition thresholds and source mapping remain subject to validation.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish the battery-fault condition, MOS-disabled warning and
                lowDischargeVoltageWarning concurrently as independent BatteryStatus conditions, without
                battery-local priority or HMI-code selection, within the BMSIF-020 component output budget.
            */
        }
    }
    satisfy batteryStatusPublication by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-021'> batteryStatusRestart : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): [REQ-SYS-BMS-007](../BatteryControl.sysml);
            [REQ-SYS-BMS-010](../BatteryControl.sysml).
            Sources: FLT-005/006 restart handling.
            Verify: T-SW/T-SYS normal and unexpected restart with cleared and still-present faults. Evidence
            / open: Startup qualification and current-fault recognition apply anew.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller restart BatterySupervision shall discard prior-cycle
                retained battery fault effects and diagnostic evidence.
            */
        }
    }
    satisfy batteryStatusRestart by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-015'> bmsBasicScaleQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance).
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
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance).
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
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance).
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

    requirement <'REQ-SYS-BMSIF-018'> bmsOutstandingRequestLimit : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall have at most one BMS read request outstanding at a time.
            */
        }
    }
    satisfy bmsOutstandingRequestLimit by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-019'> bmsReadRetrySchedule : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                After a failed cyclic read, BatterySupervision shall reattempt it at its next normal cyclic
                slot without burst or queued retries.
            */
        }
    }
    satisfy bmsReadRetrySchedule by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-020'> bmsOutputPublicationTiming : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall recompute and publish affected component outputs within 10 ms of
                relevant accepted information or timer expiry, including fault recognition and status
                publication.
            */
        }
    }
    satisfy bmsOutputPublicationTiming by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-021'> bmsIdentityRequestSchedule : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall issue no periodic 0x05 identity request.
            */
        }
    }
    satisfy bmsIdentityRequestSchedule by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-022'> bmsPackCurrentPublication : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: original BMS-003 and
            [consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance); owner
            decision 2026-10-28 on pack-current consumption. Verify: T-SW/T-SYS signed current publication
            and independent qualification; field-only loss affects only current, preserves other qualified
            outputs, and does not alone establish a battery fault under BMSIF-009 and BATSUP-017. Installed
            schema and physical accuracy remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish signed pack current with its independent qualification on
                batteryCurrentOut, using the sign convention in REQ-SYS-BMSIF-005.
            */
        }
    }
    satisfy bmsPackCurrentPublication by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-022'> startupRequiredEvidenceDeadline : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-006](../BatteryControl.sysml). Sources: selected-unit UART acceptance and
            BATSUP-001 startup qualification.
            Verify: T-SW/T-SYS initial waiting and deadline boundaries. Open: OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller startup, BatterySupervision shall recognize a
                battery-information fault if either startup check or required startup data, including the
                capacity reference before capture, remains unavailable or unqualified 1 s after polling
                begins.
            */
        }
    }
    satisfy startupRequiredEvidenceDeadline by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-023'> cyclicRequiredEvidenceFault : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml). Sources: FLT-005/006 and BMSIF-010 field
            expiry.
            Verify: T-SW/T-SYS qualified field expiry, rejected frames and optional-field loss. Open:
            OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                After a required cyclic field has qualified, BatterySupervision shall recognize a
                battery-information fault when that field expires under BMSIF-010.
            */
        }
    }
    satisfy cyclicRequiredEvidenceFault by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-024'> capacityReferenceRetention : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml). Sources: owner-authorized regenerative and
            discharge pack capability decisions.
            Verify: T-SW/T-SYS later field changes, expiry and controller restart. Open: OI-041/061 and
            WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall retain the captured C_Ah unchanged for the controller cycle until
                the next normal or unexpected controller restart, irrespective of subsequent capacity
                updates, expiry or return.
            */
        }
    }
    satisfy capacityReferenceRetention by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-025'> batteryFaultReportEvidence : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-010](../BatteryControl.sysml). Sources: FLT-005/006, BMS-007 and
            TMP-001/002.
            Verify: T-SW/T-SYS brief, cleared, simultaneous and overlapping faults. Open: OI-041/061 and
            WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall capture and make each recognized fault and its common recognition
                order available to RidingControl for reporting, including brief, cleared and simultaneous
                events even while operating assessments are unqualified.
            */
        }
    }
    satisfy batteryFaultReportEvidence by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-026'> lowDischargeVoltageStatus : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-010](../BatteryControl.sysml). Sources: BMS-007 and owner-authorized
            discharge pack capability decision.
            Verify: T-SW/T-SYS voltage boundaries and missing evidence. Open: OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish lowDischargeVoltageWarning as qualified true when all
                fourteen group voltages and discharge cutoff calibration are qualified and Vl ≤ Dcut,
                qualified false when that evidence is qualified and Vl > Dcut, and unknown when any of that
                evidence is unqualified.
            */
        }
    }
    satisfy lowDischargeVoltageStatus by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-027'> batteryStatusNotFunctionalInput : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml). Source: AG-001 operational and reporting
            interfaces.
            Verify: T-SW/T-SYS independently vary reporting status and qualified functional evidence.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine operating capability without using BatteryStatus as a
                functional input.
            */
        }
    }
    satisfy batteryStatusNotFunctionalInput by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement batterySupervisionRequirements : AbstractSoftwareRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatterySupervision
            architectural occurrence.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require X2CityComponent_BatterySupervision::bmsObservationIdentity;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::bmsStartupChecks;
        require X2CityComponent_BatterySupervision::operatingLimitQualification;
        require X2CityComponent_BatterySupervision::actualSocQualification;
        require X2CityComponent_BatterySupervision::chargePathCapability;
        require X2CityComponent_BatterySupervision::dischargePathCapability;
        require X2CityComponent_BatterySupervision::bmsMosDisabledStatus;
        require X2CityComponent_BatterySupervision::batteryFaultRecognition;
        require X2CityComponent_BatterySupervision::batteryFaultRetainedEffect;
        require X2CityComponent_BatterySupervision::batteryStatusPublication;
        require X2CityComponent_BatterySupervision::batteryStatusRestart;
        require X2CityComponent_BatterySupervision::startupCapacityReference;
        require X2CityComponent_BatterySupervision::regenerativeBaseCurrent;
        require X2CityComponent_BatterySupervision::regenerativeTemperatureCeiling;
        require X2CityComponent_BatterySupervision::regenerativeVoltageCeiling;
        require X2CityComponent_BatterySupervision::regenerativePackCeiling;
        require X2CityComponent_BatterySupervision::dischargeBaseCurrent;
        require X2CityComponent_BatterySupervision::dischargeTemperatureCeiling;
        require X2CityComponent_BatterySupervision::dischargeVoltageCeiling;
        require X2CityComponent_BatterySupervision::dischargePackCeiling;
        require X2CityComponent_BatterySupervision::voltageDeratingCalibrationQualification;
        require X2CityComponent_BatterySupervision::bmsReadCommandRestriction;
        require X2CityComponent_BatterySupervision::bmsResponseValidation;
        require X2CityComponent_BatterySupervision::bmsTransactionAcceptance;
        require X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
        require X2CityComponent_BatterySupervision::bmsGroupVoltageQualification;
        require X2CityComponent_BatterySupervision::bmsIdentityInformationDecoding;
        require X2CityComponent_BatterySupervision::bmsTemperatureQualification;
        require X2CityComponent_BatterySupervision::bmsFieldQualification;
        require X2CityComponent_BatterySupervision::bmsObservationAgeQualification;
        require X2CityComponent_BatterySupervision::bmsObservationRetention;
        require X2CityComponent_BatterySupervision::bmsSourceRequalification;
        require X2CityComponent_BatterySupervision::bmsReadServiceTiming;
        require X2CityComponent_BatterySupervision::bmsBasicScaleQualification;
        require X2CityComponent_BatterySupervision::bmsGroupCountQualification;
        require X2CityComponent_BatterySupervision::bmsQualificationWithdrawal;
        require X2CityComponent_BatterySupervision::bmsOutstandingRequestLimit;
        require X2CityComponent_BatterySupervision::bmsReadRetrySchedule;
        require X2CityComponent_BatterySupervision::bmsOutputPublicationTiming;
        require X2CityComponent_BatterySupervision::bmsIdentityRequestSchedule;
        require X2CityComponent_BatterySupervision::bmsPackCurrentPublication;
        require X2CityComponent_BatterySupervision::startupRequiredEvidenceDeadline;
        require X2CityComponent_BatterySupervision::cyclicRequiredEvidenceFault;
        require X2CityComponent_BatterySupervision::capacityReferenceRetention;
        require X2CityComponent_BatterySupervision::batteryFaultReportEvidence;
        require X2CityComponent_BatterySupervision::lowDischargeVoltageStatus;
        require X2CityComponent_BatterySupervision::batteryStatusNotFunctionalInput;
    }
    satisfy batterySupervisionRequirements by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    doc /*
        Output responsibility and system integration retained from the capability-policy record:
        - Operating battery capability: Keep charge and discharge capabilities distinct, including qualified
        effective current limits and charge-path acceptance. The selected temperature and group-voltage
        curves determine ordinary operating ceilings; configured supplied-BMS protection remains separate.
        Unqualified required evidence leaves affected current at zero and dependent operation unavailable.
        - Operation-specific battery restrictions: Distinguish regenerative charge acceptance from discharge
        capability, including auxiliary discharge. BatterySupervision includes lowest-group discharge and
        highest-group regenerative voltage cutoffs in its respective effective current limits. A temperature
        where discharge current remains available but effective charge current is zero is an ordinary
        regeneration restriction under DEC-TMP-003.
        - Riding integration: BatterySupervision publishes qualified battery assessment and fault evidence.
        A newly available battery envelope alone does not determine RidingControl authority or its session
        state.
        - Physical protection: LE-EPCS and the supplied BMS/other derived protection contributors retain the
        system obligation for energized paths, residual/generated energy, faults, and host/UART loss. Vendor
        protection release is an observation, not automatic restoration of effective limits or a system
        session. Only the information-policy contribution is allocated here. Calibration, source accuracy,
        diagnostics, actual protection, and parent system acceptance remain open; no software unit, inverter
        algorithm, or circuit is selected.
    */
}
