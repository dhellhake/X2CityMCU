#![allow(static_mut_refs)]

use crate::{
    drv::{
        cortex::Shared,
        flash::Flash,
        gpio::{Gpio, GPIOA_ADDR, GPIOB_ADDR, GPIOD_ADDR},
        pwr::Pwr,
        rcc::Rcc,
        scb::Scb,
        syscfg::Syscfg,
        systick::Systick,
        usart::{Usart, USART1_ADDR, USART2_ADDR, USART3_ADDR, USART_ERROR_FLAGS},
        wwdg::Wwdg,
    },
    mcu::program_flow::ProgramFlowMonitor,
    os::{task::Task, Scheduler},
};

pub mod deployment;
pub mod peripherals;
pub mod program_flow;
pub(crate) const TASK_COUNT: usize = 4;
pub(crate) const STACK_SIZE: usize = 256;
const PROGRAM_FLOW_START_US: u64 = 0;
const INITIAL_SCHEDULER_WAKEUP_US: u64 = 1_000;
const SVC_PRIORITY: u8 = 0xD0;
const SYSTICK_PRIORITY: u8 = 0xE0;
const PENDSV_PRIORITY: u8 = 0xF0;

#[unsafe(link_section = ".dtcm_bss.os")]
pub(crate) static TASK_5MS: Task<STACK_SIZE> = Task::new();
#[unsafe(link_section = ".dtcm_bss.os")]
pub(crate) static TASK_10MS: Task<STACK_SIZE> = Task::new();
#[unsafe(link_section = ".dtcm_bss.os")]
pub(crate) static TASK_PROGRAM_FLOW: Task<STACK_SIZE> = Task::new();
#[unsafe(link_section = ".dtcm_bss.os")]
pub(crate) static TASK_BACKGROUND: Task<STACK_SIZE> = Task::new();

#[unsafe(link_section = ".dtcm_data.os")]
pub(crate) static SCHEDULER: Shared<Scheduler<TASK_COUNT>> = Shared::new(unsafe {
    Scheduler::new([
        TASK_5MS.handle(),
        TASK_10MS.handle(),
        TASK_PROGRAM_FLOW.handle(),
        TASK_BACKGROUND.handle(),
    ])
});

pub static SCB: Shared<Scb> = Shared::new(Scb::new());
#[unsafe(link_section = ".dtcm_bss.systick")]
pub static SYSTICK: Shared<Systick> = Shared::new(Systick::new());
pub static RCC: Shared<Rcc> = Shared::new(Rcc::new());
pub static PWR: Shared<Pwr> = Shared::new(Pwr::new());
pub static SYSCFG: Shared<Syscfg> = Shared::new(Syscfg::new());
pub static FLASH: Shared<Flash> = Shared::new(Flash::new());
pub static GPIOA: Shared<Gpio> = Shared::new(Gpio::new(GPIOA_ADDR));
pub static GPIOB: Shared<Gpio> = Shared::new(Gpio::new(GPIOB_ADDR));
pub static GPIOD: Shared<Gpio> = Shared::new(Gpio::new(GPIOD_ADDR));
pub static USART1: Shared<Usart> = Shared::new(Usart::new(USART1_ADDR));
pub static USART2: Shared<Usart> = Shared::new(Usart::new(USART2_ADDR));
pub static USART3: Shared<Usart> = Shared::new(Usart::new(USART3_ADDR));
#[unsafe(link_section = ".dtcm_bss.wwdg")]
static WWDG: Shared<Wwdg> = Shared::new(Wwdg::new());
#[unsafe(link_section = ".dtcm_bss.pfm")]
static PFM: Shared<ProgramFlowMonitor> = Shared::new(ProgramFlowMonitor::new());

// CortexOs requires a way to re-pend SysTick if a requested absolute timer
// deadline is already due. The latest STM32 driver exposes the typed ICSR bit
// operation, so keep this target-specific compatibility method in the
// superproject while leaving the driver submodule at its upstream tip.
impl Scb {
    #[inline]
    pub fn SetSysTickPending(&mut self) {
        self.Set_ICSR_PENDSTSET(crate::drv::BIT::VALUE_1);
    }
}

pub struct McuManager {}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct UartByteReadResult {
    pub Byte: Option<u8>,
    pub Errors: USART_ERROR_FLAGS,
}

impl UartByteReadResult {
    pub const fn HasError(self) -> bool {
        self.Errors.Any()
    }
}

