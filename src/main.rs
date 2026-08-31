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
    unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };

    /* Pre-OS Init */
    McuManager::McuClockTree_Init();
    McuManager::BoardLed_Init();
    McuManager::UartCommunication_Init();

    /* OS Init */
    let stack = SCHEDULER.with(|scheduler| {
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
    McuManager::ProgramFlowSupervision_Start(SYSTICK_CLOCK_HZ);

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
