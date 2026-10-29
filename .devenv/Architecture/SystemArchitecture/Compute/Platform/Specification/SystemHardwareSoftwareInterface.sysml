package X2CitySpecification_Platform_SystemHardwareSoftwareInterface {
    private import X2CityComponent_Platform::Platform;
    private import RequirementTypes::*;

    requirement <'REQ-SYS-HSI-007'> endpointContextRequalification : SystemRequirement {
        doc /*
            Original source:
            .devenv/Requirements/System_Requirements/System_Hardware_Software_Interface.md#req-sys-hsi-007
            (line 14).
            Original target: LE-PLATFORM.
            Original type: System Requirement.
            Status: Approved.
            ID: <a id="req-sys-hsi-007"></a>`REQ-SYS-HSI-007` **Approved**
            Original obligation column: Approved requirement
            Target / allocation direction: [LE-PLATFORM](../../../X2CityMCU.md#le-platform); selected
            vehicle power/reset realization remains open; software realization remains pending.
            Derived from / interfaces: IF-A-001–006/009–011,
            [STA-001](../../../Specification/PowerStartupAndFaults.sysml),
            [FLT-005](../../../Specification/PowerStartupAndFaults.sysml).
            Planned verification and open acceptance: `A`, `T-FI`, `T-SYS`: interrupt each relevant
            rail/host and each peer endpoint in every vehicle configuration; verify context invalidation and
            the specified retained states. Derive reset domains, brownout behavior, retention integrity,
            scheduling/health bounds and shared-dependency coverage.
        */
        subject owner:Platform =
            X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;
        require constraint {
            doc /*
                A power, reset, retention or platform-health event affecting a vehicle endpoint shall make
                affected observations, commands and acknowledgements unusable until qualified in their
                current context. Riding and BMS state shall retain, discard or requalify only as their
                existing parent requirements prescribe; a shared processor or rail shall not silently
                conflate these lifetimes.
            */
        }
    }
    satisfy endpointContextRequalification by X2CitySystemArchitecture::x2CityVehicle.epcs.compute.platform;

}
