#![allow(non_snake_case)]

use crate::drv::{
    flash::{
        Flash,
        FLASH_LATENCY,
    },
};

pub fn ConfigureFor480Mhz(flash: &Flash) {
    flash.SetLatency(FLASH_LATENCY::WAIT_STATES_4);
}
