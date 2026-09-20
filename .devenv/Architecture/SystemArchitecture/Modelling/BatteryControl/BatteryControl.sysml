package X2CityContract_BatteryControl {
    private import X2CitySharedContracts::*;

    attribute def FaultRecognitionOrder {
        doc /* Comparable recognition ordering shared with SessionPolicy fault evidence. Zero means not recognized; equal non-zero values mean indistinguishable recognition order and require SessionPolicy's established tie rule. The ordering is not a BMS measurement timestamp or a battery-local sequence. */
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
        doc /* Current startup assessment and recognized battery fault evidence for SessionPolicy under BMS-005/006/007. Thermal and other battery fault categories stay distinct; recognition order supports SessionPolicy's existing first-recognized reporting rule without preselecting a display fault. */
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
        doc /* BatterySupervision's qualified actual SOC for HMI display and SessionPolicy's low-charge selection. It is distinct from the supplied BMS candidate SOC. */
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
    port def BatteryReadinessAndFaultOutputPort { doc /* Publishes startup assessment and separate recognized thermal/battery fault evidence to SessionPolicy. */ out item readinessAndFault:BatteryReadinessAndFault; }
    port def BatteryReadinessAndFaultInputPort { doc /* Receives startup assessment and separate recognized thermal/battery fault evidence at SessionPolicy. */ in item readinessAndFault:BatteryReadinessAndFault; }
    port def BatteryOperatingLimitsOutputPort { doc /* Publishes independently qualified discharge, regenerative-charge, and SOC-positive-propulsion limits to DemandPolicy. */ out item operatingLimits:BatteryOperatingLimits; }
    port def BatteryOperatingLimitsInputPort { doc /* Receives independently qualified discharge, regenerative-charge, and SOC-positive-propulsion limits at DemandPolicy. */ in item operatingLimits:BatteryOperatingLimits; }
    port def BatteryStateOfChargeOutputPort { doc /* Publishes qualified actual SOC to HmiAdapter or SessionPolicy. */ out item stateOfCharge:BatteryStateOfCharge; }
    port def BatteryStateOfChargeInputPort { doc /* Receives qualified actual SOC at HmiAdapter or SessionPolicy. */ in item stateOfCharge:BatteryStateOfCharge; }
    port def BatteryCurrentOutputPort { doc /* Publishes qualified signed pack current to HmiAdapter. */ out item batteryCurrent:BatteryCurrent; }
    port def BatteryCurrentInputPort { doc /* Receives qualified signed pack current at HmiAdapter. */ in item batteryCurrent:BatteryCurrent; }

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

    part def BatteryControl { // LE-BATTERY-CONTROL
        doc /* EPCS battery composite. It contains exactly the removable physical BatteryAssembly and vehicle-host BatterySupervision, separating supplied BMS protection from project read/qualification and operating policy. */
        part batteryAssembly:BatteryAssembly { doc /* The sole removable physical 14S5P pack assembly. */ }
        part batterySupervision:BatterySupervision { doc /* Project vehicle-host supervision for BMS reading, qualification, and battery operating policy. */ }
        port batteryPower:BatteryPowerPort { doc /* External physical bidirectional pack-to-EnergyPath boundary for discharge and regeneration. */ }
        port batteryReadinessAndFaultOut:BatteryReadinessAndFaultOutputPort { doc /* External SessionPolicy evidence for startup and recognized battery faults. */ }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort { doc /* External DemandPolicy operating limits including both current-sign branches and SOC caps. */ }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort { doc /* External qualified actual-SOC publication for HMI and SessionPolicy. */ }
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
}
