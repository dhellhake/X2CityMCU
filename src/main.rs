#![no_main]
#![no_std]
#![allow(non_upper_case_globals)]
#![allow(dead_code)]
#![allow(non_snake_case)]
#![allow(unused_assignments)]

pub mod drv;
pub mod mcu;
pub mod os;

use core::{arch::asm, panic::PanicInfo};

use crate::{
    drv::cortex::with_access_unchecked,
    mcu::{
        deployment::{tsk_1_5ms, tsk_pfm_10ms},
        McuManager, SCHEDULER,
    },
    os::{
        task::{TaskCycleTime, TaskRole},
        task_return_trap,
    },
};

// SysTick runs from the processor clock when CLKSOURCE is set.
const SYSTICK_CLOCK_HZ: u32 = 480_000_000;

extern "C" fn background(_tstmp: u64) {
    loop {
        core::hint::spin_loop();
    }
}

fn main() -> ! {
    // Reset briefly enables interrupts before entering main. Keep the
    // scheduler quiescent until PSP and CONTROL are installed below.
    unsafe { asm!("cpsid i", options(nostack, preserves_flags)) };

    // Select the context-preservation policy before application or interrupt
    // code can establish a floating-point context. This is a no-op when the
    // compiler target has no floating-point registers.
    unsafe { os::InitializeContextSwitching() };

    // SAFETY: interrupts have been masked above and no access token exists.
    // The scope ends before the final assembly block unmasks interrupts.
    let stack = unsafe {
        with_access_unchecked(|access| {
            /* Pre-OS Init */
            McuManager::McuClockTree_Init(access);
            McuManager::BoardLed_Init(access);
            McuManager::UartCommunication_Init(access);

            /* OS Init */
            let stack = SCHEDULER.with(access, |scheduler| {
                scheduler.SetTask(0, tsk_1_5ms, TaskCycleTime::_5MS, TaskRole::Supervised);
                scheduler.SetTask(
                    1,
                    tsk_pfm_10ms,
                    TaskCycleTime::_10MS,
                    TaskRole::Unsupervised,
                );
                scheduler.SetTask(
                    2,
                    background,
                    TaskCycleTime::NonCyclic,
                    TaskRole::Background,
                );
                scheduler.ActivateBackgroundTask()
            });

            /* Program Flow Start */
            McuManager::ProgramFlowSupervision_Start(access, SYSTICK_CLOCK_HZ);
            stack
        })
    };

    /* OS Start */
    // This is the final, non-returning operation in main. Once CONTROL selects
    // PSP, the compiler must not access main's MSP-based stack frame again.
    unsafe {
        asm!(
            "msr psp, r0",
            "movs r0, #2",
            "msr control, r0",
            "isb",
            "movs r0, #0",
            "movs r1, #0",
            "ldr r2, ={background}",
            "cpsie i",
            "blx r2",
            "ldr r2, ={task_return_trap}",
            "bx r2",
            in("r0") stack,
            background = sym background,
            task_return_trap = sym task_return_trap,
            options(noreturn),
        )
    }
}

#[panic_handler]
fn panic(_i: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub unsafe extern "C" fn HardFault() {
    loop {}
}
