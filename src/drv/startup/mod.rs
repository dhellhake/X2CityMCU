#![allow(non_upper_case_globals)]
#![allow(dead_code)]
#![allow(unreachable_code)]
#![allow(static_mut_refs)]

use core::{
    arch::asm,
    ptr::{addr_of, addr_of_mut, read_volatile, write_volatile},
};

use crate::main;

unsafe extern "C" {
    fn NonMaskableInt();
    fn HardFault();
    fn MemManage();
    fn BusFault();
    fn UsageFault();
    fn SVCall();
    fn DebugMonitor();
    fn PendSV();
    fn SysTick();
    fn DefaultHandler();
}

#[repr(C)]
pub union Vector {
    handler: unsafe extern "C" fn(),
    reserved: usize,
}

#[doc(hidden)]
#[unsafe(link_section = ".vectors.exception_table")]
#[no_mangle]
pub static __exception_table: [Vector; 15] = [
    Vector { handler: Reset },
    Vector {
        handler: NonMaskableInt,
    },
    Vector { handler: HardFault },
    Vector { handler: MemManage },
    Vector { handler: BusFault },
    Vector {
        handler: UsageFault,
    },
    Vector { reserved: 0 },
    Vector { reserved: 0 },
    Vector { reserved: 0 },
    Vector { reserved: 0 },
    Vector { handler: SVCall },
    Vector {
        handler: DebugMonitor,
    },
    Vector { reserved: 0 },
    Vector { handler: PendSV },
    Vector { handler: SysTick },
];

const SCB_VTOR: *mut u32 = 0xE000_ED08 as *mut u32;
const SCB_CPACR: *mut u32 = 0xE000_ED88 as *mut u32;
const EXTERNAL_INTERRUPT_COUNT: usize = 150;

#[no_mangle]
pub unsafe extern "C" fn Reset() {
    unsafe extern "C" {
        static mut _sidata: u32;
        static mut _srelocate: u32;
        static mut _erelocate: u32;
        static mut _szero: u32;
        static mut _ezero: u32;
        static __vector_table_flash_start: u32;
        static __vector_table_flash_end: u32;
        static mut __vector_table_ram_start: u32;
    }

    asm!("cpsid i", options(nostack, preserves_flags));

    /* Enable the Cortex-M7 FPU before any hard-float code can run. */
    write_volatile(SCB_CPACR, read_volatile(SCB_CPACR) | (0b1111 << 20));
    asm!("dsb 0xF", options(nomem, nostack, preserves_flags));
    asm!("isb 0xF", options(nomem, nostack, preserves_flags));

    /* Relocate .data from ROM to RAM */
    {
        let mut src = addr_of!(_sidata);
        let mut dst = addr_of_mut!(_srelocate);
        let end = addr_of!(_erelocate);

        while (dst as *const u32) < end {
            write_volatile(dst, read_volatile(src));
            dst = dst.add(1);
            src = src.add(1);
        }
    }

    /* Zero .bss */
    {
        let mut dst = addr_of_mut!(_szero);
        let end = addr_of!(_ezero);

        while (dst as *const u32) < end {
            write_volatile(dst, 0);
            dst = dst.add(1);
        }
    }

    /* Copy the vector table to RAM so handlers can be patched at runtime. */
    {
        let src = addr_of!(__vector_table_flash_start) as *const u32;
        let end = addr_of!(__vector_table_flash_end) as *const u32;
        let dst = addr_of_mut!(__vector_table_ram_start);

        let words = end.offset_from(src) as usize;
        let dst_addr = dst as usize;

        debug_assert_eq!(dst_addr % 1024, 0);

        for i in 0..words {
            write_volatile(dst.add(i), read_volatile(src.add(i)));
        }

        write_volatile(SCB_VTOR, dst_addr as u32);
        asm!("dsb 0xF", options(nomem, nostack, preserves_flags));
        asm!("isb 0xF", options(nomem, nostack, preserves_flags));
    }

    asm!("cpsie i", options(nostack, preserves_flags));

    main();

    loop {
        asm!("wfi", options(nomem, nostack, preserves_flags));
    }
}

#[no_mangle]
pub unsafe extern "C" fn DefaultHandler_() -> ! {
    loop {
        asm!("wfi", options(nomem, nostack, preserves_flags));
    }
}

#[unsafe(link_section = ".vectors.interrupt_table")]
#[no_mangle]
pub static __interrupt_table: [unsafe extern "C" fn(); EXTERNAL_INTERRUPT_COUNT] =
    [DefaultHandler; EXTERNAL_INTERRUPT_COUNT];
