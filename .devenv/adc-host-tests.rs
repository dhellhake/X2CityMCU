#![allow(dead_code)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

mod drv {
    pub fn reg32(base: usize, offset: usize) -> *mut u32 {
        (base + offset) as *mut u32
    }
}

#[path = "../src/drv/adc/mod.rs"]
mod adc;
