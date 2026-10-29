package X2CitySpecification_BatterySupervision_BmsCommunication {
    private import X2CityComponent_BatterySupervision::*;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-BMSIF-002'> bmsReadCommandRestriction : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [BAT-001](../../BatteryAssembly/BatteryAssembly.md#fixed-inputs-and-provenance). Verify: T-SW/T-SYS request
            command restriction; installed support remains open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall issue only supported read-only BMS requests 0x03, 0x04 and 0x05.
            */
        }
    }
    satisfy bmsReadCommandRestriction by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-003'> bmsResponseValidation : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract).
            Verify: T-SW envelope vectors and T-SYS selected-unit captures. Transaction acceptance is
            BMSIF-014. Installed framing evidence remains open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall accept a response envelope only when its boundaries are complete
                and unambiguous, its start and end markers are valid, its declared length is within protocol
                bounds and matches the received bytes, and its checksum is valid.
            */
        }
    }
    satisfy bmsResponseValidation by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-014'> bmsTransactionAcceptance : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract).
            Verify: T-SW/T-SYS matching, success/error status and deadline boundaries. Installed response
            correlation and status remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall accept a response for measurement updates only when its envelope
                meets REQ-SYS-BMSIF-003, it matches the outstanding read request, and it reports success
                within 100 ms of the start of request transmission. A valid-envelope non-success response is
                a transaction failure.
            */
        }
    }
    satisfy bmsTransactionAcceptance by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-013'> bmsReadServiceTiming : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent: [REQ-SYS-BMS-003](../../Specification/BmsIntegration.sysml). Sources:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract),
            [qualification and response budget](../../BatteryControl.md#qualification-evidence-and-response-budget).
            Verify: T-SW/T-SYS cyclic schedule. Transaction acceptance, outstanding request limit, retry and
            publication are BMSIF-014/018/019/020. Installed device response, refresh, sleep and energy
            remain open under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall request Basic (0x03) and complete 14-group voltage (0x04)
                information each every 200 ms, alternating nominally 100 ms apart.
            */
        }
    }
    satisfy bmsReadServiceTiming by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-018'> bmsOutstandingRequestLimit : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall have at most one BMS read request outstanding at a time.
            */
        }
    }
    satisfy bmsOutstandingRequestLimit by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-019'> bmsReadRetrySchedule : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                After a failed cyclic read, BatterySupervision shall reattempt it at its next normal cyclic
                slot without burst or queued retries.
            */
        }
    }
    satisfy bmsReadRetrySchedule by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;

    requirement <'REQ-SYS-BMSIF-021'> bmsIdentityRequestSchedule : AbstractSoftwareRequirement {
        doc /*
            Status: Draft. Allocation: LE-BATTERY-SUPERVISION; software realization pending.
            Parent(s): REQ-SYS-BMS-003 (../BatteryControl.sysml). Source:
            [selected-unit UART acceptance](../BatterySupervision.md#selected-unit-uart-read-acceptance-contract);
            [Battery Integration consumer acceptance](../../BatteryControl.md#per-consumer-information-acceptance).
            Verify: T-SW/T-SYS against accepted and rejected source evidence and applicable boundaries.
            Open: installed-unit acceptance and physical timing under OI-041/061 and WS-OI-018/019.
        */
        subject supervision:BatterySupervision =
            X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
        require constraint {
            doc /*
                BatterySupervision shall issue no periodic 0x05 identity request.
            */
        }
    }
    satisfy bmsIdentityRequestSchedule by
        X2CitySystemArchitecture::x2CityVehicle.epcs.batteryControl.batterySupervision;
}
