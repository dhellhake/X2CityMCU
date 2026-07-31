#![allow(static_mut_refs)]

use core::cell::RefCell;

use crate::{drv::{
        cortex::Shared,
        flash::Flash,
        gpio::{
            Gpio,
            GPIOA_ADDR,
            GPIOD_ADDR,
        },
        pwr::Pwr,
        wwdg::Wwdg,
        rcc::Rcc,
        scb::Scb,
        syscfg::Syscfg,
        systick::Systick,
        usart::{
            Usart,
            USART1_ADDR,
            USART2_ADDR,
        },
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
pub static GPIOA: Shared<Gpio> = Shared::new(Gpio::new(GPIOA_ADDR));
pub static GPIOD: Shared<Gpio> = Shared::new(Gpio::new(GPIOD_ADDR));
pub static USART1: Shared<Usart> = Shared::new(Usart::new(USART1_ADDR));
pub static USART2: Shared<Usart> = Shared::new(Usart::new(USART2_ADDR));
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

    pub fn UartCommunication_Init()
    {
        RCC.with(|rcc| {
            peripherals::usart::ConfigureUsart1DebugHeaderClocks(rcc);
        });

        GPIOA.with(|gpioa| {
            peripherals::usart::ConfigureUsart1DebugHeaderPins(gpioa);
        });

        USART1.with(|usart1| {
            peripherals::usart::ConfigureUsart1DebugHeader115200(usart1);
        });
    }

    pub fn UartCommunication_Write(bytes: &[u8])
    {
        for byte in bytes {
            while !Self::UartCommunication_TryWriteByte(*byte) {}
        }

        while !USART1.with(|usart1| usart1.IsTransmissionComplete()) {}
    }

    pub fn UartCommunication_TryReadByte() -> Option<u8>
    {
        USART1.with(|usart1| {
            usart1.TryReadWord().and_then(|word| {
                if word <= u8::MAX as u16 {
                    Some(word as u8)
                } else {
                    None
                }
            })
        })
    }

    pub fn UartCommunication_TryWriteByte(byte: u8) -> bool
    {
        USART1.with(|usart1| usart1.TryWriteWord(byte as u16))
    }

    pub fn VD18MTCommunication_Init()
    {
        RCC.with(|rcc| {
            peripherals::usart::ConfigureUsart2Vd18mtClocks(rcc);
        });

        GPIOA.with(|gpioa| {
            peripherals::usart::ConfigureUsart2Vd18mtRxPin(gpioa);
        });

        GPIOD.with(|gpiod| {
            peripherals::usart::ConfigureUsart2Vd18mtTxPin(gpiod);
        });

        USART2.with(|usart2| {
            peripherals::usart::ConfigureUsart2Vd18mt9600(usart2);
        });
    }

    pub fn VD18MTCommunication_Write(bytes: &[u8])
    {
        for byte in bytes {
            while !Self::VD18MTCommunication_TryWriteByte(*byte) {}
        }

        while !USART2.with(|usart2| usart2.IsTransmissionComplete()) {}
    }

    pub fn VD18MTCommunication_TryReadByte() -> Option<u8>
    {
        USART2.with(|usart2| {
            usart2.TryReadWord().and_then(|word| {
                if word <= u8::MAX as u16 {
                    Some(word as u8)
                } else {
                    None
                }
            })
        })
    }

    pub fn VD18MTCommunication_TryWriteByte(byte: u8) -> bool
    {
        USART2.with(|usart2| usart2.TryWriteWord(byte as u16))
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
