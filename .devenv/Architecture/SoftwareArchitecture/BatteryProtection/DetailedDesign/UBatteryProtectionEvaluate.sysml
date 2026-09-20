package X2CityDetailedUnit_BatteryProtectionEvaluate {
    private import X2CityDetailedSharedContracts::*;
    private import X2CitySharedSoftwareTypes::*;
    private import X2CityContract_BatteryControl::*;
    // Owner: SC-BAT-POLICY.V; DD-002; SW-I-003/009.
    item def BatteryAssessmentCandidate :> UnitInformationEnvelope {
        item readinessAndFault:BatteryReadinessAndFault;
        item operatingLimits:BatteryOperatingLimits;
        item stateOfCharge:BatteryStateOfCharge;
        item batteryCurrent:BatteryCurrent;
    }
    port def BatteryMeasurementsInputPort {
        doc /* Receives only BmsLink's required field-qualified pack measurements. Motor, supply, phase and generic traction diagnostics remain with their owning Session/Traction fault paths. */
        in item payload:BatteryMeasurements;
    }
    port def EnvelopeCandidateOutputPort {
        doc /* Sends independent charge and discharge capability candidates, including their reasons and qualification, to the restriction policy. */
        out item payload:BatteryAssessmentCandidate;
    }
    part def BatteryCapabilityEvaluator {
        /* Evaluates qualified battery observations and operating context into independent charge/discharge envelope candidates. It preserves reason and qualification metadata; it does not implement physical protection or current regulation. */
        port executionTimeIn:ExecutionTimeInputPort; port batteryMeasurementsIn:BatteryMeasurementsInputPort; port candidateOut:EnvelopeCandidateOutputPort; }
}
