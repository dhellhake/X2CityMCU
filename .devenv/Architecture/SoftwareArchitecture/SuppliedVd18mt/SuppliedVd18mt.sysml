package X2CitySoftwareComponent_SuppliedVd18mt {
    private import X2CityContract_HmiControl::*;
    part def SuppliedVd18mt {
        /* External endpoint representing the fixed five-pin VD18MT assembly and opaque vendor
           firmware. It exchanges received/transmitted UART data through LE-HMI-ELECTRICAL only;
           it has no project-owned firmware decomposition, no software on/off command, and no
           power-lock acknowledgement. */
        port uartReceivedDataOut:HmiUartReceivedDataOutputPort;
        port uartTransmittedDataIn:HmiUartTransmittedDataInputPort;
    }
}
