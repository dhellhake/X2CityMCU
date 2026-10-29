package X2CityComponent_TractionHardware {
    private import X2CityContract_TractionControl::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_EnergyPath::*;

    part def TractionHardware { // LE-TRACTION-HW
        /* Hardware responsibility for physical PVDD/GVDD and motor/traction-board temperature measurement, traction-energy conversion and the physical motor-actuation boundary. It applies its protections independently of software command; it neither provides Hall/current/phase-voltage observation nor decides Session policy. */
        port tractionElectricalPower:TractionElectricalPowerPort { doc /* Delegated physical bidirectional EnergyPath connection. */ }
        port temperatureMeasurementOut:TemperatureMeasurementOutputPort { doc /* Physical motor/board sensor-response measurement evidence. */ }
        port supplyVoltageMeasurementOut:SupplyVoltageMeasurementOutputPort { doc /* Physical PVDD/GVDD measurement evidence. */ }
        port phaseExcitationCommandIn:PhaseExcitationCommandInputPort { doc /* Requested phase-voltage vector and software inhibition; protections remain independent. */ }
        port tractionStageEvidenceOut:TractionStageEvidenceOutputPort { doc /* Physical output-stage evidence; it does not echo a request as proof. */ }
        port appliedTractionModulationEvidenceOut:AppliedTractionModulationEvidenceOutputPort { doc /* Qualified applied modulation and permit effects for local DC-current estimation. */ }
        port tractionHardwareProtectionEvidenceOut:TractionHardwareProtectionEvidenceOutputPort { doc /* Independent hardware protection evidence. */ }
        port physicalMotorActuation:PhysicalMotorActuationPort { doc /* Explicit physical motor-actuation boundary. */ }
    }
}
