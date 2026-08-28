use core::arch::asm;

use crate::{
    drv::{
        ccm::{
            Ccm, CcmAnalog, CLOCK_GATE, PERIPH_CLK2_SEL, PLL_ARM_BYPASS_CLK_SRC,
            PRE_PERIPH_CLK_SEL, UART_CLK_SEL,
        },
        cortex::Shared,
        dcdc::Dcdc,
        BIT,
    },
    mcu::McuManager,
};

const XTAL_CLOCK_HZ: u32 = 24_000_000;
const ARM_PLL_LOOP_DIVIDER: u8 = 100;
const ARM_PLL_OUTPUT_HZ: u32 = XTAL_CLOCK_HZ * ARM_PLL_LOOP_DIVIDER as u32 / 2;
const ARM_PODF: u8 = 1; // Encoded divide-by-two.
const AHB_PODF: u8 = 0; // Encoded divide-by-one.
const IPG_PODF: u8 = 3; // Encoded divide-by-four.
const UART_CLK_PODF: u8 = 0; // Encoded divide-by-one.

// 0.800 V + 0x12 * 0.025 V = 1.250 V. This is the lowest voltage in NXP's
// 600 MHz overdrive range and remains inside the CVL5 part's 1.26 V recommended
// operating ceiling, although 600 MHz itself is not qualified for this grade.
// Raise this only after HIL demonstrates voltage-related instability. The
// unaligned DTCM fault found during bring-up was caused by inherited MPU state,
// not core voltage, and reproduced unchanged at 1.275 V.
const DCDC_RUN_TARGET: u8 = 0x12;

// Keep the software time base derived from the same divider values that the
// clock transition programs into hardware.
pub(super) const CORE_CLOCK_HZ: u32 = ARM_PLL_OUTPUT_HZ / (ARM_PODF as u32 + 1);
const AHB_CLOCK_HZ: u32 = CORE_CLOCK_HZ / (AHB_PODF as u32 + 1);
pub(super) const IPG_CLOCK_HZ: u32 = AHB_CLOCK_HZ / (IPG_PODF as u32 + 1);
pub(super) const LPUART_CLOCK_HZ: u32 = XTAL_CLOCK_HZ / (UART_CLK_PODF as u32 + 1);

const _: () = {
    assert!(CORE_CLOCK_HZ == 600_000_000);
    assert!(AHB_CLOCK_HZ == 600_000_000);
    assert!(IPG_CLOCK_HZ == 150_000_000);
    assert!(LPUART_CLOCK_HZ == 24_000_000);
};

static CCM: Shared<Ccm> = Shared::new(Ccm::new());
static CCM_ANALOG: Shared<CcmAnalog> = Shared::new(CcmAnalog::new());
static DCDC: Shared<Dcdc> = Shared::new(Dcdc::new());

pub(super) fn EnableGpio1AndIomuxcClocks() {
    CCM.with(|ccm| {
        ccm.Set_CCGR1_CG13(CLOCK_GATE::RUN_WAIT);
        ccm.Set_CCGR4_CG1(CLOCK_GATE::RUN_WAIT);
    });
}

pub(super) fn EnableAdc2Gpio1AndIomuxcClocks() {
    CCM.with(|ccm| {
        ccm.Set_CCGR1_CG4(CLOCK_GATE::RUN_WAIT);
        ccm.Set_CCGR1_CG13(CLOCK_GATE::RUN_WAIT);
        ccm.Set_CCGR4_CG1(CLOCK_GATE::RUN_WAIT);
        ccm.Set_CCGR4_CG2(CLOCK_GATE::RUN_WAIT);
    });
}

pub(super) fn EnableLpuart2AndIomuxcClocks() {
    CCM.with(|ccm| {
        ccm.Set_CCGR0_CG14(CLOCK_GATE::RUN_WAIT);
        ccm.Set_CCGR4_CG1(CLOCK_GATE::RUN_WAIT);
    });
}

pub(super) fn EnableLpuart6AndIomuxcClocks() {
    CCM.with(|ccm| {
        ccm.Set_CCGR3_CG3(CLOCK_GATE::RUN_WAIT);
        ccm.Set_CCGR4_CG1(CLOCK_GATE::RUN_WAIT);
    });
}

impl McuManager {
    pub fn McuClockTree_Init() {
        // Reset has already copied this function to ITCM and keeps interrupts
        // disabled. Route the live bus/core tree to the 24 MHz crystal before
        // changing either the ARM PLL or the core voltage.
        CCM.with(|ccm| {
            ccm.Set_CBCMR_PERIPH_CLK2_SEL(PERIPH_CLK2_SEL::OSC_CLK);
            ccm.Set_CBCDR_PERIPH_CLK2_PODF(0);
            ccm.Set_CBCDR_PERIPH_CLK_SEL(BIT::VALUE_1);

            // Use the crystal directly for every LPUART root. This remains
            // deterministic while PLLs are reconfigured and gives the 9600
            // bit/s LPUART2 and LPUART6 links exact divisors.
            ccm.Set_CCGR0_CG14(CLOCK_GATE::OFF);
            ccm.Set_CCGR3_CG3(CLOCK_GATE::OFF);
            ccm.Set_CSCDR1_UART_CLK_SEL(UART_CLK_SEL::OSC_CLK);
            ccm.Set_CSCDR1_UART_CLK_PODF(UART_CLK_PODF);
        });
        unsafe { asm!("dsb sy", "isb sy", options(nostack, preserves_flags)) };

        // Permit the DCDC to slew rather than jump to its new target. Frequency
        // is raised only after the regulator reports that its output settled.
        DCDC.with(|dcdc| {
            dcdc.Set_REG3_DISABLE_STEP(BIT::VALUE_0);
            dcdc.Set_REG3_TRG(DCDC_RUN_TARGET);
            dcdc.WaitUntilOutputStable();
        });

        // PLL_ARM = 24 MHz * 100 / 2 = 1.2 GHz. It is not a live source while
        // being bypassed, reprogrammed, and locked by this operation.
        CCM_ANALOG.with(|ccmAnalog| {
            ccmAnalog.ConfigureArmPll(ARM_PLL_LOOP_DIVIDER, PLL_ARM_BYPASS_CLK_SRC::OSC_24M);
        });

        // The resulting run clocks are core/AHB 600 MHz and IPG 150 MHz.
        CCM.with(|ccm| {
            ccm.Set_CBCDR_AHB_PODF(AHB_PODF);
            ccm.Set_CBCDR_IPG_PODF(IPG_PODF);
            ccm.Set_CACRR_ARM_PODF(ARM_PODF);
            ccm.Set_CBCMR_PRE_PERIPH_CLK_SEL(PRE_PERIPH_CLK_SEL::DIVIDED_PLL1);
            ccm.Set_CBCDR_PERIPH_CLK_SEL(BIT::VALUE_0);
        });

        unsafe { asm!("dsb sy", "isb sy", options(nostack, preserves_flags)) };
    }
}