impl McuManager {
    pub fn McuClockTree_Init() {
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

    pub fn UartCommunication_Init() {
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

    pub fn UartCommunication_Write(bytes: &[u8]) {
        for byte in bytes {
            while !Self::UartCommunication_TryWriteByte(*byte) {}
        }

        while !USART1.with(|usart1| usart1.IsTransmissionComplete()) {}
    }

    pub fn UartCommunication_TryReadByte() -> Option<u8> {
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

    pub fn UartCommunication_TryWriteByte(byte: u8) -> bool {
        USART1.with(|usart1| usart1.TryWriteWord(byte as u16))
    }

    pub fn VD18MTCommunication_Init() {
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

    pub fn VD18MTCommunication_Write(bytes: &[u8]) {
        for byte in bytes {
            while !Self::VD18MTCommunication_TryWriteByte(*byte) {}
        }

        while !USART2.with(|usart2| usart2.IsTransmissionComplete()) {}
    }

    pub fn VD18MTCommunication_TryReadByte() -> Option<u8> {
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

    pub fn VD18MTCommunication_TryWriteByte(byte: u8) -> bool {
        USART2.with(|usart2| usart2.TryWriteWord(byte as u16))
    }

    pub fn BmsCommunication_Init() {
        RCC.with(|rcc| {
            peripherals::usart::ConfigureUsart3BmsClocks(rcc);
        });

        GPIOB.with(|gpiob| {
            peripherals::usart::ConfigureUsart3BmsPins(gpiob);
        });

        USART3.with(|usart3| {
            peripherals::usart::ConfigureUsart3Bms9600(usart3);
        });
    }

    pub fn BmsCommunication_Write(bytes: &[u8]) {
        for byte in bytes {
            while !Self::BmsCommunication_TryWriteByte(*byte) {}
        }

        while !USART3.with(|usart3| usart3.IsTransmissionComplete()) {}
    }

    pub fn BmsCommunication_TryReadByte() -> Option<u8> {
        USART3.with(|usart3| {
            usart3.TryReadWord().and_then(|word| {
                if word <= u8::MAX as u16 {
                    Some(word as u8)
                } else {
                    None
                }
            })
        })
    }

    pub fn BmsCommunication_TryReadByteWithErrors() -> UartByteReadResult {
        USART3.with(|usart3| {
            let result = usart3.TryReadWordWithErrors();
            UartByteReadResult {
                Byte: result.word.and_then(|word| {
                    if word <= u8::MAX as u16 {
                        Some(word as u8)
                    } else {
                        None
                    }
                }),
                Errors: result.errors,
            }
        })
    }

    pub fn BmsCommunication_TryWriteByte(byte: u8) -> bool {
        USART3.with(|usart3| usart3.TryWriteWord(byte as u16))
    }

    pub fn ProgramFlowSupervision_Start(systickClockHz: u32) {
        SCB.with(|scb| {
            // Cortex-M7 implements priority preemption numerically: keep SVC
            // and SysTick above PendSV so scheduling state is complete before
            // the context switch executes.
            scb.Set_SHPR2_PRI_11(SVC_PRIORITY);
            scb.Set_SHPR3_PRI_14(PENDSV_PRIORITY);
            scb.Set_SHPR3_PRI_15(SYSTICK_PRIORITY);
        });

        SYSTICK.with(|syst| {
            syst.Configure(systickClockHz);
        });

        RCC.with(|rcc| {
            rcc.EnableWwdg1Clock();
        });

        WWDG.with(|wwdg| {
            peripherals::wwdg::ConfigureWwdg1For10MsProgramFlow(wwdg);
        });

        let taskConfigurations = SCHEDULER.with(|scheduler| {
            scheduler.SetCyclicReleaseBase(PROGRAM_FLOW_START_US);
            scheduler.GetTaskConfigurations()
        });
        PFM.with(|pfm| {
            pfm.ConfigureFromTasks(&taskConfigurations, PROGRAM_FLOW_START_US);
        });

        // The outer critical section keeps the watchdog and SysTick start writes
        // adjacent. Both hardware and software supervision therefore use epoch 0.
        WWDG.with(|wwdg| {
            SYSTICK.with(|syst| {
                peripherals::wwdg::StartWwdg1For10MsProgramFlow(wwdg);
                let armed = syst
                    .SetTimerAt(PROGRAM_FLOW_START_US.saturating_add(INITIAL_SCHEDULER_WAKEUP_US));
                assert!(armed);
            });
        });
    }

    pub fn ProgramFlow_ReportTaskStart(taskId: u32) {
        let mut now_us = 0;
        SYSTICK.with(|syst| {
            now_us = syst.GetElapsedMicroseconds();
        });

        PFM.with(|pfm| {
            pfm.ReportTaskStart(taskId, now_us);
        });
    }

    pub fn ProgramFlow_ReportTaskEnd(taskId: u32) {
        let mut now_us = 0;
        SYSTICK.with(|syst| {
            now_us = syst.GetElapsedMicroseconds();
        });

        PFM.with(|pfm| {
            pfm.ReportTaskEnd(taskId, now_us);
        });
    }

    pub fn PFM_ValidateAndServiceWatchdog() {
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
