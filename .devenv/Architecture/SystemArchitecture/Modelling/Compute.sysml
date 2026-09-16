package X2CityComponent_Compute {
    private import X2CitySharedContracts::*;
    private import X2CityComponent_ComputeHardware::*;
    private import X2CityComponent_Platform::*;
    part def Compute { // LE-COMPUTE
        /* Composes compute hardware and platform services that host the system software functions. It provides the execution/platform boundary without allocating individual software units here. */
        part computeHardware:ComputeHardware;
        part platform:Platform;
    }
}
