#![allow(non_snake_case)]

use crate::{
    drv::{
        BIT,
        pwr::{
            CR3,
            Pwr,
            PWR_VOS,
        },
        syscfg::Syscfg,
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

pub fn ConfigureVoltageScale0For480Mhz(pwr: &Pwr, syscfg: &Syscfg) {
    assert!(pwr.IsLdoEnabled());

    pwr.WaitForActiveVoltageReady();
    pwr.SelectVoltageScale(PWR_VOS::SCALE_1);
    pwr.WaitForActiveVoltageReady();

    syscfg.EnableOverdrive();
    while !syscfg.IsOverdriveEnabled() {}

    pwr.WaitForVoltageReady();
    pwr.WaitForActiveVoltageReady();
}
