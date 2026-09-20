package X2CityContract_MotorControl {
    private import X2CitySharedContracts::*;
    item def ActualTractionOutput:>QualifiedInformationRecord;
    item def ElectricalBrakingState:>QualifiedInformationRecord {
        doc /* Traction-owned projection of actual electrical braking at the output boundary. Present includes recuperative braking, rollback retardation, and constant-speed descent control; it does not require net battery charging or a particular requested torque sign. */
        attribute actualElectricalBrakingPresent:Boolean;
    }
    item def QualifiedVehicleMotion:>QualifiedInformationRecord;
    port def ActualTractionOutputPort {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy and DemandPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command; MotorControl's electrical-braking projection provides LightControl's dedicated input. */
        out item payload:ActualTractionOutput;
    }
    port def ActualTractionInputPort {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy and DemandPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command; MotorControl's electrical-braking projection provides LightControl's dedicated input. */
        in item payload:ActualTractionOutput;
    }
    port def ElectricalBrakingStateOutputPort {
        doc /* Carries Traction's qualified actual electrical-braking present/absent projection. It is derived from actual output-stage evidence, retains that evidence's qualification, and is distinct from a brake-lever request and from battery charging. */
        out item payload:ElectricalBrakingState;
    }
    port def ElectricalBrakingStateInputPort {
        doc /* Receives Traction's qualified actual electrical-braking present/absent projection. It is derived from actual output-stage evidence, retains that evidence's qualification, and is distinct from a brake-lever request and from battery charging. */
        in item payload:ElectricalBrakingState;
    }
    port def QualifiedVehicleMotionOutputPort {
        doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy and DemandPolicy. This physical-motion qualification is separate from Input's accelerator/rest and coded-brake facts. */
        out item payload:QualifiedVehicleMotion;
    }
    port def QualifiedVehicleMotionInputPort {
        doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy and DemandPolicy. This physical-motion qualification is separate from Input's accelerator/rest and coded-brake facts. */
        in item payload:QualifiedVehicleMotion;
    }
    interface def IfA005ActualTractionOutput { end producer:ActualTractionOutputPort; end consumer:ActualTractionInputPort; flow producer.payload to consumer.payload; }
    interface def IfA005ElectricalBrakingState { end producer:ElectricalBrakingStateOutputPort; end consumer:ElectricalBrakingStateInputPort; flow producer.payload to consumer.payload; }
    interface def IfA005QualifiedVehicleMotion { end producer:QualifiedVehicleMotionOutputPort; end consumer:QualifiedVehicleMotionInputPort; flow producer.payload to consumer.payload; }
}

package X2CityComponent_MotorControl {
    private import X2CitySharedContracts::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_SessionPolicy::*;
    private import X2CityContract_DemandPolicy::*;
    part def MotorControl { // LE-MOTOR-CTRL
        /* Provides the logical motor-control boundary. It accepts independent riding authority
           and signed torque demand, then publishes qualified physical-motion and actual-output
           observations. Demand evaluation remains in DemandPolicy. This is an architectural boundary only: it selects neither software
           units, calibration, hardware nor an execution mechanism. */
        port ridingAuthorityIn:RidingAuthorityInputPort;
        port wheelTorqueCommandIn:WheelTorqueCommandInputPort;
        port qualifiedVehicleMotionOut:QualifiedVehicleMotionOutputPort;
        port actualTractionOutputOut:ActualTractionOutputPort;
        port electricalBrakingStateOut:ElectricalBrakingStateOutputPort { doc /* Projects qualified actual electrical-braking state from the output-stage observation. */ }
    }
}
