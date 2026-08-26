#![allow(unused_variables)]

use crate::{
    drv::{
        cortex::Shared,
        nvic::Nvic,
        rtwdog::{
            Rtwdog, RTWDOG_CLOCK_SOURCE, RTWDOG_CONFIGURATION, RTWDOG_PRESCALER, RTWDOG_TEST_MODE,
        },
        scb::Scb,
        src::Src,
        systick::Systick,
    },
    os::{task::Task, Scheduler},
};

mod bmscommunication;
mod boardled;
#[cfg(feature = "qspi-boot")]
mod boot;
mod clocktree;
pub mod deployment;
mod programflow;

use clocktree::CORE_CLOCK_HZ;
pub use programflow::{
    ProgramFlowCheckpoint, ProgramFlowCheckpointKind, ProgramFlowDiagnostic, ProgramFlowFault,
    ProgramFlowSnapshot, ProgramFlowState,
};

pub(crate) const TASK_COUNT: usize = 4;
pub(crate) const TASK_5MS_STACK_SIZE: usize = 256;
pub(crate) const TASK_10MS_STACK_SIZE: usize = 256;
pub(crate) const TASK_PROGRAM_FLOW_STACK_SIZE: usize = 256;
pub(crate) const TASK_BACKGROUND_STACK_SIZE: usize = 256;

// RT1061 automatically falls back from the 32.768 kHz crystal to its nominal
// 40 kHz ring oscillator. NXP characterizes that oscillator at approximately
// +/-50%, so 60 kHz is the conservative engineering bound used for the
// minimum-timeout proof below (the data sheet does not specify a hard limit).
const RTWDOG_CLOCK_MAX_ENGINEERING_HZ: u32 = 60_000;
const RTWDOG_TIMEOUT_TICKS: u16 = 3_277;
const RTWDOG_ALIGNMENT_MAX_US: u64 = 500;
const SVC_PRIORITY: u8 = 0xD0;
const SYSTICK_PRIORITY: u8 = 0xE0;
const PENDSV_PRIORITY: u8 = 0xF0;

const _: () = {
    let timeoutUs =
        RTWDOG_TIMEOUT_TICKS as u64 * 1_000_000 / RTWDOG_CLOCK_MAX_ENGINEERING_HZ as u64;
    assert!(timeoutUs > programflow::WATCHDOG_SERVICE_MAX_US as u64 + RTWDOG_ALIGNMENT_MAX_US);
};

// Tasks are stable objects outside Scheduler. Each one owns its stack and may
// select a different compile-time capacity; Scheduler stores only their
// handles in scheduler order.
pub(crate) static TASK_5MS: Task<TASK_5MS_STACK_SIZE> = Task::new();
pub(crate) static TASK_10MS: Task<TASK_10MS_STACK_SIZE> = Task::new();
pub(crate) static TASK_PROGRAM_FLOW: Task<TASK_PROGRAM_FLOW_STACK_SIZE> = Task::new();
pub(crate) static TASK_BACKGROUND: Task<TASK_BACKGROUND_STACK_SIZE> = Task::new();

pub(crate) static SCHEDULER: Shared<Scheduler<TASK_COUNT>> = Shared::new(unsafe {
    Scheduler::new([
        TASK_5MS.handle(),
        TASK_10MS.handle(),
        TASK_PROGRAM_FLOW.handle(),
        TASK_BACKGROUND.handle(),
    ])
});

pub static SYSTICK: Shared<Systick> = Shared::new(Systick::new());
pub static SCB: Shared<Scb> = Shared::new(Scb::new());
pub static NVIC: Shared<Nvic> = Shared::new(Nvic::new());
// Only the program-flow controller may refresh RTWDOG or change its reset
// route. Keeping these global instances private preserves the established
// peripheral-access model without exposing a path around supervision.
static RTWDOG: Shared<Rtwdog> = Shared::new(unsafe { Rtwdog::new() });
static SRC: Shared<Src> = Shared::new(unsafe { Src::new() });
static PROGRAM_FLOW_START_GUARD: Shared<programflow::ProgramFlowStartGuard> =
    Shared::new(programflow::ProgramFlowStartGuard::new());
