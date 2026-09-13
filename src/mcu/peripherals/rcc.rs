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

pub const CPU_CLOCK_HZ: u32 = 550_000_000;
pub const AHB_CLOCK_HZ: u32 = CPU_CLOCK_HZ / 2;
pub const APB_CLOCK_HZ: u32 = AHB_CLOCK_HZ / 2;

/// Establishes a clock source that can remain active while PLL1 is changed.
/// This also tolerates entry with a previously configured clock tree.
pub fn SelectHsiForClockConfiguration(rcc: &Rcc) {
    rcc.EnableHsi();
    rcc.SetSystemClockSource(RCC_SYSTEM_CLOCK::HSI);
    rcc.WaitForSystemClockSource(RCC_SYSTEM_CLOCK::HSI);
}

/// RCC-only part of the WeAct STM32H723VGT6 550 MHz clock switch.
/// CPUFREQ_BOOST, PWR voltage scale 0 and FLASH access timing must be
/// configured, with HSI selected as SYSCLK, before this function is called.
pub fn ConfigurePll1Hse25MhzTo550Mhz(rcc: &Rcc) {
    SetBusPrescalersFor550Mhz(rcc);
    rcc.EnableHseCrystal();
    rcc.DisablePll1();

    rcc.Set_PLLCKSELR_PLLSRC(RCC_PLL_SOURCE::HSE);
    rcc.Set_PLLCKSELR_DIVM1(5);
    rcc.Set_PLLCFGR_PLL1FRACEN(BIT::VALUE_0);
    rcc.Set_PLLCFGR_PLL1VCOSEL(RCC_PLL_VCOSEL::WIDE);
    rcc.Set_PLLCFGR_PLL1RGE(RCC_PLL_RGE::RANGE_4_TO_8_MHZ);
    // 25 MHz / 5 * 110 = 550 MHz VCO; PLL1P /1 supplies SYSCLK.
    rcc.SetPll1Dividers(110, 1, 2, 2);
    rcc.Set_PLL1FRACR_FRACN1(0);
    rcc.Set_PLLCFGR_DIVP1EN(BIT::VALUE_1);
    rcc.Set_PLLCFGR_DIVQ1EN(BIT::VALUE_0);
    rcc.Set_PLLCFGR_DIVR1EN(BIT::VALUE_0);

    rcc.EnablePll1();
    rcc.SetSystemClockSource(RCC_SYSTEM_CLOCK::PLL1);
    rcc.WaitForSystemClockSource(RCC_SYSTEM_CLOCK::PLL1);
}

pub fn SetBusPrescalersFor550Mhz(rcc: &Rcc) {
    rcc.Set_D1CFGR_D1CPRE(RCC_D1CPRE::SYSCLK_DIV1);
    rcc.Set_D1CFGR_HPRE(RCC_HPRE::SYSCLK_DIV2);
    rcc.Set_D1CFGR_D1PPRE(RCC_APB_PRESCALER::HCLK_DIV2);
    rcc.Set_D2CFGR_D2PPRE1(RCC_APB_PRESCALER::HCLK_DIV2);
    rcc.Set_D2CFGR_D2PPRE2(RCC_APB_PRESCALER::HCLK_DIV2);
    rcc.Set_D3CFGR_D3PPRE(RCC_APB_PRESCALER::HCLK_DIV2);
}
