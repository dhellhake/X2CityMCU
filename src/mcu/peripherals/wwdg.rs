#![allow(non_snake_case)]

use crate::{
    drv::{
        BIT,
        wwdg::{
            Wwdg,
            WWDG_PRESCALER,
        },
    },
};

pub const WWDG_RELOAD_COUNTER: u8 = 0x7F;
pub const WWDG_WINDOW_COUNTER: u8 = 0x61;

// Check the software service interval against the actual hardware window.
// Refresh requires T < W; expiration occurs on the transition to 0x3F.
// Allow a full prescaler tick of phase uncertainty at the reset boundary.
const _: () = {
    let pclk_hz = super::rcc::APB_CLOCK_HZ as u64;
    let tick_us_numerator = 32_768u64 * 1_000_000;
    let first_refresh_tick = (WWDG_RELOAD_COUNTER - WWDG_WINDOW_COUNTER + 1) as u64;
    let earliest_reset_tick = (WWDG_RELOAD_COUNTER - 0x40) as u64;
    assert!(crate::mcu::program_flow::WATCHDOG_SERVICE_MIN_US as u64 * pclk_hz
        > first_refresh_tick * tick_us_numerator);
    assert!(crate::mcu::program_flow::WATCHDOG_SERVICE_MAX_US as u64 * pclk_hz
        < earliest_reset_tick * tick_us_numerator);
};

/// WWDG1 setup for the 550 MHz clock tree:
/// PCLK3 = 137.5 MHz, WDGTB = /32768, counter 0x7F -> 0x3F.
/// Reset occurs after about 15.25 ms; refresh is possible after about 7.39 ms.
/// The software service interval is restricted to 8.5 through 14 ms.
pub fn ConfigureWwdg1For10MsProgramFlow(wwdg: &mut Wwdg) {
    wwdg.Configure(
        WWDG_RELOAD_COUNTER,
        WWDG_WINDOW_COUNTER,
        WWDG_PRESCALER::PCLK_DIV_32768,
        BIT::VALUE_0,
    );
}

pub fn StartWwdg1For10MsProgramFlow(wwdg: &mut Wwdg) {
    wwdg.Start(WWDG_RELOAD_COUNTER);
}
