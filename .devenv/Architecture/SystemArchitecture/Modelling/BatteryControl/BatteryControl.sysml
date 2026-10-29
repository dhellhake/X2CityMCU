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
        doc /* One available BMS temperature reading. probeIdentifier is its 1-based Basic (0x03) source ordinal: 1=MOS, 2=T1, 3=T2 (physical probe at the centre of the cell pack). Availability does not imply seventy cell sensors. */
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
        doc /* Logical reporting contract: battery fault, ordinary at-least-one-MOS-disabled warning, and
            lowDischargeVoltageWarning are independent, simultaneous conditions. Each has
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
            flag. Effective limits are finite, nonnegative ordinary operating ceilings calculated from the selected
            temperature and voltage curves, subject to path status, qualification and retained faults. Physical
            current protection is configured in the supplied BMS and is distinct from these operating ceilings.
            A qualified zero limit means known zero capability; it is not missing information or a fault. Qualification remains authoritative: when
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
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Source: DEC-BAT-002; BAT-001; PD CON-041–042, §10.8.
            Planned verification: I, T-SYS. Reconcile the installed removable pack and its BMS against BAT-001 and record the observed configuration.
            Open: initial bay fit, effective configuration and interface qualification remain under OI-040/041/062.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatteryAssembly::assemblySelectionRequirements;
        require constraint {
            doc /*
                BatteryControl shall use the owner-selected removable 14S5P Samsung INR18650-35E battery
                assembly with the JBD SP14S004 BMS and UART interface, as defined in BAT-001.
            */
        }
    }
    satisfy removableBatteryAssemblySelection by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-002'> integratedBmsConfiguration : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Acceptance criteria: [configuration baseline](Battery_Integration.md#configuration-acceptance-baseline) and
            [SOC source acceptance](Battery_Integration.md#soc-source-acceptance).
            Sources: PD OI-041/061 and CON-048–050; [BAT-001](../../../../Battery/BAT-001_Selected_Pack_and_BMS.md); configuration and SOC acceptance criteria.
            Planned verification: I, A, T-SYS. Review accepted commissioning configuration and integration evidence against the referenced criteria for the fixed 14S5P35E pack.
            Open: effective settings, margins, calibration and acceptance evidence remain under OI-041/049/061.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatteryAssembly::assemblyConfigurationRequirements;
        require X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
        require constraint {
            doc /*
                BatteryControl shall integrate the selected BMS with an effective configuration accepted
                against the linked pack-configuration and SOC-source criteria for the fixed 14S5P35E assembly.
            */
        }
            require X2CityComponent_BatterySupervision::bmsGroupCountQualification;
    }
    satisfy integratedBmsConfiguration by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-003'> batteryInterfaceProvision : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: PD OI-041/047/061; [BAT-001 UART information contract](../../../../Battery/BAT-001_Selected_Pack_and_BMS.md); [selected-unit read acceptance](Decomposition/BMS_Information.md#selected-unit-uart-read-acceptance-contract) and
            [per-consumer acceptance](Battery_Integration.md#per-consumer-information-acceptance) criteria; SOC/fault integration policy.
            Planned verification: I, T-SYS. Check acquisition and internal qualification of required source fields
            against the cited contracts; separately observe actual SOC and signed pack current at their published
            interfaces and compare values and validity with independent references.
            Open: installed schema, accuracy, supported fields and source timing remain to be qualified under
            WS-OI-005/018/019 and OI-041/049. Signed current is positive when charging and negative when
            discharging; reported RSOC alone does not establish actual SOC.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatteryAssembly::assemblySourceInformationRequirements;
        require X2CityComponent_BatterySupervision::bmsObservationIdentity;
        require X2CityComponent_BatterySupervision::actualSocQualification;
        require X2CityComponent_BatterySupervision::bmsPackCurrentPublication;
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
                BatteryControl shall acquire and internally qualify each selected BMS source observation
                required for battery supervision against its applicable source and consumer acceptance
                criteria.
            */
        }
            require X2CityComponent_BatterySupervision::bmsBasicScaleQualification;
        require X2CityComponent_BatterySupervision::bmsGroupCountQualification;
        require X2CityComponent_BatterySupervision::bmsQualificationWithdrawal;
        require X2CityComponent_BatterySupervision::bmsOutstandingRequestLimit;
        require X2CityComponent_BatterySupervision::bmsReadRetrySchedule;
        require X2CityComponent_BatterySupervision::bmsOutputPublicationTiming;
        require X2CityComponent_BatterySupervision::bmsIdentityRequestSchedule;
        require X2CityComponent_BatterySupervision::bmsPackCurrentPublication;
    }
    satisfy batteryInterfaceProvision by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-006'> batteryStartupQualification : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: [REQ-SYS-STA-006](../../../../Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-006); BATSUP-001/002; BMSIF-005; BAT-001.
            Planned verification: T-SYS, T-FI. At normal and unexpected restart, withhold or invalidate startup
            and branch input evidence; verify branch qualification and effective current outputs before and after
            required evidence passes.
            Open: per-consumer source and protection qualification remain under OI-041/049/061 and
            WS-OI-007/018/019.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::bmsStartupChecks;
        require X2CityComponent_BatterySupervision::operatingLimitQualification;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
        require constraint {
            doc /*
                Following each controller startup or restart, BatteryControl shall keep each discharge or
                regenerative-charge assessment unqualified, with zero effective current, until that assessment’s
                required startup checks and input qualification have passed.
            */
        }
            require X2CityComponent_BatterySupervision::startupRequiredEvidenceDeadline;
    }
    satisfy batteryStartupQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-007'> batteryOperatingClassification : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: REQ-SYS-BMS-005; BAT-001; DEC-FLT-005–009 and DEC-TMP-001–003.
            Planned verification: A, T-SYS, T-FI. Exercise qualified and unqualified branch inputs and ordinary
            restrictions; compare each published effective current limit with its applicable assessment.
            Open: recognition coverage, timing, physical protection correspondence and configuration-specific
            acceptance remain under OI-041/049/061.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::chargePathCapability;
        require X2CityComponent_BatterySupervision::dischargePathCapability;
        require X2CityComponent_BatterySupervision::batteryFaultRecognition;
        require X2CityComponent_BatterySupervision::batteryFaultRetainedEffect;
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
                BatteryControl shall publish independently qualified effective current limits for regenerative
                charge and discharge based on their applicable battery operating assessments.
            */
        }
            require X2CityComponent_BatterySupervision::cyclicRequiredEvidenceFault;
        require X2CityComponent_BatterySupervision::capacityReferenceRetention;
        require X2CityComponent_BatterySupervision::batteryStatusNotFunctionalInput;
    }
    satisfy batteryOperatingClassification by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-010'> batteryStatusReporting : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Parent: [REQ-SYS-BMS-003](BatteryControl.sysml). Source: [REQ-SYS-BMS-005](Battery_Integration.md#req-sys-bms-005),
            BAT-001 and DEC-FLT-005–009.
            Planned verification: I, T-SYS. Observe BatteryStatus at its BatteryControl-to-RidingControl
            interface for current, cleared and unknown battery conditions; verify the data are available for
            downstream reporting without battery-local code selection or priority.
            Open: physical delivery and end-to-end reporting timing remain subject to validation under OI-041/049.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::bmsMosDisabledStatus;
        require X2CityComponent_BatterySupervision::batteryFaultRecognition;
        require X2CityComponent_BatterySupervision::batteryStatusPublication;
        require X2CityComponent_BatterySupervision::batteryStatusRestart;
        require X2CityComponent_BatterySupervision::batteryFaultReportEvidence;
        require X2CityComponent_BatterySupervision::lowDischargeVoltageStatus;
        require constraint {
            doc /*
                BatteryControl shall provide RidingControl with BatteryStatus containing the qualified
                battery-fault, MOS-warning and low-discharge-voltage conditions, preserving unknown
                qualification where applicable.
            */
        }
    }
    satisfy batteryStatusReporting by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-BMS-008'> dischargePermissiveChargeRestriction : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: REQ-SYS-BMS-001; REQ-SYS-REG-001; DEC-TMP-003.
            Planned verification: A, T-SYS. With qualified cell temperatures that permit discharge but exclude charge, verify charge capability is zero and otherwise eligible discharge capability remains available, subject to other restrictions.
            Open: integrated thermal margins and coverage remain under WS-OI-005/019.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require constraint {
            doc /*
                When qualified cell temperature permits discharge but not charging, BatteryControl shall
                report zero qualified regenerative-charge current capability while preserving any otherwise
                qualified discharge capability, subject to other applicable restrictions.
            */
        }
    }
    satisfy dischargePermissiveChargeRestriction by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-003'> dischargeVoltageCutoff : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: DEC-SOC-001; PD CON-048; OI-061.
            Planned verification: T-SYS with propulsion demand and auxiliary loads at and around the validated discharge-voltage endpoint.
            Open: endpoint and measurement acceptance remain controlled by the discharge-voltage calibration and OI-061.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::dischargeVoltageCeiling;
        require X2CityComponent_BatterySupervision::dischargePackCeiling;
        require constraint {
            doc /*
                At or below the validated discharge cutoff voltage of the lowest qualified series group,
                BatteryControl shall set total battery discharge current capability to zero, including
                auxiliary loads. Abrupt withdrawal is permitted in every riding level without a comfort fade.
            */
        }
    }
    satisfy dischargeVoltageCutoff by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-004'> currentBranchIndependence : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: DEC-SOC-001; DEC-REG-001/006; DEC-SPD-001.
            Planned verification: A, T-SYS. Vary required charge-only and discharge-only evidence independently and verify the unaffected branch retains its own qualified outcome, subject to shared constraints and recognized common faults.
            Open: branch input acceptance remains under the applicable BatterySupervision requirements.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require constraint {
            doc /*
                BatteryControl shall assess regenerative-charge and discharge capability independently against
                their respective qualified operating evidence, subject to shared constraints and recognized
                common faults.
            */
        }
    }
    satisfy currentBranchIndependence by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-SOC-005'> dischargeVoltageRecovery : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Source: DEC-SOC-001.
            Planned verification: T-SYS at and just above the validated lowest-group discharge cutoff, including startup and concurrent restrictions.
            Open: positive response acceptance follows REQ-SYS-SOC-008 and the validated discharge-voltage calibration.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::dischargeVoltageCeiling;
        require X2CityComponent_BatterySupervision::dischargePackCeiling;
        require constraint {
            doc /*
                When the lowest qualified series-group voltage rises strictly above the validated discharge
                cutoff, BatteryControl shall allow the discharge-voltage restriction to recover automatically,
                subject to other applicable limits.
            */
        }
    }
    satisfy dischargeVoltageRecovery by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-REG-002'> regenerativeVoltageCutoff : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: DEC-REG-001/004; PD CON-048; OI-061.
            Planned verification: A, T-SYS at and around the calibrated highest-group charge cutoff in each
            regenerative level, with other limits varied independently.
            Open: endpoint and measurement acceptance remain subject to product validation under OI-061;
            4.10 V is a provisional endpoint, not an accepted fixed value.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::regenerativeVoltageCeiling;
        require X2CityComponent_BatterySupervision::regenerativePackCeiling;
        require constraint {
            doc /*
                At or above the calibrated charge cutoff voltage of the highest qualified series group,
                BatteryControl shall set regenerative-charge current capability to zero. Abrupt withdrawal is
                permitted in riding Levels 1–5 without an anticipatory comfort fade.
            */
        }
    }
    satisfy regenerativeVoltageCutoff by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

    requirement <'REQ-SYS-REG-012'> regenerativeVoltageRecovery : SystemRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-CONTROL.
            Sources: DEC-REG-001/004; OI-061. This top-level System Requirement has no System Requirement parent.
            Planned verification: A, T-SYS. Approach the calibrated highest-group charge cutoff from above and
            below with qualified voltage, temperature and path evidence; verify battery capability follows the
            voltage curve without requiring restart or an extra enable action.
            Open: endpoint, measurement accuracy and accepted response remain subject to product validation.
            RidingControl's separate regenerative re-entry guards continue to govern application of torque.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        require X2CityComponent_BatterySupervision::regenerativeVoltageCeiling;
        require X2CityComponent_BatterySupervision::regenerativePackCeiling;
        require constraint {
            doc /*
                When the highest qualified series-group voltage falls below the calibrated charge cutoff,
                BatteryControl shall allow the regenerative-voltage restriction to recover automatically,
                subject to other applicable limits.
            */
        }
    }
    satisfy regenerativeVoltageRecovery by X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;

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
            require X2CityComponent_BatteryControl::batteryStatusReporting;
        require X2CityComponent_BatteryControl::regenerativeVoltageRecovery;
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

    #derivation connection def RegenerativeVoltageRecoveryDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive regenerativeVoltageCeiling : Requirements::RequirementCheck;
        end #derive regenerativePackCeiling : Requirements::RequirementCheck;
    }
    #derivation connection regenerativeVoltageRecoveryDerivation : RegenerativeVoltageRecoveryDerivation {
        end original ::> X2CityComponent_BatteryControl::regenerativeVoltageRecovery;
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
            end #derive bmsGroupCountQualification : Requirements::RequirementCheck;
        end #derive effectiveBmsCurrentProtection : Requirements::RequirementCheck;
        end #derive effectiveBmsTemperatureProtection : Requirements::RequirementCheck;
    }
    #derivation connection bmsConfigurationDerivation : BmsConfigurationDerivation {
        end original ::> X2CityComponent_BatteryControl::integratedBmsConfiguration;
        end effectiveConfiguration ::> X2CityComponent_Bms::effectiveBmsConfiguration;
        end bmsBasicInformationDecoding ::> X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
        end startupAssessment ::> X2CityComponent_BatteryControl::batteryStartupQualification;
            end bmsGroupCountQualification ::> X2CityComponent_BatterySupervision::bmsGroupCountQualification;
        end effectiveBmsCurrentProtection ::> X2CityComponent_Bms::effectiveBmsCurrentProtection;
        end effectiveBmsTemperatureProtection ::> X2CityComponent_Bms::effectiveBmsTemperatureProtection;
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
            end #derive bmsBasicScaleQualification : Requirements::RequirementCheck;
        end #derive bmsGroupCountQualification : Requirements::RequirementCheck;
        end #derive bmsQualificationWithdrawal : Requirements::RequirementCheck;
        end #derive bmsOutstandingRequestLimit : Requirements::RequirementCheck;
        end #derive bmsReadRetrySchedule : Requirements::RequirementCheck;
        end #derive bmsOutputPublicationTiming : Requirements::RequirementCheck;
        end #derive bmsIdentityRequestSchedule : Requirements::RequirementCheck;
        end #derive bmsPackCurrentPublication : Requirements::RequirementCheck;
        end #derive statusReporting : Requirements::RequirementCheck;
    }
    #derivation connection bmsInterfaceDerivation : BmsInterfaceDerivation {
        end original ::> X2CityComponent_BatteryControl::batteryInterfaceProvision;
        end measurementSources ::> X2CityComponent_Bms::bmsMeasurementSources;
        end informationQualification ::> X2CityComponent_BatterySupervision::bmsObservationIdentity;
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
            end bmsBasicScaleQualification ::> X2CityComponent_BatterySupervision::bmsBasicScaleQualification;
        end bmsGroupCountQualification ::> X2CityComponent_BatterySupervision::bmsGroupCountQualification;
        end bmsQualificationWithdrawal ::> X2CityComponent_BatterySupervision::bmsQualificationWithdrawal;
        end bmsOutstandingRequestLimit ::> X2CityComponent_BatterySupervision::bmsOutstandingRequestLimit;
        end bmsReadRetrySchedule ::> X2CityComponent_BatterySupervision::bmsReadRetrySchedule;
        end bmsOutputPublicationTiming ::> X2CityComponent_BatterySupervision::bmsOutputPublicationTiming;
        end bmsIdentityRequestSchedule ::> X2CityComponent_BatterySupervision::bmsIdentityRequestSchedule;
        end bmsPackCurrentPublication ::> X2CityComponent_BatterySupervision::bmsPackCurrentPublication;
        end statusReporting ::> X2CityComponent_BatteryControl::batteryStatusReporting;
    }

    #derivation connection def StartupQualificationDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive bmsStartupChecks : Requirements::RequirementCheck;
        end #derive operatingLimitQualification : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive bmsBasicInformationDecoding : Requirements::RequirementCheck;
            end #derive startupRequiredEvidenceDeadline : Requirements::RequirementCheck;
    }
    #derivation connection startupQualificationDerivation : StartupQualificationDerivation {
        end original ::> X2CityComponent_BatteryControl::batteryStartupQualification;
        end bmsStartupChecks ::> X2CityComponent_BatterySupervision::bmsStartupChecks;
        end operatingLimitQualification ::> X2CityComponent_BatterySupervision::operatingLimitQualification;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        end bmsBasicInformationDecoding ::> X2CityComponent_BatterySupervision::bmsBasicInformationDecoding;
            end startupRequiredEvidenceDeadline ::> X2CityComponent_BatterySupervision::startupRequiredEvidenceDeadline;
    }

    #derivation connection def OperatingClassificationDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive batteryCapabilityPolicy : Requirements::RequirementCheck;
        end #derive chargePathCapability : Requirements::RequirementCheck;
        end #derive dischargePathCapability : Requirements::RequirementCheck;

        end #derive batteryFaultRecognition : Requirements::RequirementCheck;
        end #derive batteryFaultRetainedEffect : Requirements::RequirementCheck;

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
            end #derive cyclicRequiredEvidenceFault : Requirements::RequirementCheck;
        end #derive capacityReferenceRetention : Requirements::RequirementCheck;
        end #derive batteryStatusNotFunctionalInput : Requirements::RequirementCheck;
    }
    #derivation connection operatingClassificationDerivation : OperatingClassificationDerivation {
        end original ::> X2CityComponent_BatteryControl::batteryOperatingClassification;
        end batteryCapabilityPolicy ::> X2CityComponent_BatterySupervision::batteryCapabilityPolicy;
        end chargePathCapability ::> X2CityComponent_BatterySupervision::chargePathCapability;
        end dischargePathCapability ::> X2CityComponent_BatterySupervision::dischargePathCapability;

        end batteryFaultRecognition ::> X2CityComponent_BatterySupervision::batteryFaultRecognition;
        end batteryFaultRetainedEffect ::> X2CityComponent_BatterySupervision::batteryFaultRetainedEffect;

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
            end cyclicRequiredEvidenceFault ::> X2CityComponent_BatterySupervision::cyclicRequiredEvidenceFault;
        end capacityReferenceRetention ::> X2CityComponent_BatterySupervision::capacityReferenceRetention;
        end batteryStatusNotFunctionalInput ::> X2CityComponent_BatterySupervision::batteryStatusNotFunctionalInput;
    }

    #derivation connection def BatteryStatusReportingDerivation {
        end #original original : Requirements::RequirementCheck;
        end #derive bmsMosDisabledStatus : Requirements::RequirementCheck;
        end #derive batteryFaultRecognition : Requirements::RequirementCheck;
        end #derive batteryStatusPublication : Requirements::RequirementCheck;
        end #derive batteryStatusRestart : Requirements::RequirementCheck;
        end #derive batteryFaultReportEvidence : Requirements::RequirementCheck;
        end #derive lowDischargeVoltageStatus : Requirements::RequirementCheck;
    }
    #derivation connection batteryStatusReportingDerivation : BatteryStatusReportingDerivation {
        end original ::> X2CityComponent_BatteryControl::batteryStatusReporting;
        end bmsMosDisabledStatus ::> X2CityComponent_BatterySupervision::bmsMosDisabledStatus;
        end batteryFaultRecognition ::> X2CityComponent_BatterySupervision::batteryFaultRecognition;
        end batteryStatusPublication ::> X2CityComponent_BatterySupervision::batteryStatusPublication;
        end batteryStatusRestart ::> X2CityComponent_BatterySupervision::batteryStatusRestart;
        end batteryFaultReportEvidence ::> X2CityComponent_BatterySupervision::batteryFaultReportEvidence;
        end lowDischargeVoltageStatus ::> X2CityComponent_BatterySupervision::lowDischargeVoltageStatus;
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
