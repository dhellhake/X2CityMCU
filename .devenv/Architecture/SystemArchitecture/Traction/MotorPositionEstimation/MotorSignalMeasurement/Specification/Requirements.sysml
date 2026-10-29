package X2CitySpecification_MotorSignalMeasurement_Requirements {
    private import X2CityComponent_MotorSignalMeasurement::MotorSignalMeasurement;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-MSM-001'> hallAndPhaseCurrentAcquisition : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorSignalMeasurement/MotorSignalMeasurement.md#req-sys-msm-001
            (line 10).
            Original target: LE-MOTOR-SIGNAL.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-msm-001"></a>`REQ-SYS-MSM-001` **Draft successor allocation; refined
            ownership**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-MPE-001](../../Specification/Requirements.sysml),
            [REQ-SYS-MPE-002](../../Specification/Requirements.sysml),
            [REQ-SYS-HSI-001](../../../../Specification/SystemHardwareSoftwareInterface.sysml),
            [REQ-SYS-HSI-009](../../../../Specification/SystemHardwareSoftwareInterface.sysml)
            Related / governing contracts: Consumer: `REQ-SYS-MPP-001`, `REQ-SYS-MPP-005`; current feedback
            allocation: `REQ-SYS-PHASE-IF-001`. This is the relocated logical current-channel and
            Hall-supply allocation from the TractionHardware split. Software owns host timestamp/context,
            semantic legality and final electrical rotor position.
            Planned verification / acceptance: `I`, `A`, `T-FI`: inspect physical sources and Hall supply;
            inject capture loss, overrun, out-of-window and saturated inputs; verify invalid physical
            evidence is distinguishable and final position remains estimator-owned.
        */
        subject owner:MotorSignalMeasurement =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.signalMeasurement;
        require constraint {
            doc /*
                `LE-MOTOR-SIGNAL` shall provide `MotorPositionProcessing` with physical Hall capture and
                three phase-leg low-side current-observation channels, including timer-synchronous
                valid-sample evidence. Each shall carry physical capture reference and applicable
                capture-integrity or current-window/saturation qualification. The physical Hall source path
                shall provide the HSI-allocated external 5-V Hall supply.
            */
        }
    }
    satisfy hallAndPhaseCurrentAcquisition by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.signalMeasurement;

    requirement <'REQ-SYS-MSM-002'> windingVoltageObservation : AbstractHardwareRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/MotorPositionEstimation/MotorSignalMeasurement/MotorSignalMeasurement.md#req-sys-msm-002
            (line 11).
            Original target: LE-MOTOR-SIGNAL.
            Original type: Abstract Hardware Requirement.
            Status: Draft.
            ID: <a id="req-sys-msm-002"></a>`REQ-SYS-MSM-002` **Draft**
            Original obligation column: Requirement
            Derived from: [REQ-SYS-MPE-003](../../Specification/Requirements.sysml),
            [REQ-SYS-HSI-009](../../../../Specification/SystemHardwareSoftwareInterface.sysml)
            Related / governing contracts: `LE-MOTOR-POSITION-PROC` decides direct-sensing versus calibrated
            reconstruction and accepts it only after the HSI gate establishes its frame, provenance,
            bandwidth, skew and error bounds. The regular phase-voltage diagnostic scan cannot substitute.
            Planned verification / acceptance: `I`, `A`, `T-HW`, `T-FI`: trace the physical source through
            the output stage; invalidate physical observation/integrity and verify the later qualified
            observer input is unavailable.
        */
        subject owner:MotorSignalMeasurement =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.signalMeasurement;
        require constraint {
            doc /*
                `LE-MOTOR-SIGNAL` shall provide physical winding-voltage or bridge-state observations, with
                physical observation reference and integrity, sufficient for later software qualification of
                applied-winding-voltage evidence.
            */
        }
    }
    satisfy windingVoltageObservation by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.motorPositionEstimation.signalMeasurement;

}
