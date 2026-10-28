package X2CityComponent_BatterySupervision {
    doc /* Requirement status is Draft unless a record states its canonical historical approval. Named verification methods, source links and OI/WS dependencies are planning evidence; numerical acceptance criteria remain controlled qualification inputs. */
    private import X2CityContract_BatteryControl::*;
    private import RequirementTypes::AbstractSoftwareRequirement;

    attribute def BatteryVoltageDeratingCalibration {
        doc /* Endpoints in volts per series group: discharge uses Vl and regeneration uses Vh. */
        attribute dischargeFullCurrentVoltageVolts:Real {
            doc /* Discharge voltage factor is 1; other constraints may reduce final current. */
        }
        attribute dischargeCutoffVoltageVolts:Real { doc /* Discharge voltage factor is 0. */ }
        attribute regenerativeFullCurrentVoltageVolts:Real {
            doc /* Regenerative voltage factor is 1; other constraints may reduce final current. */
        }
        attribute regenerativeCutoffVoltageVolts:Real { doc /* Regenerative voltage factor is 0. */ }
    }

    part def BatterySupervision { // LE-BATTERY-SUPERVISION
        doc /* Vehicle-host logical responsibility for reading and qualifying BMS information, capability and operating policy. Software realization is pending; supplied BMS internals remain outside it. */
        attribute voltageDeratingCalibration:BatteryVoltageDeratingCalibration {
            doc /* Immutable compiled calibration set; these current values await product validation. */
            :>> dischargeFullCurrentVoltageVolts = 3.40;
            :>> dischargeCutoffVoltageVolts = 3.10;
            :>> regenerativeFullCurrentVoltageVolts = 4.00;
            :>> regenerativeCutoffVoltageVolts = 4.10;
        }
        port bmsTelemetryIn:BmsTelemetryInputPort { doc /* Read-only UART response input from the supplied BMS. */ }
        port bmsReadRequestOut:BmsReadRequestOutputPort { doc /* Read-only UART request output to the supplied BMS. */ }
        port batteryStatusOut:BatteryStatusOutputPort { doc /* Publishes independent battery reporting conditions; operating qualification and effective limits travel on BatteryOperatingLimits. */ }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort { doc /* Publishes qualified operating assessment and independent charge/discharge branches to RidingControl. */ }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort { doc /* Publishes qualified actual SOC for HMI display and RidingControl's low-SOC propulsion policy. */ }
        port batteryCurrentOut:BatteryCurrentOutputPort { doc /* Publishes qualified signed pack current in amperes for HMI. */ }
    }

    requirement <'REQ-SYS-BMSIF-001'> bmsInformationQualification : AbstractSoftwareRequirement {
        doc /*
            Abstract Software Requirement; Draft successor to canonical REQ-001-R1.6 (Approved).
            Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources:
            [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md); [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract). Verify:
            T-SW/T-SYS against selected-unit evidence and independent valid/invalid observations;
            see [REQ-001 verification rules](../../../../../Requirements/REQ-001_Requirements.md). Open: installed schema, source-age
            criteria and acceptance.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall provide each applicable BMS observation with its field
                identity, applicable units and independent qualification, including source
                timeliness. Unavailable or unqualified information shall not be presented as
                current.
            */
        }
    }
    satisfy bmsInformationQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;



    requirement <'REQ-SYS-BMSIF-002'> bmsReadCommandRestriction : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md) selected identity. Verify: T-SW/T-SYS confirms requests are limited to supported
            read-only 0x03/0x04/0x05. Open: confirm installed-unit support under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall obtain BMS information using only supported read-only 0x03,
                0x04 and 0x05 requests. It shall issue no configuration or EEPROM writes, MOS or
                protection overrides, or control commands.
            */
        }
    }
    satisfy bmsReadCommandRestriction by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-003'> bmsResponseValidation : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Source: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract). Verify:
            T-SW framing vectors and T-SYS selected-unit captures; payload and transaction semantics
            are verified under 005-008/014. Open: installed framing evidence, OI-041/061; WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall use a BMS response for measurement updates only when its
                boundaries are complete and unambiguous, its start/end markers are valid, its
                declared length is within protocol bounds and matches received bytes, and its
                checksum is valid. A response that does not meet these envelope conditions shall
                update no measurement.
            */
        }
    }
    satisfy bmsResponseValidation by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-014'> bmsTransactionAcceptance : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Source: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract). Verify:
            T-SW/T-SYS matching and wrong requests, success/error status, outstanding-request
            boundaries. Open: qualify installed response correlation/status under OI-041/061; WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall use a response for measurement updates only when it meets
                the envelope conditions of REQ-SYS-BMSIF-003, matches the outstanding read request,
                and reports success. A wrong-request or non-success response shall update no
                measurement. A response with a valid envelope and non-success status is a
                transaction failure and shall follow existing failure, timeout and retention
                behavior.
            */
        }
    }
    satisfy bmsTransactionAcceptance by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-005'> bmsBasicInformationDecoding : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parents: [REQ-SYS-BMS-002](../BatteryControl.sysml) (configuration decoding),
            [REQ-SYS-BMS-003](../BatteryControl.sysml) (source fields), and
            [REQ-SYS-BMS-006](../BatteryControl.sysml) (startup version field). Sources: selected-unit UART facts in
            [selected-unit UART facts](BMS_Information.md#selected-unit-uart-read-acceptance-contract); [Battery Integration per-consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance). Verify:
            T-SW/T-SYS against qualified schema vectors and independent engineering references.
            Open: installed layout, units and scaling under OI-041/061; actual SOC is
            [REQ-SYS-BATSUP-003](BatterySupervision.sysml#req-sys-batsup-003).
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify supported 0x03 basic-information fields only when
                payload length, field count, positions, encoding, units and scale conform to the
                selected-unit interface schema. It shall preserve supported pack voltage, signed
                current, candidate SOC, capacity-source evidence, group count, firmware,
                temperature, protection and the named chargePathEnabled and dischargePathEnabled
                observations. Positive current means charging and negative current means discharging.
                The scale indicator shall select a scale supported by the selected-unit profile, and
                that response's scale shall be applied to its current and capacity fields. An
                unsupported scale shall leave the affected current and capacity fields unqualified
                without invalidating independent fields. A reported series-group count other than
                14 shall not qualify dependent pack data; this is ordinary field qualification, not
                an additional startup check. Candidate SOC does not by itself qualify
                actual SOC. Scale interpretation is field qualification, not an additional startup
                check.
            */
        }
    }
    satisfy bmsBasicInformationDecoding by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-006'> bmsGroupVoltageQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance). Verify: T-SW/T-SYS complete, missing,
            reordered, implausible and contradictory group sets. Open:
            physical measurement adequacy and evidence-based physical/inter-group/pack plausibility
            bounds require product validation under OI-041/061; WS-OI-018/019. Measurement adequacy is
            engineering evidence, not a runtime uncertainty adjustment.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify group voltage only when the payload conforms to the
                selected-unit 0x04 schema and represents a complete, ordered set of 14 identified
                groups with qualified millivolt-to-volt units and evidence-based physical,
                inter-group and pack-comparison plausibility checks consistent with the selected-unit
                profile. An incomplete, unsupported, implausible or contradictory set shall remain unqualified
                without invalidating independent observations.
            */
        }
    }
    satisfy bmsGroupVoltageQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-007'> bmsIdentityInformationDecoding : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending. Native
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml) (identity information/source). Sources:
            [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md). Verify: T-SW/T-SYS
            identity decoding against accepted installed-unit captures. Open: identity encoding under
            OI-041/061; WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall decode identity information only from a valid 0x05 payload
                conforming to the selected-unit interface schema and preserve it as information.
                Identity information is not a startup prerequisite.
            */
        }
    }
    satisfy bmsIdentityInformationDecoding by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-008'> bmsTemperatureQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance). Verify: T-SW/T-SYS conversion, probe
            identity/count, optional and unavailable readings. Open: installed probe layout and
            required-probe criteria under OI-041/061; retention is REQ-SYS-BMSIF-011.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall express supported temperature observations in Celsius and
                preserve probe identity and count only when payload layout and encoding conform to
                the selected-unit interface schema, the decoded number of readings matches the
                response's declared NTC count, and identifiers are unique and match supported
                channel assignments. An absent permitted optional reading shall
                affect only that reading. A bad conversion, unsupported or conflicting probe layout,
                or unavailable required reading shall leave affected temperature information
                unqualified. It shall not substitute ambient, zero/default or display values, or
                present an expired reading as current temperature.
            */
        }
    }
    satisfy bmsTemperatureQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-009'> bmsFieldQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance). Verify: T-SW/T-SYS field loss, invalidity,
            staleness, and independence; confirm display fallback cannot qualify control data. Open:
            consumer-visible qualification representation under OI-041/061; WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify each applicable field independently. Unknown,
                invalid or stale information shall remain unqualified. An absent optional field
                shall not invalidate unrelated accepted fields. Fabricated values and HMI display
                fallbacks shall not qualify information for control use.
            */
        }
    }
    satisfy bmsFieldQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-010'> bmsObservationAgeQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: selected-unit UART facts in
            [selected-unit UART acceptance contract](BMS_Information.md#selected-unit-uart-read-acceptance-contract); [Battery Integration per-consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance) and response
            budget. Verify: T-SW/T-SYS same-value accepted updates, rejected/unrelated/cached data,
            no-frame timeout, sample latency, and missed transaction deadlines. Open:
            evidence-derived per-field age/latency and reaction limits under OI-041/061;
            WS-OI-018/019; FLT-010 startup SOC classification.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                For each applicable field, timeliness shall remain qualified only while its
                evidence-based source-age criteria hold, including measurement-to-response latency
                and uncertainty; host receipt shall not be treated as sample time. A newly accepted
                relevant source update shall renew that field's timeliness even when its value is
                unchanged. Rejected, malformed, wrong-request, unrelated-field or cached data, and
                republication alone, shall renew none. Timeliness shall expire when its age
                criterion is exceeded, including when no new frame arrives. Missing a transaction
                response deadline alone shall not expire otherwise timely information.
            */
        }
    }
    satisfy bmsObservationAgeQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-011'> bmsObservationRetention : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../Battery_Integration.md#per-consumer-information-acceptance) and response budget. Verify: T-SW/T-SYS
            interruption, sleep/wake, missed replies, field-specific expiry and dependent-use
            withdrawal. Open: evidence-derived timeout and delivery/use budgets under OI-041/061;
            WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall retain an accepted observation only while its applicable
                source-age and consistency criteria remain satisfied; a rejected response, brief
                interruption, missed transaction deadline or sleep/wake alone shall not invalidate
                still-qualified data. On expiry or loss of another qualification criterion, it shall
                withdraw only affected shared or branch qualification and set the dependent
                effective discharge or regenerative-charge current limit to zero. Expired
                information shall not support dependent use, including after delayed publication or
                delivery. Expiry and its qualification withdrawal shall occur within the accepted
                delivery/use budget, including when no new frame arrives.
            */
        }
    }
    satisfy bmsObservationRetention by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-012'> bmsSourceRequalification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [operating-limit qualification](BatterySupervision.sysml#req-sys-batsup-002). Verify: T-SW/T-SYS controller startup and source loss/recovery, preserving unrelated validity and
            RidingControl fault authority. BatteryMeasurements retains its host-provided producer
            identity and current controller-startup context.
            Open: required-source criteria under OI-041/061; WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At controller startup or after loss of required source qualification, affected information shall remain
                unqualified until newly accepted relevant source evidence satisfies its qualification
                criteria. Cached data and republication alone shall not requalify it; unaffected independent
                observations may remain qualified. Optional or HMI-only information loss shall not create a
                blanket battery assessment fault. Source recovery shall not clear a retained
                restart-required battery-side fault effect; existing fault and restart classification
                remains authoritative.
            */
        }
    }
    satisfy bmsSourceRequalification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-013'> bmsReadServiceTiming : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration qualification and response budget](../Battery_Integration.md#qualification-evidence-and-response-budget); [operating-limit qualification](BatterySupervision.sysml#req-sys-batsup-002).
            Verify: T-SYS startup, source-update, response, timeout, publication, delivery/use,
            sleep and energy budgets. Open: numerical acceptance criteria under OI-041/061 and WS-OI-018/019; FLT-010 startup classification remains external.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision's read-only service shall meet the accepted budgets for source
                updates, transaction responses, field timeout detection, startup qualification,
                qualification publication, delivery, dependent use, and applicable power, sleep and
                storage-energy consumption. Timeout-driven qualification withdrawal shall meet its
                accepted delivery/use budget without requiring a new frame. Existing startup SOC
                fault classification remains governed by FLT-010.
            */
        }
    }
    satisfy bmsReadServiceTiming by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSPOL-001'> batteryCapabilityPolicy : AbstractSoftwareRequirement {
        doc /*
            Abstract Software Requirement; Draft successor to canonical REQ-001-R1.6 (Approved).
            Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001). Sources: [Battery Integration qualification and response budget](../Battery_Integration.md#qualification-evidence-and-response-budget) and
            event/recovery matrix; [REQ-001 verification rules](../../../../../Requirements/REQ-001_Requirements.md). Verify: analysis,
            T-SW/T-SYS/T-FI against independent quality, path, policy and overlapping-restriction
            cases, including exact minimum selection, qualified zero, unqualified required constraints
            and branch independence. Open: IF-A-003/009 and OI-041/045/048/049/061. Software outputs do not establish
            physical protection with the host unavailable.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                For each qualified branch, BatterySupervision shall set its finite, nonnegative effective
                current limit to exactly the minimum of the computed branch-specific pack ceiling and
                every applicable qualified battery-side current ceiling or restriction, including physical
                capability, battery policy, protection, configuration and path restrictions. A qualified
                prohibition or disabled path contributes zero; a nonapplicable constraint does not limit
                operation. If no additional applicable qualified constraint is tighter, the effective limit
                equals the computed pack ceiling. An unqualified required constraint leaves the affected
                branch unqualified with effective current limit zero. BatterySupervision shall internally
                assess applicable shared evidence as part of each dependent branch qualification, and publish
                independent branch qualification, effective current limits and restriction reasons. A qualified zero means known zero capability. Reporting conditions remain separate from operating capability.
            */
        }
    }
    satisfy batteryCapabilityPolicy by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-001'> bmsStartupChecks : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-006](../BatteryControl.sysml); input source:
            [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [selected-unit UART acceptance](BMS_Information.md#selected-unit-uart-read-acceptance-contract).
            Verify: T-SW/T-SYS missing, invalid, mismatched and accepted startup evidence on every
            normal or unexpected controller startup. Scope: current/capacity scale and
            temperature/probe consistency remain under BMSIF-005/008; 0x04 group-voltage checks
            remain under BMSIF-006; physical acceptance remains commissioning evidence; 0x05 remains
            informational. Open: selected-unit version field interpretation under OI-041/061.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller startup/restart, BatterySupervision shall establish both
                startup checks from the same current accepted Basic (0x03) response: decoded software
                version 3.2 and 14 reported series groups. Version interpretation shall follow the
                selected-unit protocol reference. A missing or invalid value means that check has not
                passed; missing initial information alone does not establish a battery fault. A
                recognized mismatch shall follow existing battery/configuration fault handling. Until
                both checks pass, dependent operating limits remain unqualified with effective limits
                zero.
            */
        }
    }
    satisfy bmsStartupChecks by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-002'> operatingLimitQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-006](../BatteryControl.sysml). Inputs:
            [REQ-SYS-BMS-002](../BatteryControl.sysml) and [REQ-SYS-BMS-003](../BatteryControl.sysml).
            Sources: [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md); Battery_Integration
            configuration and per-consumer acceptance. Verify:
            inspection, analysis, T-SW/T-SYS/T-FI across controller startup, independent
            shared/branch loss, restrictions and recovery. Open: two startup checks, source ages,
            per-consumer input subsets and required temperature channels, numeric plausibility limits,
            timeout criteria, dependencies and update budget under OI-041/049/061; WS-OI-007/018/019.
            No universal pack-current requirement is selected for both branches.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                After controller startup/restart, both existing branch qualifications shall remain false until their
                applicable current assessments pass.
                Both checks in REQ-SYS-BATSUP-001 shall pass before dependent limits qualify. Each
                branch qualification shall include its applicable shared and operation-specific
                evidence; shared qualification shall remain internal and shall not be published as a
                separate flag. Charge-only evidence shall not gate discharge qualification; HMI-only
                current display evidence shall gate neither branch, while operation-required current
                remains required. Loss of a required shared input shall withdraw every dependent
                branch qualification; branch-only loss shall withdraw only that branch unless a
                restart-required battery-side fault is recognized. A zero current limit while
                required startup assessment is unqualified denotes unavailable information, not
                known zero capability under REQ-SYS-BMSPOL-001. Affected qualification changes shall
                be published within the accepted update budget.
            */
        }
    }
    satisfy operatingLimitQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-003'> actualSocQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending;
            HMI fallback and RidingControl SOC policy remain consumer concerns.
            Parent: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001) / [REQ-SYS-BMS-003](../BatteryControl.sysml). Sources: [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md); [Battery Integration SOC acceptance](../Battery_Integration.md#soc-source-acceptance);
            selected-unit UART facts; DEC-SOC-001/002, DEC-HMI-002/005. Verify: analysis, T-SW/T-SYS
            against independent SOC references, startup/restart and loss. Open: calibration,
            uncertainty, usable range and age criteria under OI-041/049/061; WS-OI-018.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify and publish actual state of charge only when the
                supplied candidate meets the controlled SOC source acceptance criteria against
                actual charge and capacity references for the selected pack. Qualification shall
                account for source and calibration evidence, capacity references, error and
                uncertainty, usable range, and data age suitable for the 10%, 80% and 90%
                vehicle SOC policies. Reported RSOC alone and any HMI display fallback are not
                qualified actual SOC.
            */
        }
    }
    satisfy actualSocQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-004'> chargePathCapability : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml). Sources: owner-authorized
            battery current-path capability refinement; [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md);
            [selected-unit UART facts](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            source qualification and age rules in [BMSIF-009–011](BatterySupervision.sysml#req-sys-bmsif-009) and
            [BATSUP-002](BatterySupervision.sysml#req-sys-batsup-002).
            Verify: T-SW/T-SYS across enabled, disabled, unknown, invalid and stale charge-path states,
            independently varying discharge state and all remaining charge-envelope constraints.
            Open: installed-unit field/bit qualification and physical path observability under OI-041/049/061;
            WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                If charge-path status is qualified disabled and all other applicable shared and charge-branch
                criteria pass and no retained restart-required fault applies, BatterySupervision shall
                publish the charge branch qualified with a zero
                effective regenerative-charge current limit. Unknown, invalid or stale required charge-path
                status shall leave that branch unqualified with a zero limit. Qualified enabled status removes
                only the charge-path restriction; remaining required evidence and envelope constraints still
                determine qualification and capability, so enabled status alone does not establish a nonzero
                limit.
            */
        }
    }
    satisfy chargePathCapability by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-005'> dischargePathCapability : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml). Sources: owner-authorized
            battery current-path capability refinement; [BAT-001](../../../../../Battery/BAT-001_Selected_Pack_and_BMS.md);
            [selected-unit UART facts](BMS_Information.md#selected-unit-uart-read-acceptance-contract);
            source qualification and age rules in [BMSIF-009–011](BatterySupervision.sysml#req-sys-bmsif-009) and
            [BATSUP-002](BatterySupervision.sysml#req-sys-batsup-002).
            Verify: T-SW/T-SYS across enabled, disabled, unknown, invalid and stale discharge-path states,
            independently varying charge state and all remaining discharge-envelope constraints.
            Open: installed-unit field/bit qualification and physical path observability under OI-041/049/061;
            WS-OI-018/019.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                If discharge-path status is qualified disabled and all other applicable shared and discharge-branch
                criteria pass and no retained restart-required fault applies, BatterySupervision shall
                publish the discharge branch qualified with a
                zero effective discharge-current limit. Unknown, invalid or stale required discharge-path
                status shall leave that branch unqualified with a zero limit. Qualified enabled status removes
                only the discharge-path restriction; remaining required evidence and envelope constraints still
                determine qualification and capability, so enabled status alone does not establish a nonzero
                limit.
            */
        }
    }
    satisfy dischargePathCapability by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-006'> bmsMosDisabledStatus : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml). Source: qualified charge- and
            discharge-path status in the accepted BMS protection/path observation; source update and expiry
            budgets reuse [BMSIF-009–011](BatterySupervision.sysml#req-sys-bmsif-009) qualification rules. Verify: T-SW/T-SYS for each combination
            of qualified enabled/disabled charge and discharge paths, plus unknown, invalid, stale and source-loss
            recovery cases. Display-code selection remains a RidingControl concern. This status is not evidence of
            physical isolation and does not itself establish a fault.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish the BatteryStatus MOS-disabled warning as an independent condition
                derived from the current qualified BMS charge- and discharge-MOS path states. When both states are
                qualified, the warning shall be present if either state is disabled and absent only if both states
                are enabled. The qualification of this status shall depend on current qualification of the path-state
                source and shall be independent of charge/discharge branch current-assessment
                completeness. Unknown, invalid, stale or otherwise unqualified source state shall make this status
                unqualified; it shall not be interpreted as either disabled or enabled. Loss of source qualification
                shall invalidate the status under existing BMS source-loss and expiry rules. The status alone shall
                neither create or latch a fault nor assert physical isolation; recognized fault evidence continues
                through BatteryStatus. The live warning clears on qualified evidence that both paths are enabled.
            */
        }
    }
    satisfy bmsMosDisabledStatus by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-007'> startupCapacityReference : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized regenerative and discharge pack capability decisions.
            Verify: T-SW/T-SYS with positive, zero, negative, nonfinite, missing and unqualified capacity;
            exercise later field changes and expiry, controller restart.
            Evidence / open: Basic (0x03) standard nominal capacity is the full-pack reference,
            not remaining capacity or optional learned FCC. Installed-unit scaling and profile calibration
            need qualification. This adds no global startup compatibility check.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected vehicle-controller startup, BatterySupervision shall capture once
                the first finite, positive, qualified standard nominal full-pack capacity from current startup
                BMS evidence as C_Ah in ampere-hours. It shall retain that reference unchanged for the entire
                controller cycle and ignore later nominal-capacity values for regenerative and discharge base
                currents. It shall not carry the reference across a controller startup or use a substitute
                capacity. Until the reference is captured, both dependent current limits shall be unqualified
                and zero. Loss, expiry or later
                return of live capacity information shall not refresh or invalidate the captured reference.
                Other required current evidence, qualification and fault policies remain applicable.
            */
        }
    }
    satisfy startupCapacityReference by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-008'> regenerativeBaseCurrent : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized regenerative pack capability decision.
            Verify: T-SW/T-SYS with multiple qualified capacities, including 17 Ah.
            Evidence: 17 Ah gives 5.10 A as an example only; runtime follows the qualified reference.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the regenerative base current Ib in amperes as 0.30
                times the qualified nominal full-pack capacity C_Ah in ampere-hours.
            */
        }
    }
    satisfy regenerativeBaseCurrent by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-009'> regenerativeTemperatureCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized regenerative pack capability decision.
            Verify: T-SW/T-SYS at each breakpoint, between points and with missing temperature.
            Evidence / open: Measurement adequacy and cell-probe role are to be verified at product validation.
            MOS/T1 is not proven to represent cell temperature; the external central T2 assignment is provisional.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the temperature ceiling IT = Ib × fT(Tcell), where
                Tcell is the qualified reported cell-temperature reading in degrees Celsius from a correctly
                identified cell probe in the selected BMS data. fT is piecewise
                linear through (5, 0), (10, 0.25), (15, 0.50), (20, 1), (30, 1), (35, 0.75),
                and (40, 0), and is zero at Tcell ≤ 5 and Tcell ≥ 40. Missing, invalid or unqualified
                required cell temperature shall leave the dependent regenerative limit unqualified and zero.
            */
        }
    }
    satisfy regenerativeTemperatureCeiling by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-010'> regenerativeVoltageCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized regenerative pack capability decision.
            Verify: T-SW/T-SYS at and around each configured endpoint, and with each group missing.
            Evidence: Existing BMS interface requirements govern each group observation and its age.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine Vh in volts as the maximum of all fourteen qualified
                reported series-group voltage readings. With Rfull and Rcut respectively denoting the qualified
                voltageDeratingCalibration.regenerativeFullCurrentVoltageVolts and
                voltageDeratingCalibration.regenerativeCutoffVoltageVolts, it shall determine
                IV = Ib × clip((Rcut − Vh) / (Rcut − Rfull), 0, 1), where clip bounds its argument
                to [0, 1]. Missing, invalid or unqualified required group voltage or regenerative
                calibration shall leave the dependent regenerative limit unqualified and zero.
            */
        }
    }
    satisfy regenerativeVoltageCeiling by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-011'> regenerativePackCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized regenerative pack capability decision.
            Verify: T-SW/T-SYS with simultaneous derating and independent discharge evidence. At C=17 Ah,
            Tcell=25°C, all 14 groups=3.8 V, both paths qualified enabled and actual SOC=50%, the only
            additional physical ceiling is 10 A, so the regenerative limit is exactly 5.10 A; an applicable
            qualified 2 A ceiling gives exactly 2 A. A qualified disabled charge path gives qualified zero;
            missing required regenerative evidence gives unqualified zero. Confirm missing discharge-only
            evidence leaves the discharge branch unqualified without withdrawing this regenerative branch.
            Also cover qualified zero curves.
            Evidence: The existing 10 A physical ideal ceiling and qualified component restrictions apply.
            RidingControl retains its fault and regenerative re-entry guards.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the regenerative pack ceiling Ipack = min(IT, IV), without
                multiplying the temperature and voltage factors. When all required regenerative evidence is
                qualified and no retained restart-required fault applies, a zero from either curve shall
                contribute a qualified known zero. The effective
                regenerative current limit shall equal exactly the minimum of Ipack and every applicable
                qualified battery-side current ceiling or restriction, including physical, component, charge-path,
                SOC policy, protection and configuration limits. A qualified prohibition or disabled charge path
                contributes zero; a nonapplicable constraint does not limit operation. If no additional applicable
                qualified constraint is tighter, the limit equals Ipack. Missing, invalid or unqualified required
                capacity, cell temperature or any of the fourteen voltages shall leave the dependent regenerative
                limit unqualified and zero without withdrawing an otherwise qualified independent discharge
                assessment.
            */
        }
    }
    satisfy regenerativePackCeiling by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-012'> dischargeBaseCurrent : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized discharge pack capability decision.
            Verify: T-SW/T-SYS with multiple qualified capacities, including 17 Ah.
            Evidence: 17 Ah gives 17 A as an example only; runtime follows the qualified reference.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the discharge base current IbD in amperes as 1.00 A/Ah
                times the qualified nominal full-pack capacity C_Ah in ampere-hours.
            */
        }
    }
    satisfy dischargeBaseCurrent by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-013'> dischargeTemperatureCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized discharge pack capability decision.
            Verify: T-SW/T-SYS at each breakpoint, between points and with missing temperature.
            Evidence / open: Measurement adequacy and cell-probe role are to be verified at product validation.
            MOS/T1 is not proven to represent cell temperature; the external central T2 assignment is provisional.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the discharge temperature ceiling ITD = IbD × FD(Tcell),
                where Tcell is the qualified reported cell-temperature reading in degrees Celsius from a correctly
                identified cell probe in the selected BMS data. FD is
                piecewise linear through (-5, 0), (0, 0.25), (10, 0.60), (20, 1), (35, 1),
                (40, 0.75), (45, 0.40), and (50, 0), and is zero at Tcell ≤ -5 and Tcell ≥ 50.
                Missing, invalid or unqualified required cell temperature shall leave the dependent discharge
                limit unqualified and zero.
            */
        }
    }
    satisfy dischargeTemperatureCeiling by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-014'> dischargeVoltageCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized discharge pack capability decision.
            Verify: T-SW/T-SYS at and around each configured endpoint, and with each group missing.
            Evidence: Existing BMS interface requirements govern each group observation and its age.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine Vl in volts as the minimum of all fourteen qualified
                reported series-group voltage readings. With Dfull and Dcut respectively denoting the qualified
                voltageDeratingCalibration.dischargeFullCurrentVoltageVolts and
                voltageDeratingCalibration.dischargeCutoffVoltageVolts, it shall determine
                IVD = IbD × clip((Vl − Dcut) / (Dfull − Dcut), 0, 1), where clip bounds its argument
                to [0, 1]. Missing, invalid or unqualified required group voltage or discharge calibration
                shall leave the dependent discharge limit unqualified and zero.
            */
        }
    }
    satisfy dischargeVoltageCeiling by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-015'> dischargePackCeiling : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: [REQ-SYS-BMS-001](../Battery_Integration.md#req-sys-bms-001);
            owner-authorized discharge pack capability decision.
            Verify: T-SW/T-SYS with simultaneous derating and independent regenerative evidence. At C=17 Ah,
            Tcell=25°C, all 14 groups=3.8 V, both paths qualified enabled and actual SOC=50%, the only
            additional physical ceiling is 40 A, so the discharge limit is exactly 17 A; an applicable
            qualified 12 A ceiling gives exactly 12 A. A qualified disabled discharge path gives qualified zero;
            missing required discharge evidence gives unqualified zero. Confirm missing charge-only evidence
            leaves the regenerative branch unqualified without withdrawing this discharge branch. Also cover
            qualified zero curves.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall determine the discharge pack ceiling IpackD = min(ITD, IVD), without
                multiplying the temperature and voltage factors. When all required discharge evidence is
                qualified and no retained restart-required fault applies, a zero from either curve shall
                contribute a qualified known zero as an ordinary
                restriction and shall not by itself create or latch a fault. The effective discharge current
                limit shall equal exactly the minimum of IpackD and every applicable qualified battery-side
                current ceiling or restriction, including cell, pack, component, protection and discharge-path
                limits. A qualified prohibition or disabled discharge path contributes zero; a nonapplicable
                constraint does not limit operation. If no additional applicable qualified constraint is tighter,
                the limit equals IpackD. Missing, invalid or unqualified required capacity, cell temperature or
                any of the fourteen voltages shall leave the dependent discharge limit unqualified and zero
                without withdrawing an otherwise qualified independent regenerative assessment.
            */
        }
    }
    satisfy dischargePackCeiling by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-016'> voltageDeratingCalibrationQualification : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Verify: T-SW/T-SYS for missing, nonfinite, nonpositive, reversed and equal endpoints,
            configuration mismatch, envelope acceptance and independent branch behavior.
            Open: numerical pack/cell envelope validation and release evidence remain to be completed.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall qualify each voltage derating calibration branch independently.
                Each pair shall be present, finite and positive, correspond to the controlled compiled
                configuration and lie within the applicable qualified pack and cell envelopes. The discharge
                pair shall satisfy dischargeCutoffVoltageVolts < dischargeFullCurrentVoltageVolts; the
                regenerative pair shall satisfy regenerativeFullCurrentVoltageVolts <
                regenerativeCutoffVoltageVolts. A missing, invalid or unqualified pair shall leave its
                dependent branch unqualified and zero. Failure of either pair shall not by itself invalidate
                the independently valid other branch.
            */
        }
    }
    satisfy voltageDeratingCalibrationQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-017'> batteryFaultRecognition : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: FLT-008/010; BATSUP-001 startup mismatch.
            Verify: T-SW/T-SYS BMS thermal and other faults, mismatch, required-information loss,
            initial waiting, rejected frames and optional or HMI-only loss.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall recognize the battery-fault category from qualified BMS-reported
                faults, including BMS thermal faults, recognized startup mismatch, and recognized failure of
                required battery information under the applicable existing recognition policies. Initial
                waiting, a single rejected frame, and loss solely of optional or HMI-only information shall
                not alone establish this fault.
            */
        }
    }
    satisfy batteryFaultRecognition by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-018'> localThermalFaultRecognition : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: TMP-001/002 and existing temperature fault policy.
            Verify: T-SW/T-SYS actual violation, missing information and ordinary charge ineligibility.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall separately recognize an actual local thermal limit violation under
                the applicable temperature fault policy; missing temperature information alone shall not
                establish an actual thermal violation. Ordinary temperature-based charge ineligibility
                shall not alone establish a fault.
            */
        }
    }
    satisfy localThermalFaultRecognition by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-019'> batteryFaultRetainedEffect : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: FLT-008/010 and TMP-001/002.
            Verify: T-SW/T-SYS both fault categories, source and path recovery, valid unrelated
            measurements, and normal and unexpected restart.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                Upon recognition of a restart-required battery-side fault, including either the battery-fault
                or local actual thermal-fault category, BatterySupervision shall retain both operating
                branches unqualified with effective current limits zero until the next normal or unexpected
                controller restart. Source or path recovery, live condition clearing or requalification shall
                not clear this effect. Other actually valid measurements shall retain independent validity.
            */
        }
    }
    satisfy batteryFaultRetainedEffect by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-020'> batteryStatusPublication : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Sources: FLT-008/010, TMP-001/002 and BATSUP-001.
            Verify: T-SW/T-SYS simultaneous, brief and cleared faults, unknown source states and
            unqualified operating assessments; confirm common first-recognized report ordering.
            Open: recognition thresholds, source mapping and publication/delivery budgets.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall publish independent battery and local thermal fault conditions and
                the live MOS warning concurrently in BatteryStatus, without battery-local priority or HMI-code
                selection. A live condition clears only on qualified evidence of its absence; unknown is
                neither confirmed presence nor confirmed absence. It shall capture and make every recognized
                fault and its common recognition order available to RidingControl for reporting, including
                brief, cleared and simultaneous events, even while operating assessments are unqualified.
                Publication and delivery shall meet the accepted derived budgets.
            */
        }
    }
    satisfy batteryStatusPublication by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BATSUP-021'> batteryStatusRestart : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION.
            Parent: [REQ-SYS-BMS-007](../BatteryControl.sysml).
            Verify: T-SW/T-SYS normal and unexpected restart with cleared and still-present faults.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                At each normal or unexpected controller restart BatterySupervision shall discard prior-cycle
                retained fault effects and diagnostic evidence and reacquire current evidence under startup
                qualification and recognition rules; a still-present fault may be recognized anew. No
                prior-cycle fault memory shall be carried across restart.
            */
        }
    }
    satisfy batteryStatusRestart by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement batterySupervisionRequirements : AbstractSoftwareRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatterySupervision architectural
            occurrence.
        */
        subject supervision:BatterySupervision = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require X2CityComponent_BatterySupervision::bmsInformationQualification;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::bmsStartupChecks;
        require X2CityComponent_BatterySupervision::operatingLimitQualification;
        require X2CityComponent_BatterySupervision::actualSocQualification;
        require X2CityComponent_BatterySupervision::chargePathCapability;
        require X2CityComponent_BatterySupervision::dischargePathCapability;
        require X2CityComponent_BatterySupervision::bmsMosDisabledStatus;
        require X2CityComponent_BatterySupervision::batteryFaultRecognition;
        require X2CityComponent_BatterySupervision::localThermalFaultRecognition;
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
    }
    satisfy batterySupervisionRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    doc /* Output responsibility and system integration retained from the capability-policy record:
        - Physical battery capability: Keep charge and discharge capabilities distinct, including qualified effective current limits and charge-path acceptance. Limits account for the most restrictive applicable cell/group, temperature, configured protection and connected-component envelope. An unknown required limit shall leave affected current at zero and dependent operation unavailable.
        - Operation-specific battery restrictions: Distinguish regenerative charge acceptance from discharge capability, including auxiliary discharge. Low-SOC propulsion cutoff does not alter the BatterySupervision discharge-current assessment. A temperature where discharge current remains available but effective charge current is zero is an ordinary regeneration restriction under DEC-TMP-003. RidingControl applies the 10% positive-propulsion cutoff and recovery from qualified actual SOC.
        - Riding integration: BatterySupervision publishes qualified battery assessment and fault evidence. A newly available battery envelope alone does not determine RidingControl authority or its session state.
        - Physical protection: LE-EPCS and the supplied BMS/other derived protection contributors retain the system obligation for energized paths, residual/generated energy, faults, and host/UART loss. Vendor protection release is an observation, not automatic restoration of effective limits or a system session.
        Only the information-policy contribution is allocated here. Calibration, source accuracy, diagnostics, actual protection, and parent system acceptance remain open; no software unit, inverter algorithm, or circuit is selected. */
}
