#![no_main]
#![no_std]
#![allow(dead_code)]
#![allow(non_snake_case)]
#![allow(unused_assignments)]

use core::{arch::asm, panic::PanicInfo};

use crate::{
    mcu::{
        deployment::{background, tsk_1_5ms, tsk_2_10ms, tsk_program_flow_10ms},
        McuManager, SCHEDULER,
    },
    os::{
        task::{TaskCycleTime, TaskRole},
        task_return_trap,
    },
};

pub mod bms;
pub mod brkhdl;
mod drv;
pub mod mcu;
pub mod os;
pub mod vd18mt;

#[unsafe(no_mangle)]
pub extern "C" fn main() -> ! {
    // Reset keeps interrupts masked. Keep the scheduler quiescent until PSP
    // and CONTROL have been installed by the final OS handoff below.
    unsafe { asm!("cpsid i", options(nomem, nostack, preserves_flags)) };

    /* Pre-OS Init */
    McuManager::McuClockTree_Init();
    McuManager::BrkHdlInput_Init();
    McuManager::BoardLed_Init();
    McuManager::BmsCommunication_Init();
    McuManager::VD18MTCommunication_Init();

    /* OS Init */
    let stack = SCHEDULER.with(|scheduler| {
        scheduler.SetTask(0, tsk_1_5ms, TaskCycleTime::_5MS, TaskRole::Supervised);
        scheduler.SetTask(1, tsk_2_10ms, TaskCycleTime::_10MS, TaskRole::Supervised);
        scheduler.SetTask(
            2,
            tsk_program_flow_10ms,
            TaskCycleTime::_10MS,
            TaskRole::Unsupervised,
        );
        scheduler.SetTask(
            3,
            background,
            TaskCycleTime::NonCyclic,
            TaskRole::Background,
        );
        scheduler.ActivateBackgroundTask()
    });

    /* Post-OS Init */

    /* Scheduler / Program Flow Start */
    McuManager::Scheduler_Start();

    /* OS Start */
    // This is the final, non-returning operation in main: after selecting PSP,
    // the compiler must never try to access main's MSP-based stack frame again.
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
fn panic(_info: &PanicInfo) -> ! {
    loop {
        core::hint::spin_loop();
    }
}
