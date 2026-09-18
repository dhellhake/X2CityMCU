package X2CityComponent_InputQualification {
    private import X2CitySharedContracts::*;
    private import X2CityContract_ServiceInformation::*;
    part def InputQualification { // LE-INPUT-QUAL
        /* Retained qualification for non-accelerator observations, including coded brake. Accelerator semantic qualification is owned by LE-ACCELERATOR-QUAL. */
        port serviceReportOut:ServiceReportOutputPort;
    }
}
