#![allow(static_mut_refs)]

use core::cell::RefCell;

use crate::{drv::{
        cortex::Shared,
        flash::Flash,
        gpio::{
            Gpio,
            GPIOC_ADDR,
        },
        pwr::Pwr,
        wwdg::Wwdg,
        rcc::Rcc,
        scb::Scb,
        syscfg::Syscfg,
        systick::Systick
    },
    mcu::program_flow::ProgramFlowMonitor,
    os::{
        Application,
        Mutex
    }
};

pub mod peripherals;
pub mod deployment;
pub mod program_flow;
pub(crate) const TASK_COUNT: usize = 4;
pub(crate) const STACK_SIZE: usize = 256;
const PROGRAM_FLOW_START_US: u64 = 0;
const INITIAL_SCHEDULER_WAKEUP_US: u64 = 1_000;
#[unsafe(link_section = ".dtcm_bss.os")]
pub(crate) static Os: Mutex<RefCell<Option<Application<TASK_COUNT, STACK_SIZE>>>> = Mutex::new(RefCell::new(None));

pub static SCB: Shared<Scb> = Shared::new(Scb::new());
#[unsafe(link_section = ".dtcm_bss.systick")]
pub static SYSTICK: Shared<Systick> = Shared::new(Systick::new());
pub static RCC: Shared<Rcc> = Shared::new(Rcc::new());
pub static PWR: Shared<Pwr> = Shared::new(Pwr::new());
pub static SYSCFG: Shared<Syscfg> = Shared::new(Syscfg::new());
pub static FLASH: Shared<Flash> = Shared::new(Flash::new());
pub static GPIOC: Shared<Gpio> = Shared::new(Gpio::new(GPIOC_ADDR));
#[unsafe(link_section = ".dtcm_bss.wwdg")]
static WWDG: Shared<Wwdg> = Shared::new(Wwdg::new());
#[unsafe(link_section = ".dtcm_bss.pfm")]
static PFM: Shared<ProgramFlowMonitor> = Shared::new(ProgramFlowMonitor::new());

pub struct McuManager {
}

impl McuManager {

    pub fn McuClockTree_Init()
    {
        PWR.with(|pwr| {
            peripherals::pwr::ConfigureLdoSupply(pwr);
        });

        RCC.with(|rcc| {
            rcc.EnableSyscfgClock();
        });

        PWR.with(|pwr| {
            SYSCFG.with(|syscfg| {
                peripherals::pwr::ConfigureVoltageScale0For480Mhz(pwr, syscfg);
            });
        });

        FLASH.with(|flash| {
            peripherals::flash::ConfigureFor480Mhz(flash);
        });

        RCC.with(|rcc| {
            peripherals::rcc::ConfigurePll1Hse25MhzTo480Mhz(rcc);
        });
    }

    pub fn ProgramFlowSupervision_Start(systickClockHz: u32)
    {
        SYSTICK.with(|syst| {
            syst.Configure(systickClockHz);
        });

        RCC.with(|rcc| {
            rcc.EnableWwdg1Clock();
        });

        WWDG.with(|wwdg| {
            peripherals::wwdg::ConfigureWwdg1For10MsProgramFlow(wwdg);
        });

        {
            let mut os_ref = Os.borrow().borrow_mut();
            if let Some(os) = os_ref.as_mut() {
                os.SetCyclicReleaseBase(PROGRAM_FLOW_START_US);
                PFM.with(|pfm| {
                    pfm.ConfigureFromTasks(&os.tasks, PROGRAM_FLOW_START_US);
                });
            }
        }

        // The outer critical section keeps the watchdog and SysTick start writes
        // adjacent. Both hardware and software supervision therefore use epoch 0.
        WWDG.with(|wwdg| {
            SYSTICK.with(|syst| {
                peripherals::wwdg::StartWwdg1For10MsProgramFlow(wwdg);
                let armed = syst.SetTimerAt(
                    PROGRAM_FLOW_START_US.saturating_add(INITIAL_SCHEDULER_WAKEUP_US)
                );
                assert!(armed);
            });
        });
    }

    pub fn ProgramFlow_ReportTaskStart(taskId: u32)
    {
        let mut now_us = 0;
        SYSTICK.with(|syst| {
            now_us = syst.GetElapsedMicroseconds();
        });

        PFM.with(|pfm| {
            pfm.ReportTaskStart(taskId, now_us);
        });
    }

    pub fn ProgramFlow_ReportTaskEnd(taskId: u32)
    {
        let mut now_us = 0;
        SYSTICK.with(|syst| {
            now_us = syst.GetElapsedMicroseconds();
        });

        PFM.with(|pfm| {
            pfm.ReportTaskEnd(taskId, now_us);
        });
    }

    pub fn PFM_ValidateAndServiceWatchdog()
    {
        let mut now_us = 0;
        SYSTICK.with(|syst| {
            now_us = syst.GetElapsedMicroseconds();
        });

        PFM.with(|pfm| {
            WWDG.with(|wwdg| {
                pfm.ValidateAndServiceWatchdog(now_us, wwdg);
            });
        });
    }
}
