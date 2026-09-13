#![allow(non_snake_case)]

use crate::{
    drv::{
        BIT,
        pwr::{
            CR3,
            Pwr,
            PWR_VOS,
        },
    },
};

pub fn ConfigureLdoSupply(pwr: &Pwr) {
    pwr.Write_CR3(CR3 {
        BYPASS: BIT::VALUE_0,
        LDOEN: BIT::VALUE_1,
        SCUEN: BIT::VALUE_0,
    });
    pwr.WaitForActiveVoltageReady();
}

pub fn PrepareVoltageScale0For550Mhz(pwr: &Pwr) {
    assert!(pwr.IsLdoEnabled());

    pwr.WaitForActiveVoltageReady();
    // RM0468: H723 selects VOS0 directly; there is no SYSCFG ODEN bit.
    pwr.SelectVoltageScale(PWR_VOS::SCALE_0);
    pwr.WaitForActiveVoltageReady();
}

pub fn WaitForVoltageScale0Ready(pwr: &Pwr) {
    pwr.WaitForVoltageReady();
    pwr.WaitForActiveVoltageReady();
}
