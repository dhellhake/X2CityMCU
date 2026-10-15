package X2CityContract_BatteryControl {
    private import X2CitySharedContracts::*;

    attribute def FaultRecognitionOrder {
        doc /* Comparable recognition ordering shared with RidingControl fault evidence. Zero means not recognized; equal non-zero values mean indistinguishable recognition order and require RidingControl's established tie rule. The ordering is not a BMS measurement timestamp or a battery-local sequence. */
    }

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
        doc /* Reported BMS identity/configuration evidence needed by BMSIF-001 to qualify source SOC against the fixed compiled configuration. Remaining/full capacity, series-group count, and version are Basic (0x03) evidence; reportedBmsIdentity is only Identity (0x05) evidence. A response carries only its applicable evidence and does not establish calibration, capacity acceptance, or a BMS write/configuration action. */
        attribute reportedRemainingCapacityAmpereHours:Real[0..1];
        attribute reportedFullCapacityAmpereHours:Real[0..1];
        attribute reportedSeriesGroupCount:Integer[0..1];
        attribute reportedBmsIdentity:String[0..1];
        attribute reportedBmsVersion:String[0..1];
    }
    item def BmsFieldUpdateReferences {
        doc /* Host-monotonic references of each last accepted source-field update. The shared assessment reference in BatteryMeasurements lets consumers determine each current age after partial frames or queues; none is a BMS measurement timestamp. */
        attribute packVoltageLastAcceptedUpdateReferenceMicroseconds:Integer;
        attribute packCurrentLastAcceptedUpdateReferenceMicroseconds:Integer;
        attribute stateOfChargeCandidateLastAcceptedUpdateReferenceMicroseconds:Integer;
        attribute cellGroupVoltagesLastAcceptedUpdateReferenceMicroseconds:Integer;
        attribute availableTemperaturesLastAcceptedUpdateReferenceMicroseconds:Integer;
        attribute protectionPathStateLastAcceptedUpdateReferenceMicroseconds:Integer;
        attribute basicInfoLastAcceptedUpdateReferenceMicroseconds:Integer;
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
    item def BatteryMeasurements:>QualifiedInformationRecord {
        doc /* BatterySupervision's aggregated, field-qualified projection of BMS-003 source data. Each validity flag is independently assessed: accepting one discriminated source response refreshes only its represented fields and never refreshes other groups or identity. This record deliberately asserts no BMS measurement timestamp or that receipt time is measurement time. */
        attribute packVoltageVolts:Real;
        attribute packVoltageValid:Boolean;
        attribute packCurrentAmperes:Real;
        attribute packCurrentValid:Boolean;
        attribute stateOfChargeCandidatePercent:Real;
        attribute stateOfChargeCandidateValid:Boolean;
        attribute cellGroupVoltagesVolts:Real[14];
        attribute cellGroupVoltagesValid:Boolean;
        item availableTemperatures:TemperatureObservation[*];
        attribute availableTemperaturesValid:Boolean;
        item protectionPathState:ProtectionPathState;
        attribute protectionPathStateValid:Boolean;
        item socSourceEvidence:BmsSocSourceEvidence;
        attribute socSourceEvidenceValid:Boolean;
        attribute assessmentReferenceMicroseconds:Integer { doc /* Host-monotonic publication/qualification reference. A consumer supplies its current caller reference to determine current age; this stored value is not a live clock or BMS measurement time. */ }
        item fieldUpdateReferences:BmsFieldUpdateReferences;
    }
    item def BatteryReadinessAndFault:>QualifiedInformationRecord {
        doc /* Current startup assessment and recognized battery fault evidence for RidingControl under BMS-005/006/007. Thermal and other battery fault categories stay distinct; recognition order supports RidingControl's existing first-recognized reporting rule without preselecting a display fault. */
        attribute startupChecksPassed:Boolean;
        attribute thermalFaultRecognized:Boolean;
        attribute thermalFaultRecognitionOrder:FaultRecognitionOrder;
        attribute batteryFaultRecognized:Boolean;
        attribute batteryFaultRecognitionOrder:FaultRecognitionOrder;
    }
    item def BatteryOperatingLimits:>QualifiedInformationRecord {
        doc /* BatterySupervision's independently qualified discharge and regenerative-charge operating branches under BMSPOL-001. Positive wheel-torque SOC caps for SOC-001 through SOC-006 are separate from electrical power-flow sign; the reached-10-percent latch remains internal until actual SOC exceeds 20 percent. */
        attribute dischargeBranchQualified:Boolean;
        attribute dischargePermitted:Boolean;
        attribute dischargeCurrentLimitAmperes:Real;
        attribute dischargeRestrictionActive:Boolean;
        attribute dischargeRestrictionReason:Integer;
        attribute positivePropulsionPermitted:Boolean;
        attribute positiveTorqueLimitNewtonMetres:Real;
        attribute positiveSpeedLimitKilometresPerHour:Real;
        attribute regenerativeChargeBranchQualified:Boolean;
        attribute regenerativeChargePermitted:Boolean;
        attribute regenerativeChargeCurrentLimitAmperes:Real;
        attribute regenerativeChargeRestrictionActive:Boolean;
        attribute regenerativeChargeRestrictionReason:Integer;
    }
    item def BatteryStateOfCharge:>QualifiedInformationRecord {
        doc /* BatterySupervision's qualified actual SOC for HMI display and RidingControl's low-charge selection. It is distinct from the supplied BMS candidate SOC. */
        attribute actualStateOfChargePercent:Real;
    }
    item def BatteryCurrent:>QualifiedInformationRecord {
        doc /* BatterySupervision's qualified signed pack current in amperes for HMI-020. Positive/negative sign interpretation follows the project pack-current convention; it is not a torque value. */
        attribute signedPackCurrentAmperes:Real;
    }

    port def BatteryPowerPort { doc /* Physical bidirectional battery-power connection between BatteryControl and EnergyPath. */ inout item batteryPower:BatteryPower; }
    port def BmsReadRequestOutputPort { doc /* Sends a read-only UART information request from BatterySupervision to the supplied BMS. */ out item request:BmsReadRequest; }
    port def BmsReadRequestInputPort { doc /* Receives a read-only UART information request at the supplied BMS. */ in item request:BmsReadRequest; }
    port def BmsTelemetryOutputPort { doc /* Sends selected BMS source fields from the supplied BMS to BatterySupervision over the read-only UART route. */ out item telemetry:BmsTelemetry; }
    port def BmsTelemetryInputPort { doc /* Receives selected BMS source fields at BatterySupervision for qualification. */ in item telemetry:BmsTelemetry; }
    port def BatteryMeasurementsOutputPort { doc /* Sends BmsLink's qualified BMS measurements to BatteryProtection's operating-policy realization inside BatterySupervision. */ out item measurements:BatteryMeasurements; }
    port def BatteryMeasurementsInputPort { doc /* Receives BmsLink's qualified BMS measurements at BatteryProtection's operating-policy realization inside BatterySupervision. */ in item measurements:BatteryMeasurements; }
    port def BatteryReadinessAndFaultOutputPort { doc /* Publishes startup assessment and separate recognized thermal/battery fault evidence to RidingControl. */ out item readinessAndFault:BatteryReadinessAndFault; }
    port def BatteryReadinessAndFaultInputPort { doc /* Receives startup assessment and separate recognized thermal/battery fault evidence at RidingControl. */ in item readinessAndFault:BatteryReadinessAndFault; }
    port def BatteryOperatingLimitsOutputPort { doc /* Publishes independently qualified discharge, regenerative-charge, and SOC-positive-propulsion limits to RidingControl. */ out item operatingLimits:BatteryOperatingLimits; }
    port def BatteryOperatingLimitsInputPort { doc /* Receives independently qualified discharge, regenerative-charge, and SOC-positive-propulsion limits at RidingControl. */ in item operatingLimits:BatteryOperatingLimits; }
    port def BatteryStateOfChargeOutputPort { doc /* Publishes qualified actual SOC to HMIControl or RidingControl. */ out item stateOfCharge:BatteryStateOfCharge; }
    port def BatteryStateOfChargeInputPort { doc /* Receives qualified actual SOC at HMIControl or RidingControl. */ in item stateOfCharge:BatteryStateOfCharge; }
    port def BatteryCurrentOutputPort { doc /* Publishes qualified signed pack current to HMIControl. */ out item batteryCurrent:BatteryCurrent; }
    port def BatteryCurrentInputPort { doc /* Receives qualified signed pack current at HMIControl. */ in item batteryCurrent:BatteryCurrent; }

    interface def IfA003BatteryReadinessAndFault { end producer:BatteryReadinessAndFaultOutputPort; end consumer:BatteryReadinessAndFaultInputPort; flow producer.readinessAndFault to consumer.readinessAndFault; }
    interface def IfA003BatteryOperatingLimits { end producer:BatteryOperatingLimitsOutputPort; end consumer:BatteryOperatingLimitsInputPort; flow producer.operatingLimits to consumer.operatingLimits; }
    interface def IfA003BatteryStateOfCharge { end producer:BatteryStateOfChargeOutputPort; end consumer:BatteryStateOfChargeInputPort; flow producer.stateOfCharge to consumer.stateOfCharge; }
    interface def IfA003BatteryCurrent { end producer:BatteryCurrentOutputPort; end consumer:BatteryCurrentInputPort; flow producer.batteryCurrent to consumer.batteryCurrent; }
    interface def IfA009BmsReadRequest { end producer:BmsReadRequestOutputPort; end consumer:BmsReadRequestInputPort; flow producer.request to consumer.request; }
    interface def IfA009BmsTelemetry { end producer:BmsTelemetryOutputPort; end consumer:BmsTelemetryInputPort; flow producer.telemetry to consumer.telemetry; }
    interface def IfA009BatteryMeasurements { end producer:BatteryMeasurementsOutputPort; end consumer:BatteryMeasurementsInputPort; flow producer.measurements to consumer.measurements; }
    interface def IfA010BatteryPower { end batteryControl:BatteryPowerPort; end energyPath:BatteryPowerPort; flow batteryControl.batteryPower to energyPath.batteryPower; flow energyPath.batteryPower to batteryControl.batteryPower; }
}

