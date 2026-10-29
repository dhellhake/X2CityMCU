package X2CityContract_BatteryControl {
    private import X2CitySharedContracts::*;

    item def BatteryPower {
        doc /*
            Physical bidirectional pack-energy-path power boundary. It conveys discharge and regenerative
            charging energy without selecting voltage, conductors, switching, protection topology, or a
            software protection credit.
        */
    }

    enum def BmsReadRecordKind {
        enum Basic;
        enum FourteenGroup;
        enum Identity;
    }

    item def BmsReadRequest {
        doc /*
            A selected UART request for one BMSIF-001 record: Basic, FourteenGroup, or Identity. It is
            read-only: it cannot write configuration, override protection, or command charging.
        */
        attribute recordKind:BmsReadRecordKind;
    }

    item def TemperatureObservation {
        doc /*
            One available BMS temperature reading. probeIdentifier is its 1-based Basic (0x03) source
            ordinal: 1=MOS, 2=T1, 3=T2 (physical probe at the centre of the cell pack). Availability does
            not imply seventy cell sensors.
        */
        attribute probeIdentifier:Integer;
        attribute temperatureCelsius:Real;
    }

    item def ProtectionPathState {
        doc /*
            Supplied BMS protection flags and the independent discharge/charge path states. It is source
            evidence, not a project protection decision.
        */
        attribute protectionFlags:Integer;
        attribute dischargePathEnabled:Boolean;
        attribute chargePathEnabled:Boolean;
    }

    item def BmsSocSourceEvidence {
        doc /*
            Reported BMS identity/configuration evidence needed by BMSIF-001 to qualify source SOC against
            the fixed compiled configuration. Remaining capacity, standard nominal capacity, series-group
            count, and version are Basic (0x03) evidence; nominal capacity is not optional learned FCC and
            requires scale and profile calibration qualification; reportedBmsIdentity is only Identity
            (0x05) evidence. A response carries only its applicable evidence and does not establish
            calibration, capacity acceptance, or a BMS write/configuration action.
        */
        attribute reportedRemainingCapacityAmpereHours:Real[0..1];
        attribute reportedNominalCapacityAmpereHours:Real[0..1];
        attribute reportedSeriesGroupCount:Integer[0..1];
        attribute reportedBmsIdentity:String[0..1];
        attribute reportedBmsVersion:String[0..1];
    }

    item def BmsTelemetry {
        doc /*
            Discriminated supplied BMS source response. Basic (0x03) carries its pack voltage/current,
            candidate SOC, available temperatures, protection/path state, capacity/group-count, and version
            evidence; FourteenGroup (0x04) carries exactly the fourteen group voltages; Identity (0x05)
            carries the device identity. Fields outside the selected recordKind are absent/unavailable,
            never fabricated or treated as current.
        */
        attribute recordKind:BmsReadRecordKind;
        attribute packVoltageVolts:Real[0..1];
        attribute packCurrentAmperes:Real[0..1];
        attribute stateOfChargeCandidatePercent:Real[0..1];
        attribute cellGroupVoltagesVolts:Real[0..14] {
            doc /*
                Present only for FourteenGroup (0x04), which carries all fourteen group voltages.
            */
        }
        item availableTemperatures:TemperatureObservation[0..*];
        item protectionPathState:ProtectionPathState[0..1];
        item socSourceEvidence:BmsSocSourceEvidence[0..1];
    }

    item def BatteryStatus {
        doc /*
            Logical reporting contract: battery fault, ordinary at-least-one-MOS-disabled warning, and
            lowDischargeVoltageWarning are independent, simultaneous conditions. Each has meaningful
            known/unknown state; unknown is not absence. Battery fault includes BMS faults (including BMS
            thermal faults), recognized startup mismatch and recognized required battery-information
            failure. Recognition order is comparable with other RidingControl fault evidence for its
            first-recognized rule. Diagnostic evidence remains available independently of operating-limit
            qualification. This item carries reporting information only; detailed representation is deferred
            to software realization.
        */
    }

    item def BatteryOperatingLimits {
        doc /*
            Independent discharge and regenerative-charge operating branches under BMSPOL-001. Shared
            assessment is internal to BatterySupervision: each branchQualified field includes its own
            applicable shared required checks together with operation-specific checks. Shared assessment is
            not published as a separate validity flag. Effective limits are finite, nonnegative ordinary
            operating ceilings calculated from the selected temperature and voltage curves, subject to path
            status, qualification and retained faults. Physical current protection is configured in the
            supplied BMS and is distinct from these operating ceilings. A qualified zero limit means known
            zero capability; it is not missing information or a fault. Qualification remains authoritative:
            when required current-envelope information is unqualified, the affected effective current limit
            is zero and dependent operation is unavailable. A numeric zero alone never qualifies the limit.
            Battery current sign is not a wheel-torque sign; BatterySupervision assesses each electrical
            current branch independently.
        */
        attribute sourceContext:SourceContext;
        attribute dischargeBranchQualified:Boolean {
            doc /*
                True only while applicable shared and discharge-required current
                evidence/configuration/protection/path assessment supports this branch. It describes
                assessment completeness, not available magnitude; a qualified zero effective current limit
                means known zero discharge capability.
            */
        }
        attribute dischargeCurrentLimitAmperes:Real {
            doc /*
                Finite, nonnegative effective discharge-current ceiling in A.
            */
        }
        attribute dischargeRestrictionActive:Boolean;
        attribute dischargeRestrictionReason:Integer;
        attribute regenerativeChargeBranchQualified:Boolean {
            doc /*
                True only while applicable shared and charge-required current
                evidence/configuration/protection/path assessment supports this branch. Missing charge-only
                evidence does not invalidate an otherwise current discharge branch. It describes assessment
                completeness, not available magnitude; a qualified zero effective current limit means known
                zero charge acceptance.
            */
        }
        attribute regenerativeChargeCurrentLimitAmperes:Real {
            doc /*
                Finite, nonnegative effective regenerative-charge-current ceiling in A.
            */
        }
        attribute regenerativeChargeRestrictionActive:Boolean;
        attribute regenerativeChargeRestrictionReason:Integer;
    }

    item def BatteryStateOfCharge:>QualifiedInformationRecord {
        doc /*
            BatterySupervision's qualified actual SOC for display and range reporting. It is distinct from
            the supplied BMS candidate SOC.
        */
        attribute actualStateOfChargePercent:Real;
    }

    item def BatteryCurrent:>QualifiedInformationRecord {
        doc /*
            BatterySupervision's independently qualified signed pack current in amperes, consumed by
            RidingControl.CurrentConsumptionCoordination for shared-budget supervision and by HMIControl for
            HMI-020. Positive means charging and negative means discharging; this is not a torque value.
            Unavailability is represented by this value's inherited qualification only.
        */
        attribute signedPackCurrentAmperes:Real;
    }

    port def BatteryPowerPort {
        doc /*
            Physical bidirectional battery-power connection between BatteryControl and EnergyPath.
        */
        inout item batteryPower:BatteryPower;
    }

    port def BmsReadRequestOutputPort {
        doc /*
            Sends a read-only UART information request from BatterySupervision to the supplied BMS.
        */
        out item request:BmsReadRequest;
    }

    port def BmsReadRequestInputPort {
        doc /*
            Receives a read-only UART information request at the supplied BMS.
        */
        in item request:BmsReadRequest;
    }

    port def BmsTelemetryOutputPort {
        doc /*
            Sends selected BMS source fields from the supplied BMS to BatterySupervision over the read-only
            UART route.
        */
        out item telemetry:BmsTelemetry;
    }

    port def BmsTelemetryInputPort {
        doc /*
            Receives selected BMS source fields at BatterySupervision for qualification.
        */
        in item telemetry:BmsTelemetry;
    }

    port def BatteryStatusOutputPort {
        doc /*
            Publishes independent battery reporting conditions including lowDischargeVoltageWarning;
            operating qualification and effective limits travel on BatteryOperatingLimits.
        */
        out item status:BatteryStatus;
    }

    port def BatteryStatusInputPort {
        doc /*
            Receives independent battery reporting conditions including lowDischargeVoltageWarning at
            RidingControl.
        */
        in item status:BatteryStatus;
    }

    port def BatteryOperatingLimitsOutputPort {
        doc /*
            Publishes independently qualified total discharge and regenerative-charge current bounds to
            RidingControl and EnergyPath.
        */
        out item operatingLimits:BatteryOperatingLimits;
    }

    port def BatteryOperatingLimitsInputPort {
        doc /*
            Receives independently qualified total discharge and regenerative-charge current bounds at
            RidingControl or EnergyPath.
        */
        in item operatingLimits:BatteryOperatingLimits;
    }

    port def BatteryStateOfChargeOutputPort {
        doc /*
            Publishes qualified actual SOC to HMIControl.
        */
        out item stateOfCharge:BatteryStateOfCharge;
    }

    port def BatteryStateOfChargeInputPort {
        doc /*
            Receives qualified actual SOC at HMIControl.
        */
        in item stateOfCharge:BatteryStateOfCharge;
    }

    port def BatteryCurrentOutputPort {
        doc /*
            Publishes independently qualified signed pack current to
            RidingControl.CurrentConsumptionCoordination and HMIControl.
        */
        out item batteryCurrent:BatteryCurrent;
    }

    port def BatteryCurrentInputPort {
        doc /*
            Receives qualified signed pack current at RidingControl.CurrentConsumptionCoordination or
            HMIControl.
        */
        in item batteryCurrent:BatteryCurrent;
    }

    interface def IfA003BatteryStatus {
        end producer:BatteryStatusOutputPort;
        end consumer:BatteryStatusInputPort;
        flow producer.status to consumer.status;
    }

    interface def IfA003BatteryOperatingLimits {
        end producer:BatteryOperatingLimitsOutputPort;
        end consumer:BatteryOperatingLimitsInputPort;
        flow producer.operatingLimits to consumer.operatingLimits;
    }

    interface def IfA003BatteryStateOfCharge {
        end producer:BatteryStateOfChargeOutputPort;
        end consumer:BatteryStateOfChargeInputPort;
        flow producer.stateOfCharge to consumer.stateOfCharge;
    }

    interface def IfA003BatteryCurrent {
        end producer:BatteryCurrentOutputPort;
        end consumer:BatteryCurrentInputPort;
        flow producer.batteryCurrent to consumer.batteryCurrent;
    }

    interface def IfA009BmsReadRequest {
        end producer:BmsReadRequestOutputPort;
        end consumer:BmsReadRequestInputPort;
        flow producer.request to consumer.request;
    }

    interface def IfA009BmsTelemetry {
        end producer:BmsTelemetryOutputPort;
        end consumer:BmsTelemetryInputPort;
        flow producer.telemetry to consumer.telemetry;
    }

    interface def IfA010BatteryPower {
        end batteryControl:BatteryPowerPort;
        end energyPath:BatteryPowerPort;
        flow batteryControl.batteryPower to energyPath.batteryPower;
        flow energyPath.batteryPower to batteryControl.batteryPower;
    }
}

