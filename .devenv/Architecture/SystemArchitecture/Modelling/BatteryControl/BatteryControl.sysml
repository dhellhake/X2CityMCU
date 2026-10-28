package X2CityContract_BatteryControl {
    private import X2CitySharedContracts::*;

    item def BatteryPower {
        doc /* Physical bidirectional pack-energy-path power boundary. It conveys discharge and regenerative charging energy without selecting voltage, conductors, switching, protection topology, or a software protection credit. */
    }
    enum def BmsReadRecordKind { enum Basic; enum FourteenGroup; enum Identity; }
    item def BmsReadRequest {
        doc /* A selected UART request for one BMSIF-001 record: Basic, FourteenGroup, or Identity. It is read-only: it cannot write configuration, override protection, or command charging. */
        attribute recordKind:BmsReadRecordKind;
    }
    item def TemperatureObservation {
        doc /* One available BMS temperature reading with probe identity. Availability does not imply a fixed probe count, placement, or seventy cell sensors. */
        attribute probeIdentifier:Integer;
        attribute temperatureCelsius:Real;
    }
    item def ProtectionPathState {
        doc /* Supplied BMS protection flags and the independent discharge/charge path states. It is source evidence, not a project protection decision. */
        attribute protectionFlags:Integer;
        attribute dischargePathEnabled:Boolean;
        attribute chargePathEnabled:Boolean;
    }
    item def BmsSocSourceEvidence {
        doc /* Reported BMS identity/configuration evidence needed by BMSIF-001 to qualify source SOC against the fixed compiled configuration. Remaining capacity, standard nominal capacity, series-group count, and version are Basic (0x03) evidence; nominal capacity is not optional learned FCC and requires scale and profile calibration qualification; reportedBmsIdentity is only Identity (0x05) evidence. A response carries only its applicable evidence and does not establish calibration, capacity acceptance, or a BMS write/configuration action. */
        attribute reportedRemainingCapacityAmpereHours:Real[0..1];
        attribute reportedNominalCapacityAmpereHours:Real[0..1];
        attribute reportedSeriesGroupCount:Integer[0..1];
        attribute reportedBmsIdentity:String[0..1];
        attribute reportedBmsVersion:String[0..1];
    }
    item def BmsTelemetry {
        doc /* Discriminated supplied BMS source response. Basic (0x03) carries its pack voltage/current, candidate SOC, available temperatures, protection/path state, capacity/group-count, and version evidence; FourteenGroup (0x04) carries exactly the fourteen group voltages; Identity (0x05) carries the device identity. Fields outside the selected recordKind are absent/unavailable, never fabricated or treated as current. */
        attribute recordKind:BmsReadRecordKind;
        attribute packVoltageVolts:Real[0..1];
        attribute packCurrentAmperes:Real[0..1];
        attribute stateOfChargeCandidatePercent:Real[0..1];
        attribute cellGroupVoltagesVolts:Real[0..14] { doc /* Present only for FourteenGroup (0x04), which carries all fourteen group voltages. */ }
        item availableTemperatures:TemperatureObservation[0..*];
        item protectionPathState:ProtectionPathState[0..1];
        item socSourceEvidence:BmsSocSourceEvidence[0..1];
    }
    item def BatteryStatus {
        doc /* Logical reporting contract: battery fault, independently recognized local actual thermal fault,
            ordinary at-least-one-MOS-disabled warning, and lowDischargeVoltageWarning are independent,
            simultaneous conditions. Each has
            meaningful known/unknown state; unknown is not absence. Battery fault includes BMS faults (including
            BMS thermal faults), recognized startup mismatch and recognized required battery-information failure.
            Recognition order is comparable with other RidingControl fault evidence for its first-recognized rule.
            Diagnostic evidence remains available independently of operating-limit qualification. This item carries
            reporting information only; detailed representation is deferred to software realization. */
    }
    item def BatteryOperatingLimits {
        doc /*
            Independent discharge and regenerative-charge operating branches under BMSPOL-001. Shared assessment is
            internal to BatterySupervision: each branchQualified field includes its own applicable shared required
            checks together with operation-specific checks. Shared assessment is not published as a separate validity
            flag. Effective limits are finite, nonnegative ceilings that include applicable physical capability
            and battery policy, protection, configuration, and path restrictions. A qualified zero limit means known
            zero capability; it is not missing information or a fault. Qualification remains authoritative: when
            required current-envelope information is unqualified, the affected effective current limit is zero and
            dependent operation is unavailable. A numeric zero alone never qualifies the limit. Battery current sign
            is not a wheel-torque sign; BatterySupervision assesses each electrical current branch independently.
        */
        attribute sourceContext:SourceContext;
        attribute dischargeBranchQualified:Boolean {
            doc /* True only while applicable shared and discharge-required current evidence/configuration/protection/path
                assessment supports this branch. It describes assessment completeness, not available magnitude; a
                qualified zero effective current limit means known zero discharge capability. */
        }
        attribute dischargeCurrentLimitAmperes:Real { doc /* Finite, nonnegative effective discharge-current ceiling in A. */ }
        attribute dischargeRestrictionActive:Boolean;
        attribute dischargeRestrictionReason:Integer;
        attribute regenerativeChargeBranchQualified:Boolean {
            doc /* True only while applicable shared and charge-required current evidence/configuration/protection/path
                assessment supports this branch. Missing charge-only evidence does not invalidate an otherwise current
                discharge branch. It describes assessment completeness, not available magnitude; a qualified zero
                effective current limit means known zero charge acceptance. */
        }
        attribute regenerativeChargeCurrentLimitAmperes:Real { doc /* Finite, nonnegative effective regenerative-charge-current ceiling in A. */ }
        attribute regenerativeChargeRestrictionActive:Boolean;
        attribute regenerativeChargeRestrictionReason:Integer;
    }
    item def BatteryStateOfCharge:>QualifiedInformationRecord {
        doc /* BatterySupervision's qualified actual SOC for display and range reporting. It is distinct from the supplied BMS candidate SOC. */
        attribute actualStateOfChargePercent:Real;
    }
    item def BatteryCurrent:>QualifiedInformationRecord {
        doc /* BatterySupervision's independently qualified signed pack current in amperes, consumed by RidingControl.CurrentConsumptionCoordination for shared-budget supervision and by HMIControl for HMI-020. Positive means charging and negative means discharging; this is not a torque value. Unavailability is represented by this value's inherited qualification only. */
        attribute signedPackCurrentAmperes:Real;
    }

    port def BatteryPowerPort { doc /* Physical bidirectional battery-power connection between BatteryControl and EnergyPath. */ inout item batteryPower:BatteryPower; }
    port def BmsReadRequestOutputPort { doc /* Sends a read-only UART information request from BatterySupervision to the supplied BMS. */ out item request:BmsReadRequest; }
    port def BmsReadRequestInputPort { doc /* Receives a read-only UART information request at the supplied BMS. */ in item request:BmsReadRequest; }
    port def BmsTelemetryOutputPort { doc /* Sends selected BMS source fields from the supplied BMS to BatterySupervision over the read-only UART route. */ out item telemetry:BmsTelemetry; }
    port def BmsTelemetryInputPort { doc /* Receives selected BMS source fields at BatterySupervision for qualification. */ in item telemetry:BmsTelemetry; }
    port def BatteryStatusOutputPort {
        doc /* Publishes independent battery reporting conditions including lowDischargeVoltageWarning;
            operating qualification and effective limits travel on BatteryOperatingLimits. */
        out item status:BatteryStatus;
    }
    port def BatteryStatusInputPort {
        doc /* Receives independent battery reporting conditions including lowDischargeVoltageWarning at RidingControl. */
        in item status:BatteryStatus;
    }
    port def BatteryOperatingLimitsOutputPort { doc /* Publishes independently qualified total discharge and regenerative-charge current bounds to RidingControl and EnergyPath. */ out item operatingLimits:BatteryOperatingLimits; }
    port def BatteryOperatingLimitsInputPort { doc /* Receives independently qualified total discharge and regenerative-charge current bounds at RidingControl or EnergyPath. */ in item operatingLimits:BatteryOperatingLimits; }
    port def BatteryStateOfChargeOutputPort { doc /* Publishes qualified actual SOC to HMIControl. */ out item stateOfCharge:BatteryStateOfCharge; }
    port def BatteryStateOfChargeInputPort { doc /* Receives qualified actual SOC at HMIControl. */ in item stateOfCharge:BatteryStateOfCharge; }
    port def BatteryCurrentOutputPort { doc /* Publishes independently qualified signed pack current to RidingControl.CurrentConsumptionCoordination and HMIControl. */ out item batteryCurrent:BatteryCurrent; }
    port def BatteryCurrentInputPort { doc /* Receives qualified signed pack current at RidingControl.CurrentConsumptionCoordination or HMIControl. */ in item batteryCurrent:BatteryCurrent; }

    interface def IfA003BatteryStatus { end producer:BatteryStatusOutputPort; end consumer:BatteryStatusInputPort; flow producer.status to consumer.status; }
    interface def IfA003BatteryOperatingLimits { end producer:BatteryOperatingLimitsOutputPort; end consumer:BatteryOperatingLimitsInputPort; flow producer.operatingLimits to consumer.operatingLimits; }
    interface def IfA003BatteryStateOfCharge { end producer:BatteryStateOfChargeOutputPort; end consumer:BatteryStateOfChargeInputPort; flow producer.stateOfCharge to consumer.stateOfCharge; }
    interface def IfA003BatteryCurrent { end producer:BatteryCurrentOutputPort; end consumer:BatteryCurrentInputPort; flow producer.batteryCurrent to consumer.batteryCurrent; }
    interface def IfA009BmsReadRequest { end producer:BmsReadRequestOutputPort; end consumer:BmsReadRequestInputPort; flow producer.request to consumer.request; }
    interface def IfA009BmsTelemetry { end producer:BmsTelemetryOutputPort; end consumer:BmsTelemetryInputPort; flow producer.telemetry to consumer.telemetry; }
    interface def IfA010BatteryPower { end batteryControl:BatteryPowerPort; end energyPath:BatteryPowerPort; flow batteryControl.batteryPower to energyPath.batteryPower; flow energyPath.batteryPower to batteryControl.batteryPower; }
}