static PROGRAM_FLOW_MONITOR: Shared<programflow::ProgramFlowMonitor> =
    Shared::new(programflow::ProgramFlowMonitor::new());

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
        // The scheduler owns the complete operational supervision handoff.
        // Re-entry must not restart the watchdog counter independently from
        // the already-running cyclic timeline.
        if !PROGRAM_FLOW_START_GUARD.with(|guard| guard.EnterRunning()) {
            SCB.with(|scb| scb.SystemReset());
        }

        SCB.with(|scb| {
            // RT1061 implements the upper four priority bits. Keep SVC and
            // SysTick above PendSV so a context switch only happens after the
            // scheduling handler has released the OS state.
            scb.Set_SHPR2_PRI_11(SVC_PRIORITY);
            scb.Set_SHPR3_PRI_14(PENDSV_PRIORITY);
            scb.Set_SHPR3_PRI_15(SYSTICK_PRIORITY);
        });

        let taskConfigurations = SCHEDULER.with(|scheduler| scheduler.GetTaskConfigurations());

        let (resetStatus, resetRouteReady) = SRC.with(|src| {
            let resetStatus = src.ReadRaw_SRSR();
            src.SetRtwdogResetMasked(false);
            // Preserve the complete cause bitmask in the monitor, then clear
            // all captured W1C flags so the next boot observes fresh causes.
            src.ClearResetStatus(resetStatus);
            (resetStatus, !src.IsRtwdogResetMasked())
        });

        if !resetRouteReady {
            SCB.with(|scb| scb.SystemReset());
        }

        let configured = RTWDOG.with(|rtwdog| {
            rtwdog.Configure(RTWDOG_CONFIGURATION {
                // On RT1061, INTCLK is the 32.768 kHz crystal-derived source
                // with automatic 32 kHz RC-oscillator fallback. It therefore
                // remains independent from the overclocked CPU/IPG tree.
                clockSource: RTWDOG_CLOCK_SOURCE::INTERNAL_CLOCK,
                prescaler: RTWDOG_PRESCALER::DIVIDE_1,
                timeoutTicks: RTWDOG_TIMEOUT_TICKS,
                windowTicks: 0,
                enableInWait: true,
                enableInStop: false,
                // Halted debug sessions must not create artificial resets.
                enableInDebug: false,
                enableInterrupt: false,
                enableWindow: false,
                // Reset() may also be entered directly by a RAM-debug launch.
                // UPDATE therefore remains permitted so startup can return
                // the peripheral to its disabled handoff state. Every normal
                // refresh still verifies CS, TOVAL and WIN against the private
                // software-owned configuration first.
                allowUpdate: true,
                testMode: RTWDOG_TEST_MODE::DISABLED,
            })
        });

        if !configured {
            SCB.with(|scb| scb.SystemReset());
        }

        // Start the hardware-backed timebase only after the fallible RTWDOG
        // update. It now spans just the bounded alignment handoff, and no task
        // can run because interrupts remain masked until main's final switch.
        SYSTICK.with(|systick| {
            systick.Configure(CORE_CLOCK_HZ);
            systick.StartTimebase();
        });

        // Capture one shared epoch before the initialization-only refresh.
        // The monitor is fully validated and the release base is committed
        // before the refresh, so only bounded non-failing scheduler arming
        // remains after RTWDOG's operational counter origin is established.
        let schedulerEpochUs = SYSTICK.with(|systick| systick.GetElapsedMicroseconds());
        let monitorReady = PROGRAM_FLOW_MONITOR.with(|monitor| {
            monitor.ConfigureAtSchedulerEpoch(&taskConfigurations, schedulerEpochUs, resetStatus)
        });

        if !monitorReady {
            SCB.with(|scb| scb.SystemReset());
        }

        SCHEDULER.with(|scheduler| scheduler.SetCyclicReleaseBase(schedulerEpochUs));

        // Configure() has already started the counter. This deliberately
        // separate non-task refresh aligns its operational interval to the
        // scheduler epoch above. The complete setup-to-refresh span is
        // measured and bounded instead of assumed from instruction timing.
        let aligned = RTWDOG.with(|rtwdog| rtwdog.Refresh());
        let alignmentEndUs = SYSTICK.with(|systick| systick.GetElapsedMicroseconds());
        if !aligned
            || alignmentEndUs < schedulerEpochUs
            || alignmentEndUs - schedulerEpochUs > RTWDOG_ALIGNMENT_MAX_US
        {
            SCB.with(|scb| scb.SystemReset());
        }

        SCHEDULER.with(|scheduler| {
            scheduler.InvokeSchedule(schedulerEpochUs);
        });
    }

    #[inline(never)]
    pub fn ProgramFlow_ReportTaskEnd(taskId: u32) {
        SYSTICK.with(|systick| {
            let nowUs = systick.GetElapsedMicroseconds();
            PROGRAM_FLOW_MONITOR.with(|monitor| monitor.ReportTaskEnd(taskId, nowUs));
        });
    }

    #[inline(never)]
    pub fn ProgramFlow_ReportTaskStart(taskId: u32) {
        SYSTICK.with(|systick| {
            let nowUs = systick.GetElapsedMicroseconds();
            PROGRAM_FLOW_MONITOR.with(|monitor| monitor.ReportTaskStart(taskId, nowUs));
        });
    }

    #[inline(never)]
    pub fn ProgramFlow_ValidateAndServiceWatchdog(scheduledReleaseUs: u64) {
        SYSTICK.with(|systick| {
            let nowUs = systick.GetElapsedMicroseconds();
            PROGRAM_FLOW_MONITOR.with(|monitor| {
                if monitor.AuthorizeWatchdogService(scheduledReleaseUs, nowUs) {
                    let resetRouteReady = SRC.with(|src| !src.IsRtwdogResetMasked());
                    if resetRouteReady && RTWDOG.with(|rtwdog| rtwdog.Refresh()) {
                        monitor.ConfirmWatchdogService(nowUs);
                    } else {
                        monitor.RejectWatchdogService(nowUs);
                        // A disabled watchdog or masked reset route cannot be
                        // trusted to recover the system by timing out.
                        SCB.with(|scb| scb.SystemReset());
                    }
                }
            });
        });
    }

    pub fn ProgramFlow_GetSnapshot() -> ProgramFlowSnapshot {
        PROGRAM_FLOW_MONITOR.with(|monitor| monitor.GetSnapshot())
    }
}
