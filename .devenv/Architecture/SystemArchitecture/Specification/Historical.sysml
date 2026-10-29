package X2CitySpecification_X2CityMCU_Historical {
    private import X2CitySystemArchitecture::X2CityMCU;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BRK-009'> deferredBrakeTrunkOpenDetection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-009 (line
            25).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Deferred.
            ID: <a id="req-sys-brk-009"></a>`REQ-SYS-BRK-009`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A` derivation only. No active acceptance.
            Derive necessity, coverage, margins and response.
            Sources: `BRK-D-01`,
            [DEC-REF-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-ref-002)
            Open dependencies / qualifications: `WS-OI-012`: Historical BRK-D-01; complete opens differ from
            nominal codes, but bypass-open/resistive aliases remain intrinsic limitations.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Deferred:** hard trunk/complete-branch open detection; no current diagnostic obligation.
            */
        }
    }

    requirement <'REQ-SYS-BRK-010'> deferredBrakeLineShortDetection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-010 (line
            26).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Deferred.
            ID: <a id="req-sys-brk-010"></a>`REQ-SYS-BRK-010`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A` derivation only. No active acceptance.
            Derive relevant electrical conditions, margins and response.
            Sources: `BRK-D-02`,
            [DEC-REF-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-ref-002)
            Open dependencies / qualifications: `WS-OI-012`: Historical BRK-D-02; hard short differs from
            finite both-pressed resistance, without adopting historical sensing/protection.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Deferred:** hard line-to-line short detection; no current diagnostic obligation.
            */
        }
    }

    requirement <'REQ-SYS-BRK-011'> deferredBrakeConductorFaultDetection : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/Brake_Interface_and_Priority.md#req-sys-brk-011 (line
            27).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Deferred.
            ID: <a id="req-sys-brk-011"></a>`REQ-SYS-BRK-011`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: `I`, `A` derivation only. No active acceptance.
            Derive faults, compatibility, protection and diagnostic needs from the future design.
            Sources: `BRK-D-03`,
            [DEC-REF-002](../../DEC-001_Decisions_and_Open_Issues.md#dec-ref-002)
            Open dependencies / qualifications: `WS-OI-012`: Historical BRK-D-03; passive interface
            specifies no excitation topology/rail, common-mode observation or fault-survival envelope.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Deferred:** conductor-to-ground/supply fault detection; no current diagnostic obligation.
            */
        }
    }

    requirement <'REQ-VEH-LVL-001'> withdrawnAssistLevelRetention : SystemRequirement {
        doc /*
            Original source: .devenv/Requirements/System_Requirements/Rider_Control.md#req-veh-lvl-001 (line
            15).
            Original target: LE-EPCS.
            Original type: System Requirement.
            Status: Withdrawn.
            ID: <a id="req-veh-lvl-001"></a>`REQ-VEH-LVL-001`
            Original obligation column: Requirement
            Planned verification / distinguishing cases: —
            Sources: [DEC-LVL-003](../../DEC-001_Decisions_and_Open_Issues.md#dec-lvl-003)
            Open dependencies / qualifications: Owner functional-ambiguity answers 3–4; no
            retention-capability dependency remains.
        */
        subject owner:X2CityMCU =
            X2CitySystemArchitecture::x2CityVehicle.epcs;
        require constraint {
            doc /*
                **Withdrawn:** Cross-boot restoration of the last selected level is no longer required; use
                the VD18MT-communicated level under
                [REQ-SYS-LVL-001](../RidingControl/RidingPolicy/Specification/SettingsAndControlPolicy.sysml).
            */
        }
    }

}