package X2CityComponent_BatteryControl {
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_BatteryAssembly::*;
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::SystemRequirement;
    private import RequirementDerivation::*;

    part def BatteryControl { // LE-BATTERY-CONTROL
        doc /* EPCS battery composite. It contains exactly the removable physical BatteryAssembly and vehicle-host BatterySupervision, separating supplied BMS protection from project read/qualification and operating policy. */
        part batteryAssembly:BatteryAssembly { doc /* The sole removable physical 14S5P pack assembly. */ }
        part batterySupervision:BatterySupervision { doc /* Project vehicle-host supervision for BMS reading, qualification, and battery operating policy. */ }
        port batteryPower:BatteryPowerPort { doc /* External physical bidirectional pack-to-EnergyPath boundary for discharge and regeneration. */ }
        port batteryStatusOut:BatteryStatusOutputPort {
            doc /* External RidingControl reporting conditions, including independent lowDischargeVoltageWarning. */
        }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort { doc /* External total battery operating limits for RidingControl budgeting and EnergyPath enforcement across both current-sign branches. */ }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort { doc /* External qualified actual-SOC publication for HMI. */ }
        port batteryCurrentOut:BatteryCurrentOutputPort { doc /* External qualified signed-current publication for RidingControl.CurrentConsumptionCoordination and HMI. */ }
        flow assemblyPowerToBoundary from batteryAssembly.batteryPower.batteryPower to batteryPower.batteryPower;
        flow boundaryPowerToAssembly from batteryPower.batteryPower to batteryAssembly.batteryPower.batteryPower;
        interface bmsReadRequestToAssembly : IfA009BmsReadRequest
            connect batterySupervision.bmsReadRequestOut to batteryAssembly.bms.bmsReadRequestIn;
        interface bmsTelemetryFromAssembly : IfA009BmsTelemetry
            connect batteryAssembly.bms.bmsTelemetryOut to batterySupervision.bmsTelemetryIn;
        flow statusFromSupervision from batterySupervision.batteryStatusOut.status to batteryStatusOut.status;
        flow limitsFromSupervision from batterySupervision.batteryOperatingLimitsOut.operatingLimits to batteryOperatingLimitsOut.operatingLimits;
        flow socFromSupervision from batterySupervision.stateOfChargeOut.stateOfCharge to stateOfChargeOut.stateOfCharge;
        flow currentFromSupervision from batterySupervision.batteryCurrentOut.batteryCurrent to batteryCurrentOut.batteryCurrent;
    }

    doc /*
    System Requirements allocated to LE-BATTERY-CONTROL. Current requirement usages are Draft successors;
    historical approval applies only to the released REQ-001-R1.6 record, and integrated acceptance remains open. They implement
    owner-confirmed [DEC-BAT-002](../../../../Requirements/DEC-001_Decisions_and_Open_Issues.md#dec-bat-002).
    [BAT-001](../../../../Battery/BAT-001_Selected_Pack_and_BMS.md) is the canonical component/rating reference; selection and reported initial
    fit are settled. Apply the [REQ-001 model and verification rules](../../../../Requirements/REQ-001_Requirements.md).
    */

    requirement <'REQ-SYS-BAT-002'> removableBatteryAssemblySelection : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL.

            Sources: PD CON-041–042, §10.8; DEC-BAT-002; BAT-001.

            Planned verification: I, T-SYS. Record cell identity, group construction, and the owner-confirmed JBD
            SP14S004 hardware V1.0 and firmware version 3.2 against the installed assembly. Record effective BMS
            configuration identity and working UART readback; reconcile the installed assembly with the owner's
            configuration. Verify protocol readback and fixed firmware-to-schema compatibility separately; firmware
            version alone does not establish protocol revision or wire encoding.

            Open dependencies / qualifications: OI-040/041/062: construction and initial bay fit, selected BMS model,
            hardware V1.0 and firmware 3.2 are owner-confirmed; effective configuration, protocol compatibility,
            accuracy, and complete installed-unit readback remain to be qualified. The earlier SP14S004P14S50A name
            records provenance for the 14S50A selection, not an alternate device. No cell reselection or invented
            vendor-internal decomposition is required.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatteryAssembly::assemblySelectionRequirements;
        require constraint {
            doc /*
                BatteryControl shall use a removable battery comprising the owner-built 14S5P bank of 70 Samsung
                INR18650-35E cells and the selected JBD SP14S004 hardware V1.0, firmware version 3.2 BMS, with UART as
                its system communication interface.
            */
        }
    }
    satisfy removableBatteryAssemblySelection by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-002'> integratedBmsConfiguration : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL.

            Sources: PD OI-041/061, CON-048–050; BAT-001;
            [service](../../../../Requirements/System_Requirements/Service_and_Durability.md#req-sys-svc-001).

            Planned verification: I, A, T-SYS. Read and assess actual capacity, voltage/current/temperature thresholds,
            delays, release behavior and balancing settings against the
            [Configuration acceptance baseline](Battery_Integration.md#configuration-acceptance-baseline), cell limits
            and system reaction budgets; qualify SOC calibration/uncertainty against the
            [SOC source acceptance criteria](Battery_Integration.md#soc-source-acceptance) and vehicle policy.

            Open dependencies / qualifications: OI-041/049/061: source family defaults are not accepted operating
            settings; vendor voltage trips or RSOC alone do not implement actual-SOC policy. Determine remaining
            independent protection/diagnostic coverage.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatteryAssembly::assemblyConfigurationRequirements;
        require X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
        require constraint {
            doc /*
                BatteryControl shall integrate BMS configuration and supervisory protection meeting the controlled
                criteria in the
                [Configuration acceptance baseline](Battery_Integration.md#configuration-acceptance-baseline) for the
                fixed 14S5P 35E bank, including cell voltage, current, temperature and balancing, and the
                [SOC source acceptance criteria](Battery_Integration.md#soc-source-acceptance) for actual-SOC
                calibration/uncertainty and the vehicle regenerative-charge policy.

                Commissioning records of effective configuration identity and accepted settings shall be
                available for vehicle integration/service acceptance.
            */
        }
    }
    satisfy integratedBmsConfiguration by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-003'> batteryInterfaceProvision : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL.

            Sources: PD OI-041/047/061; BAT-001;
            [input qualification](../../../../Requirements/System_Requirements/Interface_Qualification.md);
            [SOC and fault behavior](../../../../Requirements/System_Requirements/Power_Startup_and_Faults.md).

            Planned verification: I, T-SYS. Exercise the
            [selected-unit UART read acceptance contract](Decomposition/BMS_Information.md#selected-unit-uart-read-acceptance-contract)
            and
            [Per-consumer information acceptance criteria](Battery_Integration.md#per-consumer-information-acceptance),
            including the exact supported per-command response schemas and payload lengths, expected group/temperature
            counts and encodings, signs/scales, malformed/stale data and per-field domain failures. Verify that
            disagreement between measurements does not invalidate individually valid BMS readings. Exercise startup,
            sleep/wake and interrupted communication. Compare against independent references and current-session
            qualification/fault behavior.

            Open dependencies / qualifications: WS-OI-005/018/019, OI-041/049: verify firmware support and its fixed
            mapping to accepted protocol captures, exact implemented response schemas, accuracy, polling/response,
            field-age-validity and initialization limits. Firmware version 3.2 is known but does not establish the
            protocol revision or wire encoding. A BMS estimate becomes actual-SOC information only after qualification.
            Fourteen groups and available probes are not complete individual-cell/temperature fault coverage.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatteryAssembly::assemblySourceInformationRequirements;
        require X2CityComponent_BatterySupervision::bmsInformationQualification;
        require X2CityComponent_BatterySupervision::actualSocQualification;
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
        require constraint {
            doc /*
                BatteryControl shall acquire and internally qualify the applicable pack voltage, candidate SOC,
                group voltages, available temperatures, protection/path state and other source fields read through
                the selected BMS UART, including their source timeliness. It shall publish signed pack current and
                actual SOC as independently qualified values. Reported RSOC alone is not actual SOC.

                Source fields shall meet the selected-unit read contract and
                [Per-consumer information acceptance criteria](Battery_Integration.md#per-consumer-information-acceptance).
                Actual SOC shall meet the [SOC source acceptance criteria](Battery_Integration.md#soc-source-acceptance).
                Unavailable or unqualified information shall not authorize dependent battery operation.
            */
        }
    }
    satisfy batteryInterfaceProvision by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-006'> batteryStartupQualification : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL.

            Native derivation parents are modeled below; external parent:
            [REQ-SYS-STA-006](../../../../Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-006).

            Planned verification: I, A, T-SYS, T-FI. Cover each qualification item independently missing, inconsistent,
            stale and valid; wrong series count/configuration, missing required probe, active protection, expected path
            disable and actual failed path. At each applicable restart, verify shared checks are reflected in each
            dependent branch qualification and operation-specific qualification from BatteryOperatingLimits.

            Open dependencies / qualifications: OI-041/049/061; WS-OI-007/018/019. Define per-consumer
            input subsets, required temperature channels, applicable per-field domain criteria and timeout criteria;
            the qualified BMS pack-current observation is not required by either current-limit branch. Use the
            [BMS configuration derivation](../../../../Battery/BAT-001_Selected_Pack_and_BMS.md#bms-configuration-derivation);
            retain commissioning evidence and admission/change control for protection settings that are not observable
            through selected telemetry reads. At each normal or unexpected controller startup/restart, establish the
            two checks in BATSUP-001 from the same current accepted Basic (0x03) response: decoded software version
            3.2 and 14 series groups. A 0x05 identity read remains informational. The selected-unit version field
            interpretation remains subject to protocol evidence; no wire encoding is presumed. Current/capacity
            scale, supported temperature encoding, probe identity/layout, and group-voltage encoding remain ordinary
            field or capability qualification. Hardware/model/configuration acceptance remains commissioning\
            evidence. Existing
            response validation and timeout/field qualification remain required. Applicable shared checks are internal
            to each dependent branch qualification.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::bmsStartupChecks;
        require X2CityComponent_BatterySupervision::operatingLimitQualification;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
        require constraint {
            doc /*
                At each normal or unexpected controller startup/restart, BatteryControl shall publish
                BatteryOperatingLimits
                with both branch qualification fields false. Before dependent
                limits qualify, both checks in REQ-SYS-BATSUP-001 shall pass from the same current accepted Basic
                (0x03) response. A missing, invalid, or mismatched value means the checks have not passed.
                Until they pass, dependent operating limits remain unqualified with effective limits zero. Existing
                applicable branch qualification behavior then applies.

                Shared required checks shall be internal to BatterySupervision and included in each dependent
                discharge or regenerative-charge branch qualification; no separate common qualification shall be
                published. Each branch qualification shall represent its applicable shared and branch-required
                assessment.
                A known ordinary restriction, including a temperature that forbids charging,
                may leave an applicable branch qualified with a reduced or zero effective limit. Every effective limit
                shall be finite and nonnegative, and shall include applicable physical capability and battery
                policy/protection/configuration/path restrictions. A qualified zero limit denotes known zero
                capability, not missing information or a fault. If required information is unqualified, the affected
                assessment shall remain unqualified and its effective current limit shall be zero.

                Missing charge-only evidence shall not withdraw an otherwise qualified discharge branch. The
                qualified BMS pack-current observation shall not be required by either branch; its field-level
                unavailability shall affect only that observation's qualification and shall not qualify or invalidate
                either branch. Loss of a required shared
                input shall withdraw each dependent branch; branch-only loss shall withdraw only that branch
                unless a restart-required battery-side fault is recognized. A recognized restart-required
                battery-side fault shall retain both branches unqualified with effective limits zero until
                the next normal or unexpected controller restart.
            */
        }
    }
    satisfy batteryStartupQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-007'> batteryOperatingClassification : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL.

            Native derivation parent is modeled below; external parent:
            [REQ-SYS-BMS-005](Battery_Integration.md#req-sys-bms-005).

            Planned verification: I, A, T-SYS, T-FI. Apply the
            [battery event matrix](Battery_Integration.md#battery-event-and-recovery-matrix); contrast voltage-curve cutoff
            with independent physical undervoltage protection, charge-disabled by a known ordinary restriction with unexpected
            trip, and valid status bits with physical path failure. Verify report masking does not change protection.

            Open dependencies / qualifications: DEC-FLT-005–009, DEC-TMP-001–003; OI-041/049/061. Qualify actual BMS
            flags, expected state per operating configuration, recognition timing and observation limitations. No
            automatic MOS override or new fault code is introduced.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
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
        require constraint {
            doc /*
                BatteryControl shall classify battery-side qualification state, operating restrictions, expected
                charge/discharge-path states and recognized battery or protection-information fault evidence, and use
                that classification to produce the applicable effective operating limits and evidence published for
                system integration. A recognized restart-required battery-side fault retains both branches
                unqualified with effective limits zero until the next normal or unexpected controller
                restart. BatteryStatus publishes independent battery-fault, local actual thermal-fault and
                MOS-warning and lowDischargeVoltageWarning reporting conditions, including unknown state and
                common fault recognition order, without selecting an HMI code. BatteryControl shall express battery-side effects on
                operation and recovery through operating values and their qualification; BatteryStatus shall
                provide reporting information only. A qualified disabled path contributes known zero
                effective current for its own
                branch while leaving that branch qualified when its other required assessments pass and no
                retained restart-required fault applies. Required unknown,
                invalid or stale path status leaves the dependent branch or branches unqualified with zero
                current. Current
                charge-path-enabled and discharge-path-enabled fields remain supplied BMS source observations, not
                project permission indications; an enabled path removes only its path restriction.

                An observed disabled path alone shall not prove either a fault or successful physical isolation; unknown
                required path/protection status shall leave the affected operation-required information unqualified,
                publish zero for the affected effective current limit, and shall not grant dependent operation.

                BatteryControl shall also publish the independent MOS-disabled warning in BatteryStatus required
                by REQ-SYS-BATSUP-006. It is qualified from current charge- and discharge-path source state even when
                either current branch assessment is incomplete; unknown, invalid or stale MOS source state leaves
                this status unqualified.
            */
        }
    }
    satisfy batteryOperatingClassification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-008'> dischargePermissiveChargeRestriction : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL.

            External parents: [REQ-SYS-BMS-001](Battery_Integration.md#req-sys-bms-001),
            [REQ-SYS-REG-001](../../../../Requirements/System_Requirements/Rider_Control.md#req-sys-reg-001).

            Planned verification: A, T-SYS. Cover valid cell temperatures below 0°C and above 45°C while within
            discharge limits, each riding level, held regenerative demand, exit/re-entry and standstill recovery. Verify
            effective charge-current limit is zero outside its envelope, no new fault/availability indication for this restriction, and preserved
            response to independent faults.

            Open dependencies / qualifications: DEC-TMP-003; WS-OI-005/019. Cell references are discharge −10…60°C and
            charging 0…45°C; qualify stricter integrated margins/coverage. Applicable discharge-limit violations and
            required-temperature-information faults retain both-sign inhibition; forbidden actual charge transfer is not
            ordinary waiting.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require constraint {
            doc /*
                When qualified cell temperatures permit battery discharge but do not permit charging, BatteryControl
                shall not let this ordinary temperature restriction alone withdraw otherwise eligible battery-side
                discharge capability, and shall set the qualified effective regenerative-charge-current limit to zero.

                It shall identify this restriction separately from recognized battery faults and preserve the effects of
                any other applicable restriction or fault.

                Restoring charging-temperature eligibility may raise the effective charge-current limit but shall not
                itself re-enter regeneration; RidingControl retains system session and regenerative re-entry authority,
                and this ordinary restriction alone shall not require restart.
            */
        }
    }
    satisfy dischargePermissiveChargeRestriction by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-003'> dischargeVoltageCutoff : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL. Sources: DEC-SOC-001, CON-048, OI-061.
            Verify: I, T-SYS with held demand, startup and auxiliary loads at and below the validated
            discharge voltage endpoint. The endpoint is expected around 10% SOC, subject to product
            validation; it is not an exact SOC threshold. Loss of auxiliary power, including brake lights,
            is allowed; physical isolation and storage protection remain separate.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::dischargeVoltageCeiling;
        require X2CityComponent_BatterySupervision::dischargePackCeiling;
        require constraint {
            doc /*
                At or below the validated discharge cutoff voltage for the lowest qualified series group,
                BatteryControl shall set total battery discharge current capability to zero, including
                auxiliary loads. The current provisional setting is owned by the discharge voltage
                calibration. Abrupt withdrawal is permitted in every riding level without a comfort fade.
            */
        }
    }
    satisfy dischargeVoltageCutoff by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-004'> currentBranchIndependence : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL. Sources: DEC-SOC-001, DEC-REG-001/006,
            DEC-SPD-001. Verify: I, T-SYS with independent charge and discharge limits and faults.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require constraint {
            doc /*
                BatteryControl shall assess each current branch against its own applicable operating
                envelopes and limits, independently of the other branch, subject to shared constraints
                and recognized common faults.
            */
        }
    }
    satisfy currentBranchIndependence by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-005'> dischargeVoltageRecovery : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL. Source: DEC-SOC-001. Verify: I, T-SYS
            at the discharge voltage endpoint and just above, including startup and overlapping
            restrictions; positive response follows REQ-SYS-SOC-008.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::dischargeVoltageCeiling;
        require X2CityComponent_BatterySupervision::dischargePackCeiling;
        require constraint {
            doc /*
                Strictly above the validated discharge cutoff voltage for the lowest qualified series group,
                BatteryControl shall automatically allow the discharge voltage curve to recover without
                restart or extra enable action, subject to temperature and all other applicable limits.
            */
        }
    }
    satisfy dischargeVoltageRecovery by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-REG-002'> regenerativeVoltageCutoff : SystemRequirement {
        doc /*
            Draft successor allocation: LE-BATTERY-CONTROL. Sources: DEC-REG-001/004, CON-048,
            OI-061. Verify: A, T-SYS at and around the calibrated highest-group charge voltage
            endpoint in every regenerative level, with independent limits and recovery.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::regenerativeVoltageCeiling;
        require X2CityComponent_BatterySupervision::regenerativePackCeiling;
        require constraint {
            doc /*
                At or above the calibrated charge cutoff voltage for the highest qualified series group,
                BatteryControl shall set regenerative charge current capability to zero. The current
                provisional endpoint is 4.10 V. Below it the voltage curve shall automatically recover,
                subject to temperature and other applicable limits. Abrupt withdrawal is permitted in
                riding Levels 1–5 without an anticipatory comfort fade.
            */
        }
    }
    satisfy regenerativeVoltageCutoff by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement batteryControlRequirements : SystemRequirement {
        doc /*
            Draft organizational conjunction of canonical obligations for the BatteryControl architectural occurrence.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatteryControl::removableBatteryAssemblySelection;
        require X2CityComponent_BatteryControl::integratedBmsConfiguration;
        require X2CityComponent_BatteryControl::batteryInterfaceProvision;
        require X2CityComponent_BatteryControl::batteryStartupQualification;
        require X2CityComponent_BatteryControl::batteryOperatingClassification;
        require X2CityComponent_BatteryControl::dischargePermissiveChargeRestriction;
        require X2CityComponent_BatteryControl::dischargeVoltageCutoff;
        require X2CityComponent_BatteryControl::currentBranchIndependence;
        require X2CityComponent_BatteryControl::dischargeVoltageRecovery;
        require X2CityComponent_BatteryControl::regenerativeVoltageCutoff;
        require X2CityComponent_BatteryAssembly::batteryAssemblyRequirements;
        require X2CityComponent_BatterySupervision::batterySupervisionRequirements;
    }
    satisfy batteryControlRequirements by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    doc /* Native requirement derivations connect only requirement usages modeled in SysML. Parent records maintained in Markdown remain source links in the owning requirement documentation; this model does not create proxy requirements for those records. */

    #derivation connection def DischargeVoltageCutoffDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive dischargeVoltageCeiling : Requirements::RequirementCheck;
        end #derive dischargePackCeiling : Requirements::RequirementCheck;
    }
    #derivation connection dischargeVoltageCutoffDerivation : DischargeVoltageCutoffDerivation {
        end original ::> X2CityComponent_BatteryControl::dischargeVoltageCutoff;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        end dischargeVoltageCeiling ::> X2CityComponent_BatterySupervision::dischargeVoltageCeiling;
        end dischargePackCeiling ::> X2CityComponent_BatterySupervision::dischargePackCeiling;
    }

    #derivation connection def CurrentBranchIndependenceDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
    }
    #derivation connection currentBranchIndependenceDerivation : CurrentBranchIndependenceDerivation {
        end original ::> X2CityComponent_BatteryControl::currentBranchIndependence;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
    }

    #derivation connection def DischargeVoltageRecoveryDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive dischargeVoltageCeiling : Requirements::RequirementCheck;
        end #derive dischargePackCeiling : Requirements::RequirementCheck;
    }
    #derivation connection dischargeVoltageRecoveryDerivation : DischargeVoltageRecoveryDerivation {
        end original ::> X2CityComponent_BatteryControl::dischargeVoltageRecovery;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        end dischargeVoltageCeiling ::> X2CityComponent_BatterySupervision::dischargeVoltageCeiling;
        end dischargePackCeiling ::> X2CityComponent_BatterySupervision::dischargePackCeiling;
    }

    #derivation connection def RegenerativeVoltageCutoffDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive regenerativeVoltageCeiling : Requirements::RequirementCheck;
        end #derive regenerativePackCeiling : Requirements::RequirementCheck;
    }
    #derivation connection regenerativeVoltageCutoffDerivation : RegenerativeVoltageCutoffDerivation {
        end original ::> X2CityComponent_BatteryControl::regenerativeVoltageCutoff;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        end regenerativeVoltageCeiling ::> X2CityComponent_BatterySupervision::regenerativeVoltageCeiling;
        end regenerativePackCeiling ::> X2CityComponent_BatterySupervision::regenerativePackCeiling;
    }

    #derivation connection def BatteryAssemblySelectionDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive cellBankComposition : Requirements::RequirementCheck;
        end #derive packIntegration : Requirements::RequirementCheck;
        end #derive bmsIdentity : Requirements::RequirementCheck;
    }
    #derivation connection batteryAssemblySelectionDerivation : BatteryAssemblySelectionDerivation {
        end original ::> X2CityComponent_BatteryControl::removableBatteryAssemblySelection;
        end cellBankComposition ::> X2CityComponent_Cells::fixedCellBankComposition;
        end packIntegration ::> X2CityComponent_BatteryAssembly::removablePackIntegration;
        end bmsIdentity ::> X2CityComponent_Bms::selectedBmsIdentity;
    }

    #derivation connection def BmsConfigurationDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive effectiveConfiguration : Requirements::RequirementCheck;
        end #derive bmsBasicInformationDecoding : Requirements::RequirementCheck;
        end #derive startupAssessment : Requirements::RequirementCheck;
    }
    #derivation connection bmsConfigurationDerivation : BmsConfigurationDerivation {
        end original ::> X2CityComponent_BatteryControl::integratedBmsConfiguration;
        end effectiveConfiguration ::> X2CityComponent_Bms::effectiveBmsConfiguration;
        end bmsBasicInformationDecoding ::> X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
        end startupAssessment ::> X2CityComponent_BatteryControl::batteryStartupQualification;
    }

    #derivation connection def BmsInterfaceDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive measurementSources : Requirements::RequirementCheck;
        end #derive informationQualification : Requirements::RequirementCheck;
        end #derive actualSocQualification : Requirements::RequirementCheck;
        end #derive startupAssessment : Requirements::RequirementCheck;
        end #derive operatingClassification : Requirements::RequirementCheck;
        end #derive bmsReadCommandRestriction : Requirements::RequirementCheck;
        end #derive bmsResponseValidation : Requirements::RequirementCheck;
        end #derive bmsTransactionAcceptance : Requirements::RequirementCheck;
        end #derive bmsBasicInformationDecoding : Requirements::RequirementCheck;
        end #derive bmsGroupVoltageQualification : Requirements::RequirementCheck;
        end #derive bmsIdentityInformationDecoding : Requirements::RequirementCheck;
        end #derive bmsTemperatureQualification : Requirements::RequirementCheck;
        end #derive bmsFieldQualification : Requirements::RequirementCheck;
        end #derive bmsObservationAgeQualification : Requirements::RequirementCheck;
        end #derive bmsObservationRetention : Requirements::RequirementCheck;
        end #derive bmsSourceRequalification : Requirements::RequirementCheck;
        end #derive bmsReadServiceTiming : Requirements::RequirementCheck;
    }
    #derivation connection bmsInterfaceDerivation : BmsInterfaceDerivation {
        end original ::> X2CityComponent_BatteryControl::batteryInterfaceProvision;
        end measurementSources ::> X2CityComponent_Bms::bmsMeasurementSources;
        end informationQualification ::> X2CityComponent_BatterySupervision::bmsInformationQualification;
        end actualSocQualification ::> X2CityComponent_BatterySupervision::actualSocQualification;
        end startupAssessment ::> X2CityComponent_BatteryControl::batteryStartupQualification;
        end operatingClassification ::> X2CityComponent_BatteryControl::batteryOperatingClassification;
        end bmsReadCommandRestriction ::> X2CityComponent_BatterySupervision::bmsReadCommandRestriction;
        end bmsResponseValidation ::> X2CityComponent_BatterySupervision::bmsResponseValidation;
        end bmsTransactionAcceptance ::> X2CityComponent_BatterySupervision::bmsTransactionAcceptance;
        end bmsBasicInformationDecoding ::> X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
        end bmsGroupVoltageQualification ::> X2CityComponent_BatterySupervision::bmsGroupVoltageQualification;
        end bmsIdentityInformationDecoding ::> X2CityComponent_BatterySupervision::bmsIdentityInformationDecoding;
        end bmsTemperatureQualification ::> X2CityComponent_BatterySupervision::bmsTemperatureQualification;
        end bmsFieldQualification ::> X2CityComponent_BatterySupervision::bmsFieldQualification;
        end bmsObservationAgeQualification ::> X2CityComponent_BatterySupervision::bmsObservationAgeQualification;
        end bmsObservationRetention ::> X2CityComponent_BatterySupervision::bmsObservationRetention;
        end bmsSourceRequalification ::> X2CityComponent_BatterySupervision::bmsSourceRequalification;
        end bmsReadServiceTiming ::> X2CityComponent_BatterySupervision::bmsReadServiceTiming;
    }

    #derivation connection def StartupQualificationDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive bmsStartupChecks : Requirements::RequirementCheck;
        end #derive operatingLimitQualification : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive bmsBasicInformationDecoding : Requirements::RequirementCheck;
    }
    #derivation connection startupQualificationDerivation : StartupQualificationDerivation {
        end original ::> X2CityComponent_BatteryControl::batteryStartupQualification;
        end bmsStartupChecks ::> X2CityComponent_BatterySupervision::bmsStartupChecks;
        end operatingLimitQualification ::> X2CityComponent_BatterySupervision::operatingLimitQualification;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        end bmsBasicInformationDecoding ::> X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
    }

    #derivation connection def OperatingClassificationDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive chargePathCapability : Requirements::RequirementCheck;
        end #derive dischargePathCapability : Requirements::RequirementCheck;
        end #derive bmsMosDisabledStatus : Requirements::RequirementCheck;
        end #derive batteryFaultRecognition : Requirements::RequirementCheck;
        end #derive localThermalFaultRecognition : Requirements::RequirementCheck;
        end #derive batteryFaultRetainedEffect : Requirements::RequirementCheck;
        end #derive batteryStatusPublication : Requirements::RequirementCheck;
        end #derive batteryStatusRestart : Requirements::RequirementCheck;
        end #derive startupCapacityReference : Requirements::RequirementCheck;
        end #derive regenerativeBaseCurrent : Requirements::RequirementCheck;
        end #derive regenerativeTemperatureCeiling : Requirements::RequirementCheck;
        end #derive regenerativeVoltageCeiling : Requirements::RequirementCheck;
        end #derive regenerativePackCeiling : Requirements::RequirementCheck;
        end #derive dischargeBaseCurrent : Requirements::RequirementCheck;
        end #derive dischargeTemperatureCeiling : Requirements::RequirementCheck;
        end #derive dischargeVoltageCeiling : Requirements::RequirementCheck;
        end #derive dischargePackCeiling : Requirements::RequirementCheck;
        end #derive voltageDeratingCalibrationQualification : Requirements::RequirementCheck;
    }
    #derivation connection operatingClassificationDerivation : OperatingClassificationDerivation {
        end original ::> X2CityComponent_BatteryControl::batteryOperatingClassification;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        end chargePathCapability ::> X2CityComponent_BatterySupervision::chargePathCapability;
        end dischargePathCapability ::> X2CityComponent_BatterySupervision::dischargePathCapability;
        end bmsMosDisabledStatus ::> X2CityComponent_BatterySupervision::bmsMosDisabledStatus;
        end batteryFaultRecognition ::> X2CityComponent_BatterySupervision::batteryFaultRecognition;
        end localThermalFaultRecognition ::> X2CityComponent_BatterySupervision::localThermalFaultRecognition;
        end batteryFaultRetainedEffect ::> X2CityComponent_BatterySupervision::batteryFaultRetainedEffect;
        end batteryStatusPublication ::> X2CityComponent_BatterySupervision::batteryStatusPublication;
        end batteryStatusRestart ::> X2CityComponent_BatterySupervision::batteryStatusRestart;
        end startupCapacityReference ::> X2CityComponent_BatterySupervision::startupCapacityReference;
        end regenerativeBaseCurrent ::> X2CityComponent_BatterySupervision::regenerativeBaseCurrent;
        end regenerativeTemperatureCeiling ::> X2CityComponent_BatterySupervision::regenerativeTemperatureCeiling;
        end regenerativeVoltageCeiling ::> X2CityComponent_BatterySupervision::regenerativeVoltageCeiling;
        end regenerativePackCeiling ::> X2CityComponent_BatterySupervision::regenerativePackCeiling;
        end dischargeBaseCurrent ::> X2CityComponent_BatterySupervision::dischargeBaseCurrent;
        end dischargeTemperatureCeiling ::> X2CityComponent_BatterySupervision::dischargeTemperatureCeiling;
        end dischargeVoltageCeiling ::> X2CityComponent_BatterySupervision::dischargeVoltageCeiling;
        end dischargePackCeiling ::> X2CityComponent_BatterySupervision::dischargePackCeiling;
        end voltageDeratingCalibrationQualification ::> X2CityComponent_BatterySupervision::voltageDeratingCalibrationQualification;
    }

    #derivation connection def ChargeRestrictionDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
    }
    #derivation connection chargeRestrictionDerivation : ChargeRestrictionDerivation {
        end original ::> X2CityComponent_BatteryControl::dischargePermissiveChargeRestriction;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
    }
}
