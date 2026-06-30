#![allow(static_mut_refs)]

use core::cell::RefCell;

use crate::{drv::{
        cortex::Shared, scb::Scb, systick::Systick
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

pub struct McuManager {
}

impl McuManager {

    pub fn McuClockTree_Init()
    {
        
    }    
}