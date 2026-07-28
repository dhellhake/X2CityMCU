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

/// WWDG1 setup for the 480 MHz clock tree:
/// PCLK3 = 120 MHz, WDGTB = /32768, counter 0x7F -> 0x3F.
/// This gives an approximate reset timeout of 17.5 ms and opens the
/// refresh window after roughly 8.2 ms.
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