package X2CityComponent_BatteryControl {
    private import X2CityContract_BatteryControl::*;
    private import X2CityComponent_BatteryAssembly::*;
    private import X2CityComponent_BatterySupervision::*;
    part def BatteryControl { // LE-BATTERY-CONTROL
        doc /*
            EPCS battery composite. It contains exactly the removable physical BatteryAssembly and
            vehicle-host BatterySupervision, separating supplied BMS protection from project
            read/qualification and operating policy.
        */
        part batteryAssembly:BatteryAssembly {
            doc /*
                The sole removable physical 14S5P pack assembly.
            */
        }
        part batterySupervision:BatterySupervision {
            doc /*
                Project vehicle-host supervision for BMS reading, qualification, and battery operating
                policy.
            */
        }
        port batteryPower:BatteryPowerPort {
            doc /*
                External physical bidirectional pack-to-EnergyPath boundary for discharge and regeneration.
            */
        }
        port batteryStatusOut:BatteryStatusOutputPort {
            doc /*
                External RidingControl reporting conditions, including independent
                lowDischargeVoltageWarning.
            */
        }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort {
            doc /*
                External total battery operating limits for RidingControl budgeting and EnergyPath
                enforcement across both current-sign branches.
            */
        }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort {
            doc /*
                External qualified actual-SOC publication for HMI.
            */
        }
        port batteryCurrentOut:BatteryCurrentOutputPort {
            doc /*
                External qualified signed-current publication for
                RidingControl.CurrentConsumptionCoordination and HMI.
            */
        }
        flow assemblyPowerToBoundary from batteryAssembly.batteryPower.batteryPower to
            batteryPower.batteryPower;
        flow boundaryPowerToAssembly from batteryPower.batteryPower to
            batteryAssembly.batteryPower.batteryPower;
        interface bmsReadRequestToAssembly : IfA009BmsReadRequest
        connect batterySupervision.bmsReadRequestOut to batteryAssembly.bms.bmsReadRequestIn;
        interface bmsTelemetryFromAssembly : IfA009BmsTelemetry
        connect batteryAssembly.bms.bmsTelemetryOut to batterySupervision.bmsTelemetryIn;
        flow statusFromSupervision from batterySupervision.batteryStatusOut.status to batteryStatusOut.status;
        flow limitsFromSupervision from batterySupervision.batteryOperatingLimitsOut.operatingLimits to
            batteryOperatingLimitsOut.operatingLimits;
        flow socFromSupervision from batterySupervision.stateOfChargeOut.stateOfCharge to
            stateOfChargeOut.stateOfCharge;
        flow currentFromSupervision from batterySupervision.batteryCurrentOut.batteryCurrent to
            batteryCurrentOut.batteryCurrent;
    }

    doc /*
        System Requirements allocated to LE-BATTERY-CONTROL. Current requirement usages are Draft
        successors; historical approval applies only to the released REQ-001-R1.6 record, and integrated
        acceptance remains open. They implement owner-confirmed
        [DEC-BAT-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-bat-002).
        [BAT-001](BatteryAssembly/BatteryAssembly.md#fixed-inputs-and-provenance) is the canonical component/rating
        reference; selection and reported initial fit are settled. Apply the
        [REQ-001 model and verification rules](../../REQ-001_Requirements.md).
    */


}
