package X2CitySpecification_MotorControl_SystemHardwareSoftwareInterface {
    private import X2CityComponent_MotorControl::MotorControl;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-HSI-004'> authorityAndTorqueCommandBoundary : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-004
            (line 12).
            Original target: LE-MOTOR-CTRL.
            Original type: System Requirement.
            Status: Approved.
            ID: <a id="req-sys-hsi-004"></a>`REQ-SYS-HSI-004` **Approved**
            Original obligation column: Approved requirement
            Target / allocation direction: [LE-MOTOR-CTRL](../../../../X2CityMCU.md#le-motor-ctrl);
            HC-TRACTION-POWER provides the physical actuation boundary; software realization remains
            pending.
            Derived from / interfaces: [INT-004](../../../Specification/InterfaceQualification.sysml),
            IF-A-004/005, HW-I-003
            Planned verification and open acceptance: `A`, `T-FI`, `T-SYS`: withdraw/restart producers and
            consumer with queued commands and compare accepted command, output observation and independent
            physical outcome. Derive identity, transfer/expiry and response bounds, actuator interface,
            output observability and failure coverage.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                The authority and torque-command boundary shall transfer a current authorization context and
                a signed command with independent validity and expiry evidence to torque realization. On
                loss, mismatch, invalidity or expiry of either item, the receiving boundary shall request
                zero commanded torque of both signs and shall report its acceptance/output-observation state
                without treating that request as proof of physical zero output.
            */
        }
    }
    satisfy authorityAndTorqueCommandBoundary by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

}
