#![allow(non_snake_case)]

use crate::{
    drv::{
        BIT,
        rcc::{
            Rcc,
            RCC_APB_PRESCALER,
            RCC_D1CPRE,
            RCC_HPRE,
            RCC_PLL_RGE,
            RCC_PLL_SOURCE,
            RCC_PLL_VCOSEL,
            RCC_SYSTEM_CLOCK,
        },
    },
};

/// RCC-only part of the FK743M2-IIT6 V1.1 480 MHz clock switch.
/// PWR voltage scaling, SYSCFG overdrive, and FLASH latency must be
/// configured before this function is called.
pub fn ConfigurePll1Hse25MhzTo480Mhz(rcc: &Rcc) {
    SetBusPrescalersFor480Mhz(rcc);
    rcc.EnableHseCrystal();
    rcc.DisablePll1();

    rcc.Set_PLLCKSELR_PLLSRC(RCC_PLL_SOURCE::HSE);
    rcc.Set_PLLCKSELR_DIVM1(5);
    rcc.Set_PLLCFGR_PLL1FRACEN(BIT::VALUE_0);
    rcc.Set_PLLCFGR_PLL1VCOSEL(RCC_PLL_VCOSEL::WIDE);
    rcc.Set_PLLCFGR_PLL1RGE(RCC_PLL_RGE::RANGE_4_TO_8_MHZ);
    rcc.SetPll1Dividers(192, 2, 2, 2);
    rcc.Set_PLL1FRACR_FRACN1(0);
    rcc.Set_PLLCFGR_DIVP1EN(BIT::VALUE_1);
    rcc.Set_PLLCFGR_DIVQ1EN(BIT::VALUE_0);
    rcc.Set_PLLCFGR_DIVR1EN(BIT::VALUE_0);

    rcc.EnablePll1();
    rcc.SetSystemClockSource(RCC_SYSTEM_CLOCK::PLL1);
    rcc.WaitForSystemClockSource(RCC_SYSTEM_CLOCK::PLL1);
}

pub fn SetBusPrescalersFor480Mhz(rcc: &Rcc) {
    rcc.Set_D1CFGR_D1CPRE(RCC_D1CPRE::SYSCLK_DIV1);
    rcc.Set_D1CFGR_HPRE(RCC_HPRE::SYSCLK_DIV2);
    rcc.Set_D1CFGR_D1PPRE(RCC_APB_PRESCALER::HCLK_DIV2);
    rcc.Set_D2CFGR_D2PPRE1(RCC_APB_PRESCALER::HCLK_DIV2);
    rcc.Set_D2CFGR_D2PPRE2(RCC_APB_PRESCALER::HCLK_DIV2);
    rcc.Set_D3CFGR_D3PPRE(RCC_APB_PRESCALER::HCLK_DIV2);
}
