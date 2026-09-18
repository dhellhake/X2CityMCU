package X2CityContract_MotorControl {
    private import X2CitySharedContracts::*;
    item def ActualTractionOutput:>QualifiedInformationRecord;
    item def QualifiedVehicleMotion:>QualifiedInformationRecord;
    port def ActualTractionOutputPort {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy, DemandPolicy and LightPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command. */
        out item payload:ActualTractionOutput;
    }
    port def ActualTractionInputPort {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy, DemandPolicy and LightPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command. */
        in item payload:ActualTractionOutput;
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
    }
}
