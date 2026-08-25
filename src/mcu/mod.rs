#![allow(unused_variables)]

use crate::{
    drv::{cortex::Shared, nvic::Nvic, scb::Scb, systick::Systick},
    os::{task::Task, Scheduler},
};

mod bmscommunication;
mod boardled;
#[cfg(feature = "qspi-boot")]
mod boot;
mod clocktree;
pub mod deployment;

use clocktree::CORE_CLOCK_HZ;

pub(crate) const TASK_COUNT: usize = 3;
pub(crate) const TASK_5MS_STACK_SIZE: usize = 256;
pub(crate) const TASK_10MS_STACK_SIZE: usize = 256;
pub(crate) const TASK_BACKGROUND_STACK_SIZE: usize = 256;

const SCHEDULER_EPOCH_US: u64 = 0;
const SVC_PRIORITY: u8 = 0xD0;
const SYSTICK_PRIORITY: u8 = 0xE0;
const PENDSV_PRIORITY: u8 = 0xF0;

// Tasks are stable objects outside Scheduler. Each one owns its stack and may
// select a different compile-time capacity; Scheduler stores only their
// handles in scheduler order.
pub(crate) static TASK_5MS: Task<TASK_5MS_STACK_SIZE> = Task::new();
pub(crate) static TASK_10MS: Task<TASK_10MS_STACK_SIZE> = Task::new();
pub(crate) static TASK_BACKGROUND: Task<TASK_BACKGROUND_STACK_SIZE> = Task::new();

pub(crate) static SCHEDULER: Shared<Scheduler<TASK_COUNT>> = Shared::new(unsafe {
    Scheduler::new([
        TASK_5MS.handle(),
        TASK_10MS.handle(),
        TASK_BACKGROUND.handle(),
    ])
});

pub static SYSTICK: Shared<Systick> = Shared::new(Systick::new());
pub static SCB: Shared<Scb> = Shared::new(Scb::new());
pub static NVIC: Shared<Nvic> = Shared::new(Nvic::new());

// Keep this field group word-aligned inside UartByteReadResult. Without the
// explicit alignment, arrays have a six-byte stride and Rust can emit an
// unaligned word store for the four flags in Cortex-M7 TCM.
#[repr(C, align(4))]
#[derive(Copy, Clone)]
pub struct USART_ERROR_FLAGS {
    pub parityError: bool,
    pub framingError: bool,
    pub noiseDetected: bool,
    pub overrunError: bool,
}

impl USART_ERROR_FLAGS {
    pub const fn Any(self) -> bool {
        self.parityError || self.framingError || self.noiseDetected || self.overrunError
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct UartByteReadResult {
    pub Byte: Option<u8>,
    pub Errors: USART_ERROR_FLAGS,
}

const _: () = {
    assert!(core::mem::align_of::<USART_ERROR_FLAGS>() == 4);
    assert!(core::mem::size_of::<USART_ERROR_FLAGS>() == 4);
    assert!(core::mem::align_of::<UartByteReadResult>() == 4);
    assert!(core::mem::size_of::<UartByteReadResult>() == 8);
    assert!(core::mem::offset_of!(UartByteReadResult, Errors) == 4);
};

impl UartByteReadResult {
    pub const fn HasError(self) -> bool {
        self.Errors.Any()
    }
}

pub struct McuManager {}

impl McuManager {
    pub fn Scheduler_Start() {
        SCB.with(|scb| {
            // RT1061 implements the upper four priority bits. Keep SVC and
            // SysTick above PendSV so a context switch only happens after the
            // scheduling handler has released the OS state.
            scb.Set_SHPR2_PRI_11(SVC_PRIORITY);
            scb.Set_SHPR3_PRI_14(PENDSV_PRIORITY);
            scb.Set_SHPR3_PRI_15(SYSTICK_PRIORITY);
        });

        SYSTICK.with(|syst| syst.Configure(CORE_CLOCK_HZ));

        SCHEDULER.with(|scheduler| {
            scheduler.SetCyclicReleaseBase(SCHEDULER_EPOCH_US);
            scheduler.InvokeSchedule(SCHEDULER_EPOCH_US);
        });
    }

    pub fn ProgramFlow_ReportTaskEnd(taskId: u32) {}

    pub fn ProgramFlow_ReportTaskStart(taskId: u32) {}
}
