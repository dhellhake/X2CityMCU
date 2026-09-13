#![allow(non_snake_case)]

use crate::drv::{
    flash::{
        Flash,
        FLASH_LATENCY,
        FLASH_WRHIGHFREQ,
    },
};

pub fn ConfigureFor550Mhz(flash: &Flash) {
    // RM0468: VOS0, 275 MHz AXI clock (210 < AXI <= 275 MHz).
    flash.Set_ACR_WRHIGHFREQ(FLASH_WRHIGHFREQ::RANGE_3);
    flash.SetLatency(FLASH_LATENCY::WAIT_STATES_3);
}
