package X2CityComponent_InputQualification {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ServiceInformation::*;
    part def InputQualification { // LE-INPUT-QUAL
        /* Qualifies raw rider and system observations into information suitable for policy consumers. It exposes its configuration/service boundary while leaving physical sensing to input hardware. */
        port serviceReportOut:ServiceReportOutputPort;
    }
}
