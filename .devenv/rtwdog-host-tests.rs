#![allow(dead_code)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

// Host shims let the production RTWDOG module compile without touching MMIO.
// Its tests exercise pure control-word construction and protected key values.
mod drv {
    pub mod cortex {
        pub fn with_interrupts_masked<R>(operation: impl FnOnce() -> R) -> R {
            operation()
        }
    }

    pub const fn reg16(base: usize, offset: usize) -> *mut u16 {
        (base + offset) as *mut u16
    }

    pub const fn reg32(base: usize, offset: usize) -> *mut u32 {
        (base + offset) as *mut u32
    }
}

#[path = "../src/drv/rtwdog/mod.rs"]
mod rtwdog;