package X2CityComponent_BatteryControl {
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_BatteryAssembly::*;
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::SystemRequirement;

    part def BatteryControl { // LE-BATTERY-CONTROL
        doc /* EPCS battery composite. It contains exactly the removable physical BatteryAssembly and vehicle-host BatterySupervision, separating supplied BMS protection from project read/qualification and operating policy. */
        part batteryAssembly:BatteryAssembly { doc /* The sole removable physical 14S5P pack assembly. */ }
        part batterySupervision:BatterySupervision { doc /* Project vehicle-host supervision for BMS reading, qualification, and battery operating policy. */ }
        port batteryPower:BatteryPowerPort { doc /* External physical bidirectional pack-to-EnergyPath boundary for discharge and regeneration. */ }
        port batteryReadinessAndFaultOut:BatteryReadinessAndFaultOutputPort { doc /* External RidingControl evidence for startup and recognized battery faults. */ }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort { doc /* External RidingControl operating limits including both current-sign branches and SOC caps. */ }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort { doc /* External qualified actual-SOC publication for HMI and RidingControl. */ }
        port batteryCurrentOut:BatteryCurrentOutputPort { doc /* External qualified signed-current publication for HMI. */ }
        flow assemblyPowerToBoundary from batteryAssembly.batteryPower.batteryPower to batteryPower.batteryPower;
        flow boundaryPowerToAssembly from batteryPower.batteryPower to batteryAssembly.batteryPower.batteryPower;
        interface bmsReadRequestToAssembly : IfA009BmsReadRequest
            connect batterySupervision.bmsReadRequestOut to batteryAssembly.bms.bmsReadRequestIn;
        interface bmsTelemetryFromAssembly : IfA009BmsTelemetry
            connect batteryAssembly.bms.bmsTelemetryOut to batterySupervision.bmsTelemetryIn;
        flow readinessFromSupervision from batterySupervision.batteryReadinessAndFaultOut.readinessAndFault to batteryReadinessAndFaultOut.readinessAndFault;
        flow limitsFromSupervision from batterySupervision.batteryOperatingLimitsOut.operatingLimits to batteryOperatingLimitsOut.operatingLimits;
        flow socFromSupervision from batterySupervision.stateOfChargeOut.stateOfCharge to stateOfChargeOut.stateOfCharge;
        flow currentFromSupervision from batterySupervision.batteryCurrentOut.batteryCurrent to batteryCurrentOut.batteryCurrent;
    }

    doc /*
    System Requirements allocated to LE-BATTERY-CONTROL. Canonical historical record: REQ-001-R1.6, Approved;
    successor allocation is Draft and integrated acceptance remains open. These approved elaborations implement
    owner-confirmed [DEC-BAT-002](../../../../Requirements/DEC-001_Decisions_and_Open_Issues.md#dec-bat-002).
    [BAT-001](../../../../Battery/BAT-001_Selected_Pack_and_BMS.md) is the canonical component/rating reference; selection and reported initial
    fit are settled. Apply the [REQ-001 model and verification rules](../../../../Requirements/REQ-001_Requirements.md).
    */

    requirement <'REQ-SYS-BAT-002'> removableBatteryAssemblySelection : SystemRequirement {
        doc /*
        Draft successor allocation: LE-BATTERY-CONTROL.
        Sources: PD CON-041–042, §10.8; DEC-BAT-002; BAT-001.
        Planned verification: I, T-SYS. Record cell identity, group construction, selected BMS hardware/firmware/configuration
        identity and working UART readback; reconcile the installed assembly with the owner's configuration.
        Open dependencies / qualifications: OI-040/041/062: construction and initial bay fit are owner-confirmed; BMS
        connection is now owner-confirmed; derive its incomplete configuration and record effective settings/identity
        and complete integration evidence. No cell reselection or invented vendor-internal decomposition required.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require constraint {
            doc /* BatteryControl shall use a removable battery comprising the owner-built 14S5P bank of 70 Samsung INR18650-35E cells and the selected JBD SP14S004P14S50A BMS, with UART as its system communication interface. */
        }
    }

    requirement <'REQ-SYS-BMS-002'> integratedBmsConfiguration : SystemRequirement {
        doc /*
        Draft successor allocation: LE-BATTERY-CONTROL.
        Sources: PD OI-041/061, CON-048–050; BAT-001; [service](../../../../Requirements/System_Requirements/Service_and_Durability.md#req-sys-svc-001).
        Planned verification: I, A, T-SYS. Read and assess actual capacity, voltage/current/temperature thresholds, delays,
        release behavior and balancing settings against cell limits and system reaction budgets; qualify SOC calibration/
        uncertainty within the vehicle policy.
        Open dependencies / qualifications: OI-041/049/061: source family defaults are not accepted operating settings;
        vendor voltage trips or RSOC alone do not implement actual-SOC policy. Determine remaining independent
        protection/diagnostic coverage.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require constraint {
            doc /* BatteryControl shall integrate BMS configuration and supervisory protection compatible with the 14S5P 35E bank, the vehicle actual-SOC policy, regenerative charge acceptance and balancing. Configuration identity and qualified settings shall be available for vehicle integration/service acceptance. */
        }
    }

    requirement <'REQ-SYS-BMS-003'> batteryInterfaceProvision : SystemRequirement {
        doc /*
        Draft successor allocation: LE-BATTERY-CONTROL.
        Sources: PD OI-041/047/061; BAT-001; [input qualification](../../../../Requirements/System_Requirements/Interface_Qualification.md);
        [SOC and fault behavior](../../../../Requirements/System_Requirements/Power_Startup_and_Faults.md).
        Planned verification: I, T-SYS. Exercise the qualified read protocol, expected group/temperature counts, signs/scales,
        malformed/stale/inconsistent data, startup, sleep/wake and interrupted communication. Compare against independent
        references and current-session qualification/fault behavior.
        Open dependencies / qualifications: WS-OI-005/018/019, OI-041/049: verify actual firmware support, accuracy,
        polling/response/freshness and initialization limits. A BMS estimate becomes actual-SOC information only after
        qualification. Fourteen groups and available probes are not complete individual-cell/temperature fault coverage.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require constraint {
            doc /* BatteryControl shall provide qualified pack voltage, signed battery current, actual-SOC information, all 14 series-group voltages, available temperature information and relevant protection/charge/discharge-path state through the selected BMS UART. Values, validity and freshness shall remain distinguishable; unavailable or unqualified data shall not authorize dependent operation. */
        }
    }

    requirement <'REQ-SYS-BMS-006'> batteryStartupQualification : SystemRequirement {
        doc /*
        Draft successor allocation: LE-BATTERY-CONTROL.
        Parents: integratedBmsConfiguration (REQ-SYS-BMS-002) and batteryInterfaceProvision (REQ-SYS-BMS-003),
        both defined in this file; [REQ-SYS-STA-006](../../../../Requirements/System_Requirements/Power_Startup_and_Faults.md#req-sys-sta-006).
        Planned verification: I, A, T-SYS, T-FI. Cover each qualification item independently missing, inconsistent, stale and
        valid; wrong series count/configuration, missing required probe, active protection, expected path disable and actual
        failed path. Verify riding Ready after each applicable restart.
        Open dependencies / qualifications: OI-041/049/061; WS-OI-007/018/019. Use the
        [BMS configuration derivation](../../../../Battery/BAT-001_Selected_Pack_and_BMS.md#bms-configuration-derivation);
        define effective configuration-check evidence and admission/change control where settings are not observable through
        selected telemetry reads. A correct packet/device string is not complete configuration/self-test evidence.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require constraint {
            doc /* Before granting battery-dependent riding permission at startup or restart, BatteryControl shall assess correspondence to the qualified pack/configuration, all 14 series groups, required information validity and current protection/energy-path readiness for riding. An incomplete or failed required assessment shall not produce a passing result. */
        }
    }

    requirement <'REQ-SYS-BMS-007'> batteryOperatingClassification : SystemRequirement {
        doc /*
        Draft successor allocation: LE-BATTERY-CONTROL.
        Parents: batteryInterfaceProvision (REQ-SYS-BMS-003), defined in this file; [REQ-SYS-BMS-005](Battery_Integration.md#req-sys-bms-005).
        Planned verification: I, A, T-SYS, T-FI. Apply the
        [battery event matrix](Battery_Integration.md#battery-event-and-recovery-matrix); contrast normal SOC cutoff with
        weakest-group undervoltage protection, charge-disabled by a known ordinary restriction with unexpected trip, and
        valid status bits with physical path failure. Verify report masking does not change protection.
        Open dependencies / qualifications: DEC-FLT-005–009, DEC-TMP-001–003; OI-041/049/061. Qualify actual BMS flags,
        expected state per operating configuration, recognition timing and observation limitations. No automatic MOS override
        or new fault code is introduced.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require constraint {
            doc /* BatteryControl shall distinguish ordinary initial qualification, normal operating restrictions, expected energy-path states and recognized battery/protection-information faults when determining operating permissions and fault reports. An observed disabled path alone shall not prove either a fault or successful physical isolation; unknown required path/protection status shall not authorize the dependent transfer. */
        }
    }

    requirement <'REQ-SYS-BMS-008'> dischargePermissiveChargeRestriction : SystemRequirement {
        doc /*
        Draft successor allocation: LE-BATTERY-CONTROL.
        Parents: [REQ-SYS-BMS-001](Battery_Integration.md#req-sys-bms-001),
        [REQ-SYS-REG-001](../../../../Requirements/System_Requirements/Rider_Control.md#req-sys-reg-001).
        Planned verification: A, T-SYS. Cover valid cell temperatures below 0°C and above 45°C while within discharge limits,
        each riding level, held regenerative demand, exit/re-entry and standstill recovery. Verify no charging outside its
        envelope, no new fault/availability indication for this restriction, and preserved response to independent faults.
        Open dependencies / qualifications: DEC-TMP-003; WS-OI-005/019. Cell references are discharge −10…60°C and
        charging 0…45°C; qualify stricter integrated margins/coverage. Applicable discharge-limit violations and
        required-temperature-information faults retain both-sign inhibition; forbidden actual charge transfer is not ordinary
        waiting.
        */
        subject batteryControl:BatteryControl = X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl;
        require constraint {
            doc /* When qualified cell temperatures permit discharge but do not permit charging, BatteryControl shall keep propulsion otherwise eligible and make regenerative charging unavailable as an ordinary operating restriction. Clearing that restriction shall use the existing regenerative-capability recovery rules and shall not require a restart solely for this condition. */
        }
    }
}
