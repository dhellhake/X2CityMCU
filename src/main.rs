#![no_main]
#![no_std]
#![allow(non_upper_case_globals)]
#![allow(dead_code)]
#![allow(non_snake_case)]
#![allow(unused_assignments)]

pub mod os;
pub mod mcu;
pub mod drv;
pub mod vd18mt;

use core::{
    arch::asm,
    ops::DerefMut,
    panic::PanicInfo
};

use crate::{
    mcu::{
        McuManager, Os,
        deployment::{
            tsk_1_5ms,
            tsk_2_10ms,
            tsk_pfm_10ms,
            VD18MT,
        }
    }, os::{
        Application,
        task::{
            TaskCycleTime,
            TaskRole,
            TaskStatus
        }
    },
    vd18mt::{
        VD18MTInterface,
        VT8MTBatteryIndication,
        VT8MTBatteryCurrent,
        VT8MTControllerStatusFlags,
        VT8MTData,
        VT8MTErrorCode,
    },
};

// SysTick runs from the processor clock when CLKSOURCE is set.
const SYSTICK_CLOCK_HZ: u32 = 480_000_000;

fn background(_tstmp: u64) {
    loop {}
}



fn main() -> ! {
    
    /* Pre-Os Init */
    McuManager::McuClockTree_Init();
    McuManager::UartCommunication_Init();
    McuManager::VD18MTCommunication_Init();

    /* OS Init */
    let mut stack: u32 = 0;
    Os.borrow().replace(Some(Application::new()));
    if let Some(ref mut os) = Os.borrow().borrow_mut().deref_mut() {
        os.SetTask(0, tsk_1_5ms, TaskCycleTime::_5MS, TaskRole::Supervised);
        os.SetTask(1, tsk_2_10ms, TaskCycleTime::_10MS, TaskRole::Supervised);
        os.SetTask(2, tsk_pfm_10ms, TaskCycleTime::_10MS, TaskRole::Unsupervised);
        os.SetTask(3, background, TaskCycleTime::NonCyclic, TaskRole::Background);
        os.tasks[os.taskIdx as usize].status = TaskStatus::Active;
        stack = os.tasks[os.taskIdx as usize].sp;
    }    
    
    /* Post-OS Init */
    let mut vd18mt = VD18MTInterface::new();
    vd18mt.VD18MTInterface_SetVT8MTData(VT8MTData {
        BatteryIndication: VT8MTBatteryIndication::FourSixths,
        ControllerStatus: VT8MTControllerStatusFlags::ControllerWorking,
        BatteryCurrentAmperes: VT8MTBatteryCurrent::FromAmperes(0.0),
        ErrorCode: VT8MTErrorCode::NoError,
        SpeedKmh: 0,
    });
    VD18MT.borrow().replace(Some(vd18mt));

    /* Program Flow Start */
    McuManager::ProgramFlowSupervision_Start(SYSTICK_CLOCK_HZ);
    
    /* OS Start */    
    unsafe {
        asm!("msr psp, {0}", in(reg) stack);
        asm!("msr control, {0}", in(reg) 0x2);
        asm!("isb");
    }

    background(0);

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
