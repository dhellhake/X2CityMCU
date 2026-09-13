#![allow(static_mut_refs)]

use crate::{
    drv::{
        cortex::{with_access, AccessToken, Shared},
        flash::Flash,
        gpio::{Gpio, GPIOA_ADDR, GPIOE_ADDR},
        pwr::Pwr,
        rcc::Rcc,
        scb::Scb,
        syscfg::Syscfg,
        systick::{Systick, TimerArmResult},
        usart::{Usart, USART1_ADDR},
        wwdg::Wwdg,
    },
    mcu::program_flow::ProgramFlowMonitor,
    os::{task::Task, Scheduler},
};

mod boardled;
pub mod deployment;
pub mod peripherals;
pub mod program_flow;
pub(crate) const TASK_COUNT: usize = 3;
pub(crate) const STACK_SIZE: usize = 256;
const PROGRAM_FLOW_START_US: u64 = 0;
const INITIAL_SCHEDULER_WAKEUP_US: u64 = 1_000;
const SVC_PRIORITY: u8 = 0xD0;
const SYSTICK_PRIORITY: u8 = 0xE0;
const PENDSV_PRIORITY: u8 = 0xF0;

#[unsafe(link_section = ".dtcm_bss.os")]
pub(crate) static TASK_5MS: Task<STACK_SIZE> = Task::new();
#[unsafe(link_section = ".dtcm_bss.os")]
pub(crate) static TASK_PROGRAM_FLOW: Task<STACK_SIZE> = Task::new();
#[unsafe(link_section = ".dtcm_bss.os")]
pub(crate) static TASK_BACKGROUND: Task<STACK_SIZE> = Task::new();

#[unsafe(link_section = ".dtcm_data.os")]
pub(crate) static SCHEDULER: Shared<Scheduler<TASK_COUNT>> = unsafe {
    Shared::new(Scheduler::new([
        TASK_5MS.handle(),
        TASK_PROGRAM_FLOW.handle(),
        TASK_BACKGROUND.handle(),
    ]))
};

pub static SCB: Shared<Scb> = unsafe { Shared::new(Scb::new()) };
#[unsafe(link_section = ".dtcm_bss.systick")]
pub static SYSTICK: Shared<Systick> = unsafe { Shared::new(Systick::new()) };
pub static RCC: Shared<Rcc> = unsafe { Shared::new(Rcc::new()) };
pub static PWR: Shared<Pwr> = unsafe { Shared::new(Pwr::new()) };
pub static SYSCFG: Shared<Syscfg> = unsafe { Shared::new(Syscfg::new()) };
pub static FLASH: Shared<Flash> = unsafe { Shared::new(Flash::new()) };
pub static GPIOA: Shared<Gpio> = unsafe { Shared::new(Gpio::new(GPIOA_ADDR)) };
pub static GPIOE: Shared<Gpio> = unsafe { Shared::new(Gpio::new(GPIOE_ADDR)) };
pub static USART1: Shared<Usart> = unsafe { Shared::new(Usart::new(USART1_ADDR)) };
#[unsafe(link_section = ".dtcm_bss.wwdg")]
static WWDG: Shared<Wwdg> = unsafe { Shared::new(Wwdg::new()) };
#[unsafe(link_section = ".dtcm_bss.pfm")]
static PFM: Shared<ProgramFlowMonitor> = unsafe { Shared::new(ProgramFlowMonitor::new()) };

pub struct McuManager {}

impl McuManager {
    pub fn McuClockTree_Init(access: &mut AccessToken) {
        RCC.with(access, |rcc| {
            peripherals::rcc::SelectHsiForClockConfiguration(rcc);
            rcc.EnableSyscfgClock();
        });

        SYSCFG.with(access, |syscfg| {
            assert!(syscfg.IsCpuFrequencyBoostEnabled(), "550 MHz requires CPU_FREQ_BOOST");
        });

        PWR.with(access, |pwr| {
            peripherals::pwr::ConfigureLdoSupply(pwr);
        });

        PWR.with(access, |pwr| {
            peripherals::pwr::PrepareVoltageScale0For550Mhz(pwr);
        });

        PWR.with(access, |pwr| {
            peripherals::pwr::WaitForVoltageScale0Ready(pwr);
        });

        FLASH.with(access, |flash| {
            peripherals::flash::ConfigureFor550Mhz(flash);
        });

        RCC.with(access, |rcc| {
            peripherals::rcc::ConfigurePll1Hse25MhzTo550Mhz(rcc);
        });
    }

