package X2CitySpecification_MotorControl_SystemInterfaceAllocations {
    private import X2CityComponent_MotorControl::MotorControl;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-TRQEX-001'> atomicControlAndAcquisitionCommit : AbstractSoftwareRequirement {
        doc /*
            Original source:
            .devenv/Requirements/Abstract_Software_Requirements/System_Interface_Allocations.md#req-sys-trqex-001
            (line 19).
            Original target: LE-MOTOR-CTRL.
            Original type: Abstract Software Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqex-001"></a>`REQ-SYS-TRQEX-001` **Draft**
            Type / logical target: Abstract Software Requirement;
            [LE-MOTOR-CTRL](../../../../X2CityMCU.md#le-motor-ctrl)
            Original obligation column: Requirement
            Derived from: REQ-SYS-HSI-009, REQ-SYS-TRQCTL-001
            Planned verification and remaining gate: `T-SW`, `A`, `T-FI`: deadline overrun, commit/guard
            failure, sequence loss, break, authority/Hall/configuration loss, saturation/anti-windup and
            output-boundary timing.
        */
        subject owner:MotorControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;
        require constraint {
            doc /*
                Motor-control responsibility shall derive each output update and its next sampling context
                from one qualified current epoch, then complete acquisition rearm and output preload commit
                before their configured boundaries. The paired control output and acquisition context shall
                be committed atomically. A missed deadline, failed rearm/preload, invalid acquisition,
                break/inhibit state or configuration mismatch withdraws both torque signs. Output-update and
                acquisition events remain distinct from physical-output and energy observation. One bounded
                responsibility owns the final control-output commit; this does not define a register-level
                realization.
            */
        }
    }
    satisfy atomicControlAndAcquisitionCommit by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl.motorControl;

}
