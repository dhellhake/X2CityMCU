#![no_main]
#![no_std]
#![allow(non_upper_case_globals)]
#![allow(dead_code)]
#![allow(non_snake_case)]
#![allow(unused_assignments)]

pub mod drv;

use core::panic::PanicInfo;

fn main() -> ! {
    

    loop {}
}

#[panic_handler]
fn panic(_i: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub unsafe extern "C" fn HardFault() {
    loop {}
}
