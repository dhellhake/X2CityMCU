#![allow(unused_variables)]

use crate::{
    drv::{cortex::Shared, scb::Scb, systick::Systick},
    os::{task::TaskStackStorage, Application},
};

pub mod deployment;

pub(crate) const TASK_COUNT: usize = 2;
pub(crate) const STACK_SIZE: usize = 256;

// The current RAM-launch clock contract. McuClockTree_Init must establish this
// rate once its intentionally missing clock-tree implementation is added.
pub(crate) const CORE_CLOCK_HZ: u32 = 528_000_000;

const SCHEDULER_EPOCH_US: u64 = 0;
const SVC_PRIORITY: u8 = 0xD0;
const SYSTICK_PRIORITY: u8 = 0xE0;
const PENDSV_PRIORITY: u8 = 0xF0;

pub(crate) static TASK_STACKS: TaskStackStorage<TASK_COUNT, STACK_SIZE> = TaskStackStorage::new();
pub(crate) static Os: Shared<Application<TASK_COUNT, STACK_SIZE>> =
    Shared::new(unsafe { Application::new(&TASK_STACKS) });

pub static SYSTICK: Shared<Systick> = Shared::new(Systick::new());
pub static SCB: Shared<Scb> = Shared::new(Scb::new());

pub struct McuManager {}

impl McuManager {
    pub fn McuClockTree_Init() {
        // Intentionally left as the project-specific clock implementation
        // point. The current RAM-launch setup is expected to run at
        // CORE_CLOCK_HZ.
    }

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

        Os.with(|os| {
            os.SetCyclicReleaseBase(SCHEDULER_EPOCH_US);
            os.InvokeSchedule(SCHEDULER_EPOCH_US);
        });
    }

    pub fn ProgramFlow_ReportTaskEnd(taskId: u32) {}

    pub fn ProgramFlow_ReportTaskStart(taskId: u32) {}
}
