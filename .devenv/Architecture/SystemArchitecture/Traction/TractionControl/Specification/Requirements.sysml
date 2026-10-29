package X2CitySpecification_TractionControl_Requirements {
    private import X2CityComponent_TractionControl::TractionControl;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-TRQRAIL-001'> tractionRailStartupQualification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/TractionControl.md#req-sys-trqrail-001
            (line 46).
            Original target: LE-TRACTION-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqrail-001"></a>`REQ-SYS-TRQRAIL-001` **Draft**
            Original obligation column: Requirement
            Derived from: Owner decision 2026-10-02; `REQ-SYS-STA-001`, `REQ-SYS-STA-006`,
            `REQ-SYS-HSI-009`.
            Planned verification and gate: `T-SYS`, `T-FI`: start with each rail absent, invalid, stale,
            mismatched, and then qualified; verify no Ready prerequisite is asserted until the accepted
            condition and qualification continues while inhibited. Thresholds, settling, startup period,
            rail set and detection budget require derivation.
        */
        subject owner:TractionControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl;
        require constraint {
            doc /*
                `LE-TRACTION-CONTROL` shall provide Session a `TractionConditionEvidence` result with
                `startupTractionConditionsAccepted` true only after qualified GVDD startup evidence and the
                applicable qualified PVDD/traction-rail condition support operation. Initial, invalid,
                stale, mismatched, or failed qualification shall withhold that prerequisite, while
                motor/board-temperature and rail measurement/qualification continue with actuation
                inhibited.
            */
        }
    }
    satisfy tractionRailStartupQualification by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl;

    requirement <'REQ-SYS-TRQRAIL-002'> tractionRailFaultResponse : SystemRequirement {
        doc /*
            Original source:
            .devenv/Architecture/SystemArchitecture/Traction/TractionControl/TractionControl.md#req-sys-trqrail-002
            (line 47).
            Original target: LE-TRACTION-CONTROL.
            Original type: System Requirement.
            Status: Draft.
            ID: <a id="req-sys-trqrail-002"></a>`REQ-SYS-TRQRAIL-002` **Draft**
            Original obligation column: Requirement
            Derived from: Owner decision 2026-10-02; `REQ-SYS-FLT-005`, `REQ-SYS-FLT-006`,
            `REQ-SYS-FLT-009`, `REQ-SYS-HSI-009`.
            Planned verification and gate: `T-FI`, `T-SYS`: inject each recognized rail fault during
            positive, negative, and zero command; restore evidence without restart, then perform
            clean/persistent restart cases. Recognition criteria, response time, coverage and report
            selection remain gates.
        */
        subject owner:TractionControl =
            X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl;
        require constraint {
            doc /*
                On a recognized runtime fault of a traction rail required by the accepted operating
                condition, `LE-TRACTION-CONTROL` shall withdraw both torque signs and set
                `TractionConditionEvidence.recognizedFault` with the applicable supply category. Restoration
                of rail evidence, including hardware UVLO auto-recovery, shall not itself re-enable
                actuation; RidingControl retains session the common current-session latch and reporting
                policy until a qualifying clean restart. An initial unknown rail state is not this
                recognized fault.
            */
        }
    }
    satisfy tractionRailFaultResponse by X2CitySystemArchitecture::x2CityVehicle.epcs.traction.tractionControl;

}
