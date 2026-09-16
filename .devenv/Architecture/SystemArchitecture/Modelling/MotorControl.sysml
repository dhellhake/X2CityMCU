package X2CityContract_MotorControl {
    private import X2CitySharedContracts::*;
    item def ActualOutputInformation:>ContextualInformation;
    port def ActualOutputOut { out item payload:ActualOutputInformation; }
    port def ActualOutputIn { in item payload:ActualOutputInformation; }
    interface def IfA005ActualOutput { end producer:ActualOutputOut; end consumer:ActualOutputIn; flow producer.payload to consumer.payload; }
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
