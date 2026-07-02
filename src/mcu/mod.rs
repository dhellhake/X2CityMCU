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
        rcc::Rcc,
        scb::Scb,
        syscfg::Syscfg,
        systick::Systick
    }, os::{
        Application,
        Mutex
    }
};

pub mod peripherals;
pub mod deployment;
pub(crate) const TASK_COUNT: usize = 3;
pub(crate) const STACK_SIZE: usize = 256;    
pub(crate) static Os: Mutex<RefCell<Option<Application<TASK_COUNT, STACK_SIZE>>>> = Mutex::new(RefCell::new(None));

pub static SCB: Shared<Scb> = Shared::new(Scb::new());
pub static SYSTICK: Shared<Systick> = Shared::new(Systick::new());
pub static RCC: Shared<Rcc> = Shared::new(Rcc::new());
pub static PWR: Shared<Pwr> = Shared::new(Pwr::new());
pub static SYSCFG: Shared<Syscfg> = Shared::new(Syscfg::new());
pub static FLASH: Shared<Flash> = Shared::new(Flash::new());
pub static GPIOC: Shared<Gpio> = Shared::new(Gpio::new(GPIOC_ADDR));

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
}