    pub fn UartCommunication_Init(access: &mut AccessToken) {
        RCC.with(access, |rcc| {
            peripherals::usart::ConfigureUsart1DebugHeaderClocks(rcc);
        });

        GPIOA.with(access, |gpioa| {
            peripherals::usart::ConfigureUsart1DebugHeaderPins(gpioa);
        });

        USART1.with(access, |usart1| {
            peripherals::usart::ConfigureUsart1DebugHeader115200(usart1);
        });
    }

    pub fn UartCommunication_Write(bytes: &[u8]) {
        for byte in bytes {
            while !Self::UartCommunication_TryWriteByte(*byte) {}
        }

        while !with_access(|access| USART1.with(access, |usart1| usart1.IsTransmissionComplete())) {
        }
    }

    pub fn UartCommunication_TryReadByte() -> Option<u8> {
        with_access(|access| {
            USART1.with(access, |usart1| {
                usart1.TryReadWord().and_then(|word| {
                    if word <= u8::MAX as u16 {
                        Some(word as u8)
                    } else {
                        None
                    }
                })
            })
        })
    }

    pub fn UartCommunication_TryWriteByte(byte: u8) -> bool {
        with_access(|access| USART1.with(access, |usart1| usart1.TryWriteWord(byte as u16)))
    }

    pub fn ProgramFlowSupervision_Start(access: &mut AccessToken, systickClockHz: u32) {
        SCB.with(access, |scb| {
            // Cortex-M7 implements priority preemption numerically: keep SVC
            // and SysTick above PendSV so scheduling state is complete before
            // the context switch executes.
            scb.Set_SHPR2_PRI_11(SVC_PRIORITY);
            scb.Set_SHPR3_PRI_14(PENDSV_PRIORITY);
            scb.Set_SHPR3_PRI_15(SYSTICK_PRIORITY);
        });

        SYSTICK.with(access, |syst| {
            syst.Configure(systickClockHz);
        });

        RCC.with(access, |rcc| {
            rcc.EnableWwdg1SystemReset();
            rcc.EnableWwdg1Clock();
        });

        WWDG.with(access, |wwdg| {
            peripherals::wwdg::ConfigureWwdg1For10MsProgramFlow(wwdg);
        });

        let taskConfigurations = SCHEDULER.with(access, |scheduler| {
            scheduler.SetCyclicReleaseBase(PROGRAM_FLOW_START_US);
            scheduler.GetTaskConfigurations()
        });
        PFM.with(access, |pfm| {
            pfm.ConfigureFromTasks(&taskConfigurations, PROGRAM_FLOW_START_US);
        });

        // The outer critical section keeps the watchdog and SysTick start writes
        // adjacent. Both hardware and software supervision therefore use epoch 0.
        WWDG.with(access, |wwdg| {
            peripherals::wwdg::StartWwdg1For10MsProgramFlow(wwdg);
        });
        SYSTICK.with(access, |syst| {
            match syst.SetTimerAt(PROGRAM_FLOW_START_US.saturating_add(INITIAL_SCHEDULER_WAKEUP_US))
            {
                TimerArmResult::Armed => {}
                TimerArmResult::ImmediateRescanRequired => {
                    panic!("initial scheduler deadline is not safely armable")
                }
            }
        });
    }

    pub fn ProgramFlow_ReportTaskStart(access: &mut AccessToken, taskId: u32) {
        let mut now_us = 0;
        SYSTICK.with(access, |syst| {
            now_us = syst.GetElapsedMicroseconds();
        });

        PFM.with(access, |pfm| {
            pfm.ReportTaskStart(taskId, now_us);
        });
    }

    pub fn ProgramFlow_ReportTaskEnd(access: &mut AccessToken, taskId: u32) {
        let mut now_us = 0;
        SYSTICK.with(access, |syst| {
            now_us = syst.GetElapsedMicroseconds();
        });

        PFM.with(access, |pfm| {
            pfm.ReportTaskEnd(taskId, now_us);
        });
    }

    pub fn PFM_ValidateAndServiceWatchdog(access: &mut AccessToken) {
        let mut now_us = 0;
        SYSTICK.with(access, |syst| {
            now_us = syst.GetElapsedMicroseconds();
        });

        let serviceAuthorized = PFM.with(access, |pfm| pfm.AuthorizeWatchdogService(now_us));

        if serviceAuthorized {
            WWDG.with(access, |wwdg| {
                wwdg.Refresh(peripherals::wwdg::WWDG_RELOAD_COUNTER);
            });
            PFM.with(access, |pfm| {
                pfm.CompleteWatchdogService();
            });
        }
    }
}
