package X2CityContract_MotorControl {
    private import X2CitySharedContracts::*;
    item def ActualOutputInformation:>ContextualInformation;
    item def QualifiedMotionInformation:>ContextualInformation;
    port def ActualOutputOut {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy, DemandPolicy and LightPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command. */
        out item payload:ActualOutputInformation;
    }
    port def ActualOutputIn {
        doc /* Carries qualified observations of actual traction output from Traction to SessionPolicy, DemandPolicy and LightPolicy. The record is output-stage evidence for policy decisions and remains separate from the requested torque command. */
        in item payload:ActualOutputInformation;
    }
    port def QualifiedMotionOut {
        doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy and DemandPolicy. This physical-motion qualification is separate from Input's accelerator/rest and coded-brake facts. */
        out item payload:QualifiedMotionInformation;
    }
    port def QualifiedMotionIn {
        doc /* Carries Traction-owned qualified vehicle speed, direction and standstill observations to SettingsPolicy, SessionPolicy and DemandPolicy. This physical-motion qualification is separate from Input's accelerator/rest and coded-brake facts. */
        in item payload:QualifiedMotionInformation;
    }
    interface def IfA005ActualOutput { end producer:ActualOutputOut; end consumer:ActualOutputIn; flow producer.payload to consumer.payload; }
    interface def IfA005QualifiedMotion { end producer:QualifiedMotionOut; end consumer:QualifiedMotionIn; flow producer.payload to consumer.payload; }
}

package X2CityComponent_MotorControl {
    private import X2CitySharedContracts::*;
    private import X2CityContract_MotorControl::*;
    private import X2CityContract_ServiceInformation::*;
    part def MotorControl { // LE-MOTOR-CTRL
        /* Provides the motor-control boundary that applies traction commands to the drive hardware and makes actual output available to observers. It publishes service configuration information; demand evaluation remains in DemandPolicy. */
        port serviceConfigurationOut:ServiceConfigurationOut;
    }
}
